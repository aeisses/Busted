//
//  Path.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "Path.h"

@implementation Path

- (MKCoordinateRegion)addLines:(NSArray*)paths
{
    double minLat = 0;
    double minLng = 0;
    double maxLat = 0;
    double maxLng = 0;
    NSMutableArray *linesMutable = [NSMutableArray array];
    for (NSDictionary *path in paths)
    {
        NSArray *pathPoints = (NSArray*)[path valueForKey:@"pathPoints"];
        CLLocationCoordinate2D *line = malloc(sizeof(CLLocationCoordinate2D) * [pathPoints count]);
        int i = 0;
        for (NSDictionary *point in pathPoints)
        {
            line[i] = CLLocationCoordinate2DMake([[point valueForKey:@"lat"] doubleValue], [[point valueForKey:@"lng"] doubleValue]);
            if (minLat == 0 || [[point valueForKey:@"lat"] doubleValue] < minLat)
                minLat = [[point valueForKey:@"lat"] doubleValue];
            if (minLng == 0 || [[point valueForKey:@"lng"] doubleValue] < minLng)
                minLng = [[point valueForKey:@"lng"] doubleValue];
            if (maxLat == 0 || [[point valueForKey:@"lat"] doubleValue] > maxLat)
                maxLat = [[point valueForKey:@"lat"] doubleValue];
            if (maxLng == 0 || [[point valueForKey:@"lng"] doubleValue] > maxLng)
                maxLng = [[point valueForKey:@"lng"] doubleValue];
            i++;
        }
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:line count:[pathPoints count]];
        [linesMutable addObject:polyline];
        free(line);
    }
    _lines = [[NSArray alloc] initWithArray:linesMutable];
    return (MKCoordinateRegion){(maxLat+minLat)/2, (maxLng+minLng)/2, maxLat-minLat, maxLng-minLng};
}

- (void)dealloc
{
    if (_lines)
        [_lines release];
    [super dealloc];
}

@end
