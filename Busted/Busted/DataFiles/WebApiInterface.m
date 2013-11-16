//
//  WebApiInterface.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "WebApiInterface.h"
#import "RouteWithTime.h"
#import "StopTimes.h"
#import "Path.h"

static NSString *const JSONDirectoryPath = @"/RawJson";

@interface WebApiInterface (PrivateMethods)
- (void)createRoutesRecordWithRoute:(NSArray*)routesArray context:(NSManagedObjectContext*)context;
- (void)createStopRecordsWithStops:(NSArray*)stopsArray context:(NSManagedObjectContext*)context;
- (NSManagedObjectContext*)createNewManagedObjectContext;
@end;

@implementation WebApiInterface

static id instance;

+ (WebApiInterface*)sharedInstance
{
    if (!instance) {
        return [[[WebApiInterface alloc] init] autorelease];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    instance = self;
    return instance;
}

- (void)createRoutesRecordWithRoute:(NSArray*)routesArray context:(NSManagedObjectContext*)context
{
    int counter = 1;
    for (NSDictionary *routeItem in routesArray)
    {
        NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"shortName == %@",[routeItem valueForKey:@"shortName"] ? [routeItem valueForKey:@"shortName"] : [NSString stringWithFormat:@"%i",counter]];
        fetchRequest.entity = myEntity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
        [fetchRequest release];
        if (![fetchedObject count])
        {
            RouteManagedObject *routes = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
            routes.longName = (NSString*)[routeItem valueForKey:@"longName"];
            routes.shortName = [routeItem valueForKey:@"shortName"] ? [routeItem valueForKey:@"shortName"] : [NSString stringWithFormat:@"%i",counter];
        }
        counter++;
    }
    [context save:nil];
}

- (void)createStopRecordsWithStops:(NSArray*)stopsArray context:(NSManagedObjectContext*)context
{
    NSLog(@"Stops: %i",stopsArray.count);
    for (NSDictionary *stopItem in stopsArray)
    {
        StopManagedObject *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
        stop.code = [NSString stringWithFormat:@"%@",[stopItem valueForKey:@"stopNumber"]];
        stop.name = [stopItem valueForKey:@"name"];
        NSDictionary *location = [stopItem valueForKey:@"location"];
        stop.lat = [location valueForKey:@"lat"];
        stop.lng = [location valueForKey:@"lng"];
    }
}

- (void)createStops
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    if (entity) {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObject.count > 0)
        {
            [self createStops:fetchedObject];
        }
    }
}

- (void)createStops:(NSArray*)fetchedObject
{
    NSMutableArray *tempStops = [[NSMutableArray alloc] initWithCapacity:fetchedObject.count];
    for (StopManagedObject *stop in fetchedObject)
    {
        StopAnnotation *newStop = [[StopAnnotation alloc] initWithStop:stop];
        [tempStops addObject:newStop];
        [newStop release];
    }
    _stops = [[NSArray alloc] initWithArray:tempStops];
    [tempStops release];
}

- (void)contextDidSave:(NSNotification *)notification
{
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    [_managedObjectContext performSelectorOnMainThread:selector withObject:notification waitUntilDone:YES];
}

- (NSManagedObjectContext*)createNewManagedObjectContext
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[_managedObjectContext persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    return [moc autorelease];
}

- (NSArray*)requestAllRoutes
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
    if (entity)
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
//        NSLog(@"FetchedObject %i",fetchedObject.retainCount);
        [error release];
        [fetchRequest release];
        if (fetchedObject.count > 0)
        {
            return fetchedObject;
        }
    }
    return nil;
}

- (void)fetchAllRoutes
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes" inManagedObjectContext:context];
//    if (entity) {
//        NSError *error = nil;
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        fetchRequest.entity = entity;
//        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
//        [fetchRequest release];
//        if (fetchedObject.count > 0)
//        {
//            [_delegate receivedRoutes];
//            return;
//        }
//    }
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@/%@", SANGSTERBASEURL, ROUTES, NAMES];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSError *error = nil;
        [self createRoutesRecordWithRoute:(NSArray*)JSON context:context];
        [context save:&error];
        [_delegate receivedRoutes];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [_delegate receivedRoutes];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (void)fetchAllStops
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    if (entity) {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObject.count > 0)
        {
            [self createStops:fetchedObject];
            [_delegate receivedStops];
            return;
        }
    }
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@", SANGSTERBASEURL, STOPS];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSError *error = nil;
        [self createStopRecordsWithStops:(NSArray*)JSON context:context];
        [context save:&error];
        [self createStops];
        [_delegate receivedStops];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [_delegate receivedStops];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (NSArray*)getFavouriteStops
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isFavourite == YES"];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    return fetchedObject;
}

- (NSArray*)getFavouriteRoutes
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isFavourite == YES"];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    return fetchedObject;
}

- (void)setFavourite:(BOOL)favourite forStop:(NSNumber*)code
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"code == %@",code];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    if ([fetchedObject count])
    {
        StopManagedObject *stop = [fetchedObject lastObject];
        stop.isFavourite = [NSNumber numberWithBool:favourite];
        [context save:nil];
    }
    fetchedObject = nil;
    context = nil;
}

- (void)setFavourite:(BOOL)favourite forRoute:(NSString *)shortName
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"shortName == %@",shortName];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    if ([fetchedObject count])
    {
        RouteManagedObject *route = [fetchedObject lastObject];
        route.isFavourite = [NSNumber numberWithBool:favourite];
        [context save:nil];
    }
    fetchedObject = nil;
    context = nil;
    shortName = nil;
}

- (StopManagedObject*)getStopForCode:(NSNumber*)code
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"code == %@",code];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    if ([fetchedObject count])
        return (StopManagedObject*)[fetchedObject lastObject];
    return nil;
}

- (void)getRouteForIdent:(NSNumber*)ident
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%i/%@", SANGSTERBASEURL, STOPTIME, [ident integerValue], [formatter stringFromDate:[NSDate date]]];
    [formatter release];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)JSON count]];
        for (NSDictionary *routeJSON in JSON)
        {
            RouteWithTime *route = [[RouteWithTime alloc] init];
            route.routeId = [routeJSON valueForKey:@"routeId"];
            route.shortName = [routeJSON valueForKey:@"shortName"];
            route.longName = [routeJSON valueForKey:@"longName"];
            NSMutableArray *timesArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)[routeJSON valueForKey:@"stopTimes"] count]];
            for (NSDictionary *timesJSON in [routeJSON valueForKey:@"stopTimes"])
            {
                StopTimes *times = [[StopTimes alloc] init];
                times.arrival = [timesJSON valueForKey:@"arrival"];
                times.departure = [timesJSON valueForKey:@"departure"];
                [timesArray addObject:times];
                [times release];
            }
            route.times = timesArray;
            [timesArray release];
            [array addObject:route];
            [route release];
        }
        [[StopDisplayViewController sharedInstance] setRoutes:array];
        [array release];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Content"
                                                     message:[NSString stringWithFormat:@"%@",error]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (void)getPathForRouteId:(NSString*)routeId
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%@/%@", SANGSTERBASEURL, PATHS, [formatter stringFromDate:[NSDate date]], routeId];
    [formatter release];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        Path *path = [[Path alloc] init];
        MKCoordinateRegion region = [path addLines:(NSArray*)JSON];
        if ([MapViewController sharedInstance].mapView) {
            [[MapViewController sharedInstance].mapView setRegion:region];
            [[MapViewController sharedInstance].mapView addOverlays:path.lines];
        }
        [path release];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Content"
                                                     message:[NSString stringWithFormat:@"%@",error]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
    }];
    [operation start];
    [url release];
    [contentUrl release];

}

- (void)loadPathForRoute:(NSString*)shortName
{
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:MM"];
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@/%@:%@/%@%@/%@", SANGSTERBASEURL, ROUTES, SHORTS, shortName, HEADSIGNS, [dayFormatter stringFromDate:[NSDate date]], [timeFormatter stringFromDate:[NSDate date]]];
    [dayFormatter release];
    [timeFormatter release];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if ([((NSArray*)JSON) count])
        {
            [self getPathForRouteId:[((NSDictionary*)[((NSArray*)JSON) firstObject]) valueForKey:@"routeId"]];
        } else {
            [[MapViewController sharedInstance] showRouteAlert];
        }
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Content"
                                                     message:@"To get the path the bus will travel requires internet access. Please ensure your internet is enabled."
                                                    delegate:nil
                                           cancelButtonTitle:@"Thanks"
                                           otherButtonTitles:nil];
        [av show];
        [av release];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (void)dealloc
{
    [_stops release];
    [super dealloc];
}
@end
