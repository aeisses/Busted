//
//  StopsViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "ParentViewController.h"
#import "MapViewController.h"

@protocol FavoritesViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (NSArray*)getRoutes;
@end

@interface FavoritesViewController : ParentViewController <UITableViewDataSource,UITableViewDelegate,ParentViewControllerDelegate,MapViewControllerDelegate>
{
    NSString *routeName;
}

@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) id <FavoritesViewControllerDelegate> delegate;
@property (retain, nonatomic) MapViewController *mapVC;

- (IBAction)touchHomeButton:(id)sender;

@end
