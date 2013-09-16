//
//  BusRoutesCollectionViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BusRouteCollectionViewControllerDelegate <NSObject>
- (NSArray*)getBusRoutes;
@end

@interface BusRoutesCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (retain, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (retain, nonatomic) id <BusRouteCollectionViewControllerDelegate> delegate;

@end
