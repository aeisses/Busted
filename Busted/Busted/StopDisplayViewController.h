//
//  StopDisplayViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewController.h"

@class BusStop;

@interface StopDisplayViewController : ParentViewController <UITableViewDataSource,UITableViewDelegate>
{
    CADisplayLink *displayLink;
    NSMutableIndexSet *expandedSections;
}

@property (retain, nonatomic) BusStop *busStop;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *favoriteButton;
@property (retain, nonatomic) NSArray *routes;

+ (StopDisplayViewController*)sharedInstance;
- (IBAction)touchHomeButton:(id)sender;
- (IBAction)touchFavoriteButton:(id)sender;

@end
