//
//  TableCell.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TableCell.h"

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
    [_routeNumber release]; _routeNumber = nil;
    [_time release]; _time = nil;
    [_timeRemaining release]; _timeRemaining = nil;
    [super dealloc];
}

@end
