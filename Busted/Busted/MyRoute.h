//
//  myRoute.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-05.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyRoute : NSObject

@property (nonatomic, retain) NSString *shortName;
@property (readwrite) NSInteger ident;
@property (nonatomic, retain) NSString *longName;
@property (nonatomic, assign) BOOL isFavorite;

@end
