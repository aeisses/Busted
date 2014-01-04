//
//  TwitterCell.h
//  Busted
//
//  Created by Aaron Eisses on 2013-12-07.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TwitterCellDelegate <NSObject>
- (void)touchReplyButton:(NSString*)statusId;
- (void)touchRetweetButton:(NSString*)statusId;
- (void)touchFavouriteButton:(NSString*)statusId isFavourite:(BOOL)favourite;
@end

@interface TwitterCell : UITableViewCell

@property (retain, nonatomic) NSString *statusId;
@property (retain, nonatomic) NSString *replyStatusId;
@property (assign, nonatomic) BOOL favourited;
@property (retain, nonatomic) IBOutlet UILabel *nameInfo;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *tweet;
@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UIButton *replyButton;
@property (retain, nonatomic) IBOutlet UIButton *retweetButton;
@property (retain, nonatomic) IBOutlet UIButton *favouriteButton;
@property (retain, nonatomic) id <TwitterCellDelegate> delegate;

- (IBAction)touchRetweetButton:(id)sender;
- (IBAction)touchReplyButton:(id)sender;
- (IBAction)touchFavouriteButton:(id)sender;

@end
