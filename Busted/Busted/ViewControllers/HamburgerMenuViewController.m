//
//  HamburgerMenuViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-11-24.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "HamburgerMenuViewController.h"
#import "Flurry.h"

@interface HamburgerMenuViewController ()

@end

@implementation HamburgerMenuViewController

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

- (IBAction)touchShareButton:(id)sender
{
    [self.superDelegate swipe:self.swipeDown];
    [Flurry logEvent:@"Track_Button_Pressed"];
}

- (IBAction)touchAboutButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        AboutViewController *aboutVC = nil;
        if (IS_IPHONE_5)
        {
            aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        }
        else
        {
            aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewControllerSmall" bundle:nil];
        }
        [_delegate loadViewController:aboutVC];
        [aboutVC release];
    });
    dispatch_release(menuQueue);
    [Flurry logEvent:@"About_Button_Pressed"];
}

- (IBAction)touchStopsButton:(id)sender
{
    [_delegate hideStops];
}

- (IBAction)touchFavouritesButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        FavouritesViewController *favVC = nil;
        if (IS_IPHONE_5)
        {
            favVC = [[FavouritesViewController alloc] initWithNibName:@"FavouritesViewController" bundle:nil];
        }
        else
        {
            favVC = [[FavouritesViewController alloc] initWithNibName:@"FavouritesViewControllerSmall" bundle:nil];
        }
        [_delegate loadViewController:favVC];
        [favVC release];
    });
    dispatch_release(menuQueue);
    [Flurry logEvent:@"Favourites_Button_Pressed"];
}

- (IBAction)touchMetroTransitTwitter:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        MTTwitterViewController *mtTVC = nil;
        if (IS_IPHONE_5)
        {
            mtTVC = [[MTTwitterViewController alloc] initWithNibName:@"MTTwitterViewController" bundle:nil];
        }
        else
        {
            mtTVC = [[MTTwitterViewController alloc] initWithNibName:@"MTTwitterViewControllerSmall" bundle:nil];
        }
        [_delegate loadViewController:mtTVC];
        [mtTVC release];
    });
    dispatch_release(menuQueue);
    [Flurry logEvent:@"MetroTransitTwitter_Button_Pressed"];
}

- (void)dealloc
{
    [super dealloc];
    [_backGroundImage release]; _backGroundImage = nil;
    [_shareButton release]; _shareButton = nil;
    [_aboutButton release]; _aboutButton = nil;
    [_stopsButton release]; _stopsButton = nil;
    [_favourtiesButton release]; _favourtiesButton = nil;
    [_metroTransitTwitter release]; _metroTransitTwitter = nil;
    _delegate = nil;
}

@end
