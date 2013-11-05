//
//  Bus.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "Bus.h"

@implementation Bus

- (id)initWithBusNumber:(NSInteger)num latitude:(float)lat longitude:(float)lng timeToNextStop:(NSString*)timeToNextStop nextStopNumber:(NSInteger)nextStop
{
    if (self = [super init])
    {
        _num = num;
        if (![timeToNextStop isEqualToString:@""]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            NSDateFormatter *currentTimeFormatter = [[NSDateFormatter alloc] init];
            [currentTimeFormatter setDateFormat:@"YYYY-MM-dd"];
            NSDate *stopDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[currentTimeFormatter stringFromDate:[NSDate date]],timeToNextStop]];
            int diff = [stopDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
            _title = [[NSString alloc] initWithFormat:@"%i mins",diff];
            [formatter release];
            [currentTimeFormatter release];
        } else {
            _title = @"";
        }
        if (!nextStop == 0) {
            _subtitle = [[NSString alloc] initWithFormat:@"Next Stop: %i",nextStop];
        } else {
            _subtitle = @"";
        }
        _coordinate = CLLocationCoordinate2DMake(lat, lng);
    }
    return self;
}

- (void)dealloc
{
    [_subtitle release]; _subtitle = nil;
    [_title release]; _title = nil;
    [super dealloc];
}
@end
