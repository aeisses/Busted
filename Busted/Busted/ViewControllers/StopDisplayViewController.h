//
//  StopDisplayViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewController.h"
#import "macros.h"
#import "StopSelectCell.h"
#import "RouteWithTime.h"
#import "StopTimes.h"
#import "StopsHeader.h"
#import "Flurry.h"
//#import "RouteManagedObject.h"

@class StopAnnotation;

@protocol StopDisplayViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (NSArray*)getRoutes;
@end

@interface StopDisplayViewController : ParentViewController <UITableViewDataSource,UITableViewDelegate>
{
    CADisplayLink *displayLink;
//    NSMutableIndexSet *expandedSections;
}

@property (retain, nonatomic) StopAnnotation *busStop;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *favouriteButton;
@property (retain, nonatomic) NSArray *routes;
@property (retain, nonatomic) id <StopDisplayViewControllerDelegate> delegate;
@property (retain, nonatomic) UIActivityIndicatorView *activityMonitor;

+ (StopDisplayViewController*)sharedInstance;
- (IBAction)touchHomeButton:(id)sender;
- (IBAction)touchFavouriteButton:(id)sender;

@end
