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
        
        _collection = [[BusRoutesCollectionViewController alloc] initWithNibName:@"BusRoutesCollectionViewController" bundle:nil];
        _collection.delegate = self;
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
    [_inputTextField release]; _inputTextField = nil;
    _delegate = nil;
    [_mapVC release]; _mapVC = nil;
    [super dealloc];
}

-(IBAction)touchSubmitButton:(id)sender
{
//    if (![_routeButton.titleLabel.text isEqualToString:@"?"]) {
    if (![_inputTextField.text isEqualToString:@""]) {
        [_delegate loadMapViewController:_mapVC];
    }
//    }
}

- (IBAction)touchRouteButton:(id)sender
{
    [self presentViewController:_collection animated:YES completion:^{}];
}

#pragma RoutesViewControllerDelegate
- (void)mapFinishedLoading
{
//    if (![_routeButton.titleLabel.text isEqualToString:@""]) {
    if (![_inputTextField.text isEqualToString:@""]) {
        [_mapVC addRoute:[_delegate getRoute:[_inputTextField.text integerValue]]];
    }
//    }
}

#pragma BusRoutesCollectionViewController
- (NSArray*)getBusRoutes
{
    return [_delegate getRoutes];
}

@end
