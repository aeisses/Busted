//
//  AboutScreen.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "AboutScreen.h"

@implementation AboutScreen

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)touchFacebookButton:(id)sender
{
    if(NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@""];
        [mySLComposerSheet addImage:[UIImage imageNamed:@"icon.png"]];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"knowtime.ca"]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
//                case SLComposeViewControllerResultCancelled:
//                    output = NSLocalizedStringFromTable(@"As it seems you didn't want to post to Facebook", @"ATLocalizable", @"");
//                    break;
                case SLComposeViewControllerResultDone:
                {
                    output = NSLocalizedStringFromTable(@"You succesfully posted to Facebook", @"ATLocalizable", @"");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
        }];
        [_delegate showSocialMedia:mySLComposerSheet];
    }
}

- (IBAction)touchTwitterButton:(id)sender
{
    if(NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"Sharing my bus ride with #KNOWtime. Get the app. Join the community. #crowdpowered #realtimetransit #hrm http://knowtime.ca"];
        [mySLComposerSheet addImage:[UIImage imageNamed:@"icon.png"]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultDone:
                {
                    output = NSLocalizedStringFromTable(@"You succesfully posted to Twitter", @"ATLocalizable", @"");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
        }];
        [_delegate showSocialMedia:mySLComposerSheet];
    }
}

- (IBAction)touchMailButton:(id)sender
{
    [_delegate showMailComposer];
}

- (void)dealloc
{
    [_facebookButton release]; _facebookButton = nil;
    [_twitterButton release]; _twitterButton = nil;
    [_mailButton release]; _mailButton = nil;
    _delegate = nil;
    [super dealloc];
}

@end
