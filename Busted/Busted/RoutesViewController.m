//
//  RoutesViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "RoutesViewController.h"

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
    [_trackButton release]; _trackButton = nil;
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
        [[WebApiInterface sharedInstance] loadPathForRoute:_routeButton.titleLabel.text];
        _mapVC.delegate = self;
        _mapVC.isStops = YES;
        [_delegate loadMapViewController:_mapVC];
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
    [self.superDelegate touchedHomeButton:YES];
}

- (IBAction)touchTrackButton:(id)sender
{
    [self.superDelegate swipe:self.swipeDown];
}

#pragma MapViewControllerDelegate
- (void)mapFinishedLoading
{
    if (![_routeButton.titleLabel.text isEqualToString:@"?"]) {
        NSArray *routesArray = [self getBusRoutes];
        MyRoute *route = [[MyRoute alloc] init];
        route.shortName = _routeButton.titleLabel.text;
        [_mapVC addRoute:[routesArray objectAtIndex:[routesArray indexOfObject:route]]];
        [route release];
    }
    _mapVC.delegate = nil;
    [_mapVC release];
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    NSArray *routes = [_delegate getRoutes];
    NSMutableArray *routesM = [[NSMutableArray alloc] initWithCapacity:[routes count]];
//    int counter = 0;
    for (Routes *route in routes)
    {
        MyRoute *myRoute = [[MyRoute alloc] init];
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
        myRoute.isFavorite = [route.isFavorite boolValue];
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

@end
