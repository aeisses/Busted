//
//  TableCell.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TableCell.h"
#import "WebApiInterface.h"

@implementation TableCell


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
    // Configure the view for the selected state
}

- (NSString *) reuseIdentifier {
    return @"TableCell";
}

- (void)dealloc
{
    [_routeNumber release]; _routeNumber = nil;
    [_downArrow release]; _downArrow = nil;
    [_time release]; _time = nil;
    [_timeRemaining release]; _timeRemaining = nil;
    [_busStopCode release]; _busStopCode = nil;
    [_timeLable release]; _timeLable = nil;
    [super dealloc];
}

@end
