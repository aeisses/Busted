//
//  Enums.h
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-28.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

typedef enum {
    DTStandard,
    DTActive,
    DTStaging,
    DTReverse
} DRAWINGTYPE;

typedef enum {
    reverseInfo
} INFO;

typedef enum {
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    eleven,
    twelve,
    thirteen,
    fourteen,
    fifteen,
    sixteen,
    seventeen,
    eighteen,
    nineteen,
    twenty,
    all,
    none
} NUMERICNODE;

typedef enum {
    trbsin, // Bus Stop Inaccessible
    trbsac, // Bus Stop Accessible
    trbstmin, // Bus Terminal Inaccessible
    trbs, // Bus Stop Non-Standard
    trbsshac, // Bus Stop Shelter Accessible
    trbssh, // Bus Stop Shelter Non-Standard
    trpr, // Park and Ride
    trbstmac, // Bus Terminal Accessible
    trbstm, // Bus Terminal Non-Standard
    trbsshin, // Bus Stop Shelter Inaccessible
    tbrsml, // Metro Link
    fcodeall
} FCODE;

typedef enum {
    north,
    south,
    east,
    west,
    inbound,
    outbound,
    unknown
} DIRECTION;

typedef enum {
    transit,
    hastus
} SOURCE;

typedef enum {
    DV,
    IN,
    XY,
    GP
} SACC;

typedef enum {
    weekday_limited
} CLASS;