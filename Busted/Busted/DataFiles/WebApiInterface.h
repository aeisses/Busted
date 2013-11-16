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
#import "StopManagedObject.h"
#import "MapViewController.h"
#import "StopAnnotation.h"

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
- (NSArray*)getFavouriteStops;
- (NSArray*)getFavouriteRoutes;
- (void)setFavourite:(BOOL)favourite forStop:(NSNumber*)code;
- (void)setFavourite:(BOOL)favourite forRoute:(NSString *)shortName;
- (StopManagedObject*)getStopForCode:(NSNumber*)code;
- (void)getRouteForIdent:(NSNumber*)ident;
- (void)loadPathForRoute:(NSString*)shortName;

@end