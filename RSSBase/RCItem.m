//
//  RCItem.m
//  RSSCenter
//
//  Created by Zhang Studyro on 13-3-24.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "RCItem.h"

@implementation RCItem

// title, link, itemDecription(long), unread, favorated need to be saved in db.

- (BOOL)isDescriptionFull
{
    if (self.itemDescription) {
        return [self.itemDescription length] > 350;
    }
    else {
        return NO;
    }
}

@end
