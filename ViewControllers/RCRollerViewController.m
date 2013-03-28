//
//  RCRollerViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-25.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCRollerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define FULL_PANNING_DISTANCE 240.0

#define RADIAN_PANNED(a) (a * M_PI_2 / FULL_PANNING_DISTANCE)

@interface UIPanGestureRecognizer (RCRoller)
@property (assign, nonatomic) RCRollerDirection availableDirection;
@end

@implementation UIPanGestureRecognizer (RCRoller)

static const char* nsnumberKey = "NSNumber";

@dynamic availableDirection;

- (RCRollerDirection)availableDirection
{
    NSNumber *result = objc_getAssociatedObject(self, nsnumberKey);
    
    return result?[result integerValue]:RCRollerDirectionNone;
}

- (void)setAvailableDirection:(RCRollerDirection)availableDirection
{
    if ([self availableDirection] != availableDirection) {
        NSNumber *number = [NSNumber numberWithInteger:availableDirection];
        objc_setAssociatedObject(self, nsnumberKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

@interface RCRollerViewController ()

@property (strong, nonatomic) UIViewController<RCRollerViewControllerProtocol> *rootViewController;
@property (strong, nonatomic) NSMutableArray *viewControllers;

@property (assign, nonatomic) NSInteger currentViewControllerIndex;
@property (assign, nonatomic) NSInteger upsideViewControllerIndex;
@property (assign, nonatomic) NSInteger downsideViewControllerIndex;
@property (assign, nonatomic) NSInteger comingViewControllerIndex;

@property (strong, nonatomic) NSMutableDictionary *gesturesHash;

@end

static CATransform3D CATransform3DMakePerspective(CGFloat zDistance)
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/zDistance;
    
    return transform;
}

typedef enum {
    kRCAnchorPointPositionTop = 10,
    kRCAnchorPointPositionBottom = 11,
    kRCAnchorPointPositionCenter = 12
}kRCAnchorPointPosition;

// return default anchor point if get a wrong parameter.
static CGPoint CGPointMakeAnchor(kRCAnchorPointPosition pos)
{
    if (pos == kRCAnchorPointPositionTop)
        return CGPointMake(0.5, 0.0);
    else if (pos == kRCAnchorPointPositionBottom)
        return CGPointMake(0.5, 1.0);
    else
        return CGPointMake(0.5, 0.5);
}

@implementation RCRollerViewController

- (instancetype)initWithRootViewController:(UIViewController<RCRollerViewControllerProtocol> *)rootViewController
{
    if (self = [super init]) {
        self.viewControllers = [[NSMutableArray alloc] init];
        self.rootViewController = rootViewController;
        rootViewController.rollerViewController = self;
        [self.viewControllers addObject:self.rootViewController];
        
        self.currentViewControllerIndex = 0;
        self.upsideViewControllerIndex = -1;
        self.downsideViewControllerIndex = -1;
        self.comingViewControllerIndex = -1;
        
        self.gesturesHash = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    
    return self;
}

- (void)_syncSlideViewControllersIndices
{
    self.upsideViewControllerIndex = self.currentViewControllerIndex - 1;
    self.downsideViewControllerIndex = self.currentViewControllerIndex + 1;
    
    if (self.currentViewControllerIndex == 0)
        self.upsideViewControllerIndex = -1;
    if (self.currentViewControllerIndex >= [self.viewControllers count] - 1)
        self.downsideViewControllerIndex = -1;
}

- (void)setCurrentViewControllerIndex:(NSInteger)currentViewControllerIndex
{
    _currentViewControllerIndex = currentViewControllerIndex;
    
    [self _syncSlideViewControllersIndices];
}

- (void)insertViewController:(UIViewController<RCRollerViewControllerProtocol> *)viewController
                     atIndex:(NSUInteger)index
{
    if (index > [self.viewControllers count]) {
        return;
    }
    
    [self.viewControllers insertObject:viewController atIndex:index];
    viewController.rollerViewController = self;
    
    if (self.currentViewControllerIndex >= index) {
        self.currentViewControllerIndex = self.currentViewControllerIndex + 1;
    }
}

- (void)addGestureDirection:(RCRollerDirection)direction
                   uponView:(UIView *)view
                     forKey:(NSString *)keyString
{
    if (self.gesturesHash[keyString]) {
        return;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    panGestureRecognizer.availableDirection = direction;
    [view addGestureRecognizer:panGestureRecognizer];
    
    self.gesturesHash[keyString] = panGestureRecognizer;
}

- (void)_setLayerWithUnchangedPosition:(CALayer *)layer
                        newAnchorPoint:(CGPoint)anchor
{
    if (!layer.superlayer) {
        return;
    }
    
    CGFloat deltaX = layer.superlayer.bounds.size.width * (anchor.x - layer.anchorPoint.x);
    CGFloat deltaY = layer.superlayer.bounds.size.height * (anchor.y - layer.anchorPoint.y);
    
    layer.anchorPoint = anchor;
    layer.position = CGPointMake(layer.position.x + deltaX, layer.position.y + deltaY);
}

- (void)_willRollForViewControllerAtIndex:(NSInteger)index
{
    UIViewController *comingViewController = [self.viewControllers objectAtIndex:index];
    UIViewController *currentViewController = [self.viewControllers objectAtIndex:self.currentViewControllerIndex];
    
    if (![self.view.subviews containsObject:comingViewController.view]) {
        [self.view addSubview:comingViewController.view];
    }
    
    // disable implicit animations to avoid unwanted rotation animations.
    [CATransaction setDisableActions:YES];
    
    CALayer *comingLayer = comingViewController.view.layer;
    CALayer *currentLayer = currentViewController.view.layer;
    
    if (index < self.currentViewControllerIndex) {
        [self _setLayerWithUnchangedPosition:comingLayer
                              newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionTop)];
        comingLayer.transform = CATransform3DRotate(CATransform3DMakePerspective(3000.0), -M_PI_2, 1.0, 0.0, 0.0);
        
        [self _setLayerWithUnchangedPosition:currentLayer
                              newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionBottom)];
//        currentLayer.opaque = NO; currentLayer.opacity = 0.5;
    }
    else if (index > self.currentViewControllerIndex) {
        [self _setLayerWithUnchangedPosition:comingLayer
                              newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionBottom)];
        comingLayer.transform = CATransform3DRotate(CATransform3DMakePerspective(3000.0), M_PI_2, 1.0, 0.0, 0.0);
        
        [self _setLayerWithUnchangedPosition:currentLayer
                              newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionTop)];
    }
    
    [CATransaction setDisableActions:NO];

    [comingViewController viewWillAppear:YES];
    self.comingViewControllerIndex = index;
}

- (void)_didRollForViewControllerAtIndex:(NSInteger)toIndex
                               fromIndex:(NSInteger)fromIndex
{
    UIViewController *toViewController = [self.viewControllers objectAtIndex:toIndex];
    UIViewController *fromViewController = [self.viewControllers objectAtIndex:fromIndex];
    
    CALayer *toLayer = toViewController.view.layer;
    [self _setLayerWithUnchangedPosition:toLayer
                          newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionCenter)];
    toLayer.transform = CATransform3DIdentity;
    
    if ([self.view.subviews containsObject:fromViewController.view]) {
        [self _setLayerWithUnchangedPosition:fromViewController.view.layer newAnchorPoint:CGPointMakeAnchor(kRCAnchorPointPositionCenter)];
        [fromViewController viewWillDisappear:YES];
        [fromViewController.view removeFromSuperview];
    }
    
    /* make sure that the coming view's controls are available in the new position.
       PS : The anchorPoint of comingLayer has been fixed to the center position in this method.
     */
//    toViewController.view.center = self.view.center;
    toViewController.view.frame = CGRectMake(0.0, 0.0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
    
    [toViewController viewDidAppear:YES];
    [fromViewController viewDidDisappear:YES];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    self.currentViewControllerIndex = toIndex;
    self.comingViewControllerIndex = -1;
}

- (RCRollerDirection)_directionWithTranslation:(CGPoint)translationPoint
{
    return translationPoint.y > 0 ? RCRollerDirectionPullFromTop : RCRollerDirectionPushFromBottom;
}

- (BOOL)_isDirectionCorrect:(RCRollerDirection)direction
                withGesture:(UIPanGestureRecognizer *)pan
{
    if (direction == pan.availableDirection)
        return YES;
    else
        return NO;
}

- (NSInteger)_indexOfViewControllerWillPresentByGesture:(UIPanGestureRecognizer *)pan
{
    if (pan.availableDirection == RCRollerDirectionPullFromTop)
        return self.upsideViewControllerIndex;
    else
        return self.downsideViewControllerIndex;
}

- (void)_layerTransformByTranslation:(CGFloat)yDistance
{
    if (self.comingViewControllerIndex >= 0) {
        UIViewController *comingViewController = [self.viewControllers objectAtIndex:self.comingViewControllerIndex];
        UIViewController *currentViewController = [self.viewControllers objectAtIndex:self.currentViewControllerIndex];
        
        CALayer *comingLayer = comingViewController.view.layer;
        CALayer *currentLayer = currentViewController.view.layer;
        
        CGFloat comingAngle = 0;
        CGFloat currentAngle = 0;
        
        if (yDistance > 0) {
            if (yDistance > 240.0) yDistance = 240.0;
            CGFloat absAngle = RADIAN_PANNED(abs(yDistance));
            comingAngle = absAngle - M_PI_2;
            currentAngle = absAngle;
        }
        else if (yDistance < 0) {
            if (yDistance < -240.0) yDistance = -240.0;
            CGFloat absAngle = RADIAN_PANNED(abs(yDistance));
            comingAngle = M_PI_2 - absAngle;
            currentAngle = -absAngle;
        }
        
        comingLayer.transform = CATransform3DRotate(CATransform3DMakePerspective(3000), comingAngle, 1.0, 0.0, 0.0);
        currentLayer.transform = CATransform3DRotate(CATransform3DMakePerspective(3000), currentAngle, 1.0, 0.0, 0.0);
    }
}

- (void)_rotateToViewControllerAtIndex:(NSInteger)index
{
    if (index > [self.viewControllers count] - 1) {
        
        return;
    }
    
    UIViewController *upsideViewController = nil, *downsideViewController = nil;
    CGFloat duration = 0.5;
    
    if (index == self.currentViewControllerIndex) {
        if (self.comingViewControllerIndex >= 0) {
            // for currently changing case.
//            [self _willRollForViewControllerAtIndex:index];
            
            [CATransaction setCompletionBlock:^{
                [self _didRollForViewControllerAtIndex:index fromIndex:self.comingViewControllerIndex];
            }];
            [CATransaction begin];
            
            if (self.comingViewControllerIndex < self.currentViewControllerIndex) {
                upsideViewController = [self.viewControllers objectAtIndex:self.comingViewControllerIndex];
                downsideViewController = [self.viewControllers objectAtIndex:index];
                
                CALayer *upsideLayer = upsideViewController.view.layer;
                CALayer *downsideLayer = downsideViewController.view.layer;
                
                CABasicAnimation *upsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
                upsideRotation.duration = duration;
                upsideRotation.fillMode = kCAFillModeForwards;
                upsideRotation.toValue = [NSNumber numberWithFloat:-M_PI_2];
                
                CABasicAnimation *downsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
                downsideRotation.duration = duration;
                downsideRotation.fillMode = kCAFillModeForwards;
                downsideRotation.toValue = [NSNumber numberWithFloat:0];
                
                [upsideLayer addAnimation:upsideRotation forKey:@"upsideRotation"];
                [downsideLayer addAnimation:downsideRotation forKey:@"downsideRotation"];
            }
            else if (self.comingViewControllerIndex > self.currentViewControllerIndex) {
                upsideViewController = [self.viewControllers objectAtIndex:index];
                downsideViewController = [self.viewControllers objectAtIndex:self.comingViewControllerIndex];
                
                CALayer *upsideLayer = upsideViewController.view.layer;
                CALayer *downsideLayer = downsideViewController.view.layer;
                
                CABasicAnimation *upsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
                upsideRotation.duration = duration;
                upsideRotation.fillMode = kCAFillModeForwards;
                upsideRotation.toValue = [NSNumber numberWithFloat:0];
                
                CABasicAnimation *downsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
                downsideRotation.duration = duration;
                downsideRotation.fillMode = kCAFillModeForwards;
                downsideRotation.toValue = [NSNumber numberWithFloat:M_PI_2];
                
                [upsideLayer addAnimation:upsideRotation forKey:@"upsideRotation"];
                [downsideLayer addAnimation:downsideRotation forKey:@"downsideRotation"];
            }
            
            [CATransaction commit];
        }
    }
    else {
//   TODO :     [self _willRollForViewControllerAtIndex:index];
        
        [CATransaction setCompletionBlock:^{
            [self _didRollForViewControllerAtIndex:index fromIndex:self.currentViewControllerIndex];
        }];
        [CATransaction begin];
        if (index < self.currentViewControllerIndex) {
            upsideViewController = [self.viewControllers objectAtIndex:index];
            downsideViewController = [self.viewControllers objectAtIndex:self.currentViewControllerIndex];
            
            CALayer *upsideLayer = upsideViewController.view.layer;
            CALayer *downsideLayer = downsideViewController.view.layer;
            
            CABasicAnimation *upsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            upsideRotation.duration = duration;
            upsideRotation.fillMode = kCAFillModeForwards;
            upsideRotation.toValue = [NSNumber numberWithFloat:0];
            
            CABasicAnimation *downsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            downsideRotation.duration = duration;
            downsideRotation.fillMode = kCAFillModeForwards;
            downsideRotation.toValue = [NSNumber numberWithFloat:M_PI_2];
            
            [upsideLayer addAnimation:upsideRotation forKey:@"upsideRotation"];
            [downsideLayer addAnimation:downsideRotation forKey:@"downsideRotation"];
        }
        else {
            upsideViewController = [self.viewControllers objectAtIndex:self.currentViewControllerIndex];
            downsideViewController = [self.viewControllers objectAtIndex:index];
            
            CALayer *upsideLayer = upsideViewController.view.layer;
            CALayer *downsideLayer = downsideViewController.view.layer;
            
            CABasicAnimation *upsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            upsideRotation.duration = duration;
            upsideRotation.fillMode = kCAFillModeForwards;
            upsideRotation.toValue = [NSNumber numberWithFloat:-M_PI_2];
            
            CABasicAnimation *downsideRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            downsideRotation.duration = duration;
            downsideRotation.fillMode = kCAFillModeForwards;
            downsideRotation.toValue = [NSNumber numberWithFloat:0];
            
            [upsideLayer addAnimation:upsideRotation forKey:@"upsideRotation"];
            [downsideLayer addAnimation:downsideRotation forKey:@"downsideRotation"];
        }
        
        [CATransaction commit];
    }
}

- (void)_rotateRemainedPartWithCurrentDirection:(RCRollerDirection)direction
                                    andDistance:(CGFloat)yDistance
{
    if (abs(yDistance) <= 240) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self _rotateToViewControllerAtIndex:self.currentViewControllerIndex];
    }
    else if (direction == RCRollerDirectionPullFromTop) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self _rotateToViewControllerAtIndex:self.upsideViewControllerIndex];
    }
    else if (direction == RCRollerDirectionPushFromBottom) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self _rotateToViewControllerAtIndex:self.downsideViewControllerIndex];
    }
}

// Currently, it is only allowed to add one gesture on a single view.
- (void)panning:(UIPanGestureRecognizer *)gesture
{
    CGPoint translationPoint = [gesture translationInView:self.view];
    // use velocity to adapt quickly swiping gesture
    CGPoint velocity = [gesture velocityInView:self.view];
    RCRollerDirection translationDirection = [self _directionWithTranslation:translationPoint];
    NSInteger commingIndex = [self _indexOfViewControllerWillPresentByGesture:gesture];
    
    if ([self _isDirectionCorrect:translationDirection withGesture:gesture]) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self _willRollForViewControllerAtIndex:commingIndex];
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            [self _layerTransformByTranslation:translationPoint.y];
        }
        else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
        {
            [self _rotateRemainedPartWithCurrentDirection:translationDirection andDistance:translationPoint.y];
        }
    }
    else {
//        [self _didRollForViewControllerAtIndex:self.currentViewControllerIndex];
    }
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.rootViewController.view];
    self.view.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
