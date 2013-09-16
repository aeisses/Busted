//
//  ViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)pushViewController:(UIViewController*)viewController
{
    
}
- (void)showMenuView
{
    _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    _menuViewController.delegate = self;
    _menuViewController.superDelegate = self;
    [[self navigationController] pushViewController:_menuViewController animated:NO];
}

- (void)viewDidLoad
{
    _trackVC = [[TrackViewController alloc] initWithNibName:@"TrackViewController" bundle:nil];
    _trackVC.superDelegate = self;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator hidesWhenStopped];
    dataReader = [[DataReader alloc] init];
    dataReader.delegate = self;
    __block DataReader *blockDataReader = dataReader;
    dispatch_queue_t loadDataQueue  = dispatch_queue_create("load data queue", NULL);
    dispatch_async(loadDataQueue, ^{
        [blockDataReader loadKMLData];
    });


//    [self showMenuView];
    [super viewDidLoad];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [dataReader release]; dataReader = nil;
    [activityIndicator release]; activityIndicator = nil;
    [super dealloc];
}

#pragma MenuViewControllerDelegate
- (void)loadViewController:(UIViewController*)vc
{
    if ([vc isKindOfClass:[RoutesViewController class]]) {
        RoutesViewController *routesVC = (RoutesViewController*)vc;
        routesVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
    } else if ([vc isKindOfClass:[TrackViewController class]]) {
        TrackViewController *trackVC = (TrackViewController*)vc;
        trackVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
    } else if ([vc isKindOfClass:[StopsViewController class]]) {
        StopsViewController *stopVC = (StopsViewController*)vc;
        stopVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
    } else if ([vc isKindOfClass:[MapViewController class]]) {
        MapViewController *mapVC = (MapViewController*)vc;
        mapVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
    }
}

- (BusRoute*)getRoute:(NSInteger)routeNumber;
{
    for (BusRoute *busRoute in dataReader.routes) {
        if (busRoute.routeNum == routeNumber)
            return busRoute;
    }
    return nil;
}

- (NSArray*)getRoutes
{
    return dataReader.routes;
}

#pragma ParentViewControllerDelegate
- (void)touchedHomeButton
{
    [[self navigationController] popToViewController:_menuViewController animated:NO];
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    switch (swipeGesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]])
                [[self navigationController] popViewControllerAnimated:NO];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]])
                [[self navigationController] popViewControllerAnimated:NO];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            if ([[self navigationController].topViewController isKindOfClass:[TrackViewController class]])
                [[self navigationController] popViewControllerAnimated:NO];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if (![[self navigationController].topViewController isKindOfClass:[TrackViewController class]])
                  [[self navigationController] pushViewController:_trackVC animated:NO];
            break;
    }
}

#pragma DataReaderDelegate Methods
- (void)startProgressIndicator
{
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)endProgressIndicator
{
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    [self showMenuView];
}

- (void)addBusStop:(BusStop*)busStop
{
//   [mapViewController addBusStop:busStop];
}

-(void)addRoute:(BusRoute*)route;
{
 //   for (BusRoute *busRoute in dataReader.routes) {
//    [mapViewController addRoute:route];
}
@end
