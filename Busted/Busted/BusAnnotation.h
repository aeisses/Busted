//
//  Bus.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BusAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, readonly) NSInteger num;

- (id)initWithBusNumber:(NSInteger)num latitude:(float)lat longitude:(float)lng timeToNextStop:(NSString*)timeToNextStop nextStopNumber:(NSInteger)nextStop;
@end
