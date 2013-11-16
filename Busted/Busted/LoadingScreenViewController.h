//
//  LoadingScreenViewController.h
//   KNOWtime
//
//  Created by Aaron Eisses on 2013-09-22.
//  Copyright (c) 2013 KNOWtime Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingScreenViewControllerDelegate <NSObject>
- (void)loadScreenLoaded;
@end

@interface LoadingScreenViewController : UIViewController
{
    CADisplayLink *displayLink;
    BOOL isOne;
}

@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UIImageView *animationImage;
@property (retain, nonatomic) id <LoadingScreenViewControllerDelegate> delegate;

@end
