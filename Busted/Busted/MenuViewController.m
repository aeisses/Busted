//
//  MenuViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

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
//        StopsViewController *stopsVC = [[StopsViewController alloc] initWithNibName:@"StopsViewController" bundle:nil];
//        [_delegate loadViewController:stopsVC];
//        [stopsVC release];
//        MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"StopsViewController" bundle:nil];
//        mapVC.delegate = self;
        
    } else if (button.tag == 4) {
//        TrackViewController *trackVC = [[TrackViewController alloc] initWithNibName:@"TrackViewController" bundle:nil];
//        [_delegate loadViewController:trackVC];
//        [trackVC release];
    }
}

- (void)dealloc
{
    [_button1 release]; _button1 = nil;
    [_button2 release]; _button2 = nil;
    [_button3 release]; _button3 = nil;
    [_button4 release]; _button4 = nil;
    [super dealloc];
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
@end
