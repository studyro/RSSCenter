//
//  RCAppDelegate.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCAppDelegate.h"

#import "RCViewController.h"

#import "RCFeedsViewController.h"
#import "RCNavigationViewController.h"
#import "RCBrowserViewController.h"
#import "RCRollerViewController.h"

@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    self.viewController = [[RCViewController alloc] initWithNibName:@"RCViewController" bundle:nil];
    /*
    RCViewController *rootViewController = [[RCViewController alloc] initWithNibName:@"RCViewController" bundle:nil];
    RCViewController *upViewController = [[RCViewController alloc] initWithNibName:@"RCViewController" bundle:nil];
    
    [rootViewController setColor:[UIColor whiteColor]];
    [upViewController setColor:[UIColor blueColor]];
    
    self.viewController = [[RCRollerViewController alloc] initWithRootViewController:rootViewController];
    [self.viewController insertViewController:upViewController atIndex:0];
     */
    
    RCFeedsViewController *feedsViewController = [[RCFeedsViewController alloc] init];
    RCNavigationViewController *rootViewController = [[RCNavigationViewController alloc] initWithRootViewController:feedsViewController];
    
    RCBrowserViewController *browserViewController = [[RCBrowserViewController alloc] init];
    
    RCRollerViewController *rollerViewController = [[RCRollerViewController alloc] initWithRootViewController:rootViewController];
    [rollerViewController insertViewController:browserViewController atIndex:0];
    
    [rollerViewController addGestureDirection:RCRollerDirectionPullFromTop uponView:rootViewController.navigationBar forKey:@"fromListToBrowser"];
    
    self.window.rootViewController = rollerViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
