//
//  Trip.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-28.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route;

@interface Trip : NSManagedObject

@property (retain, nonatomic) NSString *headsign;
@property (retain, nonatomic) NSNumber *time;
@property (retain, nonatomic) Route *route;

@end
