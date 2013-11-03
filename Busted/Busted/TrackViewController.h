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
    NSString *uudi;
    NSInteger currentRoute;
    int currentFrame;
    NSArray *frames;
    NSDate *startTrackingTime;
}

@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *sendingImage;
@property (retain, nonatomic) IBOutlet UIImageView *sendingZoom;
@property (retain, nonatomic) id <TrackViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (retain, nonatomic) BusRoutesCollectionViewController *collection;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (retain, nonatomic) NSString *locationString;
@property (assign, nonatomic) BOOL isTracking;

+ (TrackViewController*)sharedInstance;
- (IBAction)touchTrackButton:(id)sender;
- (IBAction)touchHomeButton:(id)sender;

@end
