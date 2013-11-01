//
//  myRoute.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-05.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MyRoute.h"

@implementation MyRoute

- (BOOL)isEqual:(id)object
{
    if ([self.shortName isEqualToString:((MyRoute*)object).shortName])
        return YES;
    return NO;
}

- (void)dealloc
{
    [_shortName release]; _shortName = nil;
    [_longName release]; _longName = nil;
    [super dealloc];
}

@end
