//
//  BusRoutesCollectionViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSelectCell.h"
#import "Route.h"

@protocol BusRouteCollectionViewControllerDelegate <NSObject>
- (NSArray*)getBusRoutes;
- (void)setBusRoute:(NSString*)route;
- (void)exitCollectionView;
@end

@interface BusRoutesCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (retain, nonatomic) NSArray *routes;
@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) id <BusRouteCollectionViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *exitButton;
@property (retain, nonatomic) NSArray *activeRoutesArray;

- (IBAction)touchExitButton:(id)sender;

@end
