//
//  AboutViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-11-26.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewController.h"

@interface AboutViewController : ParentViewController

@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIImageView *aboutScreenBacckGround;
@property (retain, nonatomic) IBOutlet UITextView *asTextView;

- (IBAction)touchBackButton:(id)sender;

@end
