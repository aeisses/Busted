//
//  TrackViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"
#import "BusRoutesCollectionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@protocol TrackViewControllerDelegate <NSObject>
- (NSArray*)getRoutes;
@end

@interface TrackViewController : ParentViewController <CLLocationManagerDelegate,BusRouteCollectionViewControllerDelegate>
{
    CADisplayLink *displayLink;
    BOOL isTracking;
    NSString *uudi;
}

@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) IBOutlet UIButton *routeButton;
@property (retain, nonatomic) id <TrackViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (retain, nonatomic) BusRoutesCollectionViewController *collection;

- (IBAction)touchTrackButton:(id)sender;
- (IBAction)touchRouteButton:(id)sender;

@end
