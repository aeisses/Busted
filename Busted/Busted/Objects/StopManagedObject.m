//
//  Stop.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-28.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "StopManagedObject.h"

@implementation StopManagedObject

@dynamic code;
@dynamic lat;
@dynamic lng;
@dynamic name;
@dynamic isFavourite;

- (void)dealloc
{
    [super dealloc];
}

@end
