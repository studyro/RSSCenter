//
//  RCListViewController.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-29.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCListViewController.h"
#import "RCOperationCenter.h"
#import "RCTextViewController.h"
#import "RCItem.h"

@interface RCListViewController ()
@property (strong, nonatomic) NSMutableArray *itemArray;
@end

@implementation RCListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.itemArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadRSSItems];
}

- (void)loadRSSItems
{
//    __block typeof(self.itemArray) blockedItemArray = self.itemArray;
    [[RCOperationCenter sharedOperationCenter] executeRSSFetchOperationWithLink:self.feedURL success:^(NSURLRequest *request, NSURLResponse *response, NSArray *itemArray) {
        for (RCItem *item in itemArray) {
            [self.itemArray addObject:item];
        }
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Message TODO!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13.5];
    }
    
    RCItem *item = (RCItem *)self.itemArray[indexPath.row];
    cell.textLabel.text = item.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCItem *item = (RCItem *)self.itemArray[indexPath.row];
    if (item.itemDescription) {
        RCTextViewController *textViewController = [[RCTextViewController alloc] initWithItem:item];
        [self.navigationController pushViewController:textViewController animated:YES];
    }
}

@end
