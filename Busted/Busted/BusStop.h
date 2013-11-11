//
//  BusStop.h
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "Enums.h"
#import "Route.h"
#import "WebApiInterface.h"

@interface BusStop : NSObject <MKAnnotation>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *longTitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSSet *routes;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, retain) NSArray *routesId;

- (id)initWithCode:(NSNumber *)code;
- (id)initWithStop:(Stop*)stop;
- (BOOL)isInsideSquare:(MKCoordinateRegion)region;

@end
