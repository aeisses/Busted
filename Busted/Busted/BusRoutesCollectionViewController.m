//
//  BusRoutesCollectionViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusRoutesCollectionViewController.h"

@interface BusRoutesCollectionViewController ()

@end

@implementation BusRoutesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)touchExitButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)viewDidLoad
{
   NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ident" ascending:YES];
    _routes = [[[_delegate getBusRoutes] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] retain];

    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){self.view.frame.origin.x,_exitButton.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-_exitButton.frame.size.height} collectionViewLayout:layout];
    [layout release];
    NSLog(@"Frame: %f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
    NSLog(@"FrameExit: %f, %f, %f, %f",_exitButton.frame.origin.x,_exitButton.frame.origin.y,_exitButton.frame.size.width,_exitButton.frame.size.height);
    NSLog(@"Collection: %f, %f, %f, %f",_collectionView.frame.origin.x,_collectionView.frame.origin.y,_collectionView.frame.size.width,_collectionView.frame.size.height);
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
  
    [_collectionView registerNib:[UINib nibWithNibName:@"BusRouteViewCell" bundle:nil] forCellWithReuseIdentifier:@"cellView"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backGround.jpg"]];
    [_collectionView setBackgroundView:imageView];
    [imageView release];
    
    [self.view addSubview:_collectionView];
    [_collectionView release];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_routes) {
        [_routes release];
        _routes = nil;
    }
    _delegate = nil;
    [super dealloc];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [_routes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BusRouteViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellView" forIndexPath:indexPath];
    cell.number.text = ((MyRoute*)[_routes objectAtIndex:indexPath.row]).shortName;
    cell.number.accessibilityLabel = ((MyRoute*)[_routes objectAtIndex:indexPath.row]).shortName;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BusRouteViewCell *cell = (BusRouteViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [_delegate setBusRoute:cell.number.text];
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = CGSizeMake(50, 50);
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
@end
