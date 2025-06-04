//
//  KMCoreConversationProxy.m
//  Kommunicate
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreConversationProxy.h"
#import "DB_ConversationProxy.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALLogger.h"

@implementation KMCoreConversationProxy

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (KMCoreConversationProxy *)convertAlConversationProxy:(DB_ConversationProxy *)dbConversation {
    
    KMCoreConversationProxy *conversationProxy = [[KMCoreConversationProxy alloc] init];
    
    conversationProxy.created = dbConversation.created.boolValue;
    conversationProxy.closed = dbConversation.closed.boolValue;
    conversationProxy.Id = dbConversation.iD;
    conversationProxy.topicId = dbConversation.topicId;
    conversationProxy.topicDetailJson = dbConversation.topicDetailJson;
    conversationProxy.groupId = dbConversation.groupId;
    conversationProxy.userId = dbConversation.userId;
    return conversationProxy;
}

- (void)parseMessage:(id)messageJson {
    self.created = [self getBoolFromJsonValue:messageJson[@"created"]];
    self.Id = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.topicId = [self getStringFromJsonValue:messageJson[@"topicId"]];
    self.groupId = [self getNSNumberFromJsonValue:messageJson[@"groupId"]];
    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    self.topicDetailJson =[self getStringFromJsonValue:messageJson[@"topicDetail"]];
}

- (ALTopicDetail *)getTopicDetail {
    if (!self.topicDetailJson) {
        return nil;
    }

    NSError *jsonError;
    NSData *topicData = [self.topicDetailJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:topicData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
    return (self.topicDetailJson)?[[ALTopicDetail alloc] initWithDictonary:JSONDictionary]: nil;
}

+ (NSMutableDictionary *)getDictionaryForCreate:(KMCoreConversationProxy *)conversationProxy {
    
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:conversationProxy.topicId forKey:@"topicId"];
    [requestDictionary setValue:conversationProxy.userId forKey:@"userId"];
    [requestDictionary setValue:conversationProxy.topicDetailJson forKey:@"topicDetail"];
    
    conversationProxy.fallBackTemplatesListArray = [[NSMutableArray alloc]
                                                      initWithObjects:conversationProxy.fallBackTemplateForRECEIVER,conversationProxy.fallBackTemplateForSENDER, nil];
    
    [requestDictionary setValue:conversationProxy.fallBackTemplatesListArray forKey:@"fallBackTemplatesList"];
    return requestDictionary;

}


- (void)setSenderSMSFormat:(NSString *)senderFormatString {
    
    self.fallBackTemplateForSENDER = [[NSMutableDictionary alloc] init];
    self.fallBackTemplateForSENDER = [self SMSFormatWithUserID:[KMCoreUserDefaultsHandler getUserId]
                                                     andString:senderFormatString];
}

- (void)setReceiverSMSFormat:(NSString *)recieverFormatString {
    self.fallBackTemplateForRECEIVER = [[NSMutableDictionary alloc] init];
    self.fallBackTemplateForRECEIVER = [self SMSFormatWithUserID:self.userId
                                                       andString:recieverFormatString];
}

- (NSMutableDictionary *)SMSFormatWithUserID:(NSString *)userID andString:(NSString *)string {
    
    NSMutableDictionary *fallBackTemplatesListDictionary = [[NSMutableDictionary alloc] init];
    [fallBackTemplatesListDictionary setValue:string forKey:@"fallBackTemplate"];
    [fallBackTemplatesListDictionary setValue:userID forKey:@"userId"];
    
    return fallBackTemplatesListDictionary;
}

@end
