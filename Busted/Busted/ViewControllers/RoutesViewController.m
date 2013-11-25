//
//  RoutesViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "RoutesViewController.h"
#import "WebApiInterface.h"
#import "Flurry.h"

@interface RoutesViewController (PrivateMethods)
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture;
@end

@implementation RoutesViewController

static id instance;

+ (RoutesViewController*)sharedInstance
{
    if (!instance) {
        if (IS_IPHONE)
        {
            return [[[RoutesViewController alloc] initWithNibName:@"RoutesViewControllerSmall" bundle:nil] autorelease];
        } else {
            return [[[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil] autorelease];
        }
    }
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    instance = self;
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.swipeUp.enabled = YES;
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_submitButton release]; _submitButton = nil;
    [_routeButton release]; _routeButton = nil;
    [_homeButton release]; _homeButton = nil;
    _delegate = nil;
    [super dealloc];
}

-(IBAction)touchSubmitButton:(id)sender
{
    if (!_routeButton.titleLabel.text || [_routeButton.titleLabel.text isEqualToString:@"?"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please" message:@"You need to select a route before a map will be shown" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        if (IS_IPHONE_5)
        {
            _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        }
        else
        {
            _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil];
        }
        dispatch_queue_t dataQueue  = dispatch_queue_create("data queue", NULL);
        dispatch_async(dataQueue, ^{
            [[WebApiInterface sharedInstance] loadPathForRoute:_routeButton.titleLabel.text callBack:_mapVC];
        });
        dispatch_release(dataQueue);
        _mapVC.isStops = YES;
        [_delegate loadMapViewController:_mapVC];
        NSArray *routesArray = [self getBusRoutes];
        Route *route = [[Route alloc] init];
        route.shortName = _routeButton.titleLabel.text;
        [_mapVC addRoute:[routesArray objectAtIndex:[routesArray indexOfObject:route]]];
        [route release];
        [_mapVC release];
        _mapVC = nil;
        NSDictionary *routesParams = [NSDictionary dictionaryWithObjectsAndKeys:@"Route", _routeButton.titleLabel.text, nil];
        [Flurry logEvent:@"Routes_View_Button_Pressed" withParameters:routesParams];
    }
}

- (IBAction)touchRouteButton:(id)sender
{
    if (IS_IPHONE_5)
    {
        _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
    } else {
        _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRouteCollectionViewControllerSmall" bundle:nil];
    }
    _collection.delegate = self;
    [self presentViewController:_collection animated:YES completion:^{}];
}

- (IBAction)touchHomeButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        [self.superDelegate touchedHomeButton:YES];
    });
    dispatch_release(menuQueue);
}

- (IBAction)touchTrackButton:(id)sender
{
    [self.superDelegate swipe:self.swipeDown];
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    NSArray *routes = [_delegate getRoutes];
    NSMutableArray *routesM = [[NSMutableArray alloc] initWithCapacity:[routes count]];
//    int counter = 0;
    for (RouteManagedObject *route in routes)
    {
        Route *myRoute = [[Route alloc] init];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        NSNumber *number = [numberFormatter numberFromString:route.shortName];
        if (number != nil) {
            myRoute.ident = [route.shortName integerValue];
        } else {
//            myRoute.ident = counter + 10000;
//            counter++;
            [myRoute release];
            continue;
        }
        myRoute.longName = route.longName;
        myRoute.shortName = route.shortName;
        myRoute.isFavourite = [route.isFavourite boolValue];
        [routesM addObject:myRoute];
        [myRoute release];
    }
    return [(NSArray*)routesM autorelease];
}

- (void)setBusRoute:(NSString*)route
{
    [_routeButton setTitle:route forState:UIControlStateNormal];
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

- (void)exitCollectionView
{
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    _collection.delegate = nil;
    [_collection release];
}

@end
