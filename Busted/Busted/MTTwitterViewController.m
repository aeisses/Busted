//
//  MTTwitterViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-11-26.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MTTwitterViewController.h"
#import "STTwitter.h"

@interface MTTwitterViewController ()

@end

@implementation MTTwitterViewController

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
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@""
                                                          consumerSecret:@""];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        NSLog(@"Access granted with %@", bearerToken);
        
        [twitter getUserTimelineWithScreenName:@"hfxtransit" successBlock:^(NSArray *statuses) {
            NSLog(@"-- statuses: %@", statuses);
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error: %@", error);
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchBackButton:(id)sender
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
    [_backButton release]; _backButton = nil;
    [_backGroundImage release]; _backGroundImage = nil;
}
@end
