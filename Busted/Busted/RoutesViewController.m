//
//  RoutesViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "RoutesViewController.h"

@interface RoutesViewController ()

@end

@implementation RoutesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        _mapVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    homeButton.hidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    homeButton.hidden = YES;
    [super viewDidAppear:animated];
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
    [_collection release]; _collection = nil;
    _delegate = nil;
    [_mapVC release]; _mapVC = nil;
    [super dealloc];
}

-(IBAction)touchSubmitButton:(id)sender
{
    if (!_routeButton.titleLabel.text && ![_routeButton.titleLabel.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please" message:@"You need to select a route before a map will be shown" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        [_delegate loadMapViewController:_mapVC];
    }
}

- (IBAction)touchRouteButton:(id)sender
{
    _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
    _collection.delegate = self;
    [self presentViewController:_collection animated:YES completion:^{}];
}

#pragma RoutesViewControllerDelegate
- (void)mapFinishedLoading
{
    if (![_routeButton.titleLabel.text isEqualToString:@""]) {
        [_mapVC addRoute:[_delegate getRoute:[_routeButton.titleLabel.text integerValue]]];
    }
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    return [_delegate getRoutes];
}

- (void)setBusRoute:(NSInteger)route
{
    [_routeButton setTitle:[NSString stringWithFormat:@"%i",route] forState:UIControlStateNormal];
    [_collection dismissViewControllerAnimated:YES completion:^{}];
    [_collection release];
}

@end
