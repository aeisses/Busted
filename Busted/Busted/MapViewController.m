//
//  MapViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (_annotations) [_annotations release];
    _mapView.delegate = nil;
    [_mapView release]; _mapView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    [_mapView setShowsUserLocation:YES];
    [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
    [displayLink setFrameInterval:15];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release];
    displayLink = nil;
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
            NSString *urlStr = [[NSString alloc] initWithFormat:@"%@%i",SERVERHOSTNAME,_route];
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

- (void)addRoute:(BusRoute*)route
{
    if (_mapView.overlays)
        [_mapView removeOverlays:_mapView.overlays];
    [_mapView addOverlays:route.lines];
    _route = route.routeNum;
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

@end
