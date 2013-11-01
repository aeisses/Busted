//
//  MenuViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RoutesViewController.h"
#import "TrackViewController.h"
#import "FavoritesViewController.h"
#import "ParentViewController.h"
#import "FavoritesViewController.h"
#import "AboutScreen.h"
#import "macros.h"

@protocol MenuViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (BusRoute*)getRoute:(NSInteger)routeNumber;
- (NSArray*)getRoutes;
@end

@interface MenuViewController : ParentViewController <RoutesViewControllerDelegate,MapViewControllerDelegate,FavoritesViewControllerDelegate,AboutScreenDelegate,MFMailComposeViewControllerDelegate>
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
@end
