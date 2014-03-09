//
//  BusRouteViewCell.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-20.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "RouteSelectCell.h"

@implementation RouteSelectCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _backGround.image = [UIImage imageNamed:@"cellBackGround"];
}

- (void)setToRed
{
    _backGround.image = [UIImage imageNamed:@"cellBackGroundSelected"];
}

- (void)dealloc
{
    [_backGround release]; _backGround = nil;
    [_number release]; _number = nil;
    [super dealloc];
}

@end
