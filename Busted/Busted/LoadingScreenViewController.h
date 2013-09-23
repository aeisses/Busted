//
//  LoadingScreenViewController.h
//  Busted
//
//  Created by Aaron Eisses on 2013-09-22.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingScreenViewController : UIViewController
{
    CADisplayLink *displayLink;
    BOOL isOne;
}

@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;

@end
