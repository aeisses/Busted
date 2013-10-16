//
//  Bus.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Bus : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (retain, nonatomic) NSString *UUID;
@property (readwrite) NSInteger busNumber;
@property (readwrite) double timeToNextStop;

- (id)initWithBusNumber:(NSInteger)num UUDID:(NSString*)uuid latitude:(float)lat longitude:(float)longi timeToNextStop:(double)timeToNextStop;
@end
