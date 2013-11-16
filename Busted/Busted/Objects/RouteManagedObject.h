//
//  Routes.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-01.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RouteManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *longName;
@property (nonatomic, retain) NSString *shortName;
@property (assign) NSInteger ident;
@property (nonatomic, retain) NSNumber *isFavourite;

@end
