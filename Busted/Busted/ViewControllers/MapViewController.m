//
//  MapViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "MapViewController.h"
#import "WebApiInterface.h"

@interface MapViewController ()
{
    NSMutableArray *cellToThread;
}
- (void)startService;
- (void)pollServer;
- (void)frameIntervalLoop:(CADisplayLink *)sender;

@property (retain, nonatomic) NSOperationQueue *queue;

@end

@implementation MapViewController

static id instance;

+ (MapViewController*)sharedInstance
{
    if (!instance) {
        if (IS_IPHONE_5)
        {
            return [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
        }
        else
        {
            return [[[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil] autorelease];
        }
    }
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isStarting = NO;
        _isClearToSend = NO;
        cellToThread = [[NSMutableArray alloc] init];
    }
    instance = self;
    return instance;
}

- (void)dealloc
{
    [super dealloc];
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeFromSuperview];
    if (_annotations) {
        [_mapView removeAnnotations:_annotations];
        [_annotations release];
        _annotations = nil;
    }
    if (_route) {
        [_route release];
        _route = nil;
    }
    if (_stops) {
        [_mapView removeAnnotations:_stops];
        [_stops release];
        _stops = nil;
    }
    if (_currentLocation)
    {
        [_currentLocation release];
        _currentLocation = nil;
    }
    if (_locationManager)
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager release];
    }
    if (_currentLocation)
        [_currentLocation release];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = nil;
    [_mapView release]; _mapView = nil;
    [_homeButton release]; _homeButton = nil;
    [_favouriteButton release]; _favouriteButton = nil;
    [_queue release]; _queue = nil;
    [cellToThread release]; cellToThread = nil;
}

- (void)showRouteAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This route is not in service at the moment." delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)touchHomeButton:(id)sender
{
    [self.superDelegate touchedHomeButton:NO];
}

- (IBAction)touchFavouriteButton:(id)sender
{
    _favouriteButton.selected = !_favouriteButton.selected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    @autoreleasepool {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        _queue = [[NSOperationQueue alloc] init];
        [_locationManager startUpdatingLocation];
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        if (_isStops)
        {
            [_homeButton setImage:[UIImage imageNamed:@"routeButton.png"] forState:UIControlStateNormal];
            [_homeButton setImage:[UIImage imageNamed:@"routeButtonHighlighted.png"] forState:UIControlStateHighlighted];
            [self.view bringSubviewToFront:_favouriteButton];
            _favouriteButton.layer.shadowOpacity = 1.0;
            _favouriteButton.layer.shadowOffset = (CGSize){0,0};
            _favouriteButton.layer.shadowRadius = 5.0;
            _favouriteButton.hidden = NO;
        }
        else
        {
            [_homeButton setImage:[UIImage imageNamed:@"homeButton.png"] forState:UIControlStateNormal];
            [_homeButton setImage:[UIImage imageNamed:@"homeButtonHighlighted.png"] forState:UIControlStateHighlighted];
            if (_stops)
                [_stops release];
            _stops = [[NSMutableArray alloc] initWithCapacity:0];
            _favouriteButton.hidden = YES;
        }
        _mapView.scrollEnabled = YES;
        _mapView.zoomEnabled = YES;
        [self.view bringSubviewToFront:_homeButton];
        _skipLoop = NO;
        if (_currentLocation)
        {
            [_mapView setRegion:(MKCoordinateRegion){_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude,0.014200, 0.011654}];
        } else {
            [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    hasExited = NO;
    [_mapView setShowsUserLocation:YES];
    _skipLoop =  NO;
    if (_isStops)
    {
        [self startService];
        _favouriteButton.selected = _route.isFavourite;
    } else {
        for (StopAnnotation *stop in [WebApiInterface sharedInstance].stops)
        {
            if ([stop isInsideSquare:_mapView.region])
            {
                [_mapView addAnnotation:stop];
                [_stops addObject:stop];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    @autoreleasepool {
        if (_isStops)
        {
            if (displayLink)
            {
                hasExited = YES;
                [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                [displayLink invalidate];
                [displayLink release];
                displayLink = nil;
            }
            if ([cellToThread count] > 0)
            {
                for (NSBlockOperation *operation in cellToThread)
                {
                    [operation cancel];
                }
                [cellToThread removeAllObjects];
            }
    //        cellToThread = nil;
            [_queue cancelAllOperations];
            
            [[WebApiInterface sharedInstance] setFavourite:_favouriteButton.selected forRoute:_route.shortName];
        }
    }
}

- (void)startService
{
    Reachability *remoteHostStatus = [Reachability reachabilityWithHostName:HOSTNAME];
    if (remoteHostStatus.currentReachabilityStatus != NotReachable)
    {
        [self pollServer];
    } else {
        // Internet connection is not valid
        
    }
}

- (void)pollServer
{
    @autoreleasepool {
        NSBlockOperation *operation = [[NSBlockOperation alloc] init];
        __block NSBlockOperation *blockOperation = operation;
        [operation addExecutionBlock:^{
            NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@:%@",SANGSTERBASEURL,ESTIMATE,SHORTS,_route.shortName];
            NSURL *url = [[NSURL alloc] initWithString:urlStr];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSError *error = nil;
            // Need to add a check in for server errors, check status code.
            _isClearToSend = NO;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            if (!error) {
                NSObject *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
                if (!error) {
                    NSMutableArray *myAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
                    if (([json isKindOfClass:[NSDictionary class]] && [(NSDictionary*)json objectForKey:@"status"] == nil) || [json isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *dic in (NSArray*)json) {
                            NSDictionary *location = (NSDictionary*)[dic valueForKey:@"location"];
                            if ([(NSNumber*)[location objectForKey:@"lat"] floatValue] != 0.0 && [(NSNumber*)[location objectForKey:@"lng"] floatValue] != 0.0)
                            {
                                if (![blockOperation isCancelled])
                                {
                                    BusAnnotation *bus = [[BusAnnotation alloc] initWithBusNumber:[[dic objectForKey:@"busNumber"] integerValue]
                                                                                         latitude:[(NSNumber*)[location objectForKey:@"lat"] floatValue]
                                                                                        longitude:[(NSNumber*)[location objectForKey:@"lng"] floatValue]
                                                                                   timeToNextStop:[dic valueForKey:@"estimateArrival"]
                                                                                   nextStopNumber:[(NSNumber*)[dic valueForKey:@"nextStopNumber"] integerValue]];
                                    [myAnnotations addObject:bus];
                                    [bus release];
                                    if (displayLink == nil && !hasExited)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
                                            [displayLink setFrameInterval:60];
                                            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                                        });
                                    }
                                }
                            }
                        }
                    }
                    _isClearToSend = YES;
                    json = nil;
                    if ([myAnnotations count] == 0)
                    {
                        _skipLoop = YES;
                        if (displayLink)
                        {
                            [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                            [displayLink invalidate];
                            [displayLink release];
                            displayLink = nil;
                        }
                        if (![blockOperation isCancelled])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sorry, no one is sharing their ride for this route. Share yours and be a transit hero!" delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
                                [alert show];
                                [alert release];
                            });
                        }
                        [myAnnotations release];
                        myAnnotations = nil;
                    } else {
                        _isClearToSend = YES;
                        if (_annotations) {
                            [_mapView removeAnnotations:_annotations];
                            [_annotations release];
                            _annotations = nil;
                        }
                        _annotations = [[NSArray alloc] initWithArray:myAnnotations];
                        [myAnnotations release];
                        myAnnotations = nil;
                        if (![blockOperation isCancelled])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_mapView addAnnotations:_annotations];
                                [_mapView setNeedsDisplay]; // This might not be needed
                            });
                        }
                    }
                } else {
                    _isClearToSend = YES;
                    if (!_skipLoop)
                    {
                        _skipLoop = YES;
                        if (![blockOperation isCancelled])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (displayLink)
                                {
                                    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                                    [displayLink invalidate];
                                    [displayLink release];
                                    displayLink = nil;
                                }
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sorry, no one is sharing their ride for this route. Share yours and be a transit hero!" delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
                                [alert show];
                                [alert release];
                            });
                        }
                    }
                }
            }
            [request release];
            [url release];
            [urlStr release];
            [cellToThread removeObject:blockOperation];
            [blockOperation cancel];
        }];
        [_queue addOperation:operation];
        [cellToThread addObject:operation];
        [operation release];
    }
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    if (_skipLoop)
    {
        return;
    }
    if (_isClearToSend)
    {
        [self pollServer];
    }
}

- (void)addRoute:(Route*)route
{
    if (_route)
    {
        [_route release]; _route = nil;
    }
    _route = [route retain];
    _favouriteButton.selected = _route.isFavourite;
}

- (void)addStops:(NSArray *)stops
{
    if (_stops)
    {
        [_stops release]; _stops = nil;
    }
    _stops = [[NSMutableArray alloc] initWithArray:stops];
    [_mapView addAnnotations:stops];
}

- (void)addStop:(StopAnnotation*)busStop
{
    if (_stops)
    {
        [_stops addObject:busStop];
    } else {
        _stops = [[NSMutableArray alloc] initWithObjects:busStop,nil];
    }
    [_mapView addAnnotation:busStop];
}

- (void)loadStopsForLocation
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BusAnnotation class]]) {
        BusAnnotation *bus = (BusAnnotation*)annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%li%@",(long)bus.num,bus.title]];
        if (annotationView == nil) {
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%li%@",(long)bus.num,bus.title]] autorelease];
            annotationView.enabled = YES;
//            annotationView.canShowCallout = YES;
            NSString *imageName = @"bus-icon.png";
            annotationView.image = [UIImage imageNamed:imageName];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        bus = nil;
        return annotationView;
    }
    else if ([annotation isKindOfClass:[StopAnnotation class]])
    {
        StopAnnotation *bus = (StopAnnotation*)annotation;
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%@",bus.code]];
        if (annotationView == nil)
        {
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%@",bus.code]] autorelease];
            annotationView.image = [UIImage imageNamed:@"busStop.png"];
        }
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.enabled = YES;
        bus = nil;
        return annotationView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
    polylineView.strokeColor = [UIColor blackColor];
    polylineView.lineWidth = 2.0;
    polylineView.lineJoin = kCGLineCapButt;
    
    return polylineView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    StopAnnotation *busStop = view.annotation;
    
    StopDisplayViewController *stopsVC;
    if (IS_IPHONE_5)
    {
        stopsVC = [[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewController" bundle:nil];
    } else {
        stopsVC = [[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewControllerSmall" bundle:nil];
    }
    stopsVC.busStop = busStop;
    stopsVC.superDelegate = self;
    [_delegate loadViewController:stopsVC];
    [stopsVC release];
    view.selected = NO;
    stopsVC = nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!_isStops) {
        if ([self isToBigZoom])
        {
            [_mapView removeAnnotations:_stops];
        }
        else
        {
            for (StopAnnotation *stop in [WebApiInterface sharedInstance].stops)
            {
                if ([stop isInsideSquare:_mapView.region])
                {
                    if (![_stops containsObject:stop])
                    {
                        [_mapView addAnnotation:stop];
                        [_stops addObject:stop];
                    }
                }
                else if ([_stops containsObject:stop])
                {
                    [_mapView removeAnnotation:stop];
                    [_stops removeObject:stop];
                }
            }
        }
    }
}

- (BOOL)isToBigZoom
{
//    NSLog(@"Span Lat: %f Long: %f",_mapView.region.span.latitudeDelta,_mapView.region.span.longitudeDelta);
    if (_mapView.region.span.latitudeDelta > 0.030 || _mapView.region.span.longitudeDelta > 0.027)
        return YES;
    return NO;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

}

#pragma WebApiInterfaceDegelate Methods
- (void)stopsLoaded:(NSArray*)stops
{
    [_mapView addAnnotations:stops];
}

- (void)stopLoaded:(NSNumber*)stop
{

}

- (void)touchedHomeButton:(BOOL)isAll
{
//    [_mapView addOverlays:_route.lines];
    [_mapView addAnnotations:_stops];
    [self.superDelegate touchedHomeButton:isAll];
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_currentLocation) {
        [_currentLocation release]; _currentLocation = nil;
    }
    _currentLocation =  [[locations objectAtIndex:[locations count]-1] retain];
    if (isStarting)
    {
        [_mapView setCenterCoordinate:_currentLocation.coordinate animated:YES];
        isStarting = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized)
    {
        [_locationManager startUpdatingLocation];
        isStarting = YES;
    }
}
@end
