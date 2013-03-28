//
//  RCBrowserViewController.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRollerViewController.h"

@interface RCBrowserViewController : UIViewController <RCRollerViewControllerProtocol, UITextFieldDelegate, UIWebViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIWebView *webView;

/* TODO : xml/atom feed checking on the current WebPage by DOM
    head->val(link)==alternate && attr(type)=="application/rss+xml"->attr(href)
 */

@end
