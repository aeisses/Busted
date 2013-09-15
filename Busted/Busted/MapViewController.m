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
    [_mapView release]; _mapView = nil;
    [_lattitude release]; _lattitude = nil;
    [_longitude release]; _longitude = nil;
    [_deltaLattutide release]; _deltaLattutide = nil;
    [_deltaLongitude release]; _deltaLongitude = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    annotations = [[NSMutableArray alloc] initWithCapacity:0];
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    [_mapView setShowsUserLocation:YES];
    [_mapView setRegion:[RegionZoomData getRegion:Halifax]];
    _lattitude = [[UILabel alloc] initWithFrame:(CGRect){20,312,280,21}];
    _lattitude.hidden = YES;
    [_mapView addSubview:_lattitude];
    _longitude = [[UILabel alloc] initWithFrame:(CGRect){20,341,280,21}];
    _longitude.hidden = YES;
    [_mapView addSubview:_longitude];
    _deltaLattutide = [[UILabel alloc] initWithFrame:(CGRect){20,370,280,21}];
    _deltaLattutide.hidden = YES;
    [_mapView addSubview:_deltaLattutide];
    _deltaLongitude = [[UILabel alloc] initWithFrame:(CGRect){20,395,280,21}];
    _deltaLongitude.hidden = YES;
    [_mapView addSubview:_deltaLongitude];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)];
    [displayLink setFrameInterval:15];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [super viewDidLoad];
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
//    NSError *error = nil;
    NSString *urlStr = [[NSString alloc] initWithString:@"http://ertt.ca:8080/busted/buslocation/80"];
        //    NSURL *url = [[NSURL alloc] initWithString:urlStr];
         //    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlStr]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//    NSLog(@"Json String: %@",json_string);
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSLog(@"%@",json);
    [_mapView removeAnnotations:annotations];
    [annotations removeAllObjects];
    for (NSDictionary *dic in json) {
        Bus *bus = [[Bus alloc] initWithBusNumber:[(NSNumber*)[dic objectForKey:@"busNumber"] integerValue]
                                            UUDID:[dic objectForKey:@"uuid"]
                                         latitude:[(NSNumber*)[dic objectForKey:@"latitude"] floatValue]
                                        longitude:[(NSNumber*)[dic objectForKey:@"longitude"] floatValue]
                                   timeToNextStop:0];
        [_mapView addAnnotation:bus];
        [annotations addObject:bus];
    }
}

- (void)addRoute:(BusRoute*)route
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView addOverlays:route.lines];
//    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    _lattitude.text = [NSString stringWithFormat:@"%f",_mapView.region.center.latitude];
    _longitude.text = [NSString stringWithFormat:@"%f",_mapView.region.center.longitude];
    _deltaLattutide.text = [NSString stringWithFormat:@"%f",_mapView.region.span.latitudeDelta];
    _deltaLongitude.text = [NSString stringWithFormat:@"%f",_mapView.region.span.longitudeDelta];
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
/*    if ([annotation isKindOfClass:[Bus class]]) {
        NSString *identifier;
        if (!showNumberOfRoutesStops && !showTerminals) {
            identifier = @"BusStop";
        } else if (!showNumberOfRoutesStops && showTerminals) {
            BusStop *busStop = (BusStop*)annotation;
            identifier = [NSString stringWithFormat:@"Terminal%i",busStop.fcode];
        } else {
            BusStop *busStop = (BusStop*)annotation;
            identifier = [NSString stringWithFormat:@"BusStop%i",[busStop.routes count]];
        }
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annotationView.enabled = YES;
            annotationView.canShowCallout = NO;
            NSString *imageName;
            if (!showNumberOfRoutesStops && !showTerminals) {
                imageName = @"dot0.png";
            } else if (!showNumberOfRoutesStops && showTerminals) {
                BusStop *busStop = (BusStop*)annotation;
                imageName = [NSString stringWithFormat:@"terminal%i",busStop.fcode];
            } else {
                BusStop *busStop = (BusStop*)annotation;
                imageName = [NSString stringWithFormat:@"dot%i.png",[busStop.routes count]];
            }
            annotationView.image = [UIImage imageNamed:imageName];//here we use a nice image instead of the default pins
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
 */
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
