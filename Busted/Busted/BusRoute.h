//
//  BusRoute.h
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-28.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KML/KML.h>
#import <MapKit/MapKit.h>
#import "Enums.h"

typedef struct lineSegment {
    NSInteger count;
    CLLocationCoordinate2D *line;
} lineSegment;

@interface BusRoute : NSObject
{
//    NSString *stopDescription;
    NSInteger objectId;
    CLASS classType;
//    NSString *routeTitle;
    SOURCE source;
    SACC sacc;
//    NSDate *startDate;
//    NSDate *revDate;
    float shapeLen;
//    NSString *socrateId;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSArray *lines;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, retain) NSString *routeTitle;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *revDate;
@property (nonatomic, retain) NSString *socrateId;
@property (readwrite) NSInteger routeNum;


- (id)initWithTitle:(NSString *)title description:(NSString*)description andGeometries:(KMLMultiGeometry*)geometries;
- (id)initWithLines:(NSArray *)lines andTitle:(NSString *)title andNumber:(NSString*)number andDescription:(NSString*)description;
- (id)initWithLines:(NSArray *)lines andTitle:(NSString *)title;

@end
