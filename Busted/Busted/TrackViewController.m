//
//  TrackViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TrackViewController.h"
#import "Routes.h"
#import "macros.h"
#import "WebApiInterface.h"

@interface TrackViewController (PrivateMethods)
- (void)frameIntervalLoop:(CADisplayLink *)sender;
- (void)updatePoint;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture;
@end

@implementation TrackViewController

- (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return [uuidStr autorelease];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    _swipeUp.numberOfTouchesRequired = 1;
    _swipeUp.accessibilityLabel = @"Close Tracking Window";
    _swipeUp.isAccessibilityElement = YES;
    _swipeUp.direction = (UISwipeGestureRecognizerDirectionUp);
    _swipeUp.enabled = NO;
    isTracking = NO;
    _trackButton.selected = NO;
    _sendingImage.hidden = YES;
    if (_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy =
        kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    [_locationManager startUpdatingLocation];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)];
    [displayLink setFrameInterval:15];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isTracking) {
        _sendingImage.hidden = NO;
    } else {
        _sendingImage.hidden = YES;
        currentRoute = 0;
    }
    _trackButton.selected = isTracking;
    [self.view addGestureRecognizer:_swipeUp];
    self.swipeUp.enabled = YES;
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:_swipeUp];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release]; displayLink = nil;
    [_trackButton release]; _trackButton = nil;
    [_locationManager release]; _locationManager = nil;
    [_sendingImage release]; _sendingImage = nil;
    [_collection release]; _collection = nil;
    [_homeButton release]; _homeButton = nil;
    [_swipeUp release]; _swipeUp = nil;
    [_locationString release]; _locationString = nil;
    _delegate = nil;
    if (uudi)
        [uudi release];
    [super dealloc];
}

- (IBAction)touchTrackButton:(id)sender
{
    if (IS_IPHONE_5)
    {
        _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
    } else {
        _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRouteCollectionViewControllerSmall" bundle:nil];
    }
    _trackButton.selected = YES;
    _collection.delegate = self;
    [self presentViewController:_collection animated:YES completion:^{}];
}

- (IBAction)touchHomeButton:(id)sender
{
    [_delegate exitTransitionVC];
}

#pragma Private Methods
- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    [self updatePoint];
}

- (void)createNewUser
{
    dispatch_queue_t networkQueue  = dispatch_queue_create("network queue", NULL);
    dispatch_async(networkQueue, ^{
        NSError *error = nil;

        NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@%i",SANGSTERBASEURL,USERS,NEW,currentRoute];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [urlStr release];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if ([response statusCode] != 201) {
            isTracking = NO;
            _trackButton.selected = NO;
            _sendingImage.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_trackButton setNeedsDisplay];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having some trouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        } else {
            isTracking = YES;
            _sendingImage.hidden = NO;
            _trackButton.selected = YES;
            NSDictionary *header = response.allHeaderFields;
            _locationString = [[NSString alloc] initWithString:[header valueForKey:@"Location"]];
        }
        request = nil;
        response = nil;
    });
    dispatch_release(networkQueue);
}

- (void)updatePoint
{
    if (isTracking)
    {
        __block NSString *blockLocationString = _locationString;
        __block CLLocation *blockCurrentLocation = _currentLocation;
        dispatch_queue_t networkQueue  = dispatch_queue_create("network queue", NULL);
        dispatch_async(networkQueue, ^{
            NSError *error = nil;
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:blockCurrentLocation.coordinate.latitude], @"lat",
                                        [NSNumber numberWithFloat:blockCurrentLocation.coordinate.longitude], @"lng", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
            [info release];
            NSString *urlStr = [[NSString alloc] initWithString:blockLocationString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [urlStr release];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:jsonData];
            NSHTTPURLResponse *response;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

            if (!isTracking)
            {
                jsonData = nil;
                request = nil;
                response = nil;
                return;
            }
            if ([response statusCode] != 200) {
                isTracking = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    _trackButton.selected = NO;
                    _sendingImage.hidden = YES;
//                    [_trackButton setNeedsDisplay];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having  sometrouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                });
            }
            jsonData = nil;
            request = nil;
            response = nil;
        });
        dispatch_release(networkQueue);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_currentLocation) {
        [_currentLocation release]; _currentLocation = nil;
    }
    _currentLocation =  [[locations objectAtIndex:[locations count]-1] retain];
    NSLog(@"%f, %f", _currentLocation.coordinate.longitude, _currentLocation.coordinate.latitude);
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    [_delegate exitTransitionVC];
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    NSArray *routes = [_delegate getRoutes];
    NSMutableArray *routesM = [[NSMutableArray alloc] initWithCapacity:[routes count]];
//    int counter = 0;
    for (Routes *route in routes)
    {
        MyRoute *myRoute = [[MyRoute alloc] init];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        NSNumber *number = [numberFormatter numberFromString:route.shortName];
        if (number != nil) {
            myRoute.ident = [route.shortName integerValue];
        } else {
//            myRoute.ident = counter + 10000;
//            counter++;
            [myRoute release];
            continue;
        }
        myRoute.longName = route.longName;
        myRoute.shortName = route.shortName;
        myRoute.isFavorite = [route.isFavorite boolValue];
        [routesM addObject:myRoute];
        [myRoute release];
    }
    return [(NSArray*)routesM autorelease];
}

- (void)setBusRoute:(NSString*)route
{
    currentRoute = [route integerValue];
    [self createNewUser];
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

@end
