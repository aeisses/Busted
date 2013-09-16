//
//  BusStop.h
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KML/KML.h>
#import <MapKit/MapKit.h>
#import "Enums.h"

@interface BusStop : NSObject <MKAnnotation>
{
    NSInteger objectId;
    SOURCE source;
    SACC sacc;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSInteger goTime;
@property (nonatomic, copy) NSArray *routes;
@property (readonly) FCODE fcode;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, retain) NSString *street;
@property (readonly) DIRECTION direction;

- (id)initWithTitle:(NSString *)title description:(NSString*)description andLocation:(KMLPoint*)location;
- (void)addRouteNumber:(NSNumber*)route;

@end
