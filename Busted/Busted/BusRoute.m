//
//  BusRoute.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-28.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusRoute.h"

@interface BusRoute (PrivateMethods)
- (void)parseRouteDescription;
@end;

@implementation BusRoute

- (id)initWithTitle:(NSString *)title description:(NSString*)description andGeometries:(KMLMultiGeometry*)geometries
{
    if (self = [super init])
    {
        _title = [title copy];
        NSMutableArray *linesMutable = [NSMutableArray array];
        for (int i=0; i<[geometries.geometries count]; i++) {
            if ([[geometries.geometries objectAtIndex:i] isKindOfClass:[KMLPoint class]]) {
            } else if ([[geometries.geometries objectAtIndex:i] isKindOfClass:[KMLLineString class]]) {
                NSArray *points = (NSArray *)(((KMLLineString *)[geometries.geometries objectAtIndex:i]).coordinates);
                CLLocationCoordinate2D *line = malloc(sizeof(CLLocationCoordinate2D) * [points count]);
                for (int j = 0; j < [points count]; j++) {
                    KMLCoordinate *point = (KMLCoordinate*)[points objectAtIndex:j];
                    line[j] = CLLocationCoordinate2DMake(point.latitude, point.longitude);
                }
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:line count:[points count]];
                polyline.title = @"Black";
                [linesMutable insertObject:polyline atIndex:[linesMutable count]];
                free(line);
            }
        }
        _lines = [[NSArray alloc] initWithArray:linesMutable];
        
        _description = [description copy];
        _routeTitle = nil;
        _startDate = nil;
        _revDate = nil;
        _socrateId = nil;
        [self parseRouteDescription];
    }
    return self;
}

- (id)initWithLines:(NSArray *)lines andTitle:(NSString *)title andNumber:(NSString*)number andDescription:(NSString*)description
{
    if (self = [super init])
    {
        _lines = [lines copy];
        _title = [title copy];
        _description = [description copy];
        _routeNum = [number integerValue];
        _routeTitle = nil;
        _startDate = nil;
        _revDate = nil;
        _socrateId = nil;
    }
    return self;
}

- (id)initWithLines:(NSArray *)lines andTitle:(NSString *)title
{
    if (self = [super init])
    {
        _lines = [lines copy];
        _title = [title copy];
        _description = nil;
        _routeTitle = nil;
        _startDate = nil;
        _revDate = nil;
        _socrateId = nil;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
        return true;
    if ([self class] != [object class])
        return false;
    BusRoute *other = (BusRoute*)object;
    if (self.routeNum == other.routeNum) {
        return true;
    }
    return false;
}

- (void)dealloc
{
    if (_title) [_title release];
    if (_lines) [_lines release];
    if (_description) [_description release];
    if (_routeTitle) [_routeTitle release];
//    if (_startDate) [_startDate release];
//    if (_revDate) [_revDate release];
    if (_socrateId) [_socrateId release];
    [super dealloc];
}

# pragma Private Methods
- (void)parseRouteDescription
{
    NSMutableString *temp = [[NSMutableString alloc] initWithString:_description];
    [temp replaceOccurrencesOfString:@"<ul class=\"textattributes\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<li><strong><span class=\"atr-name\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"</span>:</strong> <span class=\"atr-value\">" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"</span></li>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    
    NSArray *splitArray = [temp componentsSeparatedByString:@"\n"];
    [temp release];
    for (NSString *element in splitArray) {
        NSString *trimedElemet = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *thisArray = [trimedElemet componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([thisArray count] == 2) {
            if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"OBJECTID"]) {
                objectId = [(NSString *)([thisArray objectAtIndex:1]) integerValue];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"ROUTE_NUM"]) {
                _routeNum = [(NSString *)([thisArray objectAtIndex:1]) integerValue];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"CLASS"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"WEEKDAY LIMITED"]) {
                    classType = weekday_limited;
                }
/*                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSAC"]) {
                    fcode = trbsac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSNAC"]) {
                    fcode = trbssnac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBS"]) {
                    fcode = trbs;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSHAC"]) {
                    fcode = trbsshac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSH"]) {
                    fcode = trbssh;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRPR"]) {
                    fcode = trpr;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSTMAC"]) {
                    fcode = trbstmac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSTM"]) {
                    fcode = trbstm;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSHIN"]) {
                    fcode = trbsshin;
                }
 */
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"TITLE"]) {
                _routeTitle = [(NSString *)[thisArray objectAtIndex:1] retain];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"SOURCE"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRANSIT"]) {
                    source = transit;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"HASTUS"]) {
                    source = hastus;
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"SACC"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"DV"]) {
                    sacc = DV;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"IN"]) {
                    sacc = IN;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"XY"]) {
                    sacc = XY;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"GP"]) {
                    sacc = GP;
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"DATE_ACT"]) {
                if ([thisArray count] >= 6) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, YYYY hh:mm:ss a"];
                    _startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@%@%@%@",[thisArray objectAtIndex:1],[thisArray objectAtIndex:2],[thisArray objectAtIndex:3],[thisArray objectAtIndex:4],[thisArray objectAtIndex:5]]];
                    [formatter release];
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"DATE_REV"]) {
                if ([thisArray count] >= 6) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, YYYY hh:mm:ss a"];
                    _revDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@%@%@%@",[thisArray objectAtIndex:1],[thisArray objectAtIndex:2],[thisArray objectAtIndex:3],[thisArray objectAtIndex:4],[thisArray objectAtIndex:5]]];
                    [formatter release];
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"GOTIME"]) {
                shapeLen = [(NSString *)([thisArray objectAtIndex:1]) floatValue];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"LOCATION"]) {
                _socrateId = [(NSString *)[thisArray objectAtIndex:1] retain];
            }
        }
    }
}

@end
