//
//  KMCoreConversationService.h
//  Kommunicate
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreConversationProxy.h"
#import "KMCoreConversationClientService.h"
#import "KMCoreConversationDBService.h"

@interface KMCoreConversationService : NSObject

@property (nonatomic, strong) KMCoreConversationClientService *conversationClientService;

@property (nonatomic, strong) KMCoreConversationDBService *conversationDBService;

- (KMCoreConversationProxy *)getConversationByKey:(NSNumber *)conversationKey;

- (void)addConversations:(NSMutableArray *)conversations;

- (KMCoreConversationProxy *)convertAlConversationProxy:(DB_ConversationProxy *)dbConversation;

- (NSMutableArray*)getConversationProxyListForUserID:(NSString *)userId;

- (NSMutableArray*)getConversationProxyListForChannelKey:(NSNumber *)channelKey;

- (void)createConversation:(KMCoreConversationProxy *)conversationProxy
            withCompletion:(void(^)(NSError *error, KMCoreConversationProxy *proxy))completion;

- (void)fetchTopicDetails:(NSNumber *)conversationProxyID withCompletion:(void(^)(NSError *error, KMCoreConversationProxy *proxy))completion;

@end
