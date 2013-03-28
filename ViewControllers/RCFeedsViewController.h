//
//  RCFeedsViewController.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRollerViewController.h"

@interface RCFeedsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end
