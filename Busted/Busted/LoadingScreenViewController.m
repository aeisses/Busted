//
//  LoadingScreenViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-22.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "LoadingScreenViewController.h"

@interface LoadingScreenViewController ()

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
        _backGroundImage.image = [UIImage imageNamed:@"2.png"];
        isOne = NO;
    } else {
        _backGroundImage.image = [UIImage imageNamed:@"1.png"];
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
    [super dealloc];
}
@end
