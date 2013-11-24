//
//  AppDelegate.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNOWtimeNavigationController.h"
#import "ViewController.h"
#import "TrackViewController.h"

#define FLURRY_API_KEY @"3S4TY9QJ4PSNRJSDT377"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimer *backGroundTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KNOWtimeNavigationController *navController;
@property (strong, nonatomic) ViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
