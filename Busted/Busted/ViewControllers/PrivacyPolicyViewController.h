//
//  PrivacyPolicyViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-02.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewController.h"

@interface PrivacyPolicyViewController : ParentViewController

@property (retain, nonatomic) IBOutlet UIImageView *backGround;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *aboutBG;
@property (retain, nonatomic) IBOutlet UITextView *ppTexView;

- (IBAction)touchHomeButton:(id)sender;

@end
