//
//  ALConversationService.m
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationService.h"
#import "ALConversationProxy.h"
#import "ALConversationDBService.h"
#import "DB_ConversationProxy.h"
#import "ALConversationClientService.h"
#import "ALLogger.h"

@implementation ALConversationService

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
    self.conversationClientService = [[ALConversationClientService alloc] init];
    self.conversationDBService = [[ALConversationDBService alloc] init];
}

#pragma mark - Get conversation by key

- (ALConversationProxy *)getConversationByKey:(NSNumber *)conversationKey {
    
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

- (ALConversationProxy *)convertAlConversationProxy:(DB_ConversationProxy *)dbConversation {
    
    ALConversationProxy *alConversationProxy = [[ALConversationProxy alloc]init];
    alConversationProxy.groupId = dbConversation.groupId;
    alConversationProxy.userId = dbConversation.userId;
    alConversationProxy.topicDetailJson = dbConversation.topicDetailJson;
    alConversationProxy.topicId = dbConversation.topicId;
    alConversationProxy.Id = dbConversation.iD;
    return alConversationProxy;
}

#pragma mark - Get conversation list for UserId

- (NSMutableArray *)getConversationProxyListForUserID:(NSString *)userId {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *conversationArray = [self.conversationDBService getConversationProxyListFromDBForUserID:userId];
    if (!conversationArray.count) {
        return result;
    }
    for (DB_ConversationProxy *dbConversation in conversationArray) {
        ALConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
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
        ALConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
        [result addObject:conversation];
    }
    return result;
}

- (NSMutableArray *)getConversationProxyListForChannelKey:(NSNumber *)channelKey {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *conversationArray = [self.conversationDBService getConversationProxyListFromDBWithChannelKey:channelKey];
    
    for (DB_ConversationProxy *dbConversation in conversationArray) {
        ALConversationProxy *conversation = [self convertAlConversationProxy:dbConversation];
        [result addObject:conversation];
    }
    return  result;
}

#pragma mark - Create conversation

- (void)createConversation:(ALConversationProxy *)alConversationProxy
            withCompletion:(void(^)(NSError *error, ALConversationProxy *proxy))completion {
    
    
    NSArray *conversationArray = [[NSArray alloc] initWithArray:[self getConversationProxyListForUserID:alConversationProxy.userId andTopicId:alConversationProxy.topicId]];
    
    
    if (conversationArray.count != 0) {
        ALConversationProxy *conversationProxy = conversationArray[0];
        ALSLog(ALLoggerSeverityInfo, @"Conversation Proxy List Found In DB :%@",conversationProxy.topicDetailJson);
        completion(nil, conversationProxy);
    } else {
        [self.conversationClientService createConversation:alConversationProxy withCompletion:^(NSError *error, ALConversationCreateResponse *response) {
            
            if (!error) {
                NSMutableArray *proxyArr = [[NSMutableArray alloc] initWithObjects:response.alConversationProxy, nil];
                [self addConversations:proxyArr];
            } else {
                ALSLog(ALLoggerSeverityError, @"ALConversationService : Error creatingConversation ");
            }
            completion(error, response.alConversationProxy);
        }];
    }
    
}

#pragma mark - Fetch topic detail

- (void)fetchTopicDetails:(NSNumber *)alConversationProxyID
           withCompletion:(void(^)(NSError *error, ALConversationProxy *alConversationProxy))completion {
    
    ALConversationProxy *alConversationProxy = [self getConversationByKey:alConversationProxyID];
    
    if (alConversationProxy != nil){
        ALSLog(ALLoggerSeverityInfo, @"Conversation/Topic Alerady exists");
        completion(nil, alConversationProxy);
        return;
    }
    
    [self.conversationClientService fetchTopicDetails:alConversationProxyID andCompletion:^(NSError *error, ALAPIResponse *response) {
        
        if (!error) {
            ALSLog(ALLoggerSeverityInfo, @"ALAPIResponse: FETCH TOPIC DEATIL  %@",response);
            ALConversationProxy *conversationProxy = [[ALConversationProxy alloc] initWithDictonary:response.response];
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
