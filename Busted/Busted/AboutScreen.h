//
//  AboutScreen.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@protocol AboutScreenDelegate <NSObject>
- (void)showSocialMedia:(SLComposeViewController*)mySLComposerSheet;
@end

@interface AboutScreen : UIView

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) id <AboutScreenDelegate> delegate;

- (IBAction)touchFacebookButton:(id)sender;
- (IBAction)touchTwitterButton:(id)sender;

@end
