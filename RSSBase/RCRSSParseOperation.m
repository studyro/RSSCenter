//
//  RCRSSParseOperation.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCRSSParseOperation.h"

#pragma mark - RSSParser Implementation

@interface rc_RSSParser : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSXMLParser *parser;

- (instancetype)initWithXMLParser:(NSXMLParser *)parser
                          success:(void (^)(NSArray *items))success;

- (void)parse;

@end

@interface rc_RSSParser ()
@property (strong, nonatomic) RCItem *currentItem;
@property (strong, nonatomic) NSMutableString *tempString;
@property (strong, nonatomic) NSMutableArray *mutableItems;
@property (copy, nonatomic) void (^successBlock)(NSArray *);
@end

@implementation rc_RSSParser

- (instancetype)initWithXMLParser:(NSXMLParser *)parser
                          success:(void (^)(NSArray *))success
{
    if (self = [super init]) {
        self.parser = parser;
        self.parser.delegate = self;
        
        self.mutableItems = [[NSMutableArray alloc] init];
        self.successBlock = success;
    }
    
    return self;
}

- (void)parse
{
    [self.parser parse];
}

#pragma mark - NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) {
        self.currentItem = [[RCItem alloc] init];
    }
    
    self.tempString = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"]) {
        [self.mutableItems addObject:self.currentItem];
    }
    if (self.currentItem != nil && self.tempString != nil) {
        
        if ([elementName isEqualToString:@"title"]) {
            self.currentItem.title = self.tempString;
        }
        
        if ([elementName isEqualToString:@"description"]) {
            self.currentItem.itemDescription = self.tempString;
        }
        
        if ([elementName isEqualToString:@"content:encoded"]) {
            self.currentItem.content = self.tempString;
        }
        
        if ([elementName isEqualToString:@"link"]) {
            self.currentItem.link = [NSURL URLWithString:self.tempString];
        }
        
        if ([elementName isEqualToString:@"comments"]) {
            self.currentItem.commentsLink = [NSURL URLWithString:self.tempString];
        }
        
        if ([elementName isEqualToString:@"wfw:commentRss"]) {
            self.currentItem.commentsFeed = [NSURL URLWithString:self.tempString];
        }
        
        if ([elementName isEqualToString:@"slash:comments"]) {
            self.currentItem.commentsCount = [NSNumber numberWithInt:[self.tempString intValue]];
        }
        
        if ([elementName isEqualToString:@"pubDate"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"];
            [formatter setLocale:local];
            
            [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
            
            self.currentItem.date = [formatter dateFromString:self.tempString];
        }
        
        if ([elementName isEqualToString:@"dc:creator"]) {
            self.currentItem.author = self.tempString;
        }
    }
    
    if ([elementName isEqualToString:@"rss"]) {
        self.successBlock([NSArray arrayWithArray:self.mutableItems]);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.tempString appendString:string];
}

@end

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#pragma mark - RSSOperation Implementation

static dispatch_queue_t rc_rss_processing_queue;
static dispatch_queue_t rss_processing_queue() {
    if (rc_rss_processing_queue == NULL) {
        rc_rss_processing_queue = dispatch_queue_create("com.studyro.queue.rss_processing", 0);
    }
    
    return rc_rss_processing_queue;
}

@interface RCRSSParseOperation ()

@property (strong, nonatomic) NSXMLParser *xmlParser;

@end

@implementation RCRSSParseOperation

+ (instancetype)rssParseOperationWithRequest:(NSURLRequest *)request
                                     success:(void (^)(NSURLRequest *, NSURLResponse *, NSArray *))success
                                     failure:(void (^)(NSURLRequest *, NSURLResponse *, NSError *))failure
{
    RCRSSParseOperation *operation = (RCRSSParseOperation *)[[[self class] alloc] initWithRequest:request];
    
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

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"application/xml", @"application/rss+xml", @"text/xml", nil];
}

- (NSXMLParser *)xmlParser
{
    if (!_xmlParser && [self.responseData length] && [self isFinished]) {
        self.xmlParser = [[NSXMLParser alloc] initWithData:self.responseData];
    }
    
    return _xmlParser;
}

- (void)cancel
{
    [super cancel];
    
    self.xmlParser.delegate = nil;
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success
                              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^{
        dispatch_async(rss_processing_queue(), ^{
            
            if (weakSelf.error) {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(weakSelf, weakSelf.error);
                    });
                }
            }
            else {
                // TODO : try to parse in  background queue.
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSXMLParser *parser = weakSelf.xmlParser;
                    
                    rc_RSSParser *rssParser = [[rc_RSSParser alloc] initWithXMLParser:parser success:^(NSArray *items){
                        success(weakSelf, items);
                    }];
                    
                    [rssParser parse];
                });
            }
        });
    };
}

@end
