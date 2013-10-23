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

@protocol WebApiInterfaceDelegate <NSObject>
- (void)receivedRoutes;
- (void)receivedStops;
@end

@interface WebApiInterface : NSObject

// Calls:
//http://t2go-halifax.transittogo.com/api/v1/stop/6963/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/place/44.638508,-63.568782/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/routes/motd?appversion=15

#define BASEURL @"http://t2go-halifax.transittogo.com/api/v1/"
#define SANGSTERBASEURL @"https://ertt.ca/api/alpha_1/"
#define FILLER  @"/upcoming_stoptimes?time="
#define ENDURL  @"&all_routes=yes"
#define STOP    @"stop/"
#define STOPS   @"stops"
#define PLACE   @"place/"
#define ROUTE   @"route/"
#define ROUTES  @"routes"
#define ALL     @"all"

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *busStops;
@property (retain, nonatomic) id <WebApiInterfaceDelegate> delegate;

+ (WebApiInterface*)sharedInstance;
- (NSArray*)requestAllRoutes;
- (void)fetchAllRoutes;
- (void)fetchAllStops;
- (void)requestStop:(NSInteger)stop;
- (void)requestPlace:(CLLocationCoordinate2D)coordinate;
- (void)requestStopsForRegion:(MKCoordinateRegion)region;
- (NSArray*)getFavoriteStops;
- (NSArray*)getFavoriteRoutes;
- (void)setFavorite:(BOOL)favorite forStop:(NSNumber*)code;

@end
