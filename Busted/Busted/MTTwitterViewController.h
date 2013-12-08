//
//  MTTwitterViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-11-26.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentViewController.h"
#import "TwitterCell.h"

@interface MTTwitterViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *statuses;

@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITableView *twitterTable;

- (IBAction)touchBackButton:(id)sender;

@end
