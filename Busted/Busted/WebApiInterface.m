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
    Stop *stop = [NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:context];
    stop.code = (NSString*)[stopJson valueForKey:@"code"];
    stop.lat = (NSNumber*)[stopJson valueForKey:@"lat"];
    stop.lng = (NSNumber*)[stopJson valueForKey:@"lng"];
    stop.name = (NSString*)[stopJson valueForKey:@"name"];

    NSArray *routes = (NSArray*)[stopJson valueForKey:@"routes"];
    NSMutableSet *routesSet = [[NSMutableSet alloc] init];
    for (NSDictionary *routeJson in routes)
    {
        Route *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        route.long_name = (NSString*)[routeJson valueForKey:@"long_name"];
        route.short_name = (NSString*)[routeJson valueForKey:@"short_name"];
        NSArray *trips = (NSArray*)[routeJson valueForKey:@"trips"];
        NSMutableSet *tripsSet = [[NSMutableSet alloc] init];
        for (NSDictionary *tripJson in trips)
        {
            Trip *trip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:context];
            trip.headsign = (NSString*)[tripJson valueForKey:@"headsign"];
            trip.time = (NSNumber*)[tripJson valueForKey:@"time"];
            trip.route = route;
            [tripsSet addObject:trip];
        }
        route.trips = (NSSet*)tripsSet;
        [tripsSet release];
        route.stop = stop;
        [routesSet addObject:route];
    }
    stop.routes = (NSSet*)routesSet;
    [routesSet release];
    return (NSNumber*)[stopJson valueForKey:@"code"];
}

- (void)createRoutesRecordWithRoute:(NSArray*)routesArray context:(NSManagedObjectContext*)context
{
    Routes *routes = [NSEntityDescription insertNewObjectForEntityForName:@"Routes" inManagedObjectContext:context];
//    routes.jsonString = nil;
    NSMutableSet *routesSet = [[NSMutableSet alloc] init];
    for (NSDictionary *routeItem in routesArray) {
        Route *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        route.long_name = (NSString*)[routeItem valueForKey:@"title"];
        route.short_name = [NSString stringWithFormat:@"%@",(NSNumber*)[routeItem valueForKey:@"busNumber"]];
        route.routes = routes;
        [routesSet addObject:route];
    }
    routes.route = (NSSet*)routesSet;
//    return routes;
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
    Routes *routes = (Routes*)[NSEntityDescription entityForName:@"Routes" inManagedObjectContext:context];
    if (routes) {
        
    }
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@", SANGSTERBASEURL];
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

- (void)requestStop:(NSInteger)stop
{
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%i%@%g%@", BASEURL, STOPS, stop, FILLER, (double)[[NSDate date] timeIntervalSince1970], ENDURL];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSManagedObjectContext *threadContext = [self createNewManagedObjectContext];
        NSDictionary *data = (NSDictionary *)JSON;
        BusStop *busStop = [[BusStop alloc] initWithCode:[self createStopRecordWithStop:data context:threadContext] andContext:threadContext];
        __block BusStop *blockBusStop = busStop;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MapViewController sharedInstance].mapView addAnnotation:blockBusStop];
        });
        [busStop release];
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
    NSString *contentUrl = [[NSString alloc] initWithFormat:@"%@%@%g,%g%@%g%@", BASEURL, PLACE, coordinate.latitude, coordinate.longitude, FILLER, (double)[[NSDate date] timeIntervalSince1970], ENDURL];
    NSURL *url = [[NSURL alloc] initWithString:contentUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSManagedObjectContext *threadContext = [self createNewManagedObjectContext];
        NSDictionary *data = (NSDictionary *)JSON;
        NSArray *codes = [self createStopRecordWithStops:(NSArray*)[data valueForKey:@"stops"] context:threadContext];
        for (NSNumber *code in codes) {
            BusStop *busStop = [[BusStop alloc] initWithCode:code andContext:threadContext];
            [_busStops addObject:busStop];
            [busStop release];
        }
        __block typeof(self) blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MapViewController sharedInstance].mapView addAnnotations:blockSelf.busStops];
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
    }];
    [operation start];
    [url release];
    [contentUrl release];
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
    } else {
        NSLog(@"Got an error: %@", error);
    }
}

- (void)dealloc
{
    [_busStops release];
    [super dealloc];
}
@end
