//
//  KMCoreConversationService.m
//  Kommunicate
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreConversationService.h"
#import "KMCoreConversationProxy.h"
#import "KMCoreConversationDBService.h"
#import "DB_ConversationProxy.h"
#import "KMCoreConversationClientService.h"
#import "ALLogger.h"

@implementation KMCoreConversationService

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

#pragma mark - Setup service

-(void)setupServices {
    self.conversationClientService = [[KMCoreConversationClientService alloc] init];
    self.conversationDBService = [[KMCoreConversationDBService alloc] init];
}

#pragma mark - Get conversation by key

- (KMCoreConversationProxy *)getConversationByKey:(NSNumber *)conversationKey {
    
    DB_ConversationProxy *dbConversation = [self.conversationDBService getConversationProxyByKey:conversationKey];
    if (dbConversation == nil) {
        return nil;
    }
    return [self convertAlConversationProxy:dbConversation];
}

#pragma mark - Add conversation

- (void)addConversations:(NSMutableArray *)conversations {
    [self.conversationDBService insertConversationProxy:conversations];
}

- (void)addTopicDetails:(NSMutableArray *)conversations {
    [self.conversationDBService insertConversationProxyTopicDetails:conversations];
}

- (KMCoreConversationProxy *)convertAlConversationProxy:(DB_ConversationProxy *)dbConversation {
    
    KMCoreConversationProxy *conversationProxy = [[KMCoreConversationProxy alloc]init];
    conversationProxy.groupId = dbConversation.groupId;
    conversationProxy.userId = dbConversation.userId;
    conversationProxy.topicDetailJson = dbConversation.topicDetailJson;
    conversationProxy.topicId = dbConversation.topicId;
    conversationProxy.Id = dbConversation.iD;
    return conversationProxy;
}

#pragma mark - Get conversation list for UserId

- (NSMutableArray *)getConversationProxyListForUserID:(NSString *)userId {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *conversationArray = [self.conversationDBService getConversationProxyListFromDBForUserID:userId];
    if (!conversationArray.count) {
        return result;
    }
    for (DB_ConversationProxy *dbConversation in conversationArray) {
        KMCoreConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
        [result addObject:conversation];
    }
    
    return result;
}

#pragma mark - Get conversation list for UserId and topicId

- (NSMutableArray*)getConversationProxyListForUserID:(NSString *)userId
                                          andTopicId:(NSString *)topicId {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *conversationArray = [self.conversationDBService getConversationProxyListFromDBForUserID:userId andTopicId:topicId];
    if (!conversationArray.count) {
        return result;
    }
    for (DB_ConversationProxy *dbConversation in conversationArray) {
        KMCoreConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
        [result addObject:conversation];
    }
    return result;
}

- (NSMutableArray *)getConversationProxyListForChannelKey:(NSNumber *)channelKey {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *conversationArray = [self.conversationDBService getConversationProxyListFromDBWithChannelKey:channelKey];
    
    for (DB_ConversationProxy *dbConversation in conversationArray) {
        KMCoreConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
        [result addObject:conversation];
    }
    return  result;
}

#pragma mark - Create conversation

- (void)createConversation:(KMCoreConversationProxy *)conversationProxy
            withCompletion:(void(^)(NSError *error, KMCoreConversationProxy *proxy))completion {
    
    
    NSArray *conversationArray = [[NSArray alloc] initWithArray:[self getConversationProxyListForUserID:conversationProxy.userId andTopicId:conversationProxy.topicId]];
    
    
    if (conversationArray.count != 0) {
        KMCoreConversationProxy *conversationProxy = conversationArray[0];
        ALSLog(ALLoggerSeverityInfo, @"Conversation Proxy List Found In DB :%@",conversationProxy.topicDetailJson);
        completion(nil, conversationProxy);
    } else {
        [self.conversationClientService createConversation:conversationProxy withCompletion:^(NSError *error, KMCoreConversationCreateResponse *response) {
            
            if (!error) {
                NSMutableArray *proxyArr = [[NSMutableArray alloc] initWithObjects:response.conversationProxy, nil];
                [self addConversations:proxyArr];
            } else {
                ALSLog(ALLoggerSeverityError, @"KMCoreConversationService : Error creatingConversation ");
            }
            completion(error, response.conversationProxy);
        }];
    }
    
}

#pragma mark - Fetch topic detail

- (void)fetchTopicDetails:(NSNumber *)conversationProxyID
           withCompletion:(void(^)(NSError *error, KMCoreConversationProxy *conversationProxy))completion {
    
    KMCoreConversationProxy *conversationProxy = [self getConversationByKey:conversationProxyID];
    
    if (conversationProxy != nil){
        ALSLog(ALLoggerSeverityInfo, @"Conversation/Topic Alerady exists");
        completion(nil, conversationProxy);
        return;
    }
    
    [self.conversationClientService fetchTopicDetails:conversationProxyID andCompletion:^(NSError *error, ALAPIResponse *response) {
        
        if (!error) {
            ALSLog(ALLoggerSeverityInfo, @"ALAPIResponse: FETCH TOPIC DEATIL  %@",response);
            KMCoreConversationProxy *conversationProxy = [[KMCoreConversationProxy alloc] initWithDictonary:response.response];
            NSMutableArray *conversationProxyArray = [[NSMutableArray alloc] initWithObjects:conversationProxy, nil];
            [self addConversations:conversationProxyArray];
            completion(nil, conversationProxy);
        } else {
            ALSLog(ALLoggerSeverityError, @"ALAPIResponse : Error FETCHING TOPIC DEATILS ");
            completion(error, nil);
        }
    }];
}
@end
