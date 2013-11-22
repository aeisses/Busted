//
//  StopsViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "ParentViewController.h"
#import "MapViewController.h"
#import "WebApiInterface.h"
#import "FavouriteCell.h"
#import "RoutesViewController.h"

@protocol FavouritesViewControllerDelegate <NSObject>
- (void)loadViewController:(UIViewController*)vc;
- (NSArray*)getRoutes;
@end

@interface FavouritesViewController : ParentViewController <UITableViewDataSource,UITableViewDelegate,ParentViewControllerDelegate>
{
    NSString *routeName;
}

@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) id <FavouritesViewControllerDelegate> delegate;
@property (retain, nonatomic) MapViewController *mapVC;

- (IBAction)touchHomeButton:(id)sender;

@end
