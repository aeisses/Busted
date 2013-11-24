//
//  BusStop.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "StopAnnotation.h"
#import "WebApiInterface.h"

@implementation StopAnnotation

//- (id)initWithCode:(NSNumber *)code andContext:(NSManagedObjectContext *)context
- (id)initWithCode:(NSNumber *)code //andContext:(NSManagedObjectContext *)context
{
    if (self = [super init])
    {
        _code = [code copy];
        StopManagedObject *stop = [[WebApiInterface sharedInstance] getStopForCode:_code];
        _isFavourite = [stop.isFavourite boolValue];
        _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\w+" options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error)
        {
            NSArray *matches = [regexp matchesInString:stop.name options:0 range:NSMakeRange(0, [stop.name length])];
            NSMutableString *street = [[NSMutableString alloc] initWithString:@""];
            for (NSTextCheckingResult *match in matches)
            {
                NSRange matchRange = match.range;
                if ([[stop.name substringWithRange:matchRange] isEqualToString:@"in"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"before"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"after"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"opposite"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"after"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[southbound]"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[inbound]"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[northbound]"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[outbound]"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[westbound]"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"[eastbound]"]) {
                    break;
                } else {
                    [street appendString:[NSString stringWithFormat:@"%@ ",[stop.name substringWithRange:matchRange]]];
                }
            }
            _title = [[NSString alloc] initWithString:[[street stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] capitalizedString]];
            [street release];
            _longTitle = [stop.name copy];
        } else {
            _title = @"";
            _longTitle = @"";
        }
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

- (id)initWithStop:(StopManagedObject*)stop
{
    if (self = [super init])
    {
        _code = [stop.code copy];
        _isFavourite = [stop.isFavourite boolValue];
        _coordinate = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lng doubleValue]);
//        _title = [stop.name copy];
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\w+" options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error)
        {
            NSArray *matches = [regexp matchesInString:stop.name options:0 range:NSMakeRange(0, [stop.name length])];
            NSMutableString *street = [[NSMutableString alloc] initWithString:@""];
            for (NSTextCheckingResult *match in matches)
            {
                NSRange matchRange = match.range;
                if ([[stop.name substringWithRange:matchRange] isEqualToString:@"in"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"before"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"after"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"opposite"] ||
                    [[stop.name substringWithRange:matchRange] isEqualToString:@"after"]) {
                    break;
                } else {
                    [street appendString:[NSString stringWithFormat:@"%@ ",[stop.name substringWithRange:matchRange]]];
                }
            }
            _title = [[NSString alloc] initWithString:[[street stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] capitalizedString]];
            [street release];
            _longTitle = [[stop.name capitalizedString] copy];
        } else {
            _title = @"";
            _longTitle = @"";
        }
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
    [_longTitle release]; _longTitle = nil;
    [_code release]; _code = nil;
    [_managedObjectContext release]; _managedObjectContext = nil;
    [_routesId release]; _routesId = nil;
}

@end
