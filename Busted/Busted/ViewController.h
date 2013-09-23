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

@interface ViewController : UIViewController <MenuViewControllerDelegate,ParentViewControllerDelegate,DataReaderDelegate>
{
    DataReader *dataReader;
    UIActivityIndicatorView *activityIndicator;
}

@property (retain, nonatomic) MenuViewController *menuViewController;
@property (retain, nonatomic) TrackViewController *trackVC;
@property (retain, nonatomic) LoadingScreenViewController *loadingScreen;

@end
