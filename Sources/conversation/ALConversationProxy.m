//
//  ALConversationProxy.m
//  Kommunicate
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALConversationProxy.h"
#import "DB_ConversationProxy.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALLogger.h"

@implementation ALConversationProxy

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (ALConversationProxy *)convertAlConversationProxy:(DB_ConversationProxy *)dbConversation {
    
    ALConversationProxy *alConversationProxy = [[ALConversationProxy alloc] init];
    
    alConversationProxy.created = dbConversation.created.boolValue;
    alConversationProxy.closed = dbConversation.closed.boolValue;
    alConversationProxy.Id = dbConversation.iD;
    alConversationProxy.topicId = dbConversation.topicId;
    alConversationProxy.topicDetailJson = dbConversation.topicDetailJson;
    alConversationProxy.groupId = dbConversation.groupId;
    alConversationProxy.userId = dbConversation.userId;
    return alConversationProxy;
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

+ (NSMutableDictionary *)getDictionaryForCreate:(ALConversationProxy *)alConversationProxy {
    
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setValue:alConversationProxy.topicId forKey:@"topicId"];
    [requestDictionary setValue:alConversationProxy.userId forKey:@"userId"];
    [requestDictionary setValue:alConversationProxy.topicDetailJson forKey:@"topicDetail"];
    
    alConversationProxy.fallBackTemplatesListArray = [[NSMutableArray alloc]
                                                      initWithObjects:alConversationProxy.fallBackTemplateForRECEIVER,alConversationProxy.fallBackTemplateForSENDER, nil];
    
    [requestDictionary setValue:alConversationProxy.fallBackTemplatesListArray forKey:@"fallBackTemplatesList"];
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
