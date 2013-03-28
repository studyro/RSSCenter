//
//  RCFeedAddressOperation.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCFeedAddressOperation.h"
#import "HTMLParser.h"

@interface rc_FeedAddressFetcher : NSObject

- (instancetype)initWithHTMLParser:(HTMLParser *)parser
                           success:(void (^)(NSString *urlString))success
                           failure:(void (^)(NSError *))failure;

- (void)parse;
@end

@interface rc_FeedAddressFetcher ()
@property (strong, nonatomic) HTMLParser *parser;
@property (copy, nonatomic) void (^successBlock)(NSString *);
@property (copy, nonatomic) void (^failureBlock)(NSError *);
@end

static dispatch_queue_t rc_feed_address_processing_queue;
static dispatch_queue_t feed_address_processing_queue() {
    if (rc_feed_address_processing_queue == NULL) {
        rc_feed_address_processing_queue = dispatch_queue_create("com.studyro.queue.html_processing", 0);
    }
    
    return rc_feed_address_processing_queue;
}

@implementation rc_FeedAddressFetcher

- (instancetype)initWithHTMLParser:(HTMLParser *)parser
                           success:(void (^)(NSString *))success
                           failure:(void (^)(NSError *))failure
{
    if (self = [super init]) {
        self.parser = parser;
        self.successBlock = success;
        self.failureBlock = failure;
    }
    
    return self;
}

- (void)parse
{
    HTMLNode *headNode = [self.parser head];
    
    if (!headNode) {
        // no domain code now
        self.failureBlock([NSError errorWithDomain:nil code:10101 userInfo:nil]);
        return;
    }
    
    NSArray *linkTags = [headNode findChildTags:@"link"];
    
    if (![linkTags count]) {
        self.failureBlock([NSError errorWithDomain:nil code:10101 userInfo:nil]);
        return;
    }
    
    NSString *feedURLString = nil;
    for (HTMLNode *node in linkTags) {
        NSString *tempURLString = nil;
        
        NSString *rel = [node getAttributeNamed:@"rel"];
        if ([rel isEqualToString:@"alternate"]) {
            NSString *type = [node getAttributeNamed:@"type"];
            if ([type isEqualToString:@"application/rss+xml"]) {
                tempURLString = [node getAttributeNamed:@"href"];
            }
            if ([tempURLString rangeOfString:@"comment"].location == NSNotFound) {
                feedURLString = tempURLString;
            }
        }
    }
    
    if (feedURLString) {
        self.successBlock(feedURLString);
    }
    else {
        self.failureBlock([NSError errorWithDomain:nil code:10101 userInfo:nil]);
    }
}

@end

@implementation RCFeedAddressOperation

+ (instancetype)feedAddressOperationWithRequest:(NSURLRequest *)request
                                        success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                        failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCFeedAddressOperation *operation = (RCFeedAddressOperation *)[[[self class] alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (failure) {
            failure(operation.request, operation.response, error);
        }
    }];
    
    return operation;
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^{
        dispatch_async(feed_address_processing_queue(), ^{
            NSError *parseError = nil;
            HTMLParser *parser = [[HTMLParser alloc] initWithData:weakSelf.responseData error:&parseError];
            
            if (weakSelf.error || parseError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(weakSelf, weakSelf.error);
                });
            }
            else {
                rc_FeedAddressFetcher *rcParser = [[rc_FeedAddressFetcher alloc] initWithHTMLParser:parser success:^(NSString *contentString){
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *urlString = contentString;
                            if (![contentString hasPrefix:@"http://"]) {
                                urlString = [[weakSelf.request.URL URLByAppendingPathComponent:urlString] absoluteString];
                            }
                            success(weakSelf, urlString);
                        });
                    }
                } failure:^(NSError *error){
                    if (failure) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failure(weakSelf, error);
                        });
                    }
                }];
                
                [rcParser parse];
            }
        });
    };
}

@end
