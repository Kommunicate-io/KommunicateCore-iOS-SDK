//
//  KMCoreChannelUser.m
//  Kommunicate
//
//  Created by Adarsh Kumar Mishra on 12/8/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreChannelUser.h"

@implementation KMCoreChannelUser

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (void)parseMessage:(id) messageJson {
    self.role = [self getNSNumberFromJsonValue:messageJson[@"role"]];
    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    self.parentGroupKey = [self getNSNumberFromJsonValue:messageJson[@"parentGroupKey"]];
}

@end
