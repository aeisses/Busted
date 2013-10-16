//
//  myRoute.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-05.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyRoute : NSObject

@property (nonatomic, retain) NSString *title;
@property (readwrite) NSInteger busNumber;
@property (nonatomic, retain) NSString *ident;

@end
