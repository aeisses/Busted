//
//  ParentViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
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
        _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeLeft.numberOfTouchesRequired = 1;
        _swipeLeft.accessibilityLabel = @"Exit Screen";
        _swipeLeft.isAccessibilityElement = YES;
        _swipeLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
        
        _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeRight.numberOfTouchesRequired = 1;
        _swipeRight.accessibilityLabel = @"Exit Screen";
        _swipeRight.isAccessibilityElement = YES;
        _swipeRight.direction = (UISwipeGestureRecognizerDirectionRight);
        
        _swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeUp.numberOfTouchesRequired = 1;
        _swipeUp.accessibilityLabel = @"Close Tracking Window";
        _swipeUp.isAccessibilityElement = YES;
        _swipeUp.direction = (UISwipeGestureRecognizerDirectionUp);
        _swipeUp.enabled = NO;
        
        _swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeDown.numberOfTouchesRequired = 1;
        _swipeDown.accessibilityLabel = @"Show tracking window";
        _swipeDown.isAccessibilityElement = YES;
        _swipeDown.direction = (UISwipeGestureRecognizerDirectionDown);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view addGestureRecognizer:_swipeRight];
    [self.view addGestureRecognizer:_swipeLeft];
    [self.view addGestureRecognizer:_swipeUp];
    [self.view addGestureRecognizer:_swipeDown];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:_swipeRight];
    [self.view removeGestureRecognizer:_swipeLeft];
    [self.view removeGestureRecognizer:_swipeUp];
    [self.view removeGestureRecognizer:_swipeDown];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_swipeRight release]; _swipeRight = nil;
    [_swipeLeft release]; _swipeLeft = nil;
    [_swipeUp release]; _swipeUp = nil;
    [_swipeDown release]; _swipeDown = nil;
    _superDelegate = nil;
    [super dealloc];
}

#pragma Private Methods
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture
{
    [_superDelegate swipe:swipeGesture];
}

@end
