//
//  BusStop.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusStop.h"
#import "Stop.h"
#import "Trip.h"

@implementation BusStop

//- (id)initWithCode:(NSNumber *)code andContext:(NSManagedObjectContext *)context
- (id)initWithCode:(NSNumber *)code //andContext:(NSManagedObjectContext *)context
{
    if (self = [super init])
    {
        _code = [code copy];
        Stop *stop = [[WebApiInterface sharedInstance] getStopForCode:_code];
        _isFavorite = [stop.isFavorite boolValue];
        _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
        _title = [stop.name copy];
/*        _routes = [stop.routes retain];
        if ([stop.routes count] == 0)
        {
            [[WebApiInterface sharedInstance] requestStop:[_code integerValue]];
        } else {
            NSMutableArray *tempRoutes = [[NSMutableArray alloc] initWithCapacity:[stop.routes count]];
            for (Route *route in stop.routes)
            {
                [tempRoutes addObject:route.short_name];
            }
            _routesId = [[NSArray alloc] initWithArray:tempRoutes];
            [tempRoutes release];
        }
 */
    }
    return self;
}

- (id)initWithStop:(Stop*)stop
{
    if (self = [super init])
    {
        _code = [stop.code copy];
        _isFavorite = [stop.isFavorite boolValue];
        _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
        _title = [stop.name copy];
    }
    return self;
}

- (BOOL)isInsideSquare:(MKCoordinateRegion)region
{
    double lowBoundsLat = region.center.latitude - region.span.latitudeDelta/2;
    double lowBoundsLng = region.center.longitude - region.span.longitudeDelta/2;
    double highBoundsLat = region.center.latitude + region.span.latitudeDelta/2;
    double highBoundsLng = region.center.longitude + region.span.longitudeDelta/2;
    if (_coordinate.latitude < lowBoundsLat || _coordinate.latitude > highBoundsLat || _coordinate.longitude < lowBoundsLng || _coordinate.longitude > highBoundsLng)
    {
        return NO;
    }
    return YES;
}

- (NSString*)subtitle
{
    return [NSString stringWithFormat:@"GoTime: %@",_code];
}

- (void)dealloc
{
    [super dealloc];
    [_title release]; _title = nil;
    [_code release]; _code = nil;
    [_managedObjectContext release]; _managedObjectContext = nil;
    [_routesId release]; _routesId = nil;
}

@end
