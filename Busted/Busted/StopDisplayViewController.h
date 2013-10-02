//
//  StopDisplayViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusStop.h"

@interface StopDisplayViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) BusStop *busStop;

@end
