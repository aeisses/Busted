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

@interface StopDisplayViewController ()

@end

@implementation StopDisplayViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableViewDelegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Route *route = [[_busStop.routes allObjects] objectAtIndex:indexPath.row];
    NSArray *nibObjects = [[NSArray alloc] initWithArray:[[NSBundle mainBundle] loadNibNamed:@"MenuScreen" owner:self options:nil]];
    TableCell *cell = [[nibObjects objectAtIndex:0] retain];
    cell.route.text = route.short_name;
    cell.timeOne.text = [NSString stringWithFormat:@"%f",[((Trip*)[[route.trips allObjects] objectAtIndex:0]).time doubleValue]];
    cell.timeTwo.text = [[route.trips allObjects] objectAtIndex:1];
    cell.timeThree.text = [[route.trips allObjects] objectAtIndex:2];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger counter = 0;
    for (Route *route in _busStop.routes) {
        counter++;
    }
    return counter;
}
@end
