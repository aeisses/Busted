//
//  WebApiInterface.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "WebApiInterface.h"

static NSString *const JSONDirectoryPath = @"/RawJson";

@interface WebApiInterface (PrivateMethods)
- (NSArray*)createStopRecordWithStops:(NSArray*)stops context:(NSManagedObjectContext*)context;
- (NSNumber*)createStopRecordWithStop:(NSDictionary*)stopJson context:(NSManagedObjectContext*)context;
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
        _busStops = [[NSMutableArray alloc] initWithCapacity:0];

        // Initialize dateFormatter
//        _dateFormatter = [[NSDateFormatter alloc] init];
//        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
        
/*
        NSError *error;
        // Create json document directory if it doesn't already exist
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:JSONDirectoryPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
 */
    }
    instance = self;
    return instance;
}

- (NSArray*)createStopRecordWithStops:(NSArray*)stops context:(NSManagedObjectContext*)context
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[stops count]];
    for (NSDictionary *stop in stops)
    {
        [returnArray addObject:[self createStopRecordWithStop:stop context:context]];
    }
    return [(NSArray*)returnArray autorelease];
}

- (NSNumber*)createStopRecordWithStop:(NSDictionary*)stopJson context:(NSManagedObjectContext*)context
{
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"code == %@",[stopJson valueForKey:@"code"]];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    Stop *stop = nil;
    if ([fetchedObject count] > 0)
    {
        stop = [fetchedObject lastObject];
    }
    else
    {
        stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
    }
    stop.code = (NSString*)[stopJson valueForKey:@"code"];
    stop.lat = (NSNumber*)[stopJson valueForKey:@"lat"];
    stop.lng = (NSNumber*)[stopJson valueForKey:@"lng"];
    stop.name = (NSString*)[stopJson valueForKey:@"name"];
    stop.isFavorite = (NSNumber*)[stopJson valueForKey:@"isFavorite"];

    NSArray *routes = (NSArray*)[stopJson valueForKey:@"routes"];
    NSMutableSet *routesSet = [[NSMutableSet alloc] init];
    for (NSDictionary *routeJson in routes)
    {
        NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = myEntity;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"short_name == %@",[routeJson valueForKey:@"short_name"]];
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
        [fetchRequest release];
        Route *route = nil;
        if ([fetchedObject count])
        {
            route = [fetchedObject lastObject];
        }
        else
        {
            route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        }
        route.long_name = (NSString*)[routeJson valueForKey:@"long_name"];
        route.short_name = (NSString*)[routeJson valueForKey:@"short_name"];
//        route.headsign = (NSString*)[routeJson valueForKey:@"headsign"];
        route.times = (NSArray*)[routeJson valueForKey:@"times"];
        route.isFavorite = (NSNumber*)[routeJson valueForKey:@"isFavorite"];

/*        NSArray *trips = (NSArray*)[routeJson valueForKey:@"trips"];
        NSMutableSet *tripsSet = [[NSMutableSet alloc] init];
        for (NSDictionary *tripJson in trips)
        {
            NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:context];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = myEntity;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"headsign == %@",[tripJson valueForKey:@"headsign"]];
            NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
            [fetchRequest release];
            Trip *trip = nil;
            if ([fetchedObject count] > 0)
            {
                trip = [fetchedObject lastObject];
            }
            else
            {
                trip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:context];
            }
            trip.headsign = (NSString*)[tripJson valueForKey:@"headsign"];
            trip.time = (NSNumber*)[tripJson valueForKey:@"time"];
            trip.route = route;
            [tripsSet addObject:trip];
        }
        route.trips = (NSSet*)tripsSet;
        [tripsSet release];
 */
        route.stop = stop;
        [routesSet addObject:route];
    }
    stop.routes = (NSSet*)routesSet;
    [routesSet release];
    [context save:nil];
    return (NSNumber*)[stopJson valueForKey:@"code"];
}

- (void)createRoutesRecordWithRoute:(NSArray*)routesArray context:(NSManagedObjectContext*)context
{
    Routes *routes = nil;
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Routes" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    if ([fetchedObject count] > 0)
    {
        routes = (Routes*)[fetchedObject lastObject];
    }
    else
    {
        routes = (Routes*)[NSEntityDescription insertNewObjectForEntityForName:@"Routes" inManagedObjectContext:context];
    }
//    routes.jsonString = nil;
    NSMutableSet *routesSet = [[NSMutableSet alloc] init];
    int counter = 1;
    for (NSDictionary *routeItem in routesArray)
    {
        Route *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        route.long_name = (NSString*)[routeItem valueForKey:@"longName"];
        route.short_name = [routeItem valueForKey:@"shortName"] ? [routeItem valueForKey:@"shortName"] : [NSString stringWithFormat:@"%i",counter];
        route.ident = (NSString*)[routeItem valueForKey:@"id"];
        route.type = (NSNumber*)[routeItem objectForKey:@"type"];
        route.routes = routes;
        [routesSet addObject:route];
        counter++;
    }
    routes.route = (NSSet*)routesSet;
    [routesSet release];
    [context save:nil];
}

- (void)createStopRecordsWithStops:(NSArray*)stopsArray context:(NSManagedObjectContext*)context
{
    for (NSDictionary *stopItem in stopsArray)
    {
        Stop *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
        stop.code = [NSString stringWithFormat:@"%@",[stopItem valueForKey:@"id"]];
        stop.name = [stopItem valueForKey:@"name"];
        NSDictionary *location = [stopItem valueForKey:@"location"];
        stop.lat = [location valueForKey:@"lat"];
        stop.lng = [location valueForKey:@"lng"];
    }
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes" inManagedObjectContext:context];
    if (entity)
    {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObject.count > 0)
        {
            Routes *routes = fetchedObject[0];
            return [routes.route allObjects];
        }
    }
    return nil;
}

- (void)fetchAllRoutes
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes" inManagedObjectContext:context];
    if (entity) {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = entity;
        NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObject.count > 0)
        {
            [_delegate receivedRoutes];
            return;
        }
    }
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@", SANGSTERBASEURL, ROUTES];
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
        [_delegate receivedRoutes];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [_delegate receivedStops];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (void)requestStop:(NSInteger)stop
{
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%i%@%f%@", BASEURL, STOP, stop, FILLER, (double)[[NSDate date] timeIntervalSince1970], ENDURL];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSManagedObjectContext *context = [self createNewManagedObjectContext];
        NSDictionary *data = [[(NSDictionary *)JSON valueForKey:@"stops"] objectAtIndex:0];
        int counter = 0;
        for (BusStop *stop in [NSArray arrayWithArray:_busStops])
        {
            if ([[data valueForKey:@"code"] integerValue] == [stop.code integerValue])
            {
                BusStop *busStop = [[BusStop alloc] initWithCode:[self createStopRecordWithStop:data context:context] andContext:context];
                [[MapViewController sharedInstance].mapView removeAnnotation:stop];
                [[MapViewController sharedInstance].mapView addAnnotation:busStop];
                [_busStops replaceObjectAtIndex:counter withObject:busStop];
                [busStop release];
            }
            counter++;
        }
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Content"
                                                     message:[NSString stringWithFormat:@"%@",error]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }];
    [operation start];
    [url release];
    [contentUrl release];
}

- (void)requestPlace:(CLLocationCoordinate2D)coordinate
{
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%f,%f%@%f%@", BASEURL, PLACE, coordinate.latitude, coordinate.longitude, FILLER,[[NSDate date] timeIntervalSince1970], ENDURL];
    NSLog(@"ContentURl: %@",contentUrl);
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSManagedObjectContext *threadContext = [self createNewManagedObjectContext];
        NSLog(@"JSON: %@",JSON);
        NSDictionary *data = (NSDictionary *)JSON;
        NSArray *codes = [self createStopRecordWithStops:(NSArray*)[data valueForKey:@"stops"] context:threadContext];
        for (NSNumber *code in codes) {
            BusStop *busStop = [[BusStop alloc] initWithCode:code andContext:threadContext];
            [_busStops addObject:busStop];
            [busStop release];
        }
        __block typeof(self) blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MapViewController sharedInstance] addStops:blockSelf.busStops];
//            [[MapViewController sharedInstance].mapView addAnnotations:blockSelf.busStops];
        });
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

- (void)requestStopsForRegion:(MKCoordinateRegion)region
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
//    NSMutableArray *busStops = [[NSMutableArray alloc] initWithCapacity:0];
    for (Stop *stop in fetchedObject)
    {
        CLLocationCoordinate2D northWestCorner, southEastCorner;
        northWestCorner.latitude = region.center.latitude - (region.span.latitudeDelta / 2.0);
        northWestCorner.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
        southEastCorner.latitude = region.center.latitude + (region.span.latitudeDelta / 2.0);
        southEastCorner.longitude = region.center.longitude + (region.span.longitudeDelta / 2.0);
        if ([stop.lat doubleValue] >= northWestCorner.latitude &&
            [stop.lat doubleValue] <= southEastCorner.latitude &&
            [stop.lng doubleValue] >= northWestCorner.longitude &&
            [stop.lng doubleValue] <= southEastCorner.longitude)
        {
            BusStop *busStop = [[BusStop alloc] initWithCode:[NSNumber numberWithInteger:[stop.code integerValue]] andContext:context];
            [_busStops addObject:busStop];
            __block typeof(BusStop) *blockBusStop = busStop;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MapViewController sharedInstance] addStop:blockBusStop];
            });
            [busStop release];
        }
    }
}

- (void)saveRawData:(NSDictionary *)item {
    NSLog(@"Saving raw data");
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (jsonData) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:JSONDirectoryPath];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath, [item valueForKey:@"id"]];
        BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                                   contents:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 attributes:nil];
        if (!fileCreated) {
            NSLog(@"Could not create file '%@'", filePath);
        }
        [jsonString release];
    } else {
        NSLog(@"Got an error: %@", error);
    }
}

- (NSArray*)getFavoriteStops
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    return fetchedObject;
}

- (NSArray*)getFavoriteRoutes
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    return fetchedObject;
}

- (void)setFavorite:(BOOL)favorite forStop:(NSNumber*)code
{
    NSManagedObjectContext *context = [self createNewManagedObjectContext];
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = myEntity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"code == %@",code];
    NSArray *fetchedObject = [context executeFetchRequest:fetchRequest error:nil];
    if ([fetchedObject count])
    {
        Stop *stop = [fetchedObject lastObject];
        stop.isFavorite = [NSNumber numberWithBool:favorite];
        [context save:nil];
    }
}

- (void)dealloc
{
    [_busStops release];
    [super dealloc];
}
@end
