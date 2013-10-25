//
//  TableCell.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *routeNumber;
@property (retain, nonatomic) IBOutlet UILabel *routeName;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *timeRemaining;
@property (retain, nonatomic) NSNumber *busStopCode;
@property (retain, nonatomic) IBOutlet UIImageView *downArrow;

@end
