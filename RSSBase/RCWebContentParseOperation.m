//
//  RCWebContentParseOperation.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCWebContentParseOperation.h"
#import "HTMLParser.h"
#import "RCErrorField.h"

#pragma mark - HTMLParser Implementation

// public APIs
@interface rc_HTMLParser : NSObject
- (instancetype)initWithHTMLParser:(HTMLParser *)parser
                           success:(void (^)(NSString *contentString))success
                           failure:(void (^)(NSError *))failure;

/* The web content-get algorithm is just the naive strategy used in ChineseHackerNews project.
 *   1. Find the 'div' node which has most of <p> or <hx> children. This specific <div> node is regarded as the one holding the article content.
 *   2. Append all <p> and <hx> children after a pre-wrote css string.
 *   3. Calculate the length of the string. If it's longer the a given threshold, the final string will be send to a UIWebview.
 */
- (void)parse;
@end

// private APIs
@interface rc_HTMLParser ()
@property (strong, nonatomic) HTMLParser *parser;
@property (copy, nonatomic) void (^successBlock)(NSString *);
@property (copy, nonatomic) void (^failureBlock)(NSError *);
@end

@implementation rc_HTMLParser
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

- (void)testNode:(HTMLNode *)childNode withMuableArray:(NSMutableArray *)mutableArrayOfString
{
    // TODO : <li></li> like blogOverFlow.com
    if ([childNode nodetype] == HTMLPNode || [childNode nodetype] == HTMLHeaderNode) {
        NSDictionary *dic = nil;
        if ([childNode nodetype] == HTMLPNode) {
            dic = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [childNode allContents]] forKey:@"p"];
        }
        else if ([childNode nodetype] == HTMLHeaderNode) {
            dic = [NSDictionary dictionaryWithObject:[childNode allContents] forKey:@"h"];
        }
        
        [mutableArrayOfString addObject:dic];
    }
}

- (NSUInteger)contentLengthOfDicArray:(NSArray *)contentArray
{
    NSUInteger lengthToReturn = 0;
    for (NSDictionary *dic in contentArray) {
        NSString *content = [dic objectForKey:@"p"];
        if (content == nil) content = [dic objectForKey:@"h"];
        
        lengthToReturn += [content length];
    }
    return lengthToReturn;
}

- (void)parse
{
    HTMLNode *totalNode = [self.parser body];
    
    NSArray *divArray = [totalNode findChildTags:@"div"];
    NSMutableArray *postArray = [NSMutableArray array];
    
    // 1. find strings that have 'p''h2|3' nodes, put it in postArray
    for (HTMLNode *divNode in divArray) {
        @autoreleasepool {
            NSString *idAttributedName = [divNode getAttributeNamed:@"id"];
            NSString *classAttributedName = [divNode getAttributeNamed:@"class"];
            NSRange range1 = [idAttributedName rangeOfString:@"comment"];
            NSRange range2 = [classAttributedName rangeOfString:@"comment"];
            if ((idAttributedName && range1.location != NSNotFound) || (classAttributedName && range2.location != NSNotFound)) {
                continue;
            }
            
            NSArray *childrenOfDiv = [divNode children];
            NSMutableArray *mutableArrayOfString = [[NSMutableArray alloc] init];
            
            for (HTMLNode *childNode in childrenOfDiv) {
                [self testNode:childNode withMuableArray:mutableArrayOfString];
            }
            if (![mutableArrayOfString count]) {
                // for tumblr case
                HTMLNode *articleNode = [divNode findChildTag:@"article"];
                if (articleNode) {
                    for (HTMLNode *childNode in [articleNode children]) {
                        [self testNode:childNode withMuableArray:mutableArrayOfString];
                    }
                }
            }
            
            if (mutableArrayOfString && [mutableArrayOfString count]) {
                [postArray addObject:mutableArrayOfString];
            }
        }
    }
    
    // 2. find the longest string in the postArray
    NSUInteger maxLength = 0;
    NSArray *finalDicArray = nil;
    for (NSArray *contentArray in postArray) {
        NSUInteger length = [self contentLengthOfDicArray:contentArray];
        if (length > maxLength) {
            maxLength = length;
            finalDicArray = contentArray;
        }
    }
    
    if (finalDicArray && maxLength > 500) {
    }
    else {
        NSError *error = [NSError errorWithDomain:kErrorDomain_Parse code:kErrorCode_ContentManager_Error userInfo:nil];
        if (self.failureBlock) {
            self.failureBlock(error);
        }
        [postArray removeAllObjects];
        return;
    }
    
    [postArray removeAllObjects];
    
    NSString *contentString = [self generateHTMLStringWithDic:finalDicArray];
   
    if (self.successBlock) {
        self.successBlock(contentString);
    }
}

- (NSString *)generateHTMLStringWithDic:(NSArray *)contentDicArray
{
    NSMutableString *stringToReturn = [[NSMutableString alloc] init];
    [stringToReturn appendFormat:@"<html>"];
    [stringToReturn appendString:@"<meta name=\"viewport\" content=\"width=device-width; minimum-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>"];
    [stringToReturn appendFormat:@"<style type=\"text/css\">"];
    [stringToReturn appendFormat:@"h1 { font-family:Arial; font-size:22; font-weight:bold;}"];
    [stringToReturn appendFormat:@"h2 { font-family:Arial; font-size:20; font-weight:bold;}"];
    [stringToReturn appendFormat:@"p { font-family:Georgia; font-size:15; line-height: 22px;}"];
    [stringToReturn appendFormat:@"</style>"];
    [stringToReturn appendFormat:@"<body>"];
//    [stringToReturn appendFormat:@"<h1>%@</h1>", title]; no title here
    for (NSDictionary *contentDic in contentDicArray) {
        NSString *pString = [contentDic objectForKey:@"p"];
        NSString *hString = [contentDic objectForKey:@"h"];
        
        if (pString)
            [stringToReturn appendFormat:@"<p>&nbsp;&nbsp;&nbsp;&nbsp;%@</p>", pString];
        else if (hString)
            [stringToReturn appendFormat:@"<h2>%@</h2>", hString];
    }
    [stringToReturn appendFormat:@"</body>"];
    
    return stringToReturn;
}
@end

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#pragma mark - ParseOperation Implementation

static dispatch_queue_t rc_html_processing_queue;
static dispatch_queue_t html_processing_queue() {
    if (rc_html_processing_queue == NULL) {
        rc_html_processing_queue = dispatch_queue_create("com.studyro.queue.html_processing", 0);
    }
    
    return rc_html_processing_queue;
}
@implementation RCWebContentParseOperation

+ (instancetype)contentParseOperationWithRequest:(NSURLRequest *)request
                                         success:(void (^)(NSURLRequest *, NSURLResponse *, NSString *))success
                                         failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCWebContentParseOperation *operation = (RCWebContentParseOperation *)[[[self class] alloc] initWithRequest:request];
    
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
        dispatch_async(html_processing_queue(), ^{
            NSError *parseError = nil;
            HTMLParser *parser = [[HTMLParser alloc] initWithData:weakSelf.responseData error:&parseError];
            
            if (weakSelf.error || parseError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(weakSelf, weakSelf.error);
                });
            }
            else {
                rc_HTMLParser *rcParser = [[rc_HTMLParser alloc] initWithHTMLParser:parser success:^(NSString *contentString){
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(weakSelf, contentString);
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
