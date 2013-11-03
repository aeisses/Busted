//
//  MapViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
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
    instance = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (instance) {
        // Custom initialization
    }
    return instance;
}

- (void)dealloc
{
    if (_annotations) {
        [_mapView removeAnnotations:_annotations];
        [_annotations release];
        _annotations = nil;
    }
    if (_route) {
//        [_mapView removeOverlays:_route.lines];
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
    _mapView.delegate = nil;
    [_mapView release]; _mapView = nil;
    [_homeButton release]; _homeButton = nil;
    [_favoriteButton release]; _favoriteButton = nil;
    [super dealloc];
}

- (IBAction)touchHomeButton:(id)sender
{
    [self.superDelegate touchedHomeButton:NO];
}

- (IBAction)touchFavoriteButton:(id)sender
{
    _favoriteButton.selected = !_favoriteButton.selected;
}

- (void)viewDidLoad
{
    [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    if (_isStops)
    {
        [_homeButton setImage:[UIImage imageNamed:@"routeButton.png"] forState:UIControlStateNormal];
        [_homeButton setImage:[UIImage imageNamed:@"routeButtonHighlighted.png"] forState:UIControlStateHighlighted];
        [self.view bringSubviewToFront:_favoriteButton];
        _favoriteButton.hidden = NO;
    }
    else
    {
        [_homeButton setImage:[UIImage imageNamed:@"homeButton.png"] forState:UIControlStateNormal];
        [_homeButton setImage:[UIImage imageNamed:@"homeButtonHighlighted.png"] forState:UIControlStateHighlighted];
        if (_currentLocation)
        {
            [_mapView setRegion:(MKCoordinateRegion){_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude,0.014200, 0.011654}];
        } else {
            [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
        }
        if (_stops)
            [_stops release];
        _stops = [[NSMutableArray alloc] initWithCapacity:0];
        for (BusStop *stop in [WebApiInterface sharedInstance].stops)
        {
            if ([stop isInsideSquare:_mapView.region])
            {
                [_mapView addAnnotation:stop];
                [_stops addObject:stop];
            }
        }
        _favoriteButton.hidden = YES;
    }
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    [_mapView setShowsUserLocation:YES];
    [self.view bringSubviewToFront:_homeButton];
//    if (!_isStops)
//    {
//        dispatch_queue_t dataQueue  = dispatch_queue_create("data queue", NULL);
//        dispatch_async(dataQueue, ^{
//            [[WebApiInterface sharedInstance] requestStopsForRegion:_mapView.region];
//        });
//        dispatch_release(dataQueue);
//    }
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_isStops)
    {
        displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
        [displayLink setFrameInterval:15];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
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
        [[WebApiInterface sharedInstance] setFavorite:_favoriteButton.selected forRoute:_route.shortName];
    }
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeFromSuperview];
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    Reachability *remoteHostStatus = [Reachability reachabilityWithHostName:SERVERHOSTNAME];
    if (remoteHostStatus.currentReachabilityStatus != NotReachable)
    {
        // TODO: Might still have some memory issues here....
        dispatch_queue_t networkQueue  = dispatch_queue_create("network queue", NULL);
        dispatch_async(networkQueue, ^{
            NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%@",SERVERHOSTNAME,_route.shortName];
            NSURL *url = [[NSURL alloc] initWithString:urlStr];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSError *error = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
                if (!error) {
                    NSMutableArray *myAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
                    for (NSDictionary *dic in json) {
                        Bus *bus = [[Bus alloc] initWithBusNumber:[(NSNumber*)[dic objectForKey:@"busNumber"] integerValue]
                                                            UUDID:[dic objectForKey:@"uuid"]
                                                         latitude:[(NSNumber*)[dic objectForKey:@"latitude"] floatValue]
                                                        longitude:[(NSNumber*)[dic objectForKey:@"longitude"] floatValue]
                                                   timeToNextStop:0];
                        [myAnnotations addObject:bus];
                        [bus release];
                    }
                    json = nil;
                    if (_annotations) {
                        [_mapView removeAnnotations:_annotations];
                        _annotations = nil;
                    }
                    _annotations = [[NSArray alloc] initWithArray:myAnnotations];
                    [myAnnotations release];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_mapView addAnnotations:_annotations];
                        [_mapView setNeedsDisplay]; // This might not be needed
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

- (void)addRoute:(MyRoute*)route
{
    if (_route)
    {
        [_route release]; _route = nil;
    }
    _route = [route retain];
    _favoriteButton.selected = _route.isFavorite;
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

- (void)addStop:(BusStop*)busStop
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

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [_delegate mapFinishedLoading];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[Bus class]]) {
        Bus *bus = (Bus*)annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:bus.UUID];
        if (annotationView == nil) {
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:bus.UUID] autorelease];
            annotationView.enabled = YES;
            annotationView.canShowCallout = NO;
            NSString *imageName = @"dot0.png";
            annotationView.image = [UIImage imageNamed:imageName];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        bus = nil;
        return annotationView;
    }
    else if ([annotation isKindOfClass:[BusStop class]])
    {
        BusStop *bus = (BusStop*)annotation;
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
    BusStop *busStop = view.annotation;
    
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
    stopsVC = nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!_isStops) {
        for (BusStop *stop in [WebApiInterface sharedInstance].stops)
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

@end
