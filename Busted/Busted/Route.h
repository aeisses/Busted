//
//  Route.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-28.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;
@class Stop;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSString *long_name;
@property (nonatomic, retain) NSString *short_name;
@property (nonatomic, retain) NSString *ident;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSNumber *isFavorite;
@property (nonatomic, assign) id times;

@end
