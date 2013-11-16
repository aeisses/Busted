//
//  Path.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Path : NSObject

@property (retain, nonatomic) NSArray *lines;

- (MKCoordinateRegion)addLines:(NSArray*)paths;

@end
