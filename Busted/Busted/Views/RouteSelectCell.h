//
//  BusRouteViewCell.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-20.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteSelectCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *backGround;
@property (retain, nonatomic) IBOutlet UILabel *number;

- (void)setToRed;

@end
