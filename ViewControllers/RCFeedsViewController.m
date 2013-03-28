//
//  RCFeedsViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCFeedsViewController.h"
#import "RCListViewController.h"
#import "RCOperationCenter.h"

@interface RCFeedsViewController ()

@property (strong, nonatomic) NSMutableArray *feedsArray;

@end

@implementation RCFeedsViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.feedsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenSize.width, screenSize.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    UIBarButtonItem *plusBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFeed:)];
    self.navigationItem.rightBarButtonItem = plusBarButtonItem;
    
    [self loadDefaultFeeds];
}

- (void)loadDefaultFeeds
{
    NSArray *feedsArray = @[@"http://www.nshipster.com", @"http://blog.darkrainfall.org", @"http://www.minroad.com"];
    
    for (NSString *urlString in feedsArray) {
        [self addFeedWithURLString:urlString];
    }
}

- (void)addFeed:(id)sender
{
    // there is no url-checker yet ;(
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input URL" message:@"plz input full \"http://\"-prefixed url" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)addFeedWithURLString:(NSString *)urlString
{
    [[RCOperationCenter sharedOperationCenter] enqueueFeedFetchOperationWithLink:[NSURL URLWithString:urlString] success:^(NSURLRequest *request, NSURLResponse *response, NSString *feedURLString) {
        [self.feedsArray addObject:feedURLString];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Message TODO!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // TODO : legal-url checking
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self addFeedWithURLString:textField.text];
    }
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCListViewController *listViewController = [[RCListViewController alloc] initWithStyle:UITableViewStylePlain];
    listViewController.feedURL = [NSURL URLWithString:self.feedsArray[indexPath.row]];
    [self.navigationController pushViewController:listViewController animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.5];
    }
    
    cell.textLabel.text = self.feedsArray[indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
