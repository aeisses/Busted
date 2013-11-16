//
//  macros.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-16.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#define HEIGHT_IPHONE_5 568
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_5 )
