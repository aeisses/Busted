//
//  TrackViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface TrackViewController : ParentViewController <CLLocationManagerDelegate>
{
    CADisplayLink *displayLink;
    BOOL isTracking;
    NSString *uudi;
}

@property (retain, nonatomic) IBOutlet UIImageView *greenButton;
@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) IBOutlet UITextField *inputField;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) CLLocation *currentLocation;

- (IBAction)touchTrackButton:(id)sender;

@end
