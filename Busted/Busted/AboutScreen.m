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
        SLComposeViewController *mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"We need copy here!"];
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
        }];
        [_delegate showSocialMedia:mySLComposerSheet];
    }
}

- (IBAction)touchTwitterButton:(id)sender
{
    if(NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:@"We need 140 character of copy here!"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"knowtime.ca"]];
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
        }];
        [_delegate showSocialMedia:mySLComposerSheet];
    }
}

- (void)dealloc
{
    [_facebookButton release]; _facebookButton = nil;
    [_twitterButton release]; _twitterButton = nil;
    [super dealloc];
}

@end
