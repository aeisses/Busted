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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (IS_IPHONE_5)
    {
        _indicator.center = (CGPoint){self.view.frame.size.width/2,450};
    } else {
        _indicator.center = (CGPoint){self.view.frame.size.width/2,410};
    }
    [self.view addSubview:_indicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_indicator startAnimating];
    [_delegate loadScreenLoaded];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_indicator stopAnimating];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_backGroundImage release]; _backGroundImage = nil;
    [_indicator removeFromSuperview];
    [_indicator release];
    [super dealloc];
}
@end
