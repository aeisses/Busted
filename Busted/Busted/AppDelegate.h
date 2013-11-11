//
//  AppDelegate.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BustedNavigationController.h"
#import "ViewController.h"

#define FLURRY_API_KEY @"3S4TY9QJ4PSNRJSDT377"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimer *backGroundTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BustedNavigationController *navController;
@property (strong, nonatomic) ViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
