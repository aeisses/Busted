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

@protocol MapViewControllerDelegate <NSObject>
- (void)mapFinishedLoading;
@end

@interface MapViewController : ParentViewController <MKMapViewDelegate>
{
    CADisplayLink *displayLink;
}

@property (retain, nonatomic) NSArray *annotations;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) id <MapViewControllerDelegate> delegate;

- (void)addRoute:(BusRoute*)route;

@end
