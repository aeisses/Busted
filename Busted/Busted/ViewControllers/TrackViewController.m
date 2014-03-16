//
//  TrackViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "TrackViewController.h"
#import "macros.h"
#import "WebApiInterface.h"
#import "Flurry.h"
#import "RegionZoomData.h"

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
            _locationManager.distanceFilter = 1;
//            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//            _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
            _locationManager.delegate = self;
        }
    }
    instance = self;
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewIsVisable = NO;
    int height = 225;
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
    [_locationManager stopUpdatingLocation];
    _trackButton.selected = NO;
    _sendingImage.hidden = YES;
    _connectedToServer.hidden = YES;
//    _sendingImage.hidden = YES;

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)];
    sendingLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendingIntervalLoop:)];
    Reachability *remoteHostStatus = [Reachability reachabilityWithHostName:HOSTNAME];
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
                    [_displayLink setFrameInterval:rate*60];
                } else {
                    [_displayLink setFrameInterval:600];
                }
            } else {
                [_displayLink setFrameInterval:600];
            }
        } else {
            [_displayLink setFrameInterval:600];
        }
        [urlStr release];
        [url release];
        [request release];
    }
    [sendingLink setFrameInterval:15];
    [sendingLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    viewIsVisable = YES;
    if (_isTracking) {
        _sendingImage.hidden = NO;
        _sendingZoom.hidden = NO;
        _routeLabel.text = [NSString stringWithFormat:@"Sharing route: %li",(long)_currentRoute];
        [_routeLabel setNeedsDisplay];
    } else {
        _sendingImage.hidden = YES;
        _sendingZoom.hidden = YES;
        _routeLabel.text = @"";
        _currentRoute = 0;
    }
    
    _trackButton.selected = _isTracking;
    [self.view addGestureRecognizer:_swipeUp];
    self.swipeUp.enabled = YES;
    [Flurry logEvent:@"Track_View_Did_Appear"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    viewIsVisable = NO;
    [self.view removeGestureRecognizer:_swipeUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_displayLink invalidate];
    [_displayLink release]; _displayLink = nil;
    [sendingLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [sendingLink invalidate];
    [sendingLink release]; sendingLink = nil;
    [_trackButton release]; _trackButton = nil;
    [_locationManager release]; _locationManager = nil;
    [_sendingImage release]; _sendingImage = nil;
    [_connectedToServer release]; _connectedToServer = nil;
    [_sendingZoom release]; _sendingZoom = nil;
    [_collection release]; _collection = nil;
    [_homeButton release]; _homeButton = nil;
    [_swipeUp release]; _swipeUp = nil;
    [_locationString release]; _locationString = nil;
    [_routeLabel release]; _routeLabel = nil;
    [frames release];
    _delegate = nil;
    if (uudi)
        [uudi release];
    [super dealloc];
}

- (BOOL)isCurrentLocaitonInHRM
{
    if (_currentLocation)
    {
        if (_currentLocation.coordinate.latitude >= (HRM_LATITUDE - HRM_LATITUDE_DELTA/2) &&
            _currentLocation.coordinate.latitude <= (HRM_LATITUDE + HRM_LATITUDE_DELTA/2) &&
            _currentLocation.coordinate.longitude >= (HRM_LONGITUDE - HRM_LONGITUDE_DELTA/2) &&
            _currentLocation.coordinate.longitude <= (HRM_LONGITUDE + HRM_LONGITUDE_DELTA/2)) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)touchTrackButton:(id)sender
{
    if (_trackButton.selected && _isTracking)
    {
        _trackButton.selected = NO;
        _isTracking = NO;
        [_locationManager stopUpdatingLocation];
        _sendingImage.hidden = YES;
        _connectedToServer.hidden = YES;
        _sendingZoom.hidden = YES;
        currentFrame = 0;
        [Flurry endTimedEvent:@"Tracking_Location_For_Route" withParameters:nil];
        _routeLabel.text = @"";
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

- (IBAction)touchTwitterButton:(id)sender
{
    if (_isTracking)
    {
        if(NSClassFromString(@"SLComposeViewController") != nil)
        {
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"I'm on bus %li sharing my ride with #KNOWtime #apps4hfx",(long)_currentRoute]];
            [mySLComposerSheet addImage:[UIImage imageNamed:@"icon.png"]];
            [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                NSString *output;
                switch (result) {
                    case SLComposeViewControllerResultDone:
                    {
                        output = NSLocalizedStringFromTable(@"You succesfully posted to Twitter", @"ATLocalizable", @"");
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    }
                        break;
                    default:
                        break;
                }
   
            }];
            [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please share your ride before you Tweet." delegate:nil cancelButtonTitle:@"thanks" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
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
        @autoreleasepool {
            NSError *error = nil;

            NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@%li",SANGSTERBASEURL,USERS,NEW,(long)_currentRoute];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [urlStr release];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            NSHTTPURLResponse *response;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if ([response statusCode] != 201) {
                _isTracking = NO;
                [_locationManager stopUpdatingLocation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendLocalNotification];
                    _trackButton.selected = NO;
                    _sendingImage.hidden = YES;
                    _connectedToServer.hidden = YES;
                    _sendingZoom.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having some trouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                });
            } else {
                _isTracking = YES;
                [_locationManager startUpdatingLocation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _sendingImage.hidden = NO;
                    _connectedToServer.hidden = NO;
                    _sendingZoom.hidden = NO;
                    _trackButton.selected = YES;
                });
                NSDictionary *header = response.allHeaderFields;
                if (_locationString) {
                    [_locationString release];
                    _locationString = nil;
                }
                _locationString = [[NSString alloc] initWithString:[[header valueForKey:@"Location"] stringByReplacingOccurrencesOfString:@"buserver" withString:@"api"]];
                _routeLabel.text = [NSString stringWithFormat:@"Sharing route: %li",(long)_currentRoute];
                [_routeLabel setNeedsDisplay];
                NSDictionary *routesParams = [NSDictionary dictionaryWithObjectsAndKeys:@"Route", [NSString stringWithFormat:@"%li",(long)_currentRoute], nil];
                [Flurry logEvent:@"Tracking_Location_For_Route" withParameters:routesParams timed:YES];
            }
            request = nil;
            response = nil;
        }
    });
    dispatch_release(networkQueue);
}

- (void)sendLocationToServer
{
//    if (![self isCurrentLocaitonInHRM]) {
//        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You need to be located in Halifax Regional Municipality, Nova Scotia Canada to send your location data to our server." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
//        _isTracking = NO;
//        [_locationManager stopUpdatingLocation];
//        return;
//    }
//    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
//    {
//        
//    }
    @autoreleasepool {
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
//            NSLog(@"Response StatusCode: %i",[response statusCode]);
//            if ([response statusCode] != 200) {
//                _isTracking = NO;
//                [_locationManager stopUpdatingLocation];
//                startTrackingTime = [NSDate date];
//                [Flurry endTimedEvent:@"Tracking_Location_For_Route" withParameters:nil];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    _trackButton.selected = NO;
//                    _sendingImage.hidden = YES;
//                    _connectedToServer.hidden = YES;
//                    _sendingZoom.hidden = YES;
//                    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears our server is having some trouble at the moment, please try back later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//                        [alert show];
//                        [alert release];
//                    }
//                });
//            }
            jsonData = nil;
            request = nil;
            response = nil;
        });
        dispatch_release(networkQueue);
    }
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
        if (_backGroundTime && [_backGroundTime timeIntervalSinceNow] < -1800.0)
        {
            [self sendLocalNotification];
            [_locationManager stopUpdatingLocation];
            [Flurry setBackgroundSessionEnabled:NO];
            _isTracking = NO;
            _backGroundTime = nil;
            _trackButton.selected = NO;
            _sendingImage.hidden = YES;
            _connectedToServer.hidden = YES;
            _sendingZoom.hidden = YES;
            _routeLabel.text = @"";
        }
    }
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
    for (RouteManagedObject *route in routes)
    {
        Route *myRoute = [[Route alloc] init];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        NSNumber *number = [numberFormatter numberFromString:route.shortName];
        if (number != nil) {
            myRoute.ident = [route.shortName integerValue];
        } else {
            [myRoute release];
            continue;
        }
        myRoute.longName = route.longName;
        myRoute.shortName = route.shortName;
        myRoute.isFavourite = [route.isFavourite boolValue];
        [routesM addObject:myRoute];
        [myRoute release];
    }
    return [(NSArray*)routesM autorelease];
}

- (void)setBusRoute:(NSString*)route
{
    _currentRoute = [route integerValue];
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized)
    {
        if (viewIsVisable)
        {
            [_locationManager startUpdatingLocation];
            _isTracking = YES;
        }
    }
}

- (void)sendLocalNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification == nil)
        return;
    notification.alertBody = @"Oops! Looks like your GPS signal has been interrupted – please reset the app to continue sharing your ride.";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    [notification release];
}

@end
