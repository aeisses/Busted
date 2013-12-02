//
//  RouteTime.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-01.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "StopTimeManagedObject.h"

@interface RouteTimeManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *longName;
@property (nonatomic, retain) NSString *routeId;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) StopTimeManagedObject *stopTime;
@property (nonatomic, retain) NSOrderedSet *times;

@end
