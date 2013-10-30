//
//  Path.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-29.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Path : NSObject

@property (retain, nonatomic) NSArray *lines;

- (void)addLines:(NSArray*)paths;

@end
