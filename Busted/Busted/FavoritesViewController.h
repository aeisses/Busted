//
//  StopsViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"

@protocol FavoritesViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
@end

@interface FavoritesViewController : ParentViewController <UITableViewDataSource,UITableViewDelegate,ParentViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) id <FavoritesViewControllerDelegate> delegate;

- (IBAction)touchHomeButton:(id)sender;

@end
