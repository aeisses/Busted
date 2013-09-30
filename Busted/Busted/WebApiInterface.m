//
//  WebApiInterface.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "WebApiInterface.h"

@interface WebApiInterface (PrivateMethods)
- (NSArray*)createStopRecordWithStops:(NSArray*)stops context:(NSManagedObjectContext*)context;
- (NSNumber*)createStopRecordWithStop:(NSDictionary*)stopJson context:(NSManagedObjectContext*)context;
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
        route.type = (NSNumber*)[routeJson valueForKey:@"type"];
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
        [[MapViewController sharedInstance].mapView addAnnotation:busStop];
        [busStop release];
//         [self createStopRecordWithStop:data context:threadContext]];
//        [_delegate stopLoaded:[self createStopRecordWithStop:data context:threadContext]];
//        NSLog(@"data: %@",data);
        /*
stops = ({
         code = 6963;
         lat = "44.635895";
         lng = "-63.569874";
         name = "Inglis & Barrington";
         "route_types" = (3);
         routes = ({
            "long_name" = Barrington;
            "short_name" = 9;
            times = (
                1380273960,
                1380275820,
                1380277320);
            trips = ({
                headsign = "Barrington to Mumford";
                time = 1380273960;
            },
            {
                headsign = "Barrington to Mumford";
                time = 1380275820;
            },
            {
                headsign = "Barrington to Mumford";
                time = 1380277320;
            });
            type = 3;
         });
});
data: {
         stops = ({
            code = 7410;
            lat = "44.641064";
            lng = "-63.598442";
            name = "Oxford & Jublilee";
            "route_types" = (3);
            routes = ({
                "long_name" = "Spring Garden";
                "short_name" = 1;
                times = (
                    1380339840,
                    1380359700,
                    1380360600
                );
                trips = ({
                    headsign = "Spring Garden to Mumford";
                    time = 1380339840;
                },{
                    headsign = "Spring Garden to Mumford";
                    time = 1380359700;
                },{
                    headsign = "Spring Garden to Mumford";
                    time = 1380360600;
                });
                type = 3;
            },{
                "long_name" = "Leiblin Park";
                "short_name" = 14;
                times = (
                    1380366540,
                    1380370140,
                    1380373740
                );
                trips = ({
                    headsign = "Leiblin Park";
                    time = 1380366540;
                },{
                    headsign = "Leiblin Park";
                    time = 1380370140;
                },{
                    headsign = "Leiblin Park";
                    time = 1380373740;
                });
                type = 3;
            });
         });
    }
         */
//        weakSelf.items = (NSArray *)[data objectForKey:@"results"];
//        weakSelf.title = @"JSON Retrieved";
        
//        NSManagedObjectContext *backgroundThreadContext = [strongSelf createNewManagedObjectContext];
//        NSLog(@"fetched %u items from the API", weakSelf.items.count);
        
//        for (NSDictionary *item in weakSelf.items) {
//            [weakSelf saveRawData:item];
        
//            NSLog(@"Saving %@ [%@] to CoreData", [item valueForKey:@"shortTitle"], [item valueForKey:@"datePosted"]);
        
//            [strongSelf createContentRecordWithItem:item context:backgroundThreadContext];
        
//            NSError *error;
//            if (![backgroundThreadContext save:&error]) {
//                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//            }
//        }
                                                        
        // Does not appear we need to do this thanks to NSFetchedResultsControllerDelegate methods
        //                                                        [self.tableView reloadData];
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
        [[MapViewController sharedInstance].mapView addAnnotations:_busStops];
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
    
    /*
{
     "location":
     {
        "lat": 44.638507843017578, "lng": -63.568782806396484
     },
     "stops":
     [{
        "distance": 73.192516697677064,
        "code": "6938",
        "name": "Hollis & Barrington", "routes":
        [{
            "long_name": "Parkland Express", "type": 3, "trips": [], "short_name": "35", "times": []
        }],
        "lat": 44.639136999999998, "lng": -63.569054000000001, "route_types": [3]
     }, {
        "distance": 93.09438128536047, "code": "7092", "name": "Barrington & Hollis", "routes":
        [{
            "long_name": "Barrington", "type": 3, "trips":
            [{
                "headsign": "Barrington to Mumford", "time": 1380146760
            }, {
                "headsign": "Barrington to Mumford", "time": 1380150360
            }, {
                "headsign": "Barrington to Mumford", "time": 1380153900
            }],
            "short_name": "9",
            "times": [1380146760, 1380150360, 1380153900]
        }],
        "lat": 44.638882000000002, "lng": -63.569836000000002, "route_types": [3]
     }, {
        "distance": 94.492658692744115, "code": "6112", "name": "Barrington & Kent", "routes":
        [{
            "long_name": "Barrington",
            "type": 3, "trips":
            [{
                "headsign": "Barrington to Point Pleasant", "time": 1380149340
            }, {
                "headsign": "Barrington to Tower Rd Loop", "time": 1380153000
            }, {
                "headsign": "Barrington to Tower Rd Loop", "time": 1380156360
            }],
            "short_name": "9",
            "times": [1380149340, 1380153000, 1380156360]
        }], 
        "lat": 44.638660000000002, "lng": -63.569958, "route_types": [3]
    }, {
        "distance": 111.55374734676141, "code": "6093", "name": "Barrington & Green", "routes":
        [{
            "long_name": "Barrington", "type": 3, "trips":
            [{
                "headsign": "Barrington to Mumford", "time": 1380146700
            }, {
                "headsign": "Barrington to Mumford", "time": 1380150300
            }, {
                "headsign": "Barrington to Mumford", "time": 1380153900
            }],
            "short_name": "9", "times": [1380146700, 1380150300, 1380153900]
        }],
        "lat": 44.637732999999997, "lng": -63.569679000000001, "route_types": [3]}, {"distance": 154.03923225645684, "code": "6092", "name": "Barrington & Green", "routes": [{"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Point Pleasant", "time": 1380149340}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380153060}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380156360}], "short_name": "9", "times": [1380149340, 1380153060, 1380156360]}], "lat": 44.637306000000002, "lng": -63.569752000000001, "route_types": [3]}, {"distance": 229.74170390661939, "code": "6096", "name": "Barrington & South", "routes": [{"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [{"headsign": "Dartmouth", "time": 1380145980}, {"headsign": "Dartmouth", "time": 1380147180}], "short_name": "41", "times": [1380145980, 1380147180]}, {"long_name": "Robie", "type": 3, "trips": [{"headsign": "Gottingen", "time": 1380146580}, {"headsign": "Gottingen", "time": 1380147780}, {"headsign": "Gottingen", "time": 1380148980}], "short_name": "7", "times": [1380146580, 1380147780, 1380148980]}, {"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Mumford", "time": 1380146760}, {"headsign": "Barrington to Mumford", "time": 1380150360}, {"headsign": "Barrington to Mumford", "time": 1380153900}], "short_name": "9", "times": [1380146760, 1380150360, 1380153900]}, {"long_name": "Parkland Express", "type": 3, "trips": [], "short_name": "35", "times": []}], "lat": 44.640202000000002, "lng": -63.570445999999997, "route_types": [3]}, {"distance": 232.82070843899871, "code": "6097", "name": "Barrington & South", "routes": [{"long_name": "Robie", "type": 3, "trips": [{"headsign": "Robie", "time": 1380146460}, {"headsign": "Robie", "time": 1380147660}, {"headsign": "Robie", "time": 1380148860}], "short_name": "7", "times": [1380146460, 1380147660, 1380148860]}, {"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Point Pleasant", "time": 1380149280}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380153000}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380156300}], "short_name": "9", "times": [1380149280, 1380153000, 1380156300]}, {"long_name": "Parkland Express", "type": 3, "trips": [], "short_name": "35", "times": []}, {"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [], "short_name": "41", "times": []}], "lat": 44.640141, "lng": -63.570625, "route_types": [3]}, {"distance": 237.76792031395351, "code": "8818", "name": "Near 1113 Harbour Walk South", "routes": [{"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.639671, "lng": -63.566260999999997, "route_types": [3]}, {"distance": 244.42779176484501, "code": "6111", "name": "Barrington & Inglis", "routes": [{"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Point Pleasant", "time": 1380149340}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380153060}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380156420}], "short_name": "9", "times": [1380149340, 1380153060, 1380156420]}], "lat": 44.636391000000003, "lng": -63.569614000000001, "route_types": [3]}, {"distance": 253.15227950420342, "code": "8817", "name": "Cunard Centre", "routes": [{"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.637959000000002, "lng": -63.565677999999998, "route_types": [3]}, {"distance": 253.48769782961321, "code": "8827", "name": "Terminal & And Opposite Lower Water", "routes": [{"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.640780999999997, "lng": -63.568545999999998, "route_types": [3]}, {"distance": 258.46418172495356, "code": "8293", "name": "Near 5244 South St", "routes": [{"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [{"headsign": "Dartmouth", "time": 1380145980}, {"headsign": "Dartmouth", "time": 1380147180}], "short_name": "41", "times": [1380145980, 1380147180]}, {"long_name": "Robie", "type": 3, "trips": [{"headsign": "Gottingen", "time": 1380146580}, {"headsign": "Gottingen", "time": 1380147780}, {"headsign": "Gottingen", "time": 1380148980}], "short_name": "7", "times": [1380146580, 1380147780, 1380148980]}], "lat": 44.639645000000002, "lng": -63.571632000000001, "route_types": [3]}, {"distance": 303.09723237118817, "code": "6963", "name": "Inglis & Barrington", "routes": [{"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Mumford", "time": 1380146700}, {"headsign": "Barrington to Mumford", "time": 1380150300}, {"headsign": "Barrington to Mumford", "time": 1380153840}], "short_name": "9", "times": [1380146700, 1380150300, 1380153840]}], "lat": 44.635894999999998, "lng": -63.569873999999999, "route_types": [3]}, {"distance": 325.30072885628249, "code": "8294", "name": "Near 5283 South St", "routes": [{"long_name": "Robie", "type": 3, "trips": [{"headsign": "Robie", "time": 1380146460}, {"headsign": "Robie", "time": 1380147660}, {"headsign": "Robie", "time": 1380148860}], "short_name": "7", "times": [1380146460, 1380147660, 1380148860]}, {"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [], "short_name": "41", "times": []}], "lat": 44.639468999999998, "lng": -63.572665999999998, "route_types": [3]}, {"distance": 354.48555926534067, "code": "8814", "name": "Lower Water After Terminal Rd", "routes": [{"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.641677999999999, "lng": -63.568306, "route_types": [3]}, {"distance": 392.45663721564131, "code": "6113", "name": "Barrington & Morris", "routes": [{"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [{"headsign": "Dartmouth", "time": 1380146040}, {"headsign": "Dartmouth", "time": 1380147240}], "short_name": "41", "times": [1380146040, 1380147240]}, {"long_name": "Robie", "type": 3, "trips": [{"headsign": "Gottingen", "time": 1380146640}, {"headsign": "Gottingen", "time": 1380147840}, {"headsign": "Gottingen", "time": 1380149040}], "short_name": "7", "times": [1380146640, 1380147840, 1380149040]}, {"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Mumford", "time": 1380146820}, {"headsign": "Barrington to Mumford", "time": 1380150420}, {"headsign": "Barrington to Mumford", "time": 1380153960}], "short_name": "9", "times": [1380146820, 1380150420, 1380153960]}], "lat": 44.641601999999999, "lng": -63.571171, "route_types": [3]}, {"distance": 430.23093053904307, "code": "8299", "name": "South & Queen", "routes": [{"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [{"headsign": "Dartmouth", "time": 1380145920}, {"headsign": "Dartmouth", "time": 1380147120}], "short_name": "41", "times": [1380145920, 1380147120]}, {"long_name": "Robie", "type": 3, "trips": [{"headsign": "Gottingen", "time": 1380146520}, {"headsign": "Gottingen", "time": 1380147720}, {"headsign": "Gottingen", "time": 1380148920}], "short_name": "7", "times": [1380146520, 1380147720, 1380148920]}], "lat": 44.638905000000001, "lng": -63.574191999999996, "route_types": [3]}, {"distance": 432.78504649402316, "code": "6114", "name": "Barrington & Morris", "routes": [{"long_name": "Robie", "type": 3, "trips": [{"headsign": "Robie", "time": 1380146400}, {"headsign": "Robie", "time": 1380147600}, {"headsign": "Robie", "time": 1380148800}], "short_name": "7", "times": [1380146400, 1380147600, 1380148800]}, {"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Point Pleasant", "time": 1380149280}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380152940}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380156300}], "short_name": "9", "times": [1380149280, 1380152940, 1380156300]}, {"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [], "short_name": "41", "times": []}], "lat": 44.641871999999999, "lng": -63.571533000000002, "route_types": [3]}, {"distance": 442.33898603518486, "code": "8292", "name": "South & Queen", "routes": [{"long_name": "Robie", "type": 3, "trips": [{"headsign": "Robie", "time": 1380146520}, {"headsign": "Robie", "time": 1380147720}, {"headsign": "Robie", "time": 1380148920}], "short_name": "7", "times": [1380146520, 1380147720, 1380148920]}, {"long_name": "Dartmouth - Dalhousie", "type": 3, "trips": [], "short_name": "41", "times": []}], "lat": 44.639068999999999, "lng": -63.574317999999998, "route_types": [3]}, {"distance": 443.20271860716207, "code": "8885", "name": "Morris St In Front Of O'brien Hall", "routes": [{"long_name": "Larry Uteck", "type": 3, "trips": [{"headsign": "Larry Uteck via Bedford Hwy", "time": 1380147780}, {"headsign": "Larry Uteck via Bedford Hwy", "time": 1380151380}, {"headsign": "Larry Uteck via Bedford Hwy", "time": 1380154980}], "short_name": "90", "times": [1380147780, 1380151380, 1380154980]}], "lat": 44.641463999999999, "lng": -63.572539999999996, "route_types": [3]}, {"distance": 444.56768588422125, "code": "8884", "name": "Near 5234 Morris St", "routes": [{"long_name": "Larry Uteck", "type": 3, "trips": [{"headsign": "Water St Term'l via University Av", "time": 1380148560}, {"headsign": "Water St Term'l via University Av", "time": 1380152160}, {"headsign": "Water St Term'l via University Av", "time": 1380155760}], "short_name": "90", "times": [1380148560, 1380152160, 1380155760]}], "lat": 44.641224000000001, "lng": -63.572906000000003, "route_types": [3]}, {"distance": 469.58606405446682, "code": "8819", "name": "Lower Water St In Front Of 1475", "routes": [{"long_name": "Larry Uteck", "type": 3, "trips": [{"headsign": "Water St Term'l via University Av", "time": 1380148620}, {"headsign": "Water St Term'l via University Av", "time": 1380152220}, {"headsign": "Water St Term'l via University Av", "time": 1380155820}], "short_name": "90", "times": [1380148620, 1380152220, 1380155820]}, {"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.642730999999998, "lng": -63.568866999999997, "route_types": [3]}, {"distance": 480.06485466271994, "code": "8825", "name": "Near 1332 Hollis St", "routes": [{"long_name": "Larry Uteck", "type": 3, "trips": [{"headsign": "Larry Uteck via Bedford Hwy", "time": 1380147780}, {"headsign": "Larry Uteck via Bedford Hwy", "time": 1380151380}, {"headsign": "Larry Uteck via Bedford Hwy", "time": 1380154980}], "short_name": "90", "times": [1380147780, 1380151380, 1380154980]}, {"long_name": "Waterfront", "type": 3, "trips": [], "short_name": "8", "times": []}], "lat": 44.642651000000001, "lng": -63.570492000000002, "route_types": [3]}, {"distance": 484.61395054250102, "code": "6972", "name": "Inglis & South Bland", "routes": [{"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Point Pleasant", "time": 1380149400}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380153180}, {"headsign": "Barrington to Tower Rd Loop", "time": 1380156420}], "short_name": "9", "times": [1380149400, 1380153180, 1380156420]}], "lat": 44.635207999999999, "lng": -63.572783999999999, "route_types": [3]}, {"distance": 495.42910387779187, "code": "6967", "name": "Inglis & South Bland", "routes": [{"long_name": "Barrington", "type": 3, "trips": [{"headsign": "Barrington to Mumford", "time": 1380146640}, {"headsign": "Barrington to Mumford", "time": 1380150240}, {"headsign": "Barrington to Mumford", "time": 1380153780}], "short_name": "9", "times": [1380146640, 1380150240, 1380153780]}], "lat": 44.635078, "lng": -63.572780999999999, "route_types": [3]}]}
     */
}

- (void)dealloc
{
    [_busStops release];
    [super dealloc];
}
@end
