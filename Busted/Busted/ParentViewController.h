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
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeUp;
    UISwipeGestureRecognizer *swipeDown;
    UIButton *homeButton;
}

@property (retain, nonatomic) id <ParentViewControllerDelegate> superDelegate;

@end
