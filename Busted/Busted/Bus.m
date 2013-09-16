//
//  Bus.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "Bus.h"

@implementation Bus

- (id)initWithBusNumber:(NSInteger)num UUDID:(NSString*)uuid latitude:(float)lat longitude:(float)longi timeToNextStop:(double)timeToNextStop
{
    if (self = [super init])
    {
        _UUID = [uuid retain];
        _title = [[NSString alloc] initWithFormat:@"%i",num];
        _coordinate = CLLocationCoordinate2DMake(lat, longi);
    }
    return self;
}

- (void)dealloc
{
    [_UUID release];
    [_title release];
    [super dealloc];
}
@end
