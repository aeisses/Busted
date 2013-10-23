//
//  FavoriteCell.m
//  Busted
//
//  Created by Aaron Eisses on 2013-10-22.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "FavoriteCell.h"

@implementation FavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)touchFavoriteButton:(id)sender
{
    _favoriteButton.selected = !_favoriteButton.selected;
}

- (NSString *) reuseIdentifier {
    return @"FavoriteCell";
}

- (void)dealloc
{
    [_number release]; _number = nil;
    [_name release]; _name = nil;
    [_favoriteButton release]; _favoriteButton = nil;
    [super dealloc];
}

@end
