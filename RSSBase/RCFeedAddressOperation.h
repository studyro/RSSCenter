//
//  RCFeedAddressOperation.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-28.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface RCFeedAddressOperation : AFHTTPRequestOperation

+ (instancetype)feedAddressOperationWithRequest:(NSURLRequest *)request
                                        success:(void (^)(NSURLRequest *request, NSURLResponse *response, NSString *urlString))success
                                        failure:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError *error))failure;

@end
