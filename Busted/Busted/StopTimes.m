//
//  StopTimes.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "StopTimes.h"

@implementation StopTimes

- (void)dealloc
{
    if (_arrival)
        [_arrival release];
    if (_departure)
        [_departure release];
    [super dealloc];
}
@end
