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
- (void)exitTransitionVC;
@end

@interface TrackViewController : UIViewController <CLLocationManagerDelegate,BusRouteCollectionViewControllerDelegate>
{
    CADisplayLink *displayLink;
    BOOL isTracking;
    NSString *uudi;
    NSInteger currentRoute;
}

@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *sendingImage;
@property (retain, nonatomic) id <TrackViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (retain, nonatomic) BusRoutesCollectionViewController *collection;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (retain, nonatomic) NSString *locationString;

- (IBAction)touchTrackButton:(id)sender;
- (IBAction)touchHomeButton:(id)sender;

@end
