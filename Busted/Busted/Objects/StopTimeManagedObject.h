//
//  StopTime.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-01.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface StopTimeManagedObject : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *stopId;
@property (nonatomic, retain) NSSet *routes;

@end
