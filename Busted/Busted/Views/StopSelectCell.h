//
//  TableCell.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopSelectCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *routeNumber;
@property (retain, nonatomic) IBOutlet UILabel *routeName;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *timeRemaining;
@property (retain, nonatomic) IBOutlet UILabel *timeNext;
@property (retain, nonatomic) IBOutlet UILabel *timeRemainingNext;
@property (retain, nonatomic) IBOutlet UILabel *timeNextNext;
@property (retain, nonatomic) IBOutlet UILabel *timeRemainingNextNext;
@property (retain, nonatomic) NSNumber *busStopCode;

@end
