//
//  TableCell.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *route;
@property (retain, nonatomic) IBOutlet UILabel *timeOne;
@property (retain, nonatomic) IBOutlet UILabel *timeTwo;
@property (retain, nonatomic) IBOutlet UILabel *timeThree;


@end
