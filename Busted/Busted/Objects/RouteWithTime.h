//
//  RouteWithTime.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteWithTime : NSObject

@property (retain, nonatomic) NSString *routeId;
@property (retain, nonatomic) NSString *shortName;
@property (retain, nonatomic) NSString *longName;
@property (retain, nonatomic) NSArray *times;

@end
