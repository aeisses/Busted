//
//  WebApiInterface.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-25.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebApiInterface : NSObject

// Calls:
//http://t2go-halifax.transittogo.com/api/v1/stop/6963/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/place/44.638508,-63.568782/upcoming_stoptimes?time=1380145872&all_routes=yes
//http://t2go-halifax.transittogo.com/api/v1/routes/motd?appversion=15

#define BASEURL @"http://t2go-halifax.transittogo.com/api/v1/"
#define STOPS   @"stop"
#define PLACE   @"place"
#define ROUTE   @"route"

@end
