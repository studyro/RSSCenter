//
//  RCOperationCenter.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCOperationCenter : NSObject

@property (readonly, strong, nonatomic) NSOperationQueue *rssFetchQueue;
@property (readonly, strong, nonatomic) NSOperationQueue *contentFetchQueue;

+ (instancetype)sharedOperationCenter;

#pragma mark - Queue-based Execution

- (void)enqueueRSSFetchOperationWithLink:(NSURL *)link
                                 success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSArray *items))success
                                 failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

- (void)enqueueContentFetchOperationWithLink:(NSURL *)link
                                     success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSString *contentString))success
                                     failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

- (void)enqueueFeedFetchOperationWithLink:(NSURL *)link
                                  success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                  failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure;

#pragma mark - Single concurrent task Execution

- (void)executeRSSFetchOperationWithLink:(NSURL *)link
                                 success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSArray *items))success
                                 failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

- (void)executeContentFetchOperationWithLink:(NSURL *)link
                                     success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSString *contentString))success
                                     failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

@end
