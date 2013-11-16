//
//  FavouriteCell.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-10-22.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "FavouriteCell.h"
#import "WebApiInterface.h"

@implementation FavouriteCell

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

- (IBAction)touchFavouriteButton:(id)sender
{
    _favouriteButton.selected = !_favouriteButton.selected;
    if (_isStop) {
        [[WebApiInterface sharedInstance] setFavourite:_favouriteButton.selected forStop:[NSNumber numberWithInt:[_number.text intValue]]];
    } else {
        [[WebApiInterface sharedInstance] setFavourite:_favouriteButton.selected forRoute:_number.text];
    }
}

- (NSString *) reuseIdentifier {
    return @"FavouriteCell";
}

- (void)dealloc
{
    [_number release]; _number = nil;
    [_name release]; _name = nil;
    [_favouriteButton release]; _favouriteButton = nil;
    [super dealloc];
}

@end
