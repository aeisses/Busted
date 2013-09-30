//
//  BusStop.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusStop.h"
#import "Stop.h"

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
        if (fetchedObjects != nil && error == nil && [fetchedObjects count] == 1)
        {
            Stop *stop = (Stop*)[fetchedObjects objectAtIndex:0];
            _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
            _title = [stop.name copy];
        }
        else
        {
            if (error != nil) {
                
            }
            else if (fetchedObjects == nil)
            {
                
            }
            else if ([fetchedObjects count] != 1)
            {
                
           }
        }
        [fetchRequest release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [_title release]; _title = nil;
    [_code release]; _code = nil;
    [_managedObjectContext release]; _managedObjectContext = nil;
}

@end
