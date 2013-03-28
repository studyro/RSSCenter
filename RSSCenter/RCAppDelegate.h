//
//  RCAppDelegate.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCViewController;
@class RCRollerViewController;

@interface RCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RCRollerViewController *viewController;

@end
