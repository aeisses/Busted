//
//  MenuViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MenuViewController.h"
#import "WebApiInterface.h"

@interface MenuViewController (PrivateMethods)
- (void)disableButton;
- (void)enableButton;
@end

@implementation MenuViewController

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
    NSArray *nibObjects = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] loadNibNamed:@"AboutScreen" owner:self options:nil]];
    self.aboutView = [[nibObjects objectAtIndex:0] retain];
    self.aboutView.frame = (CGRect){314,50,241,519};
    [self.view addSubview:self.aboutView];
    isAboutScreenVisible = NO;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    homeButton.hidden = YES; homeButton.enabled = NO;
    self.swipeRight.enabled = NO;
    self.swipeLeft.enabled = NO;
    self.swipeUp.enabled = NO;
    self.swipeDown.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button.tag == 1) {
        RoutesViewController *rootsVC = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
        rootsVC.delegate = self;
        [_delegate loadViewController:rootsVC];
        [rootsVC release];
    } else if (button.tag == 2) {
        _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        _mapVC.delegate = self;
        [_delegate loadViewController:_mapVC];
        [_mapVC.mapView setRegion:(MKCoordinateRegion){_mapVC.currentLocation.coordinate.latitude,_mapVC.currentLocation.coordinate.longitude,0.014200, 0.011654}];
        dispatch_queue_t loadDataQueue  = dispatch_queue_create("load data queue", NULL);
        dispatch_async(loadDataQueue, ^{
            [[WebApiInterface sharedInstance] requestPlace:_mapVC.currentLocation.coordinate];
        });
        dispatch_release(loadDataQueue);
    } else if (button.tag == 3) {
    
    } else if (button.tag == 4) {
        if (isAboutScreenVisible)
        {
            [UIView animateWithDuration:0.50 animations:^{
                _aboutView.frame = (CGRect){314,49,241,519};
                _button4.frame = (CGRect){265,73,50,50};
            }completion:^(BOOL finished) {
                [self enableButton];
                isAboutScreenVisible = NO;
            }];
        } else {
            [self disableButton];
            [UIView animateWithDuration:0.50 animations:^{
                _aboutView.frame = (CGRect){79,49,241,519};
                _button4.frame = (CGRect){30,73,50,50};
            } completion:^(BOOL finished) {
                isAboutScreenVisible = YES;
            }];
        }
    }
}

- (IBAction)touchTrackButton:(id)sender
{
    [self.superDelegate swipe:self.swipeDown];
}

- (void)dealloc
{
    [_button1 release]; _button1 = nil;
    [_button2 release]; _button2 = nil;
    [_button3 release]; _button3 = nil;
    [_button4 release]; _button4 = nil;
    [_aboutView release];
    [super dealloc];
}

#pragma PrivateMethods
- (void)disableButton
{
    _button1.enabled = NO;
    _button2.enabled = NO;
    _button3.enabled = NO;
}

- (void)enableButton
{
    _button1.enabled = YES;
    _button2.enabled = YES;
    _button3.enabled = YES;
}

#pragma RoutesViewControllerDelegate Methods
- (void)loadMapViewController:(MapViewController*)mapViewController
{
    [_delegate loadViewController:mapViewController];
}

- (BusRoute*)getRoute:(NSInteger)routeNumber
{
    return [_delegate getRoute:routeNumber];
}

- (NSArray*)getRoutes
{
    return [_delegate getRoutes];
}

#pragma MapViewControllerDelegate
- (void)mapFinishedLoading
{
//    if (![_routeButton.titleLabel.text isEqualToString:@"?"]) {
//        [_mapVC addRoute:[_delegate getRoute:[_routeButton.titleLabel.text integerValue]]];
//    }
    _mapVC.delegate = nil;
    [_mapVC release];
}

- (void)updateStops:(CLLocationCoordinate2D)mapCenter
{
    [[WebApiInterface sharedInstance] requestPlace:mapCenter];
}

- (void)loadViewController:(UIViewController*)vc
{
    [_delegate loadViewController:vc];
}
@end
