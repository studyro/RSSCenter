//
//  RCRollerViewController.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-25.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RCRollerDirectionNone = 0,
    RCRollerDirectionPullFromTop = 100,
    RCRollerDirectionPushFromBottom = 101,
    RCRollerDirectionBoth = 110
}RCRollerDirection;

@protocol RCRollerViewControllerProtocol;

@interface RCRollerViewController : UIViewController

@property (readonly, strong, nonatomic) UIViewController<RCRollerViewControllerProtocol> *rootViewController;
@property (readonly, assign, nonatomic) NSInteger currentViewControllerIndex;
@property (readonly, strong, nonatomic) NSMutableArray *viewControllers;

//@property (assign, nonatomic) CGFloat rollingSpeed; not available yet

- (instancetype)initWithRootViewController:(UIViewController<RCRollerViewControllerProtocol> *)rootViewController;

/* the order of indices of viewControllers is corresponded to the geometric positions from upside to downside.
 */
- (void)insertViewController:(UIViewController<RCRollerViewControllerProtocol> *)viewController
                     atIndex:(NSUInteger)index;

// auto rotate
- (void)rollToViewControllerAtDirection:(RCRollerDirection)direction withInfo:(id)info;

/*  Currently, it is only allowed to add one gesture on a single view.
    keyString : different recognizers should have different keyString
 */
- (void)addGestureDirection:(RCRollerDirection)direction
                   uponView:(UIView *)view
                     forKey:(NSString *)keyString;

@end

@protocol RCRollerViewControllerProtocol <NSObject>

@property (strong, nonatomic) RCRollerViewController *rollerViewController;

@end