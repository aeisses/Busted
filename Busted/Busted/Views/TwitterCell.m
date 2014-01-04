//
//  TwitterCell.m
//  Busted
//
//  Created by Aaron Eisses on 2013-12-07.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "TwitterCell.h"

@implementation TwitterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)touchRetweetButton:(id)sender
{
    
}

- (IBAction)touchReplyButton:(id)sender
{
    
}

- (IBAction)touchFavouriteButton:(id)sender
{
    
}

- (void)dealloc
{
    [super dealloc];
    [_nameInfo release]; _nameInfo = nil;
    [_tweet release]; _tweet = nil;
    [_date release]; _date = nil;
    [_iconImage release]; _iconImage = nil;
    [_replyButton release]; _replyButton = nil;
    [_retweetButton release]; _retweetButton = nil;
    [_favouriteButton release]; _favouriteButton = nil;
}
@end
