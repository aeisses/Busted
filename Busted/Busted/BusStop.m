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

- (id)initWithCode:(NSNumber *)code andContext:(NSManagedObjectContext *)context
{
    if (self = [super init])
    {
        _code = [code copy];
        _managedObjectContext = [context retain];
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:_managedObjectContext];
        fetchRequest.entity = entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", _code];
        fetchRequest.predicate = predicate;
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchedObjects != nil && error == nil && [fetchedObjects count] == 1)
        {
            Stop *stop = (Stop*)[fetchedObjects objectAtIndex:0];
            _isFavorite = [stop.isFavorite boolValue];
            _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
            _title = [stop.name copy];
            _routes = [stop.routes retain];
            if ([_routes count] == 0)
            {
                [[WebApiInterface sharedInstance] requestStop:[_code integerValue]];
            }
        }
        else
        {
        }
    }
    return self;
}

- (NSString*)subtitle
{
    NSTimeInterval lowestTime = -1;
    NSString *routeShortName = nil;
    NSString *routeLongName = nil;
    for (Route *route in _routes)
    {
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
}

@end
