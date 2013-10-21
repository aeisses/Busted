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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
        _mapVC.delegate = self;
        _mapVC.isStops = YES;
        [_delegate loadMapViewController:_mapVC];
    }
}

- (IBAction)touchRouteButton:(id)sender
{
    _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
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
        [_mapVC addRoute:[_delegate getRoute:[_routeButton.titleLabel.text integerValue]]];
    }
    _mapVC.delegate = nil;
    [_mapVC release];
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    NSArray *routes = [_delegate getRoutes];
    NSMutableArray *routesM = [[NSMutableArray alloc] initWithCapacity:[routes count]];
    for (Route *route in routes)
    {
        MyRoute *myRoute = [[MyRoute alloc] init];
        myRoute.ident = route.ident;
        myRoute.title = route.long_name;
        myRoute.busNumber = [route.short_name integerValue];
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
