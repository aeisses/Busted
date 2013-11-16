//
//  RegionZoomData.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-25.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "RegionZoomData.h"

@implementation RegionZoomData

+ (MKCoordinateRegion)getRegion:(REGION)region
{
    MKCoordinateRegion coordinates;
    switch (region)
    {
        case HRM:
        default:
            coordinates = (MKCoordinateRegion){HRM_LATITUDE,HRM_LONGITUDE,HRM_LATITUDE_DELTA,HRM_LONGITUDE_DELTA};
            break;
        case Halifax:
            coordinates = (MKCoordinateRegion){HALIFAX_LATITUDE,HALIFAX_LONGITUDE,HALIFAX_LATITUDE_DELTA,HALIFAX_LONGITUDE_DELTA};
            break;
        case Dartmouth:
            coordinates = (MKCoordinateRegion){DARTMOUTH_LATITUDE,DARTMOUTH_LONGITUDE,DARTMOUTH_LATITUDE_DELTA,DARTMOUTH_LONGITUDE_DELTA};
            break;
        case ColeHarbour:
            coordinates = (MKCoordinateRegion){COLEHARBOUR_LATITUDE,COLEHARBOUR_LONGITUDE,COLEHARBOUR_LATITUDE_DELTA,COLEHARBOUR_LONGITUDE_DELTA};
            break;
        case Sackville:
            coordinates = (MKCoordinateRegion){SACKVILLE_LATITUDE,SACKVILLE_LONGITUDE,SACKVILLE_LATITUDE_DELTA,SACKVILLE_LONGITUDE_DELTA};
            break;
        case Fairview:
            coordinates = (MKCoordinateRegion){FAIRVIEW_LATITUDE,FAIRVIEW_LONGITUDE,FAIRVIEW_LATITUDE_DELTA,FAIRVIEW_LONGITUDE_DELTA};
            break;
        case ClaytonPark:
            coordinates = (MKCoordinateRegion){CLAYTONPARK_LATITUDE,CLAYTONPARK_LONGITUDE,CLAYTONPARK_LATITUDE_DELTA,CLAYTONPARK_LONGITUDE_DELTA};
            break;
        case Spryfield:
            coordinates = (MKCoordinateRegion){SPRYFIELD_LATITUDE,SPRYFIELD_LONGITUDE,SPRYFIELD_LATITUDE_DELTA,SPRYFIELD_LONGITUDE_DELTA};
            break;
        case Bedford:
            coordinates = (MKCoordinateRegion){BEDFORD_LATITUDE,BEDFORD_LONGITUDE,BEDFORD_LATITUDE_DELTA,BEDFORD_LONGITUDE_DELTA};
            break;
    }
    return coordinates;
}

@end
