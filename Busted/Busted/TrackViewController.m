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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface TrackViewController (PrivateMethods)
- (void)frameIntervalLoop:(CADisplayLink *)sender;
- (void)sendingIntervalLoop:(CADisplayLink *)sender;
- (void)updatePoint;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture;
- (void)sendLocationToServer;
@end

@implementation TrackViewController

static id instance;

+ (TrackViewController*)sharedInstance
{
    if (!instance) {
        if (IS_IPHONE_5)
        {
            return [[[TrackViewController alloc] initWithNibName:@"TrackViewController" bundle:nil] autorelease];
        } else {
            return [[[TrackViewController alloc] initWithNibName:@"TrackViewControllerSmall" bundle:nil] autorelease];
        }
    }
    return instance;
}

//- (NSString *)uuidString {
//    // Returns a UUID
//    
//    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
//    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
//    CFRelease(uuid);
//    
//    return [uuidStr autorelease];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (_locationManager == nil)
        {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.delegate = self;
        }
        [_locationManager startUpdatingLocation];
    }
    return self;
}

- (void)viewDidLoad
{
    int height = 215;
    if (IS_IPHONE_5)
    {
        height = 255;
    }
    frames = [[NSArray alloc] initWithObjects:
                [NSValue valueWithCGRect:(CGRect){160,height,0,12}],
                [NSValue valueWithCGRect:(CGRect){150,height,20,12}],
                [NSValue valueWithCGRect:(CGRect){140,height,40,12}],
                [NSValue valueWithCGRect:(CGRect){130,height,60,12}],
                [NSValue valueWithCGRect:(CGRect){120,height,80,12}],
                [NSValue valueWithCGRect:(CGRect){110,height,100,12}],
                [NSValue valueWithCGRect:(CGRect){100,height,120,12}],
                [NSValue valueWithCGRect:(CGRect){90,height,140,12}],
                [NSValue valueWithCGRect:(CGRect){80,height,160,12}],
                [NSValue valueWithCGRect:(CGRect){70,height,180,12}],
                [NSValue valueWithCGRect:(CGRect){60,height,200,12}],
                [NSValue valueWithCGRect:(CGRect){50,height,220,12}],
                [NSValue valueWithCGRect:(CGRect){40,height,240,12}],
                [NSValue valueWithCGRect:(CGRect){30,height,260,12}],
                [NSValue valueWithCGRect:(CGRect){20,height,280,12}],
                [NSValue valueWithCGRect:(CGRect){10,height,300,12}],
                [NSValue valueWithCGRect:(CGRect){0,height,320,12}],
                  nil];

    currentFrame = 0;
    _swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    _swipeUp.numberOfTouchesRequired = 1;
    _swipeUp.accessibilityLabel = @"Close Tracking Window";
    _swipeUp.isAccessibilityElement = YES;
    _swipeUp.direction = (UISwipeGestureRecognizerDirectionUp);
    _swipeUp.enabled = NO;
    _isTracking = NO;
    _trackButton.selected = NO;
    _sendingImage.hidden = YES;
//    _sendingImage.hidden = YES;

    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)];
    sendingLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendingIntervalLoop:)];
    Reachability *remoteHostStatus = [Reachability reachabilityWithHostName:@"knowtime.ca"];
    if (remoteHostStatus.currentReachabilityStatus != NotReachable)
    {
        NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",SANGSTERBASEURL,@"pollrate"];
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
            if (!error) {
                float rate = [(NSNumber*)[json objectForKey:@"rate"] floatValue];
                if (rate != 0)
                {
                    [displayLink setFrameInterval:rate*60];
                } else {
                    [displayLink setFrameInterval:600];
                }
            } else {
                [displayLink setFrameInterval:600];
            }
        } else {
            [displayLink setFrameInterval:600];
        }
        [urlStr release];
        [url release];
        [request release];
    }
    [sendingLink setFrameInterval:15];
    [sendingLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_isTracking) {
        _sendingImage.hidden = NO;
        _sendingZoom.hidden = NO;
    } else {
        _sendingImage.hidden = YES;
        _sendingZoom.hidden = YES;
        currentRoute = 0;
    }
    
    _trackButton.selected = _isTracking;
    [self.view addGestureRecognizer:_swipeUp];
    self.swipeUp.enabled = YES;
//    dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//    dispatch_async(googleQueue, ^{
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
//                                                                                            action:@"viewshow"
//                                                                                             label:@"Tracking View Shown"
//                                                                                             value:nil] build]];
//    });
//    dispatch_release(googleQueue);
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
    [sendingLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [sendingLink invalidate];
    [sendingLink release]; sendingLink = nil;
    [_trackButton release]; _trackButton = nil;
    [_locationManager release]; _locationManager = nil;
    [_sendingImage release]; _sendingImage = nil;
    [_sendingZoom release]; _sendingZoom = nil;
    [_collection release]; _collection = nil;
    [_homeButton release]; _homeButton = nil;
    [_swipeUp release]; _swipeUp = nil;
    [_locationString release]; _locationString = nil;
    [frames release];
    _delegate = nil;
    if (uudi)
        [uudi release];
    [super dealloc];
}

- (IBAction)touchTrackButton:(id)sender
{
    if (_trackButton.selected && _isTracking)
    {
        _trackButton.selected = NO;
        _isTracking = NO;
        _sendingImage.hidden = YES;
        _sendingZoom.hidden = YES;
        currentFrame = 0;
//        dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//        dispatch_async(googleQueue, ^{
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_action"
//                                                                                               interval:[NSNumber numberWithDouble:[startTrackingTime timeIntervalSinceNow]]
//                                                                                                   name:@"Tracking ended"
//                                                                                                  label:@"Tacking Stopped"] build]];
//        });
//        dispatch_release(googleQueue);
    } else {
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
}

- (IBAction)touchHomeButton:(id)sender
{
    [_delegate exitTransitionVC];
}

#pragma Private Methods
- (void)sendingIntervalLoop:(CADisplayLink *)sender
{
    if (_isTracking)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _sendingZoom.frame = [[frames objectAtIndex:currentFrame] CGRectValue];
        });
        currentFrame++;
        if (currentFrame >= [frames count])
        {
            currentFrame = 0;
        }
    }
}

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
            _isTracking = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _trackButton.selected = NO;
                _sendingImage.hidden = YES;
                _sendingZoom.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having some trouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        } else {
            _isTracking = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                _sendingImage.hidden = NO;
                _sendingZoom.hidden = NO;
                _trackButton.selected = YES;
            });
            NSDictionary *header = response.allHeaderFields;
            if (_locationString) {
                [_locationString release];
                _locationString = nil;
            }
            _locationString = [[NSString alloc] initWithString:[[header valueForKey:@"Location"] stringByReplacingOccurrencesOfString:@"buserver" withString:@"api"]];
//            dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//            dispatch_async(googleQueue, ^{
//                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"tracking_action"
//                                                                                                    action:@"tracking started"
//                                                                                                     label:@"tracking started"
//                                                                                                     value:[NSNumber numberWithInt:currentRoute]] build]];
//            });
//            dispatch_release(googleQueue);
        }
        request = nil;
        response = nil;
    });
    dispatch_release(networkQueue);
}

- (void)sendLocationToServer
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
        
        if (!_isTracking)
        {
            jsonData = nil;
            request = nil;
            response = nil;
            error  = nil;
            return;
        }
        if ([response statusCode] != 200) {
            _isTracking = NO;
            startTrackingTime = [NSDate date];
            //                dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
            //                dispatch_async(googleQueue, ^{
            //                    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createTimingWithCategory:@"ui_action"
            //                                                                                                       interval:[NSNumber numberWithDouble:[startTrackingTime timeIntervalSinceNow]]
            //                                                                                                           name:@"Tracking ended"
            //                                                                                                          label:@"Tacking Stopped"] build]];
            //                });
            //                dispatch_release(googleQueue);
            dispatch_async(dispatch_get_main_queue(), ^{
                _trackButton.selected = NO;
                _sendingImage.hidden = YES;
                _sendingZoom.hidden = YES;
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

- (void)updatePoint
{
    if (_isTracking)
    {
        [self sendLocationToServer];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_currentLocation) {
        [_currentLocation release]; _currentLocation = nil;
    }
    _currentLocation =  [[locations objectAtIndex:[locations count]-1] retain];
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive && _isTracking)
    {
        [self sendLocationToServer];
    }
//    NSLog(@"%f, %f", _currentLocation.coordinate.longitude, _currentLocation.coordinate.latitude);
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

- (void)exitCollectionView
{
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

@end
