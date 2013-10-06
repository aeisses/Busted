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
    _menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    _menuViewController.delegate = self;
    _menuViewController.superDelegate = self;
    [[self navigationController] pushViewController:_menuViewController animated:NO];
}

- (void)viewDidLoad
{
    _webApiInterface = [[WebApiInterface alloc] init];
    _webApiInterface.delegate = self;
    _trackVC = [[TrackViewController alloc] initWithNibName:@"TrackViewController" bundle:nil];
    _trackVC.delegate = self;
    _loadingScreen = [[LoadingScreenViewController alloc] initWithNibName:@"LoadingScreenViewController" bundle:nil];
    _loadingScreen.delegate = self;
    [[self navigationController] pushViewController:_loadingScreen animated:NO];
    [_loadingScreen release];
//    dataReader = [[DataReader alloc] init];
//    dataReader.delegate = self;
//    __block DataReader *blockDataReader = dataReader;
//    dispatch_queue_t loadDataQueue  = dispatch_queue_create("load data queue", NULL);
//    dispatch_async(loadDataQueue, ^{
//        [blockDataReader loadKMLData];
//    });
//    dispatch_release(loadDataQueue);
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
        [UIView transitionFromView:self.navigationController.topViewController.view toView:routesVC.view duration:0.5 options:UIViewAnimationOptionCurveEaseIn completion:^(BOOL finished) {
            [[self navigationController] pushViewController:routesVC animated:NO];
        }];
    } else if ([vc isKindOfClass:[StopsViewController class]]) {
        StopsViewController *stopVC = (StopsViewController*)vc;
        stopVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
    } else if ([vc isKindOfClass:[MapViewController class]]) {
        MapViewController *mapVC = (MapViewController*)vc;
        mapVC.superDelegate = self;
        [[self navigationController] pushViewController:vc animated:NO];
        mapVC.currentLocation = _trackVC.currentLocation;
    } else if ([vc isKindOfClass:[StopDisplayViewController class]]) {
        StopDisplayViewController *stopDisplayVC = (StopDisplayViewController*)vc;
        [[self navigationController] pushViewController:stopDisplayVC animated:NO];
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
- (void)touchedHomeButton
{
    [[self navigationController] popToViewController:_menuViewController animated:NO];
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    switch (swipeGesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]]) {
                [UIView animateWithDuration:0.75 animations:^{
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    [[self navigationController] popViewControllerAnimated:NO];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self navigationController].view cache:NO];
                }];
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (![[self navigationController].topViewController isKindOfClass:[MenuViewController class]]) {
                [UIView animateWithDuration:0.75 animations:^{
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    [[self navigationController] popViewControllerAnimated:NO];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self navigationController].view cache:NO];
                }];
            }
            break;
        case UISwipeGestureRecognizerDirectionUp: 
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if (![[self navigationController].topViewController isKindOfClass:[TrackViewController class]])
            {
                _trackVC.transitioningDelegate = self;
                _trackVC.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:_trackVC animated:YES completion:^{}];
            }
            break;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
    //Configure the animator
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TLTransitionAnimator *animator = [TLTransitionAnimator new];
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
    [self showMenuView];
}

#pragma LoadingScreenViewControllerDelegate
- (void)loadScreenLoaded
{
    _webApiInterface.managedObjectContext = _managedObjectContext;
    [_webApiInterface fetchAllRoutes];
}

@end
