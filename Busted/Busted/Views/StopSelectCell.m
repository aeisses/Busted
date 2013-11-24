//
//  TableCell.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "StopSelectCell.h"
#import "WebApiInterface.h"

@implementation StopSelectCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (NSString *) reuseIdentifier {
    return @"StopSelectCell";
}

- (void)dealloc
{
    [_routeNumber release]; _routeNumber = nil;
    [_routeName release]; _routeName = nil;
    [_time release]; _time = nil;
    [_timeRemaining release]; _timeRemaining = nil;
    [_timeNext release]; _timeNext = nil;
    [_timeRemainingNext release]; _timeRemainingNext = nil;
    [_timeNextNext release]; _timeNextNext = nil;
    [_timeRemainingNextNext release]; _timeRemainingNextNext = nil;
    [_busStopCode release]; _busStopCode = nil;
    [super dealloc];
}

@end
