//
//  MapViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ParentViewController.h"
#import "RegionZoomData.h"
#import "BusRoute.h"
#import "Bus.h"
#import "Reachability.h"
#import "StopDisplayViewController.h"

#define SERVERHOSTNAME @"http://ertt.ca:8080/busted/buslocation/"

@protocol MapViewControllerDelegate <NSObject>
- (void)mapFinishedLoading;
@optional
- (void)updateStops:(CLLocationCoordinate2D)mapCenter;
- (void)loadViewController:(UIViewController*)vc;
@end

@interface MapViewController : ParentViewController <MKMapViewDelegate>
{
    CADisplayLink *displayLink;
}

@property (assign) NSInteger route;
@property (retain, nonatomic) NSArray *annotations;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) id <MapViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (MapViewController*)sharedInstance;
- (void)addRoute:(BusRoute*)route;
- (void)loadStopsForLocation;

@end
