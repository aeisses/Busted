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

@interface StopDisplayViewController ()

@end

@implementation StopDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [_tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"TableCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ExpandedCell" bundle:nil] forCellReuseIdentifier:@"ExpandedCell"];
    _tableView.delegate = self;
    [_tableView setDataSource:self];
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink invalidate];
    [displayLink release];
    displayLink = nil;
}

- (void)frameIntervalLoop:(CADisplayLink *)sender
{
    // Here we need to reload the table
    [_tableView reloadData];
}

#pragma UITableViewDelegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    Route *route = [[_busStop.routes allObjects] objectAtIndex:indexPath.row];
    cell.routeNumber.text = route.short_name;
    cell.routeName.text = route.long_name;
    
    // This needs to be adjusted to the real time
    cell.time.text = [NSString stringWithFormat:@"%i mins",(int)(([[NSDate date] timeIntervalSince1970] - [((Trip*)[[route.trips allObjects] objectAtIndex:0]).time doubleValue])/3600)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    cell.timeRemaining.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[((Trip*)[[route.trips allObjects] objectAtIndex:0]).time doubleValue]]];

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
    NSInteger counter = 0;
    for (Route *route in _busStop.routes) {
        counter++;
    }
    return counter;
}

-(IBAction)touchHomeButton:(id)sender
{
    [self.superDelegate touchedHomeButton:NO];
}

@end
