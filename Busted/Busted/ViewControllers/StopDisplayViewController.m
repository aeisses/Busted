//
//  StopDisplayViewController.m
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-30.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import "StopDisplayViewController.h"
#import "WebApiInterface.h"

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
//        expandedSections = [[NSMutableIndexSet alloc] init];
        _activityMonitor = [[UIActivityIndicatorView alloc] initWithFrame:(CGRect){135,225,50,50}];
        _activityMonitor.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    instance = self;
    return instance;
}

- (void)setRoutes:(NSArray*)routes
{
    _routes = [[NSArray alloc] initWithArray:routes];
    if (_routes && [_routes count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There are no buses scheduled to service this stop today at this time." delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [_activityMonitor stopAnimating];
    [_activityMonitor removeFromSuperview];
    [_tableView reloadData];
}

- (void)setBusStop:(StopAnnotation *)busStop
{
    if (_busStop)
    {
        [_busStop release]; _busStop = nil;
    }
    _busStop = [busStop retain];
    [[WebApiInterface sharedInstance] getRouteForIdent:_busStop.code];
    NSDictionary *routesParams = [NSDictionary dictionaryWithObjectsAndKeys:@"Route", [NSString stringWithFormat:@"%li",(long)[_busStop.code integerValue]], nil];
    [Flurry logEvent:@"Stops_View_Button_Pressed" withParameters:routesParams];
}

- (NSArray*)getBusRoutes
{
    NSArray *routes = [_delegate getRoutes];
    NSMutableArray *routesM = [[NSMutableArray alloc] initWithCapacity:[routes count]];
    //    int counter = 0;
    for (RouteManagedObject *route in routes)
    {
        Route *myRoute = [[Route alloc] init];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        NSNumber *number = [numberFormatter numberFromString:route.shortName];
        if (number != nil) {
            myRoute.ident = [route.shortName integerValue];
        } else {
            //            myRoute.ident = counter + 10000;
            //            counter++;
            [myRoute release];
            continue;
        }
        myRoute.longName = route.longName;
        myRoute.shortName = route.shortName;
        myRoute.isFavourite = [route.isFavourite boolValue];
        [routesM addObject:myRoute];
        [myRoute release];
    }
    return [(NSArray*)routesM autorelease];
}

- (void)viewDidLoad
{
    [_tableView registerNib:[UINib nibWithNibName:@"StopSelectCell" bundle:nil] forCellReuseIdentifier:@"StopSelectCell"];
    _tableView.delegate = self;
    [_tableView setDataSource:self];
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView addSubview:_activityMonitor];
    [_activityMonitor startAnimating];
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
    _favouriteButton.selected = _busStop.isFavourite;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release];
    displayLink = nil;
    [[WebApiInterface sharedInstance] setFavourite:_favouriteButton.selected forStop:_busStop.code];
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
    if (_busStop)
        [_busStop release];
//    [expandedSections release];
    [_homeButton release]; _homeButton = nil;
    [_tableView release]; _tableView = nil;
    [_favouriteButton release]; _favouriteButton = nil;
    [_activityMonitor release]; _activityMonitor = nil;
    [super dealloc];
}

- (NSDate*)getStopDate:(NSString*)departTime withFromatter:(NSDateFormatter*)formatter andFormatter:(NSDateFormatter*)currentTimeFormatter
{
    NSDate *returnDate = nil;
    NSArray *components = [departTime componentsSeparatedByString:@":"];
    if ([components count] >= 2 && [(NSString*)[components objectAtIndex:0] integerValue] >= 24)
    {
        NSDate *tempDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@:%@",[currentTimeFormatter stringFromDate:[NSDate date]],@"00",(NSString*)[components objectAtIndex:1]]];
        returnDate = [NSDate dateWithTimeIntervalSinceReferenceDate:([tempDate timeIntervalSinceReferenceDate] + 86400)];
    } else {
        returnDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[currentTimeFormatter stringFromDate:[NSDate date]],departTime]];
    }
    return returnDate;
}

#pragma UITableViewDelegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_routes)
        return nil;
    StopSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StopSelectCell" forIndexPath:indexPath];
    if (_routes.count < indexPath.row) // Check to see if 
        return nil;
    RouteWithTime *route = [_routes objectAtIndex:indexPath.row];
    cell.routeNumber.text = route.shortName;
    cell.routeName.text = route.longName;
    cell.busStopCode = _busStop.code;
//    if ([expandedSections containsIndex:indexPath.row])
//    {
//        cell.downArrow.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
//        cell.time.hidden = NO;
//        cell.timeRemaining.hidden = NO;
//        cell.timeLable.hidden = NO;
//    } else {
//        cell.downArrow.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
//        cell.time.hidden = YES;
//        cell.timeRemaining.hidden = YES;
//        cell.timeLable.hidden = YES;
//        return cell;
//    }
    // This needs to be adjusted to the real time
    cell.time.text = @"unknown";
    cell.timeRemaining.text = @"unknown";
    int minDiff = 0;
    NSString *departTime = @"unknown";
    
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setDateFormat:@"h:mm"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDateFormatter *currentTimeFormatter = [[NSDateFormatter alloc] init];
    [currentTimeFormatter setDateFormat:@"yyyy-MM-dd"];

    long counter = -1;
    for (StopTimes *times in route.times)
    {
        NSDate *stopDate = [self getStopDate:times.departure withFromatter:formatter andFormatter:currentTimeFormatter];
        int diff = [stopDate timeIntervalSinceNow];
        if (diff > 0 && (minDiff <= 0 || minDiff > diff))
        {
            minDiff = diff;
            departTime = [displayFormatter stringFromDate:stopDate];
            counter = [route.times indexOfObject:times];
        }
    }
    if (minDiff != 0) {
        cell.timeRemaining.text = [NSString stringWithFormat:@"%i min",(int)minDiff/60];
        cell.time.text = departTime;
    }
    if (counter+1 >= [route.times count] || counter == -1) {
        cell.timeNext.text = @"unknown";
        cell.timeNextNext.text = @"unknown";
        cell.timeRemainingNext.text = @"unknown";
        cell.timeRemainingNextNext.text = @"unknown";
    } else {
        NSDate *stopDateNext = [self getStopDate:((StopTimes*)[route.times objectAtIndex:counter+1]).departure withFromatter:formatter andFormatter:currentTimeFormatter];
        cell.timeRemainingNext.text = [NSString stringWithFormat:@"%i min",(int)[stopDateNext timeIntervalSinceNow]/60];
        cell.timeNext.text = [displayFormatter stringFromDate:stopDateNext];
        if (counter+2 >= [route.times count]) {
            cell.timeNextNext.text = @"unknown";
            cell.timeRemainingNextNext.text = @"unknown";
        } else {
            NSDate *stopDateNextNext = [self getStopDate:((StopTimes*)[route.times objectAtIndex:counter+2]).departure withFromatter:formatter andFormatter:currentTimeFormatter];
            cell.timeRemainingNextNext.text = [NSString stringWithFormat:@"%i min",(int)[stopDateNextNext timeIntervalSinceNow]/60];
            cell.timeNextNext.text = [displayFormatter stringFromDate:stopDateNextNext];
        }
    }
    [displayFormatter release];
    [formatter release];
    [currentTimeFormatter release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    StopSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StopSelectCell" forIndexPath:indexPath];
    MapViewController *mapVC = nil;
    if (IS_IPHONE_5)
    {
        mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    }
    else
    {
        mapVC = [[MapViewController alloc] initWithNibName:@"MapViewControllerSmall" bundle:nil];
    }
    RouteWithTime *routeWTime = [_routes objectAtIndex:indexPath.row];
    dispatch_queue_t dataQueue  = dispatch_queue_create("data queue", NULL);
    dispatch_async(dataQueue, ^{
        [[WebApiInterface sharedInstance] loadPathForRoute:routeWTime.shortName callBack:mapVC];
    });
    dispatch_release(dataQueue);
    mapVC.isStops = YES;
    [_delegate loadViewController:mapVC];
    NSArray *routesArray = [self getBusRoutes];
    Route *route = [[Route alloc] init];
    route.shortName = routeWTime.shortName;
    [mapVC addRoute:[routesArray objectAtIndex:[routesArray indexOfObject:route]]];
    [route release];
    [mapVC release];
    mapVC = nil;
    NSDictionary *routesParams = [NSDictionary dictionaryWithObjectsAndKeys:@"Route", routeWTime.shortName, nil];
    [Flurry logEvent:@"Routes_View_Button_Pressed" withParameters:routesParams];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([expandedSections containsIndex:indexPath.row])
//    {
//        return 86;
//    }
    return 70;
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
//    stopsHeader.goTimeNumber.text = [NSString stringWithFormat:@"%@",_busStop.code];
    stopsHeader.title.text = _busStop.longTitle;
    return stopsHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

- (IBAction)touchHomeButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        [self.superDelegate touchedHomeButton:NO];
    });
    dispatch_release(menuQueue);
}

- (IBAction)touchFavouriteButton:(id)sender
{
    _favouriteButton.selected = !_favouriteButton.selected;
    _busStop.isFavourite = _favouriteButton.selected;
}

@end
