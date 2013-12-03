//
//  ViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "TrackViewController.h"
#import "LoadingScreenViewController.h"
#import "WebApiInterface.h"
#import "TLTransitionAnimator.h"
#import "StopDisplayViewController.h"
#import "HamburgerMenuViewController.h"
#import "MTTwitterViewController.h"
#import "AboutViewController.h"
#import "PrivacyPolicyViewController.h"

@interface ViewController : UIViewController <MenuViewControllerDelegate,ParentViewControllerDelegate,TrackViewControllerDelegate,WebApiInterfaceDelegate,LoadingScreenViewControllerDelegate,StopDisplayViewControllerDelegate,MapViewControllerDelegate,HamburgerMenuViewControllerDelegate,FavouritesViewControllerDelegate>
{
    UIActivityIndicatorView *activityIndicator;
}

@property (retain, nonatomic) MapViewController *mapViewController;
@property (retain, nonatomic) MenuViewController *menuViewController;
@property (retain, nonatomic) HamburgerMenuViewController *hamburgerMenuViewController;
@property (retain, nonatomic) TrackViewController *trackVC;
@property (retain, nonatomic) LoadingScreenViewController *loadingScreen;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) WebApiInterface *webApiInterface;
@property (copy, nonatomic) NSArray *routes;

@end
