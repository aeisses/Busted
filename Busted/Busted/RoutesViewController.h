//
//  RoutesViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-13.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "ParentViewController.h"
#import "MapViewController.h"
#import "BusRoutesCollectionViewController.h"
#import "MyRoute.h"

@protocol RoutesViewControllerDelegate <NSObject>
- (void)loadMapViewController:(MapViewController*)mapViewController;
- (BusRoute*)getRoute:(NSInteger)routeNumber;
- (NSArray*)getRoutes;
@end

@interface RoutesViewController : ParentViewController <MapViewControllerDelegate,BusRouteCollectionViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *routeButton;
@property (retain, nonatomic) IBOutlet UIButton *homeButton;
@property (retain, nonatomic) IBOutlet UIButton *trackButton;
@property (retain, nonatomic) id <RoutesViewControllerDelegate> delegate;
@property (retain, nonatomic) MapViewController *mapVC;
@property (retain, nonatomic) BusRoutesCollectionViewController *collection;

+ (RoutesViewController*)sharedInstance;
- (IBAction)touchSubmitButton:(id)sender;
- (IBAction)touchRouteButton:(id)sender;
- (IBAction)touchHomeButton:(id)sender;
- (IBAction)touchTrackButton:(id)sender;

@end
