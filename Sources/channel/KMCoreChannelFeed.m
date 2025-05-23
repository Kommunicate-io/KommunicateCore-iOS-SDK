//
//  KMCoreChannelFeed.m
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "KMCoreChannelFeed.h"
#import "ALConversationProxy.h"

@implementation KMCoreChannelFeed

- (id)initWithJSONString:(NSString *)JSONString {
    [self parseMessage:JSONString];
    return self;
}

- (void)parseMessage:(id)json {
    NSMutableArray *channelFeedArray = [NSMutableArray new];
    NSDictionary *channelFeedDictionary = [json valueForKey:@"groupFeeds"];
    for (NSDictionary *theDictionary in channelFeedDictionary) {
        KMCoreChannel *alChannel = [[KMCoreChannel alloc] initWithDictonary:theDictionary];
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
