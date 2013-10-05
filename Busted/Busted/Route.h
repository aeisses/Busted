//
//  Route.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-28.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;
@class Stop;
@class Routes;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSString *long_name;
@property (nonatomic, retain) NSString *short_name;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSSet *trips;
@property (nonatomic, retain) Routes *routes;

@end
