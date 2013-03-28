//
//  RCItem.h
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCItem : NSObject

@property (strong, nonatomic) NSString *guid;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSURL *link;
@property (strong, nonatomic) NSURL *commentsLink;
@property (strong, nonatomic) NSURL *commentsFeed;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *author;
@property (assign, nonatomic) BOOL unread;
@property (assign, nonatomic) BOOL favorated;

- (BOOL)isDescriptionFull;

@end
