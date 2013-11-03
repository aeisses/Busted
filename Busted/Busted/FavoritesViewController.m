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
#import "RoutesViewController.h"

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
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [_tableView release]; _tableView = nil;
    if (routeName)
        [routeName release];
    [super dealloc];
}

- (IBAction)touchHomeButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        [self.superDelegate touchedHomeButton:YES];
    });
    dispatch_release(menuQueue);
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
        stop = nil;
        return cell;
    } else if (indexPath.section == 1) {
        Routes *route = [[[WebApiInterface sharedInstance] getFavoriteRoutes] objectAtIndex:indexPath.row];
        cell.name.text = route.longName;
        cell.number.text = route.shortName;
        cell.favoriteButton.selected = [route.isFavorite boolValue];
        cell.isStop = NO;
        route = nil;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *imageView;
    switch (section)
    {
        case 0:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stops.png"]];
//            imageView.frame = (CGRect){0,0,320,32};
            break;
        case 1:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"routes.png"]];
//            imageView.frame = (CGRect){0,0,320,32};
            break;
        default:
            imageView = nil;
            break;
    }
    return [imageView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
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
        StopDisplayViewController *stopsVC;
        if (IS_IPHONE_5)
        {
            stopsVC = [[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewController" bundle:nil];
        } else {
            stopsVC = [[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewControllerSmall" bundle:nil];
        }
        Stop *stop = [[[WebApiInterface sharedInstance] getFavoriteStops] objectAtIndex:indexPath.row];
        stopsVC.superDelegate = self;
        BusStop *busStop = [[BusStop alloc] initWithCode:[NSNumber numberWithInt:[stop.code intValue]]];
        stopsVC.busStop =  busStop;
        [busStop release];
        [_delegate loadViewController:stopsVC];
        [stopsVC release];
    } else if (indexPath.section == 1)
    {
        if (IS_IPHONE_5)
        {
            _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        }
        else
        {
            _mapVC = [[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil];
        }
        Routes *route = [[[WebApiInterface sharedInstance] getFavoriteRoutes] objectAtIndex:indexPath.row];
        routeName = [[NSString alloc] initWithString:route.shortName];
        [[WebApiInterface sharedInstance] loadPathForRoute:routeName];
//        _mapVC.delegate = self;
        _mapVC.isStops = YES;
        [_delegate loadViewController:_mapVC];
//        _mapVC.delegate = nil;
        [_mapVC release];
    }
}

#pragma MapViewControllerDelegate
- (void)mapFinishedLoading
{
//    if (routeName) {
//        NSArray *routesArray = [[RoutesViewController sharedInstance] getBusRoutes];
//        MyRoute *route = [[MyRoute alloc] init];
//        route.shortName = routeName;
//        [_mapVC addRoute:[routesArray objectAtIndex:[routesArray indexOfObject:route]]];
//        //        [_mapVC addRoute:[_delegate getRoute:[_routeButton.titleLabel.text integerValue]]];
//    }
//    _mapVC.delegate = nil;
//    [_mapVC release];
}


- (void)touchedHomeButton:(BOOL)isAll
{
    [self.superDelegate touchedHomeButton:isAll];
}

@end
