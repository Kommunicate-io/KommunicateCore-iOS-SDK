//
//  ALMessageList.m
//  ChatApp
//
//  Created by Devashish on 22/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMessageList.h"
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALChannel.h"
#import "ALUserDefaultsHandler.h"
#import "ALLogger.h"

@implementation ALMessageList


- (id)initWithJSONString:(NSString *)syncMessageResponse {
    [self parseMessagseArray:syncMessageResponse];
    return self;
}

- (id)initWithJSONString:(NSString *)syncMessageResponse andWithUserId:(NSString *)userId andWithGroup:(NSNumber *)groupId {
    
    self.groupId = groupId;
    self.userId = userId;
    [self parseMessagseArray:syncMessageResponse];
    return self;
}

- (void)parseMessagseArray:(id)messagejson {
    NSMutableArray *messagesArray = [NSMutableArray new];
    NSMutableArray *userDetailArray = [NSMutableArray new];
    NSMutableArray *conversationProxyList = [NSMutableArray new];

    NSDictionary *messageDictionary = [messagejson valueForKey:@"message"];
    ALSLog(ALLoggerSeverityInfo, @"MESSAGES_DICT_COUNT :: %lu",(unsigned long)messageDictionary.count);
    if (messageDictionary.count == 0) {
        ALSLog(ALLoggerSeverityInfo, @"NO_MORE_MESSAGES");
        [ALUserDefaultsHandler setFlagForAllConversationFetched: YES];
    }
    
    for (NSDictionary *theDictionary in messageDictionary) {
        ALMessage *message = [[ALMessage alloc] initWithDictonary:theDictionary];
        [messagesArray addObject:message];
    }
    self.messageList = messagesArray;
    
    NSDictionary *userDetailsDictionary = [messagejson valueForKey:@"userDetails"];

    for (NSDictionary *theDictionary in userDetailsDictionary) {
        ALUserDetail *alUserDetail = [[ALUserDetail alloc] initWithDictonary:theDictionary];
        [userDetailArray addObject:alUserDetail];
    }
    
    NSDictionary *conversationProxyDictionary = [messagejson valueForKey:@"conversationPxys"];
    
    for (NSDictionary *theDictionary in conversationProxyDictionary) {
        ALConversationProxy *conversationProxy = [[ALConversationProxy alloc] initWithDictonary:theDictionary];
        conversationProxy.userId = self.userId;
        conversationProxy.groupId = self.groupId;
        [conversationProxyList addObject:conversationProxy];
    }
    
    self.conversationPxyList = conversationProxyList;
    self.userDetailsList = userDetailArray;

}

@end
