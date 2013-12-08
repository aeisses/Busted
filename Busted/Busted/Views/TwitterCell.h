//
//  TwitterCell.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-07.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *nameInfo;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *tweet;

@end
