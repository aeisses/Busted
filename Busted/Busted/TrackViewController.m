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
    _greenButton.hidden = YES;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    homeButton.hidden = YES; homeButton.enabled = NO;
    swipeRight.enabled = NO;
    swipeLeft.enabled = NO;
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
    [_trackButton release]; _trackButton = nil;
    [_inputField release]; _inputField = nil;
    [_locationManager release]; _locationManager = nil;
    [_greenButton release]; _greenButton = nil;
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
                                        [NSNumber numberWithInt:80], @"busNumber",
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
                _greenButton.hidden = YES;
                isTracking = NO;
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
    isTracking = !isTracking;
    if (isTracking) {
        _trackButton.selected = YES;
        _greenButton.hidden = NO;
        if (uudi)
            [uudi release];
        uudi = [[self uuidString] retain];
    } else {
        _trackButton.selected = NO;
        _greenButton.hidden = YES;
    }
/*    NSString *urlStr = [[NSString alloc] initWithString:@"http://ertt.ca:8080/busted/buslocation/80"];
//    NSURL *url = [[NSURL alloc] initWithString:urlStr];
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlStr]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"Json String: %@",json_string);
 */
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_currentLocation) {
        [_currentLocation release]; _currentLocation = nil;
    }
    _currentLocation =  [[locations objectAtIndex:[locations count]-1] retain];
//    [self updatePoint];
    NSLog(@"%f, %f", _currentLocation.coordinate.longitude, _currentLocation.coordinate.latitude);
}

@end
