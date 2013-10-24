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
@property (nonatomic, retain) NSString *ident;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) Routes *routes;
@property (nonatomic, retain) NSNumber *isFavorite;
@property (nonatomic, assign) id times;

@end
