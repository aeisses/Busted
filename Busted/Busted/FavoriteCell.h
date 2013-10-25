//
//  FavoriteCell.h
//  Busted
//
//  Created by Aaron Eisses on 2013-10-22.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
#import "Route.h"

@interface FavoriteCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *number;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIButton *favoriteButton;
@property (assign, nonatomic) BOOL isStop;

- (IBAction)touchFavoriteButton:(id)sender;

@end