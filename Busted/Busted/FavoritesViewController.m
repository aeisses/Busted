//
//  StopsViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "FavoritesViewController.h"
#import "WebApiInterface.h"
#import "FavoriteCell.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)viewDidLoad
{
    [_tableView registerNib:[UINib nibWithNibName:@"FavoriteCell" bundle:nil] forCellReuseIdentifier:@"FavoriteCell"];
    _tableView.delegate = self;
    [_tableView setDataSource:self];
    _tableView.backgroundColor = [UIColor clearColor];
    self.swipeDown.enabled = YES;
    self.swipeUp.enabled = NO;
    self.swipeLeft.enabled = NO;
    self.swipeRight.enabled = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_backGroundImage release]; _backGroundImage = nil;
    [_homeButton release]; _homeButton = nil;
    [_tableView release]; _tableView = nil;
    [super dealloc];
}

- (IBAction)touchHomeButton:(id)sender
{
    [self.superDelegate touchedHomeButton:YES];
}

#pragma UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        Stop *stop = [[[WebApiInterface sharedInstance] getFavoriteStops] objectAtIndex:indexPath.row];
        cell.name.text = stop.name;
        cell.number.text = stop.code;
        cell.favoriteButton.selected = [stop.isFavorite boolValue];
        cell.isStop = YES;
        return cell;
    } else if (indexPath.section == 1) {
        Route *route = [[[WebApiInterface sharedInstance] getFavoriteRoutes] objectAtIndex:indexPath.row];
        cell.name.text = route.long_name;
        cell.number.text = route.short_name;
        cell.favoriteButton.selected = [route.isFavorite boolValue];
        cell.isStop = NO;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [[[WebApiInterface sharedInstance] getFavoriteStops] count];
    return [[[WebApiInterface sharedInstance] getFavoriteRoutes] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Stops";
            break;
        case 1:
            sectionName = @"Routes";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        StopDisplayViewController *stopsVC = [[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewController" bundle:nil];
        Stop *stop = [[[WebApiInterface sharedInstance] getFavoriteStops] objectAtIndex:indexPath.row];
        stopsVC.superDelegate = self;
        BusStop *busStop = [[BusStop alloc] initWithCode:[NSNumber numberWithInt:[stop.code intValue]]];
        stopsVC.busStop =  busStop;
        [busStop release];
        [_delegate loadViewController:stopsVC];
        [stopsVC release];
    } else if (indexPath.section == 1)
    {
        
    }
}

- (void)touchedHomeButton:(BOOL)isAll
{
    [self.superDelegate touchedHomeButton:isAll];
}

@end
