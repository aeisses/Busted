//
//  ParentViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-14.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ParentViewControllerDelegate <NSObject>
- (void)touchedHomeButton;
- (void)swipe:(UISwipeGestureRecognizer*)swipeGesture;
@end

@interface ParentViewController : UIViewController
{
    UIButton *homeButton;
}

@property (retain, nonatomic) id <ParentViewControllerDelegate> superDelegate;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeRight;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeDown;

@end
