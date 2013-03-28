//
//  RCViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCViewController.h"
#import "RCOperationCenter.h"
#import <QuartzCore/QuartzCore.h>
@interface RCViewController ()

@end

@implementation RCViewController

@synthesize rollerViewController = _rollerViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*
    [[RCOperationCenter sharedOperationCenter] executeRSSFetchOperationWithLink:[NSURL URLWithString:@"http://blog.lelevier.fr/rss"] success:^(NSURLRequest *request, NSURLResponse *response, NSArray *item){
        NSLog(@"%d", [item count]);
    } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error){
        
    }];
    
    [[RCOperationCenter sharedOperationCenter] executeContentFetchOperationWithLink:[NSURL URLWithString:@"http://strata.oreilly.com/2013/03/python-data-tools-just-keep-getting-better.html"] success:^(NSURLRequest *request, NSURLResponse *response, NSString *contentString){
        NSLog(@"%@", contentString);
    } failure:nil];*/
    NSLog(@"view:%@", [self.view description]);
    self.view.userInteractionEnabled = YES;
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 50.0, 50.0)];
//    self.grayView = [[UIView alloc] init];
//    self.grayView.center = self.view.center;
//    self.grayView.bounds = CGRectMake(0.0, 0.0, 200.0, 200.0);
    self.grayView.backgroundColor = [UIColor grayColor];
    self.grayView.userInteractionEnabled = YES;
//    self.grayView.layer.transform = CATransform3DMakeRotation(M_PI_4, 0.0, 1.0, 0.0);
    
    [self.view addSubview:self.grayView];
}

- (void)setColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadGestureRecognizer];
}

- (void)loadGestureRecognizer
{
    if ([self.rollerViewController.viewControllers indexOfObject:self] == 1)
        [self.rollerViewController addGestureDirection:RCRollerDirectionPullFromTop uponView:self.view forKey:@"grayView"];
    else
        [self.rollerViewController addGestureDirection:RCRollerDirectionPushFromBottom uponView:self.view forKey:@"anotherView"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
