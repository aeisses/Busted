//
//  TrackViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "ParentViewController.h"
#import "BusRoutesCollectionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@protocol TrackViewControllerDelegate <NSObject>
- (NSArray*)getRoutes;
- (void)exitTransitionVC;
@end

@interface TrackViewController : UIViewController <CLLocationManagerDelegate,BusRouteCollectionViewControllerDelegate>
{
    CADisplayLink *sendingLink;
    NSString *uudi;
    int currentFrame;
    NSArray *frames;
    NSDate *startTrackingTime;
    BOOL viewIsVisable;
}

@property (retain, nonatomic) CADisplayLink *displayLink;
@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *sendingImage;
@property (retain, nonatomic) IBOutlet UIImageView *sendingZoom;
@property (retain, nonatomic) IBOutlet UILabel *connectedToServer;
@property (retain, nonatomic) id <TrackViewControllerDelegate> delegate;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (retain, nonatomic) BusRoutesCollectionViewController *collection;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (retain, nonatomic) NSString *locationString;
@property (assign, nonatomic) BOOL isTracking;
@property (retain, nonatomic) NSDate *backGroundTime;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UILabel *routeLabel;
@property (nonatomic, assign) NSInteger currentRoute;

+ (TrackViewController*)sharedInstance;
- (IBAction)touchTrackButton:(id)sender;
- (IBAction)touchHomeButton:(id)sender;
- (IBAction)touchTwitterButton:(id)sender;

@end
