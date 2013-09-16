//
//  ParentViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"

@interface ParentViewController (PrivateMethods)
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture;
- (void)touchedHomeButton;
@end

@implementation ParentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeLeft.numberOfTouchesRequired = 1;
        swipeLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
        
        swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeRight.numberOfTouchesRequired = 1;
        swipeRight.direction = (UISwipeGestureRecognizerDirectionRight);
        
        swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeUp.numberOfTouchesRequired = 1;
        swipeUp.direction = (UISwipeGestureRecognizerDirectionUp);
        
        swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeDown.numberOfTouchesRequired = 1;
        swipeDown.direction = (UISwipeGestureRecognizerDirectionDown);
    }
    return self;
}

- (void)viewDidLoad
{
    homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    homeButton.frame = (CGRect){0,0,40,40};
    [homeButton setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(touchedHomeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homeButton];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeUp];
    [self.view addGestureRecognizer:swipeDown];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:swipeRight];
    [self.view removeGestureRecognizer:swipeLeft];
    [self.view removeGestureRecognizer:swipeUp];
    [self.view removeGestureRecognizer:swipeDown];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [swipeRight release]; swipeRight = nil;
    [swipeLeft release]; swipeLeft = nil;
    [swipeUp release]; swipeUp = nil;
    [swipeDown release]; swipeDown = nil;
    _superDelegate = nil;
    [super dealloc];
}

#pragma Private Methods
- (void)touchedHomeButton
{
    [_superDelegate touchedHomeButton];
}

- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    [_superDelegate swipe:swipeGesture];
}

@end
