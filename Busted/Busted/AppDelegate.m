//
//  AppDelegate.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString *const kTrackingId = @"UA-45344419-1";
static NSString *const kAllowTracking = @"allowTracking";

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    ViewController *rootView = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    rootView.managedObjectContext = self.managedObjectContext;
    _navController = [[KNOWtimeNavigationController alloc] initWithRootViewController:rootView];
    _navController.navigationBarHidden = YES;
    self.window.rootViewController = _navController;
    [self.window makeKeyAndVisible];
    [rootView release];
    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:FLURRY_API_KEY];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"alert"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"alert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showalerttwice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([TrackViewController sharedInstance].isTracking)
    {
        [[TrackViewController sharedInstance].displayLink setPaused:YES];
//        [[TrackViewController sharedInstance].locationManager stopUpdatingLocation];
        [TrackViewController sharedInstance].backGroundTime = [NSDate date];
        [[TrackViewController sharedInstance].locationManager startMonitoringSignificantLocationChanges];
        [Flurry setBackgroundSessionEnabled:YES];
    }
    if ([_navController.topViewController isKindOfClass:[MapViewController class]])
    {
        [((MapViewController*)_navController.topViewController).locationManager stopUpdatingLocation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([_navController.topViewController isKindOfClass:[MenuViewController class]] && _navController.topViewController.presentedViewController == nil && ![[NSUserDefaults standardUserDefaults] boolForKey:@"showalerttwice"])
    {
        [((MenuViewController*)_navController.topViewController) showTrackingAlert];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showalerttwice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([TrackViewController sharedInstance].isTracking)
    {
        [[TrackViewController sharedInstance].displayLink setPaused:NO];
        [[TrackViewController sharedInstance].locationManager stopMonitoringSignificantLocationChanges];
        [[TrackViewController sharedInstance].locationManager startUpdatingLocation];
    }
    if ([_navController.topViewController isKindOfClass:[MapViewController class]])
    {
        [((MapViewController*)_navController.topViewController).locationManager startUpdatingLocation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [GAI sharedInstance].optOut = ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
//    if ([TrackViewController sharedInstance].isTracking)
//    {
//        [[TrackViewController sharedInstance].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
////        [[TrackViewController sharedInstance].locationManager startUpdatingLocation];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
