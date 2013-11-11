//
//  AboutScreen.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)touchFacebookButton:(id)sender
{
    if(NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"I'm tracking my bus in real time with KNOWtime. Get the app. Join the community."];
        [mySLComposerSheet addImage:[UIImage imageNamed:@"icon.png"]];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"knowtime.ca"]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = NSLocalizedStringFromTable(@"As it seems you didn't want to post to Facebook", @"ATLocalizable", @"");
                    break;
                case SLComposeViewControllerResultDone:
                    output = NSLocalizedStringFromTable(@"You succesfully posted to Facebook", @"ATLocalizable", @"");
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }];
        [_delegate showSocialMedia:mySLComposerSheet];
    }
}

- (IBAction)touchTwitterButton:(id)sender
{
    if(NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"Tracking my bus with #KNOWtime. Get the app. Join the community. #crowdpowered #realtimetransit #hrm http://knowtime.ca"];
        [mySLComposerSheet addImage:[UIImage imageNamed:@"icon.png"]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = NSLocalizedStringFromTable(@"As it seems you didn't want to post to Twitter", @"ATLocalizable", @"");
                    break;
                case SLComposeViewControllerResultDone:
                    output = NSLocalizedStringFromTable(@"You succesfully posted to Twitter", @"ATLocalizable", @"");
                    break;
                default:
                    break;
            } //check if everythink worked properly. Give out a message on the state.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
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
    [super dealloc];
}

@end