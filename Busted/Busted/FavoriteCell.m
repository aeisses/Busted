//
//  FavoriteCell.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-22.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "FavoriteCell.h"
#import "WebApiInterface.h"

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
}

- (IBAction)touchFavoriteButton:(id)sender
{
    _favoriteButton.selected = !_favoriteButton.selected;
    if (_isStop) {
        [[WebApiInterface sharedInstance] setFavorite:_favoriteButton.selected forStop:[NSNumber numberWithInt:[_number.text intValue]]];
    } else {
        [[WebApiInterface sharedInstance] setFavorite:_favoriteButton.selected forRoute:_number.text];
    }
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
