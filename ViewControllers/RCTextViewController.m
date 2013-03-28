//
//  RCTextViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCTextViewController.h"
#import "RCItem.h"

@interface RCTextViewController ()
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) RCItem *item;
@end

@implementation RCTextViewController

- (instancetype)initWithItem:(RCItem *)item
{
    if (self = [super init]) {
        self.item = item;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.webView = [[UIWebView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    
    if (self.item.itemDescription) {
        [self.webView loadHTMLString:self.item.itemDescription baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
