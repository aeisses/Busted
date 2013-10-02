//
//  WebApiInterface.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "AFJSONRequestOperation.h"
#import "Stop.h"
#import "Trip.h"
#import "Route.h"
#import "MapViewController.h"
#import "BusStop.h"
#import "Routes.h"

@interface WebApiInterface : NSObject


// Calls:
//http://t2go-halifax.transittogo.com/api/v1/stop/6963/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/place/44.638508,-63.568782/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/routes/motd?appversion=15

#define BASEURL @"http://t2go-halifax.transittogo.com/api/v1/"
#define FILLER  @"/upcoming_stoptimes?time="
#define ENDURL  @"&all_routes=yes"
#define STOPS   @"stop/"
#define PLACE   @"place/"
#define ROUTE   @"route/"
#define ROUTES  @"routes/"
#define ALL     @"all"

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *busStops;

+ (WebApiInterface*)sharedInstance;
- (void)requestAllRoutes;
- (void)requestStop:(NSInteger)stop;
- (void)requestPlace:(CLLocationCoordinate2D)coordinate;

@end
