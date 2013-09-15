//
//  DataReader.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-22.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//
#import "DataReader.h"

#define KMLBUSSTOPSURL @"https://www.halifaxopendata.ca/api/geospatial/xus8-fjzt?method=export&format=KML"
#define KMLBUSROUTEURL @"https://www.halifaxopendata.ca/api/geospatial/y3cf-ivzs?method=export&format=KML"
#define ESERVICENUMBER @"http://eservices.halifax.ca/GoTime/index.jsf?goTime="

@interface DataReader (PrivateMethods)
- (void)loadStopDataAndShow:(BOOL)show withSet:(NSSet*)set;
- (void)loadTerminalDataAndShow:(BOOL)show withSet:(NSSet*)set;
- (void)loadRouteDataAndShow:(BOOL)show;
- (NSArray*)removeRoute:(NSNumber*)number FromBusRoutes:(NSMutableArray*)array;
@end;

@implementation DataReader

- (id)init
{
    if (self = [super init])
    {
        stopsUrl = [[NSURL alloc] initWithString:KMLBUSSTOPSURL];
        routesUrl = [[NSURL alloc] initWithString:KMLBUSROUTEURL];
    }
    return self;
}

- (void)loadKMLData
{
    [_delegate startProgressIndicator];
//    [self loadStopDataAndShow:NO withSet:[NSSet set]];
    [self loadRouteDataAndShow:NO];
    [_delegate endProgressIndicator];
}

- (void)showBusStopsWithValue:(NSSet*)set
{
    [_delegate startProgressIndicator];
    [self loadStopDataAndShow:YES withSet:set];
    [_delegate endProgressIndicator];
}

- (void)showTerminalsWithValue:(NSSet*)set
{
    [_delegate startProgressIndicator];
    [self loadTerminalDataAndShow:YES withSet:set];
    [_delegate endProgressIndicator];
}

- (void)showRoutes
{
    [_delegate startProgressIndicator];
    [self loadRouteDataAndShow:YES];
    [_delegate endProgressIndicator];
}

- (void)pruneRoutesMetroX:(BOOL)metroX andMetroLink:(BOOL)metroLink andExpressRoute:(BOOL)expressRoute
{
    [_delegate startProgressIndicator];
    NSMutableArray *stops = [[NSMutableArray alloc] initWithArray:_stops];
    for (BusStop *busStop in _stops) {
        BOOL removed = NO;
        if ([busStop.routes count] == 1) {
            if (metroX) {
                if ([[busStop.routes objectAtIndex:0] intValue] == 320 || [[busStop.routes objectAtIndex:0] intValue] == 330) {
                    [stops removeObject:busStop];
                    removed = YES;
                }
            }
            if (metroLink) {
                if ([[busStop.routes objectAtIndex:0] intValue] == 159 || [[busStop.routes objectAtIndex:0] intValue] == 165 || [[busStop.routes objectAtIndex:0] intValue] == 185) {
                    [stops removeObject:busStop];
                    removed = YES;
                }
            }
            if (expressRoute) {
                if ([[busStop.routes objectAtIndex:0] intValue] == 31 || [[busStop.routes objectAtIndex:0] intValue] == 32 || [[busStop.routes objectAtIndex:0] intValue] == 33 || [[busStop.routes objectAtIndex:0] intValue] == 34 || [[busStop.routes objectAtIndex:0] intValue] == 35) {
                    [stops removeObject:busStop];
                    removed = YES;
                }
            }
        } else if ([busStop.routes count] >= 1) {
            if (metroX) {
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:320] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:330] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
            }
            if (metroLink) {
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:159] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:165] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:185] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
            }
            if (expressRoute) {
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:31] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:32] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:33] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:34] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                busStop.routes = [self removeRoute:[NSNumber numberWithInt:35] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
            }
        }
        if (!removed)
            [_delegate addBusStop:busStop];
    }
    _stops = stops;
    [stops release];
    [_delegate endProgressIndicator];
}

- (void)dealloc
{
    [super dealloc];
    [_stops release];
    [_routes release];
    [stopsUrl release];
    [routesUrl release];
    _delegate = nil;
}

#pragma Private Methods
- (void)loadStopDataAndShow:(BOOL)show withSet:(NSSet*)set
{
    NSDictionary *dictonary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"plist"]];
    if (_stops != nil && show) {
        for (BusStop *busStop in _stops) {
            if (show && ([set anyObject] == nil || [set containsObject:[NSNumber numberWithInteger:[busStop.routes count]]]))
                [_delegate addBusStop:busStop];
        }
    } else if (_stops == nil) {
        KMLRoot *kmlStops = [KMLParser parseKMLAtURL:stopsUrl];
        if (kmlStops == nil)
            kmlStops = [KMLParser parseKMLAtPath:[[NSBundle mainBundle] pathForResource:@"Bus Stops" ofType:@"kml"]];
        NSMutableArray *mutableStops = [[NSMutableArray alloc] initWithCapacity:0];
        for (KMLPlacemark *placemark in kmlStops.placemarks) {
            if (placemark.geometry && placemark.name) {
                BusStop *busStop = [[BusStop alloc] initWithTitle:placemark.name description:placemark.descriptionValue andLocation:(KMLPoint *)placemark.geometry];
                busStop.routes = (NSArray*)[dictonary objectForKey:[NSString stringWithFormat:@"%i",busStop.goTime]];
                if (!([busStop.routes count] == 1 && ([[busStop.routes objectAtIndex:0] intValue] == 400 || [[busStop.routes objectAtIndex:0] intValue] == 401 || [[busStop.routes objectAtIndex:0] intValue] == 402))) {
                    if (!([busStop.routes count] == 0)) {
                        if ([busStop.routes count] >= 1) {
                            busStop.routes = [self removeRoute:[NSNumber numberWithInt:400] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                            busStop.routes = [self removeRoute:[NSNumber numberWithInt:401] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                            busStop.routes = [self removeRoute:[NSNumber numberWithInt:402] FromBusRoutes:[NSMutableArray arrayWithArray:busStop.routes]];
                        }
                        [mutableStops addObject:busStop];
                        if (show && ([set anyObject] == nil || [set containsObject:[NSNumber numberWithInteger:[busStop.routes count]]]))
                            [_delegate addBusStop:busStop];
                    }
                }
                [busStop release];
            }
        }
        _stops = [[NSArray alloc] initWithArray:mutableStops];
        [mutableStops release];
    }
    [dictonary release];
}

- (NSArray*)removeRoute:(NSNumber*)number FromBusRoutes:(NSMutableArray*)array
{
    if ([array containsObject:number])
        [array removeObject:number];
    return array;
}

- (void)loadTerminalDataAndShow:(BOOL)show withSet:(NSSet*)set
{
    for (BusStop *busStop in _stops) {
        if (show && ([set anyObject] == nil || [set containsObject:[NSNumber numberWithInteger:busStop.fcode]]))
            [_delegate addBusStop:busStop];
    }
}

- (void)loadRouteDataAndShow:(BOOL)show
{
    if (_routes != nil && show) {
        for (BusRoute *busRoute in _routes) {
            [_delegate addRoute:busRoute];
        }
    } else if (_routes == nil) {
        KMLRoot *kmlRoutes = [KMLParser parseKMLAtURL:routesUrl];
        if (!kmlRoutes)
            kmlRoutes = [KMLParser parseKMLAtPath:[[NSBundle mainBundle] pathForResource:@"Bus Routes" ofType:@"kml"]];
        NSMutableArray *mutableRoutes = [NSMutableArray array];
        for (KMLPlacemark *placemark in kmlRoutes.placemarks) {
            if (placemark.geometry && placemark.name) {
                BusRoute *busRoute = [[BusRoute alloc] initWithTitle:placemark.name description:placemark.descriptionValue andGeometries:(KMLMultiGeometry *)placemark.geometry];
                [mutableRoutes addObject:busRoute];
                if (show)
                    [_delegate addRoute:busRoute];
                [busRoute release];
            }
        }
        _routes = [[NSArray alloc] initWithArray:mutableRoutes];
    }
}

@end
