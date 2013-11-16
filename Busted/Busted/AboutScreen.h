//
//  AboutScreen.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@protocol AboutScreenDelegate <NSObject>
- (void)showSocialMedia:(SLComposeViewController*)mySLComposerSheet;
- (void)showMailComposer;
@end

@interface AboutScreen : UIView

@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (retain, nonatomic) IBOutlet UIButton *twitterButton;
@property (retain, nonatomic) IBOutlet UIButton *mailButton;
@property (retain, nonatomic) id <AboutScreenDelegate> delegate;

- (IBAction)touchFacebookButton:(id)sender;
- (IBAction)touchTwitterButton:(id)sender;
- (IBAction)touchMailButton:(id)sender;

@end
