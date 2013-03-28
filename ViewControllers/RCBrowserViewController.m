//
//  RCBrowserViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCBrowserViewController.h"

#define textFieldHeight 32.0
#define toolBarHeight 32.0

@interface RCBrowserViewController ()

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UIControl *maskView;

@property (strong, nonatomic) UIToolbar *toolBar;

@property (strong, nonatomic) UIBarButtonItem *backBarButton;

@property (strong, nonatomic) UIBarButtonItem *forwardBarButton;

@end

@implementation RCBrowserViewController

@synthesize rollerViewController = _rollerViewController;

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, screenSize.width, textFieldHeight)];
    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor darkGrayColor];
    
    self.maskView = [[UIControl alloc] initWithFrame:CGRectMake(0.0, textFieldHeight, screenSize.width, screenSize.height - textFieldHeight)];
    [self.maskView addTarget:self action:@selector(maskViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.maskView.hidden = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, textFieldHeight, screenSize.width, screenSize.height - toolBarHeight)];
    self.scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height);
    [self loadNavigationButtons];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.scrollView.frame];
    self.webView.delegate = self;
    self.webView.hidden = YES;
    
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.scrollView.frame.size.height - textFieldHeight - toolBarHeight, screenSize.width, toolBarHeight)];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backButtonTapped:)];
    UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardButtonTapped:)];
    UIBarButtonItem *spaceFixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    spaceFixItem.width = 76.0;
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(homeButtonTapped:)];
    
    self.forwardBarButton = forwardBarButtonItem;
    self.forwardBarButton.enabled = NO;
    self.backBarButton = backBarButtonItem;
    self.backBarButton.enabled = NO;
    
    self.toolBar.items = @[backBarButtonItem, spaceFixItem, forwardBarButtonItem, spaceFixItem, homeBarButtonItem];
    [self.rollerViewController addGestureDirection:RCRollerDirectionPushFromBottom uponView:self.toolBar forKey:@"fromBrowserToList"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.textField];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.toolBar];
}

- (void)loadNavigationButtons
{
    CGFloat padding = 40.0;
    CGFloat length = 100.0;
    
    UIButton *nshipster = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nshipster.tag = 1;
    nshipster.frame = CGRectMake(padding, padding, length, length);
    [nshipster setTitle:@"NSHipster" forState:UIControlStateNormal];
    [nshipster addTarget:self action:@selector(navigationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *darkrainfall = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    darkrainfall.tag = 2;
    darkrainfall.frame = CGRectMake(padding*2 + length, padding, length, length);
    [darkrainfall setTitle:@"DarkRainFall" forState:UIControlStateNormal];
    [darkrainfall addTarget:self action:@selector(navigationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *minroad = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    minroad.tag = 3;
    minroad.frame = CGRectMake(padding, padding*2 + length, length, length);
    [minroad setTitle:@"Minroad" forState:UIControlStateNormal];
    [minroad addTarget:self action:@selector(navigationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:nshipster];
    [self.scrollView addSubview:darkrainfall];
    [self.scrollView addSubview:minroad];
}

- (void)navigationButtonTapped:(id)sender
{
    self.scrollView.hidden = YES;
    self.webView.hidden = NO;
    
    NSURL *url = nil;
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == 1) url = [NSURL URLWithString:@"http://www.nshipster.com"];
    else if (btn.tag == 2) url =[NSURL URLWithString:@"http://blog.darkrainfall.org"];
    else url = [NSURL URLWithString:@"http://www.minroad.com"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.textField.text = [url absoluteString];
}

- (void)maskViewTapped:(id)sender
{
    [self.textField resignFirstResponder];
    self.textField.text = [self.webView.request.URL absoluteString];
}

- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
}

- (void)homeButtonTapped:(id)sender
{
    self.scrollView.hidden = NO;
    self.webView.hidden = YES;
}

#pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.scrollView.hidden = YES;
    self.webView.hidden = NO;
    
    // TODO : URL checking
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.maskView.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.maskView.hidden = YES;
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self.webView canGoBack]) self.backBarButton.enabled = YES;
    else self.backBarButton.enabled = NO;
    
    if ([self.webView canGoForward]) self.forwardBarButton.enabled = YES;
    else self.forwardBarButton.enabled = NO;
    
    self.textField.text = [self.webView.request.URL absoluteString];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
