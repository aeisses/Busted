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
    }
    instance = self;
    return instance;
}

- (void)dealloc
{
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
        [_locationManager release];
    if (_currentLocation)
        [_currentLocation release];
    _mapView.delegate = nil;
    [_mapView release]; _mapView = nil;
    [_homeButton release]; _homeButton = nil;
    [_favouriteButton release]; _favouriteButton = nil;
    [super dealloc];
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
    _locationManager = [[CLLocationManager alloc] init];
    //            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
//    dispatch_queue_t loadingThread  = dispatch_queue_create("network queue", NULL);
//    dispatch_async(loadingThread, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
            if (_isStops)
            {
                [_homeButton setImage:[UIImage imageNamed:@"routeButton.png"] forState:UIControlStateNormal];
                [_homeButton setImage:[UIImage imageNamed:@"routeButtonHighlighted.png"] forState:UIControlStateHighlighted];
                [self.view bringSubviewToFront:_favouriteButton];
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
//        });
//    });
//    dispatch_release(loadingThread);
//    if (!_isStops)
//    {
//        dispatch_queue_t dataQueue  = dispatch_queue_create("data queue", NULL);
//        dispatch_async(dataQueue, ^{
//            [[WebApiInterface sharedInstance] requestStopsForRegion:_mapView.region];
//        });
//        dispatch_release(dataQueue);
//    }
    skipLoop = NO;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_mapView setShowsUserLocation:YES];
    skipLoop =  NO;
    if (_isStops)
    {
        displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
        [displayLink setFrameInterval:60];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
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
        if (_currentLocation)
        {
            [_mapView setRegion:(MKCoordinateRegion){_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude,0.014200, 0.011654}];
        } else {
            [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
        }
//        [_mapView setNeedsDisplay];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_isStops)
    {
        [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [displayLink invalidate];
        [displayLink release];
        displayLink = nil;
        [[WebApiInterface sharedInstance] setFavourite:_favouriteButton.selected forRoute:_route.shortName];
    }
    [_locationManager stopUpdatingLocation];
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    if (skipLoop)
    {
        return;
    }
    Reachability *remoteHostStatus = [Reachability reachabilityWithHostName:@"knowtime.ca"];
    if (remoteHostStatus.currentReachabilityStatus != NotReachable)
    {
        // TODO: Might still have some memory issues here....
        dispatch_queue_t networkQueue  = dispatch_queue_create("network queue", NULL);
        dispatch_async(networkQueue, ^{
            NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@%@:%@",SANGSTERBASEURL,ESTIMATE,SHORTS,_route.shortName];
//            NSLog(@"UrlString: %@",urlStr);
            NSURL *url = [[NSURL alloc] initWithString:urlStr];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSError *error = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
                if (!error) {
                    NSMutableArray *myAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *dic in json) {
                        NSDictionary *location = (NSDictionary*)[dic valueForKey:@"location"];
                        if ([(NSNumber*)[location objectForKey:@"lat"] floatValue] != 0.0 && [(NSNumber*)[location objectForKey:@"lng"] floatValue] != 0.0)
                        {
                            BusAnnotation *bus = [[BusAnnotation alloc] initWithBusNumber:[[dic objectForKey:@"busNumber"] integerValue]
                                                             latitude:[(NSNumber*)[location objectForKey:@"lat"] floatValue]
                                                            longitude:[(NSNumber*)[location objectForKey:@"lng"] floatValue]
                                                       timeToNextStop:[dic valueForKey:@"estimateArrival"]
                                                       nextStopNumber:[(NSNumber*)[dic valueForKey:@"nextStopNumber"] integerValue]];
                            [myAnnotations addObject:bus];
                            [bus release];
                        }
                    }
                    json = nil;
                    if ([myAnnotations count] == 0)
                    {
                        skipLoop = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No buses can currently be found. This can be because no one is sending a signal or a server issue." delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
                            [alert show];
                            [alert release];
                        });
                        [myAnnotations release];
                        myAnnotations = nil;
                    } else {
                        if (_annotations) {
                            [_mapView removeAnnotations:_annotations];
                            [_annotations release];
                            _annotations = nil;
                        }
                        _annotations = [[NSArray alloc] initWithArray:myAnnotations];
                        [myAnnotations release];
                        myAnnotations = nil;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_mapView addAnnotations:_annotations];
                            [_mapView setNeedsDisplay]; // This might not be needed
                        });
                    }
                } else {
                    skipLoop = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"No buses can currently be found. This can be because no one is sending a signal or a server issue." delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    });
                }
            }
            [request release];
            [url release];
            [urlStr release];
        });
        dispatch_release(networkQueue);
    } else {
        // The internet connection is not valid
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
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%i%@",bus.num,bus.title]];
        if (annotationView == nil) {
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%i%@",bus.num,bus.title]] autorelease];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
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
//        if (![bus.subtitle isEqualToString:@"Next Bus: unknown"])
//        {
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        } else {
//            annotationView.rightCalloutAccessoryView = nil;
//        }
        annotationView.enabled = YES;
        bus = nil;
        return annotationView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
//    if ([overlay.title isEqualToString:@"Black"]) {
        polylineView.strokeColor = [UIColor blackColor];
        polylineView.lineWidth = 2.0;
/*    } else if ([overlay.title isEqualToString:@"Red"]) {
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 4.0;
    } else if ([overlay.title isEqualToString:@"Blue"]) {
        polylineView.strokeColor = [UIColor blueColor];
        polylineView.lineWidth = 4.0;
    } else if ([overlay.title isEqualToString:@"Green"]) {
        polylineView.strokeColor = [UIColor greenColor];
        polylineView.lineWidth = 4.0;
    }
 */
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
        for (StopAnnotation *stop in [WebApiInterface sharedInstance].stops)
        {
            if ([stop isInsideSquare:_mapView.region])
            {
                if (![_stops containsObject:stop]) {
                    [_mapView addAnnotation:stop];
                    [_stops addObject:stop];
                }
            } else if ([_stops containsObject:stop]) {
                [_mapView removeAnnotation:stop];
                [_stops removeObject:stop];
            }
        }
    }
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
