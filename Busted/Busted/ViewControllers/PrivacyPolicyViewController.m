//
//  PrivacyPolicyViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-12-02.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController ()

@end

@implementation PrivacyPolicyViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchHomeButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        [self.superDelegate touchedHomeButton:NO];
    });
    dispatch_release(menuQueue);
}

- (void)dealloc
{
    [super dealloc];
    [_backGround release]; _backGround = nil;
    [_homeButton release]; _homeButton = nil;
    [_aboutBG release]; _aboutBG = nil;
    [_ppTexView release]; _ppTexView = nil;
}

@end
