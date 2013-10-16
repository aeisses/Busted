//
//  StopsViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"

@interface FavoritesViewController : ParentViewController

@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;

- (IBAction)touchHomeButton:(id)sender;

@end
