//
//  RegionZoomData.h
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-25.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define HRM_LATITUDE 44.690306
#define HRM_LONGITUDE -63.651112
#define HRM_LATITUDE_DELTA 0.260442
#define HRM_LONGITUDE_DELTA 0.488461

#define HALIFAX_LATITUDE 44.64745
#define HALIFAX_LONGITUDE -63.601491
#define HALIFAX_LATITUDE_DELTA 0.014200
#define HALIFAX_LONGITUDE_DELTA 0.011654

#define DARTMOUTH_LATITUDE 44.681561
#define DARTMOUTH_LONGITUDE -63.574437
#define DARTMOUTH_LATITUDE_DELTA 0.073700
#define DARTMOUTH_LONGITUDE_DELTA 0.138204

#define SACKVILLE_LATITUDE 44.775888
#define SACKVILLE_LONGITUDE -63.687666
#define SACKVILLE_LATITUDE_DELTA 0.054387
#define SACKVILLE_LONGITUDE_DELTA 0.1022155

#define FAIRVIEW_LATITUDE 44.656247
#define FAIRVIEW_LONGITUDE -63.6442351
#define FAIRVIEW_LATITUDE_DELTA 0.030080
#define FAIRVIEW_LONGITUDE_DELTA 0.056383

#define CLAYTONPARK_LATITUDE 44.673831
#define CLAYTONPARK_LONGITUDE -63.664228
#define CLAYTONPARK_LATITUDE_DELTA 0.030071
#define CLAYTONPARK_LONGITUDE_DELTA 0.056383

#define COLEHARBOUR_LATITUDE 44.678394
#define COLEHARBOUR_LONGITUDE -63.509519
#define COLEHARBOUR_LATITUDE_DELTA 0.073704
#define COLEHARBOUR_LONGITUDE_DELTA 0.138204

#define SPRYFIELD_LATITUDE 44.620734
#define SPRYFIELD_LONGITUDE -63.613456
#define SPRYFIELD_LATITUDE_DELTA 0.048875
#define SPRYFIELD_LONGITUDE_DELTA 0.091555

#define BEDFORD_LATITUDE 44.726830
#define BEDFORD_LONGITUDE -63.670635
#define BEDFORD_LATITUDE_DELTA 0.040845
#define BEDFORD_LONGITUDE_DELTA 0.076654

typedef enum {
    HRM,
    Halifax,
    Dartmouth,
    ColeHarbour,
    Sackville,
    Fairview,
    ClaytonPark,
    Spryfield,
    Bedford
} REGION;

@interface RegionZoomData : NSObject

+ (MKCoordinateRegion)getRegion:(REGION)region;

@end
