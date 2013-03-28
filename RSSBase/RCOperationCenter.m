//
//  RCOperationCenter.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCOperationCenter.h"
#import "RCRSSParseOperation.h"
#import "RCWebContentParseOperation.h"
#import "RCFeedAddressOperation.h"

static RCOperationCenter *instance = nil;

@interface RCOperationCenter ()

@property (readwrite, strong, nonatomic) NSOperationQueue *rssFetchQueue;
@property (readwrite, strong, nonatomic) NSOperationQueue *contentFetchQueue;
@property (readwrite, strong, nonatomic) NSOperationQueue *otherConnectionQueue;

@end

@implementation RCOperationCenter

+ (instancetype)sharedOperationCenter
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[[self class] alloc] init];});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        self.rssFetchQueue = [[NSOperationQueue alloc] init];
        self.contentFetchQueue = [[NSOperationQueue alloc] init];
        self.otherConnectionQueue = [[NSOperationQueue alloc] init];
    }

    return self;
}

- (RCRSSParseOperation *)_rssFetchOperationWithLink:(NSURL *)link
                                            success:(void (^)(NSURLRequest *, NSURLResponse *, NSArray *))success
                                            failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:link cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    return [RCRSSParseOperation rssParseOperationWithRequest:request success:success failure:failure];
}

- (RCWebContentParseOperation *)_contentFetchOperationWithLink:(NSURL *)link
                                                       success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                                       failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:link cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    return [RCWebContentParseOperation contentParseOperationWithRequest:request success:success failure:failure];
}

- (RCFeedAddressOperation *)_feedFetcherOperationWithLink:(NSURL *)link
                                                success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                                failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:link cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    return [RCFeedAddressOperation feedAddressOperationWithRequest:request success:success failure:failure];
}

- (void)enqueueRSSFetchOperationWithLink:(NSURL *)link
                                 success:(void (^)(NSURLRequest *, NSURLResponse *, NSArray *))success
                                 failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCRSSParseOperation *operation = [self _rssFetchOperationWithLink:link success:success failure:failure];
    
    [self.rssFetchQueue addOperation:operation];
}

- (void)enqueueContentFetchOperationWithLink:(NSURL *)link
                                     success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                     failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCWebContentParseOperation *operation = [self _contentFetchOperationWithLink:link success:success failure:failure];
    
    [self.contentFetchQueue addOperation:operation];
}

- (void)enqueueFeedFetchOperationWithLink:(NSURL *)link
                                  success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                  failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCFeedAddressOperation *operation = [self _feedFetcherOperationWithLink:link success:success failure:failure];
    
    [self.otherConnectionQueue addOperation:operation];
}

- (void)executeRSSFetchOperationWithLink:(NSURL *)link
                                 success:(void (^)(NSURLRequest *, NSURLResponse *, NSArray *))success
                                 failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCRSSParseOperation *operation = [self _rssFetchOperationWithLink:link success:success failure:failure];
    
    [operation start];
}

- (void)executeContentFetchOperationWithLink:(NSURL *)link
                                     success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                     failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCWebContentParseOperation *operation = [self _contentFetchOperationWithLink:link success:success failure:failure];
    
    [operation start];
}

@end
