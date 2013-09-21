//
//  BusRouteViewCell.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-20.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusRouteViewCell.h"

@implementation BusRouteViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    [_backGround release]; _backGround = nil;
    [_number release]; _number = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
