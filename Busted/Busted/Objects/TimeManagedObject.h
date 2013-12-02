//
//  Time.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-01.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RouteTimeManagedObject.h"

@interface TimeManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *arrival;
@property (nonatomic, retain) NSString *departure;
@property (nonatomic, retain) RouteTimeManagedObject *routetime;

@end
