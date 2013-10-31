//
//  StopDisplayViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "StopDisplayViewController.h"
#import "Route.h"
#import "TableCell.h"
#import "Trip.h"
#import "BusStop.h"
#import "RouteWithTime.h"
#import "StopTimes.h"
#import "StopsHeader.h"

@interface StopDisplayViewController ()

@end

@implementation StopDisplayViewController

static id instance;

+ (StopDisplayViewController*)sharedInstance
{
    if (!instance) {
        if (IS_IPHONE)
        {
            return [[[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewControllerSmall" bundle:nil] autorelease];
        } else {
            return [[[StopDisplayViewController alloc] initWithNibName:@"StopDisplayViewController" bundle:nil] autorelease];
        }
    }
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    instance = self;
    return instance;
}

- (void)setRoutes:(NSArray*)routes
{
    _routes = [[NSArray alloc] initWithArray:routes];
    [_tableView reloadData];
}

- (void)setBusStop:(BusStop *)busStop
{
    if (_busStop)
    {
        [_busStop release]; _busStop = nil;
    }
    _busStop = [busStop retain];
    [[WebApiInterface sharedInstance] getRouteForIdent:_busStop.code];

}

- (void)viewDidLoad
{
    [_tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"TableCell"];
    _tableView.delegate = self;
    [_tableView setDataSource:self];
    _tableView.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(frameIntervalLoop:)] retain];
    [displayLink setFrameInterval:500];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _favoriteButton.selected = _busStop.isFavorite;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release];
    displayLink = nil;
    [[WebApiInterface sharedInstance] setFavorite:_favoriteButton.selected forStop:_busStop.code];
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    // Here we need to reload the table
    [_tableView reloadData];
}

- (void)dealloc
{
    if (_routes)
        [_routes release];
    [super dealloc];
}

#pragma UITableViewDelegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_routes)
        return nil;
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    RouteWithTime *route = [_routes objectAtIndex:indexPath.row];
    cell.routeNumber.text = route.shortName;
    cell.routeName.text = route.longName;
    cell.busStopCode = _busStop.code;
    if ([expandedSections containsIndex:indexPath.row])
    {
        cell.downArrow.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        cell.time.hidden = NO;
        cell.timeRemaining.hidden = NO;
        cell.timeLable.hidden = NO;
    } else {
        cell.downArrow.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
        cell.time.hidden = YES;
        cell.timeRemaining.hidden = YES;
        cell.timeLable.hidden = YES;
        return cell;
    }
    // This needs to be adjusted to the real time
    cell.time.text = @"unknown";
    cell.timeRemaining.text = @"unknown";
    int minDiff = 0;
    NSString *departTime = @"unknown";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDateFormatter *currentTimeFormatter = [[NSDateFormatter alloc] init];
    [currentTimeFormatter setDateFormat:@"YYYY-MM-dd"];
    for (StopTimes *times in route.times)
    {
        NSDate *stopDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[currentTimeFormatter stringFromDate:[NSDate date]],times.departure]];
        int diff = [stopDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        if (diff > 0 && (minDiff <= 0 || minDiff > diff))
        {
            minDiff = diff;
            departTime = [NSString stringWithString:times.departure];
        }
    }
    [formatter release];
    [currentTimeFormatter release];
    cell.time.text = [NSString stringWithFormat:@"%i mins",(int)minDiff/60];
    cell.timeRemaining.text = departTime;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([expandedSections containsIndex:indexPath.row])
    {
        [expandedSections removeIndex:indexPath.row];
    } else {
        [expandedSections addIndex:indexPath.row];
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([expandedSections containsIndex:indexPath.row])
    {
        return 86;
    }
    return 43;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_routes)
        return [_routes count];
    return 0;
//    return [_busStop.routesId count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nibObjects = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] loadNibNamed:@"StopsHeader" owner:self options:nil]];
    StopsHeader *stopsHeader = [nibObjects objectAtIndex:0];
    [nibObjects release];
    stopsHeader.goTimeNumber.text = [NSString stringWithFormat:@"%@",_busStop.code];
    stopsHeader.title.text = _busStop.title;
    return stopsHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

- (IBAction)touchHomeButton:(id)sender
{
    [self.superDelegate touchedHomeButton:NO];
}

- (IBAction)touchFavoriteButton:(id)sender
{
    _favoriteButton.selected = !_favoriteButton.selected;
    _busStop.isFavorite = _favoriteButton.selected;
}

@end
