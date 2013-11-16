//
//  stopsHeader.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "StopsHeader.h"

@implementation StopsHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_title release]; _title = nil;
    [super dealloc];
}

@end
