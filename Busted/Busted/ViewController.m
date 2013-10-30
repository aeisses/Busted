//
//  ViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation ViewController

- (void)pushViewController:(UIViewController*)viewController
{
    
}

- (void)showMenuView
{
    [[self navigationController] popViewControllerAnimated:NO];
    if (IS_IPHONE_5)
    {
        _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    }
    else
    {
        _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewControllerSmall" bundle:nil];
    }
    _menuViewController.delegate = self;
    _menuViewController.superDelegate = self;
    [[self navigationController] pushViewController:_menuViewController animated:NO];
}

- (void)viewDidLoad
{
    _webApiInterface = [[WebApiInterface alloc] init];
    _webApiInterface.delegate = self;
    if (IS_IPHONE_5)
    {
        _trackVC = [[TrackViewController alloc] initWithNibName:@"TrackViewController" bundle:nil];
    } else {
        _trackVC = [[TrackViewController alloc] initWithNibName:@"TrackViewControllerSmall" bundle:nil];
    }
    _trackVC.delegate = self;
    if (IS_IPHONE_5)
    {
        _loadingScreen = [[LoadingScreenViewController alloc] initWithNibName:@"LoadingScreenViewController" bundle:nil];
    } else {
        _loadingScreen = [[LoadingScreenViewController alloc] initWithNibName:@"LoadingScreenViewControllerSmall" bundle:nil];
    }
    _loadingScreen.delegate = self;
    [[self navigationController] pushViewController:_loadingScreen animated:NO];
    [_loadingScreen release];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_webApiInterface release]; _webApiInterface = nil;
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
        [[self navigationController] pushViewController:routesVC animated:YES];
    } else if ([vc isKindOfClass:[FavoritesViewController class]]) {
        FavoritesViewController *favVC = (FavoritesViewController*)vc;
        favVC.superDelegate = self;
        [[self navigationController] pushViewController:favVC animated:YES];
    } else if ([vc isKindOfClass:[MapViewController class]]) {
        MapViewController *mapVC = (MapViewController*)vc;
        mapVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:YES];
        mapVC.currentLocation = _trackVC.currentLocation;
    } else if ([vc isKindOfClass:[StopDisplayViewController class]]) {
        StopDisplayViewController *stopDisplayVC = (StopDisplayViewController*)vc;
        [[self navigationController] pushViewController:stopDisplayVC animated:YES];
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

#pragma TranistionViewControllerDelegate
- (NSArray*)getRoutes
{
    NSArray *array = [_webApiInterface requestAllRoutes];
    return array;
}

- (void)exitTransitionVC
{
    [_trackVC dismissViewControllerAnimated:YES completion:^{}];
}

#pragma ParentViewControllerDelegate
- (void)touchedHomeButton:(BOOL)isAll
{
    if (isAll)
    {
        [[self navigationController] popToViewController:_menuViewController animated:YES];
    } else {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    switch (swipeGesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]]) {
//                [UIView animateWithDuration:0.75 animations:^{
//                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//                    [[self navigationController] popViewControllerAnimated:YES];
//                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self navigationController].view cache:NO];
//                }];
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]]) {
                [[self navigationController] popViewControllerAnimated:YES];
            }
            break;
        case UISwipeGestureRecognizerDirectionUp: 
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if (![[self navigationController].topViewController isKindOfClass:[TrackViewController class]])
            {
                NSString *ver = [[UIDevice currentDevice] systemVersion];
                float ver_float = [ver floatValue];
                if (ver_float >= 7.0)
                {
                    _trackVC.transitioningDelegate = self;
                    _trackVC.modalPresentationStyle = UIModalPresentationCustom;
                }
                [self presentViewController:_trackVC animated:YES completion:^{}];
            }
            break;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    TLTransitionAnimator *animator = [[TLTransitionAnimator new] autorelease];
    //Configure the animator
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TLTransitionAnimator *animator = [[TLTransitionAnimator new] autorelease];
    return animator;
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

#pragma WebApiInterfaceDelegate
- (void)receivedRoutes
{
//    _routes = [[routes.route allObjects] copy];
//    [self showMenuView];
//    [self showMenuView];

    [_webApiInterface fetchAllStops];
}

- (void)receivedStops
{
    [self showMenuView];
}

#pragma LoadingScreenViewControllerDelegate
- (void)loadScreenLoaded
{
    _webApiInterface.managedObjectContext = _managedObjectContext;
    [_webApiInterface fetchAllRoutes];
}

@end
