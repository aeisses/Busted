//
//  TrackViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TrackViewController.h"

@interface TrackViewController ()

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
    isTracking = NO;
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
    homeButton.hidden = YES; homeButton.enabled = NO;
    self.swipeRight.enabled = NO;
    self.swipeLeft.enabled = NO;
    self.swipeDown.enabled = NO;
    self.swipeUp.enabled = YES;
    [super viewDidAppear:animated];
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
    [_routeButton release]; _routeButton = nil;
    [_collection release]; _collection = nil;
    _delegate = nil;
    if (uudi)
        [uudi release];
    [super dealloc];
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
                                        [NSNumber numberWithInt:[_routeButton.titleLabel.text intValue]], @"busNumber",
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    _trackButton.selected = NO;
                    _routeButton.enabled = YES;
                    isTracking = NO;
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

- (IBAction)touchTrackButton:(id)sender
{
    if (![_routeButton.titleLabel.text isEqualToString:@"?"]) {
        isTracking = !isTracking;
        if (isTracking) {
            _trackButton.selected = YES;
            _routeButton.enabled = NO;
            if (uudi)
                [uudi release];
            uudi = [[self uuidString] retain];
        } else {
            _trackButton.selected = NO;
            _routeButton.enabled = YES;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please" message:@"You need to select a route you can activate the tracking GPS" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)touchRouteButton:(id)sender
{
    _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
    _collection.delegate = self;
    [self presentViewController:_collection animated:YES completion:^{}];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_currentLocation) {
        [_currentLocation release]; _currentLocation = nil;
    }
    _currentLocation =  [[locations objectAtIndex:[locations count]-1] retain];
    NSLog(@"%f, %f", _currentLocation.coordinate.longitude, _currentLocation.coordinate.latitude);
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
        myRoute.busNumber = (NSInteger)[route.short_name integerValue];
        [routesM addObject:myRoute];
    }
    return (NSArray*)routesM;
}

- (void)setBusRoute:(NSInteger)route
{
    [_routeButton setTitle:[NSString stringWithFormat:@"%i",route] forState:UIControlStateNormal];
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

@end
