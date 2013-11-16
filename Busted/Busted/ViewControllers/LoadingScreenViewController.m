//
//  LoadingScreenViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-22.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "LoadingScreenViewController.h"
#import "macros.h"

@interface LoadingScreenViewController ()
- (void)frameIntervalLoop:(CADisplayLink *)sender;
@end

@implementation LoadingScreenViewController

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
    isOne = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
    [displayLink setFrameInterval:15];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_delegate loadScreenLoaded];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release];
    displayLink = nil;
    [super viewDidDisappear:animated];
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    if (isOne) {
        if (IS_IPHONE_5)
        {
            _animationImage.image = [UIImage imageNamed:@"introImage2.jpg"];
        } else {
            _animationImage.image = [UIImage imageNamed:@"introImage2Small.jpg"];
        }
        isOne = NO;
    } else {
        if (IS_IPHONE_5)
        {
            _animationImage.image = [UIImage imageNamed:@"introImage1.jpg"];
        } else {
            _animationImage.image = [UIImage imageNamed:@"introImage1Small.jpg"];
        }
        isOne = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_backGroundImage release]; _backGroundImage = nil;
    [_animationImage release]; _animationImage = nil;
    [super dealloc];
}
@end
