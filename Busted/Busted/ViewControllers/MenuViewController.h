//
//  MenuViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RoutesViewController.h"
#import "TrackViewController.h"
#import "FavouritesViewController.h"
#import "ParentViewController.h"
#import "FavouritesViewController.h"
#import "AboutScreen.h"
#import "macros.h"
#import "WebApiInterface.h"

@protocol MenuViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (NSArray*)getRoutes;
@end

@interface MenuViewController : ParentViewController <RoutesViewControllerDelegate,MapViewControllerDelegate,FavouritesViewControllerDelegate,AboutScreenDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL isAboutScreenVisible;
}

@property (retain, nonatomic) id <MenuViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *button3;
@property (retain, nonatomic) IBOutlet UIButton *button4;
@property (retain, nonatomic) MapViewController *mapVC;
@property (retain, nonatomic) AboutScreen *aboutView;
@property (retain, nonatomic) IBOutlet UIButton *trackButton;

- (IBAction)touchButton:(id)sender;
- (IBAction)touchTrackButton:(id)sender;
- (void)showTrackingAlert;

@end
