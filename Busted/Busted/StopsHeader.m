//
//  stopsHeader.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_goTimeNumber release]; _goTimeNumber = nil;
    [_title release]; _title = nil;
    [super dealloc];
}

@end
