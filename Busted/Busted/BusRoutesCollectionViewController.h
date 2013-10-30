//
//  BusRoutesCollectionViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusRouteViewCell.h"
#import "MyRoute.h"

@protocol BusRouteCollectionViewControllerDelegate <NSObject>
- (NSArray*)getBusRoutes;
- (void)setBusRoute:(NSString*)route;
@end

@interface BusRoutesCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (retain, nonatomic) NSArray *routes;
@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) id <BusRouteCollectionViewControllerDelegate> delegate;

@end
