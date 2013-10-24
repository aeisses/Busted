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
        _routes = [stop.routes retain];
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
    }
    return self;
}

- (NSString*)subtitle
{
    NSTimeInterval lowestTime = -1;
    NSString *routeShortName = nil;
    NSString *routeLongName = nil;
    for (NSString *routeId in _routesId)
    {
        Route *route = [[WebApiInterface sharedInstance] getRouteForIdent:[NSString stringWithFormat:@"%@%@",_code,routeId]];
        for (NSNumber *trip in (NSArray*)route.times)
        {
            if([trip doubleValue] > 0)
            {
                double diffTime = [trip doubleValue] - [[NSDate date] timeIntervalSince1970];
//                NSLog(@"DiffTime: %f",diffTime);
//                NSLog(@"LowestTime: %f",lowestTime);
//                NSLog(@"Trip Time: %f",[trip doubleValue]);
//                NSLog(@"Current Time: %f",[[NSDate date] timeIntervalSince1970]);
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                [formatter setDateFormat:@"HH:mm"];
//                NSLog(@"TripTime: %@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[trip integerValue]]]);
//                NSLog(@"CurrentTime: %@",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]]]);
                if ((lowestTime == -1 || lowestTime > [trip doubleValue]) && diffTime > 0)
                {
                    lowestTime = [trip doubleValue];
                    if (routeShortName) {
                        [routeShortName release];
                    }
                    routeShortName = [[NSString alloc] initWithString:route.short_name];
                    routeLongName = [[NSString alloc] initWithString:route.long_name];
                }
            }
        }
    }
    if (routeShortName) {
        [routeShortName autorelease];
    }
    if (lowestTime == -1) {
        return [NSString stringWithFormat:@"Next Bus: %@",@"unknown"];
    }
    return [NSString stringWithFormat:@"Next Bus: %@ %@ - %i min",routeShortName,routeLongName,(int)((lowestTime - [[NSDate date] timeIntervalSince1970])/60)];
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
