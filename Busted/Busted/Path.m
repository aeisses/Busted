//
//  Path.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "Path.h"
#import <MapKit/MapKit.h>

@implementation Path

- (void)addLines:(NSArray*)paths
{
    NSMutableArray *linesMutable = [NSMutableArray array];
    for (NSDictionary *path in paths)
    {
        NSArray *pathPoints = (NSArray*)[path valueForKey:@"pathPoints"];
        CLLocationCoordinate2D *line = malloc(sizeof(CLLocationCoordinate2D) * [pathPoints count]);
        int i = 0;
        for (NSDictionary *point in pathPoints)
        {
            line[i] = CLLocationCoordinate2DMake([[point valueForKey:@"lat"] doubleValue], [[point valueForKey:@"lng"] doubleValue]);
            i++;
        }
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:line count:[pathPoints count]];
        [linesMutable addObject:polyline];
        free(line);
    }
    _lines = [[NSArray alloc] initWithArray:linesMutable];
}

- (void)dealloc
{
    if (_lines)
        [_lines release];
    [super dealloc];
}

@end
