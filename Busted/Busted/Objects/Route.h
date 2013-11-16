//
//  myRoute.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-05.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic, retain) NSString *shortName;
@property (readwrite) NSInteger ident;
@property (nonatomic, retain) NSString *longName;
@property (nonatomic, assign) BOOL isFavourite;

@end
