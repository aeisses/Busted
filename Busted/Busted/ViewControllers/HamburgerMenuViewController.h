//
//  HamburgerMenuViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-11-24.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavouritesViewController.h"
#import "ParentViewController.h"
#import "MTTwitterViewController.h"
#import "AboutViewController.h"

@protocol HamburgerMenuViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (void)hideStops;
@end

@interface HamburgerMenuViewController : ParentViewController

@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *aboutButton;
@property (retain, nonatomic) IBOutlet UIButton *stopsButton;
@property (retain, nonatomic) IBOutlet UIButton *favourtiesButton;
@property (retain, nonatomic) IBOutlet UIButton *metroTransitTwitter;
@property (retain, nonatomic) IBOutlet UIImageView *aboutImage;
@property (retain, nonatomic) IBOutlet UIImageView *shareImage;
@property (retain, nonatomic) IBOutlet UIImageView *stopsImage;
@property (retain, nonatomic) IBOutlet UIImageView *favourtiesImage;
@property (retain, nonatomic) IBOutlet UIImageView *mtImage;
@property (retain, nonatomic) id <HamburgerMenuViewControllerDelegate> delegate;

- (IBAction)touchShareButton:(id)sender;
- (IBAction)touchAboutButton:(id)sender;
- (IBAction)touchStopsButton:(id)sender;
- (IBAction)touchFavouritesButton:(id)sender;
- (IBAction)touchMetroTransitTwitter:(id)sender;

@end
