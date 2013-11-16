//
//  WebApiInterface.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
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

#define SANGSTERBASEURL @"http://knowtime.ca/api/alpha_1/"
#define ENDURL          @"&all_routes=yes"
#define STOPS           @"stops"
#define ROUTES          @"routes"
#define NAMES           @"names"
#define SHORTS          @"short"
#define PATHS           @"paths/"
#define STOPTIME        @"stoptimes/"
#define HEADSIGNS       @"headsigns/"
#define USERS           @"users/"
#define NEW             @"new/"
#define ESTIMATE        @"estimates/"

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *stops;
@property (retain, nonatomic) id <WebApiInterfaceDelegate> delegate;

+ (WebApiInterface*)sharedInstance;
- (NSArray*)requestAllRoutes;
- (void)fetchAllRoutes;
- (void)fetchAllStops;
- (NSArray*)getFavoriteStops;
- (NSArray*)getFavoriteRoutes;
- (void)setFavorite:(BOOL)favorite forStop:(NSNumber*)code;
- (void)setFavorite:(BOOL)favorite forRoute:(NSString *)shortName;
- (Stop*)getStopForCode:(NSNumber*)code;
- (void)getRouteForIdent:(NSNumber*)ident;
- (void)loadPathForRoute:(NSString*)shortName;

@end
