//
//  ViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation ViewController

- (void)pushViewController:(UIViewController*)viewController
{
    
}

- (void)showMapScreen
{
    [[self navigationController] popViewControllerAnimated:NO];
    if (IS_IPHONE_5)
    {
        _mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        _hamburgerMenuViewController = [[HamburgerMenuViewController alloc] initWithNibName:@"HamburgerMenuViewController" bundle:nil];
    }
    else
    {
        _mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil];
        _hamburgerMenuViewController = [[HamburgerMenuViewController alloc] initWithNibName:@"HamburgerMenuViewControllerSmall" bundle:nil];
    }
    _mapViewController.delegate = self;
    _mapViewController.superDelegate = self;
//    [[self navigationController] pushViewController:_hamburgerMenuViewController animated:NO];
    _hamburgerMenuViewController.view.frame = (CGRect){0,0,320,568};
    [[self navigationController] addChildViewController:_hamburgerMenuViewController];
//    [_hamburgerMenuViewController addChildViewController:_mapViewController];
    [[self navigationController] pushViewController:_mapViewController animated:NO];
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
    [activityIndicator release]; activityIndicator = nil;
    [super dealloc];
}

#pragma MenuViewControllerDelegate
- (void)loadViewController:(UIViewController*)vc
{
    if ([vc isKindOfClass:[RoutesViewController class]]) {
        RoutesViewController *routesVC = (RoutesViewController*)vc;
        routesVC.superDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] pushViewController:routesVC animated:YES];
        });
    } else if ([vc isKindOfClass:[FavouritesViewController class]]) {
        FavouritesViewController *favVC = (FavouritesViewController*)vc;
        favVC.superDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] pushViewController:favVC animated:YES];
        });
    } else if ([vc isKindOfClass:[MapViewController class]]) {
        MapViewController *mapVC = (MapViewController*)vc;
        mapVC.delegate = self;
        mapVC.superDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] pushViewController:vc animated:YES];
        });
        mapVC.currentLocation = _trackVC.currentLocation;
    } else if ([vc isKindOfClass:[StopDisplayViewController class]]) {
        StopDisplayViewController *stopDisplayVC = (StopDisplayViewController*)vc;
        stopDisplayVC.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] pushViewController:stopDisplayVC animated:YES];
        });
    }
}

#pragma MapViewControllerDelegate
- (void)showHamburgerMenu
{
    if (_mapViewController.view.frame.origin.x == 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            _mapViewController.view.frame = (CGRect){110,_mapViewController.view.frame.origin.y,_mapViewController.view.frame.size};
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _mapViewController.view.frame = (CGRect){0,_mapViewController.view.frame.origin.y,_mapViewController.view.frame.size};
        }];
    }
}

#pragma TranistionViewControllerDelegate
- (NSArray*)getRoutes
{
    NSArray *array = [_webApiInterface requestAllRoutes];
    return array;
}

- (void)exitTransitionVC
{
//    [_trackVC dismissViewControllerAnimated:YES completion:^{}];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma ParentViewControllerDelegate
- (void)touchedHomeButton:(BOOL)isAll
{
    if (isAll)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] popToViewController:_menuViewController animated:YES];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] popViewControllerAnimated:YES];
        });
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
//                NSString *ver = [[UIDevice currentDevice] systemVersion];
//                float ver_float = [ver floatValue];
//                if (ver_float >= 7.0)
//                {
//                    _trackVC.transitioningDelegate = self;
//                    _trackVC.modalPresentationStyle = UIModalPresentationCustom;
//                }
//                [self presentViewController:_trackVC animated:YES completion:^{}];
                [[self navigationController] pushViewController:_trackVC animated:YES];
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
//    [self showMenuView];
    [self showMapScreen];
}

- (void)addBusStop:(StopAnnotation*)busStop
{
//   [mapViewController addBusStop:busStop];
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
//    [self showMenuView];
    [self showMapScreen];
}

- (void)loadPath:(Path*)path forRegion:(MKCoordinateRegion)region
{
    if ([[self navigationController].topViewController isKindOfClass:[MapViewController class]]) {
        [((MapViewController*)[self navigationController].topViewController).mapView setRegion:region];
        [((MapViewController*)[self navigationController].topViewController).mapView addOverlays:path.lines];
    }
}

#pragma LoadingScreenViewControllerDelegate
- (void)loadScreenLoaded
{
    _webApiInterface.managedObjectContext = _managedObjectContext;
    [_webApiInterface fetchAllRoutes];
}

@end
