//
//  RCWebContentParseOperation.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface RCWebContentParseOperation : AFHTTPRequestOperation

+ (instancetype)contentParseOperationWithRequest:(NSURLRequest *)request
                                         success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSString *contentString))success
                                         failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

@end
