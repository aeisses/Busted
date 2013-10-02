//
//  Routes.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-01.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route;

@interface Routes : NSManagedObject

@property (nonatomic, retain) NSString *jsonString;
@property (nonatomic, retain) NSSet *route;

@end
