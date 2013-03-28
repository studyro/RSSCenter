//
//  RCViewController.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRollerViewController.h"

@interface RCViewController : UIViewController <RCRollerViewControllerProtocol>
@property (strong, nonatomic) UIView *grayView;
- (void)setColor:(UIColor *)color;
- (void)loadGestureRecognizer;
@end
