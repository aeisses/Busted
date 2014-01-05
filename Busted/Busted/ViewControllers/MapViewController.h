//
//  MapViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ParentViewController.h"
#import "RegionZoomData.h"
#import "BusAnnotation.h"
#import "Reachability.h"
#import "StopDisplayViewController.h"
#import "macros.h"
#import "Route.h"
#import "RouteManagedObject.h"
#import "StopAnnotation.h"

//#define SERVERHOSTNAME @"http://ertt.ca:8080/busted/buslocation/"

@protocol MapViewControllerDelegate <NSObject>
@optional
- (void)mapFinishedLoading;
- (void)loadViewController:(UIViewController*)vc;
@end

@interface MapViewController : ParentViewController <MKMapViewDelegate,ParentViewControllerDelegate,CLLocationManagerDelegate>
{
    CADisplayLink *displayLink;
//    BOOL skipLoop;
    BOOL isStarting;
    BOOL hasExited;
}

@property (retain, nonatomic) Route *route;
@property (retain, nonatomic) NSArray *annotations;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) id <MapViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (assign, nonatomic) BOOL isStops;
@property (retain, nonatomic) NSMutableArray *stops;
@property (retain, nonatomic) IBOutlet UIButton *favouriteButton;
@property (assign, nonatomic) BOOL skipLoop;
@property (assign, nonatomic) BOOL isClearToSend;
//@property (nonatomic, retain) UIActivityIndicatorView *spinner;

+ (MapViewController*)sharedInstance;
- (void)addRoute:(Route*)route;
- (void)addStops:(NSArray*)stops;
- (void)loadStopsForLocation;
- (void)addStop:(StopAnnotation*)busStop;
- (IBAction)touchHomeButton:(id)sender;
- (IBAction)touchFavouriteButton:(id)sender;
- (void)showRouteAlert;

@end
