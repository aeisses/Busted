//
//  Stop.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-28.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface StopManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lng;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *isFavourite;

@end
