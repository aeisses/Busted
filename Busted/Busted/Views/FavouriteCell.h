//
//  FavouriteCell.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-22.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopManagedObject.h"

@interface FavouriteCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *number;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIButton *favouriteButton;
@property (assign, nonatomic) BOOL isStop;

- (IBAction)touchFavouriteButton:(id)sender;

@end
