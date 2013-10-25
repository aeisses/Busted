//
//  TrackViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TrackViewController.h"

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
    _delegate = nil;
    if (uudi)
        [uudi release];
    [super dealloc];
}

- (IBAction)touchTrackButton:(id)sender
{
    _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
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

- (void)updatePoint
{
    if (isTracking) {
        __block NSString *blockUudi = uudi;
        __block CLLocation *blockCurrentLocation = _currentLocation;
        dispatch_queue_t networkQueue  = dispatch_queue_create("network queue", NULL);
        dispatch_async(networkQueue, ^{
            NSError *error = nil;
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        blockUudi, @"uuid",
                                        [NSNumber numberWithInteger:currentRoute], @"busNumber",
                                        [NSNumber numberWithFloat:blockCurrentLocation.coordinate.latitude], @"latitude",
                                        [NSNumber numberWithFloat:blockCurrentLocation.coordinate.longitude], @"longitude",
                                        [NSNumber numberWithFloat:0.1], @"capacity", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
            [info release];
            NSString *urlStr = [[NSString alloc] initWithString:@"http://ertt.ca:8080/busted/userlocation"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [urlStr release];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:jsonData];
            NSHTTPURLResponse *response;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if ([response statusCode] > 399) {
                _trackButton.selected = NO;
                isTracking = NO;
                _trackButton.selected = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_trackButton setNeedsDisplay];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having some trouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
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
    for (Route *route in routes)
    {
        MyRoute *myRoute = [[MyRoute alloc] init];
        myRoute.title = route.long_name;
        myRoute.busNumber = [route.short_name integerValue];
        [routesM addObject:myRoute];
        [myRoute release];
    }
    return [(NSArray*)routesM autorelease];
}

- (void)setBusRoute:(NSString*)route
{
    currentRoute = [route integerValue];
    _sendingImage.hidden = NO;
    _trackButton.selected = YES;
    isTracking = YES;
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

@end
