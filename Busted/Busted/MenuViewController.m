//
//  MenuViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MenuViewController.h"
#import "WebApiInterface.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface MenuViewController (PrivateMethods)
- (void)disableButton;
- (void)enableButton;
@end

@implementation MenuViewController

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
    NSArray *nibObjects = nil;
    if (IS_IPHONE_5)
    {
        nibObjects = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] loadNibNamed:@"AboutScreen" owner:self options:nil]];
    }
    else
    {
        nibObjects = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] loadNibNamed:@"AboutScreenSmall" owner:self options:nil]];
    }
    _aboutView = [[nibObjects objectAtIndex:0] retain];
    _aboutView.delegate = self;
    [nibObjects release];
    if (IS_IPHONE_5)
    {
        _aboutView.frame = (CGRect){314,49,241,519};
    }
    else
    {
        _aboutView.frame = (CGRect){314,41,241,439};
    }
    [self.view addSubview:self.aboutView];
    isAboutScreenVisible = NO;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_mapVC)
    {
        [_mapVC release];
        _mapVC = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.swipeRight.enabled = NO;
    self.swipeLeft.enabled = NO;
    self.swipeUp.enabled = NO;
    self.swipeDown.enabled = YES;
    _aboutView.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    _aboutView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button.tag == 1) {
        dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
        dispatch_async(menuQueue, ^{
            RoutesViewController *rootsVC = nil;
            if (IS_IPHONE_5)
            {
                rootsVC = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:nil];
            }
            else
            {
                rootsVC = [[RoutesViewController alloc] initWithNibName:@"RoutesViewControllerSmall" bundle:nil];
            }
            rootsVC.delegate = self;
            [_delegate loadViewController:rootsVC];
            [rootsVC release];
        });
        dispatch_release(menuQueue);
//        dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//        dispatch_async(googleQueue, ^{
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
//                                                                                                action:@"viewload"
//                                                                                                 label:@"Routes View Load"
//                                                                                                 value:nil] build]];
//        });
//        dispatch_release(googleQueue);
    } else if (button.tag == 2) {
        dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
        dispatch_async(menuQueue, ^{
            if (IS_IPHONE_5)
            {
                _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
            }
            else
            {
                _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil];
            }
            _mapVC.delegate = self;
            _mapVC.isStops = NO;
            [_delegate loadViewController:_mapVC];
        });
        dispatch_release(menuQueue);
//        dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//        dispatch_async(googleQueue, ^{
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
//                                                                                                action:@"viewload"
//                                                                                                 label:@"Stops View Load"
//                                                                                                 value:nil] build]];
//        });
//        dispatch_release(googleQueue);
    } else if (button.tag == 3) {
        dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
        dispatch_async(menuQueue, ^{
            FavoritesViewController *favVC = nil;
            if (IS_IPHONE_5)
            {
                favVC = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
            }
            else
            {
                favVC = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewControllerSmall" bundle:nil];
            }
            favVC.delegate = self;
            [_delegate loadViewController:favVC];
            [favVC release];
        });
        dispatch_release(menuQueue);
//        dispatch_queue_t googleQueue  = dispatch_queue_create("google queue", NULL);
//        dispatch_async(googleQueue, ^{
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
//                                                                                                                        action:@"viewload"
//                                                                                                                         label:@"Favorites View Load"
//                                                                                                                         value:nil] build]];
//        });
//        dispatch_release(googleQueue);
    } else if (button.tag == 4) {
        if (isAboutScreenVisible)
        {
            [UIView animateWithDuration:0.50 animations:^{
                if (IS_IPHONE_5)
                {
                    _aboutView.frame = (CGRect){314,49,241,519};
                    _button4.frame = (CGRect){265,73,50,50};
                } else {
                    _aboutView.frame = (CGRect){314,41,241,439};
                    _button4.frame = (CGRect){265,62,50,50};
                }
            }completion:^(BOOL finished) {
                [self enableButton];
                isAboutScreenVisible = NO;
            }];
        } else {
            [self disableButton];
            [UIView animateWithDuration:0.50 animations:^{
                if (IS_IPHONE_5)
                {
                    _aboutView.frame = (CGRect){79,49,241,519};
                    _button4.frame = (CGRect){30,73,50,50};
                } else {
                    _aboutView.frame = (CGRect){79,41,241,439};
                    _button4.frame = (CGRect){30,62,50,50};
                }
            } completion:^(BOOL finished) {
                isAboutScreenVisible = YES;
            }];
        }
    }
}

- (IBAction)touchTrackButton:(id)sender
{
    [self.superDelegate swipe:self.swipeDown];
}

- (void)dealloc
{
    [_button1 release]; _button1 = nil;
    [_button2 release]; _button2 = nil;
    [_button3 release]; _button3 = nil;
    [_button4 release]; _button4 = nil;
    [_aboutView release]; _aboutView = nil;
    [super dealloc];
}

#pragma PrivateMethods
- (void)disableButton
{
    _button1.enabled = NO;
    _button2.enabled = NO;
    _button3.enabled = NO;
}

- (void)enableButton
{
    _button1.enabled = YES;
    _button2.enabled = YES;
    _button3.enabled = YES;
}

#pragma RoutesViewControllerDelegate Methods
- (void)loadMapViewController:(MapViewController*)mapViewController
{
    [_delegate loadViewController:mapViewController];
}

- (BusRoute*)getRoute:(NSInteger)routeNumber
{
    return [_delegate getRoute:routeNumber];
}

- (NSArray*)getRoutes
{
    return [_delegate getRoutes];
}

#pragma MapViewControllerDelegate
- (void)mapFinishedLoading
{
//    if (![_routeButton.titleLabel.text isEqualToString:@"?"]) {
//        [_mapVC addRoute:[_delegate getRoute:[_routeButton.titleLabel.text integerValue]]];
//    }
//    _mapVC.delegate = nil;
//    [_mapVC release];
}

- (void)updateStops:(CLLocationCoordinate2D)mapCenter
{
    [[WebApiInterface sharedInstance] requestPlace:mapCenter];
}

- (void)loadViewController:(UIViewController*)vc
{
    [_delegate loadViewController:vc];
}

#pragma AboutScreenDelegate
- (void)showSocialMedia:(SLComposeViewController *)mySLComposerSheet
{
    [self presentViewController:mySLComposerSheet animated:YES completion:nil];
}

- (void)showMailComposer
{
    if ([MFMailComposeViewController canSendMail]) {
        [UIView animateWithDuration:0.50 animations:^{
            if (IS_IPHONE_5)
            {
                _aboutView.frame = (CGRect){314,49,241,519};
                _button4.frame = (CGRect){265,73,50,50};
            } else {
                _aboutView.frame = (CGRect){314,41,241,439};
                _button4.frame = (CGRect){265,62,50,50};
            }
        }completion:^(BOOL finished) {
            isAboutScreenVisible = NO;
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"My Subject"];
            [controller setMessageBody:@"Hello there." isHTML:NO];
            if (controller) [self presentViewController:controller animated:YES completion:nil];
            [controller release];
            [self enableButton];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"It appears your mail client is not setup." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
