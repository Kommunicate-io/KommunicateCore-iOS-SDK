//
//  KMCoreConversationDBService.h
//  Kommunicate
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_ConversationProxy.h"
#import "KMCoreConversationProxy.h"

@interface KMCoreConversationDBService : NSObject

- (void)insertConversationProxy:(NSMutableArray *)proxyArray;

- (DB_ConversationProxy *)createConversationProxy:(KMCoreConversationProxy *)conversationProxy;

- (DB_ConversationProxy *)getConversationProxyByKey:(NSNumber *)Id;

- (NSArray*)getConversationProxyListFromDBForUserID:(NSString *)userId;
- (NSArray*)getConversationProxyListFromDBWithChannelKey:(NSNumber *)channelKey;

- (void)insertConversationProxyTopicDetails:(NSMutableArray *)proxyArray;

- (NSArray*)getConversationProxyListFromDBForUserID:(NSString *)userId andTopicId:(NSString *)topicId;

@end
