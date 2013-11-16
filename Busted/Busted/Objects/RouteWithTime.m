//
//  RouteWithTime.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "RouteWithTime.h"

@implementation RouteWithTime

- (void)dealloc
{
    if (_routeId)
        [_routeId release];
    if (_shortName)
        [_shortName release];
    if (_longName)
        [_longName release];
    if (_times)
        [_times release];
    [super dealloc];
}

@end
