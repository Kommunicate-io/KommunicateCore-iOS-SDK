//
//  ALChannelFeed.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelFeed.h"
#import "ALConversationProxy.h"

@implementation ALChannelFeed

- (id)initWithJSONString:(NSString *)JSONString {
    [self parseMessage:JSONString];
    return self;
}

- (void)parseMessage:(id)json {
    NSMutableArray *channelFeedArray = [NSMutableArray new];
    NSDictionary *channelFeedDictionary = [json valueForKey:@"groupFeeds"];
    for (NSDictionary *theDictionary in channelFeedDictionary) {
        ALChannel *alChannel = [[ALChannel alloc] initWithDictonary:theDictionary];
        [channelFeedArray addObject:alChannel];
    }
    self.channelFeedsList = channelFeedArray;
    
    NSMutableArray *conversationProxyArray = [NSMutableArray new];
    
    NSDictionary *conversationProxyDictinoary = [json valueForKey:@"conversationPxys"];
    for (NSDictionary *theDictionary in conversationProxyDictinoary) {
        ALConversationProxy *conversationProxy = [[ALConversationProxy alloc] initWithDictonary:theDictionary];
        [conversationProxyArray addObject:conversationProxy];
    }
    self.conversationProxyList = conversationProxyArray;
}

@end
