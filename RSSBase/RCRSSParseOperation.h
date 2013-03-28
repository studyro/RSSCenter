//
//  RCRSSParseOperation.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "AFXMLRequestOperation.h"
#import "RCItem.h"

@interface RCRSSParseOperation : AFHTTPRequestOperation

+ (instancetype)rssParseOperationWithRequest:(NSURLRequest *)request
                                      success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSArray *items))success
                                      failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

@end
