//
//  ViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "DataReader.h"
#import "TrackViewController.h"
#import "LoadingScreenViewController.h"
#import "WebApiInterface.h"
#import "TLTransitionAnimator.h"

@interface ViewController : UIViewController <MenuViewControllerDelegate,ParentViewControllerDelegate,DataReaderDelegate,TrackViewControllerDelegate,WebApiInterfaceDelegate,LoadingScreenViewControllerDelegate>
{
    DataReader *dataReader;
    UIActivityIndicatorView *activityIndicator;
}

@property (retain, nonatomic) MenuViewController *menuViewController;
@property (retain, nonatomic) TrackViewController *trackVC;
@property (retain, nonatomic) LoadingScreenViewController *loadingScreen;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) WebApiInterface *webApiInterface;
@property (copy, nonatomic) NSArray *routes;

@end
