//
//  KMCoreMessageService.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "KMCoreMessageService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "KMCoreMessageDBService.h"
#import "KMCoreMessageList.h"
#import "KMCoreDBHandler.h"
#import "ALConnectionQueueHandler.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALSendMessageResponse.h"
#import "ALUserService.h"
#import "KMCoreUserDetail.h"
#import "ALContactDBService.h"
#import "ALContactService.h"
#import "ALConversationService.h"
#import "KMCoreMessage.h"
#include <tgmath.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "KMCoreSettings.h"
#import <objc/runtime.h>
#import "ALMQTTConversationService.h"
#import "KommunicateClient.h"
#import "ALHTTPManager.h"
#import "ALUploadTask.h"
#import "ALLogger.h"

@interface KMCoreMessageService  ()<KommunicateAttachmentDelegate>

@end

@implementation KMCoreMessageService

static KMCoreMessageClientService *alMsgClientService;

+ (KMCoreMessageService *)sharedInstance {
    static KMCoreMessageService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KMCoreMessageService alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUpServices];
    }
    return self;
}

#pragma mark - Setup service

- (void)setUpServices {
    self.messageClientService = [[KMCoreMessageClientService alloc] init];
    self.userService = [[ALUserService alloc] init];
    self.channelService = [[KMCoreChannelService alloc] init];
}

- (void)getMessagesListGroupByContactswithCompletionService:(void(^)(NSMutableArray *messages, NSError *error))completion {
    NSNumber *startTime = [KMCoreUserDefaultsHandler isInitialMessageListCallDone] ? [KMCoreUserDefaultsHandler getLastMessageListTime] : nil;

    [self.messageClientService getLatestMessageGroupByContact:[KMCoreUserDefaultsHandler getFetchConversationPageSize]
                                                    startTime:startTime withCompletion:^(KMCoreMessageList *alMessageList, NSError *error) {

        [self getMessageListForUserIfLastIsHiddenMessageinMessageList:alMessageList
                                                       withCompletion:^(NSMutableArray *responseMessages, NSError *responseErrorH, NSMutableArray *userDetailArray) {

            completion(responseMessages, responseErrorH);

        }];
    }];

}

- (void)getMessageListForUserIfLastIsHiddenMessageinMessageList:(KMCoreMessageList *)alMessageList
                                                 withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion {

    /*____If latest_message of a contact is HIDDEN MESSAGE OR MESSSAGE HIDE = TRUE, then get MessageList of that user from server___*/

    /// Also handle reply messages
    NSMutableArray<NSString *>* replyMessageKeys = [[NSMutableArray alloc] init];

    for (KMCoreMessage *alMessage in alMessageList.messageList) {
        if (alMessage.metadata) {
            NSString *key = [alMessage.metadata valueForKey: AL_MESSAGE_REPLY_KEY];
            if (key) {
                [replyMessageKeys addObject: key];
            }
        }
        if (![alMessage isHiddenMessage] && ![alMessage isMsgHidden]) {
            continue;
        }

        NSNumber *time = alMessage.createdAtTime;

        MessageListRequest *messageListRequest = [[MessageListRequest alloc] init];
        messageListRequest.userId = alMessage.contactIds;
        messageListRequest.channelKey = alMessage.groupId;
        messageListRequest.endTimeStamp = time;
        messageListRequest.conversationId = alMessage.conversationId;

        [[KMCoreMessageService sharedInstance] getMessageListForUser:messageListRequest withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {

            completion (messages, error, userDetailArray);
        }];
    }
    [[KMCoreMessageService sharedInstance] fetchReplyMessages:replyMessageKeys withCompletion:^(NSMutableArray<KMCoreMessage *> *messages) {
        ALSLog(ALLoggerSeverityInfo, @"Reply message api called");
        completion(alMessageList.messageList, nil, nil);
    }];
}

#pragma mark - Message thread

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
               withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion {

    if (!messageListRequest) {
        NSError *messageListRequestError = [NSError errorWithDomain:@"KMCore"
                                                               code:1
                                                           userInfo:@{NSLocalizedDescriptionKey : @"MessageListRequest is nil"}];

        completion(nil, messageListRequestError, nil);
        return;
    }

    if (!messageListRequest.userId && !messageListRequest.channelKey) {
        NSError *requestParametersError = [NSError errorWithDomain:@"KMCore"
                                                              code:1
                                                          userInfo:@{NSLocalizedDescriptionKey : @"UserId and channelKey is nil"}];
        completion(nil, requestParametersError, nil);
        return;
    }

    //On Message List Cell Tap
    KMCoreMessageDBService *alMessageDBService = [[KMCoreMessageDBService alloc] init];
    NSMutableArray *messageList = [alMessageDBService getMessageListForContactWithCreatedAt:messageListRequest];

    NSString *chatId;
    if (messageListRequest.conversationId != nil) {
        chatId = [messageListRequest.conversationId stringValue];
    } else {
        chatId = messageListRequest.channelKey != nil ? [messageListRequest.channelKey stringValue] : messageListRequest.userId;
    }
    //Found Record in DB itself ...if not make call to server
    if (messageList.count > 0 && [KMCoreUserDefaultsHandler isServerCallDoneForMSGList:chatId]) {
        // NSLog(@"the Message List::%@",messageList);
        completion(messageList, nil, nil);
        return;
    } else {
        ALSLog(ALLoggerSeverityInfo, @"Message thread fetching from server");
    }

    if (messageListRequest.channelKey != nil) {
        KMCoreChannel *alChannel = [self.channelService getChannelByKey:messageListRequest.channelKey];
        if (alChannel) {
            messageListRequest.channelType = alChannel.type;
        }
    }

    ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];

    [self.messageClientService getMessageListForUser:messageListRequest
                                       withOpenGroup:messageListRequest.channelType == OPEN
                                      withCompletion:^(NSMutableArray *messages,
                                                       NSError *error,
                                                       NSMutableArray *userDetailArray) {


        if (error) {
            completion(nil, error, nil);
            return;
        }
        
        [KMCoreUserDefaultsHandler setShowLoadEarlierOption:(messages.count == 50) forContactId: chatId];

        [alContactDBService addUserDetails:userDetailArray];

        ALContactService *contactService = [ALContactService new];
        NSMutableArray *userNotPresentIds = [NSMutableArray new];
        NSMutableArray<NSString *>* replyMessageKeys = [[NSMutableArray alloc] init];

        KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
        for (int i = (int)messages.count - 1; i >= 0; i--) {
            KMCoreMessage *message = messages[i];

            if ([message isHiddenMessage] && ![message isVOIPNotificationMessage]) {
                [messages removeObjectAtIndex:i];
            }

            if (message.to && ![contactService isContactExist:message.to]) {
                [userNotPresentIds addObject:message.to];
            }
            /// If its a reply message add the reply message key to array
            if (message.metadata) {
                NSString *replyKey = [message.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
                if (replyKey && ![messageDBService getMessageByKey:@"key" value: replyKey] && ![replyMessageKeys containsObject: replyKey]) {
                    [replyMessageKeys addObject: replyKey];
                }
            }
        }
        /// Check if the key in reply array is present in messages
        for (int i = 0; i < messages.count; i++) {
            KMCoreMessage *message = messages[i];
            if ([replyMessageKeys containsObject:message.key]) {
                [replyMessageKeys removeObject:message.key];
            }
        }

        /// Make server call for fetching reply messages
        [self fetchReplyMessages: replyMessageKeys withCompletion:^(NSMutableArray<KMCoreMessage *> *replyMessages) {
            if (replyMessages && replyMessages.count > 0) {
                for (int i = 0; i < replyMessages.count; i++) {
                    if (replyMessages[i].to && ![contactService isContactExist:replyMessages[i].to]) {
                        [userNotPresentIds addObject: replyMessages[i].to];
                    }
                }
            }
            if (userNotPresentIds.count>0) {
                ALUserService *alUserService = [ALUserService new];
                [alUserService fetchAndupdateUserDetails:userNotPresentIds withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
                    completion(messages, error, userDetailArray);
                }];
            } else {
                completion(messages, error, userDetailArray);
            }
        }];
    }];
}

+ (void)getMessageListForContactId:(NSString *)contactIds
                           isGroup:(BOOL)isGroup
                        channelKey:(NSNumber *)channelKey
                    conversationId:(NSNumber *)conversationId
                        startIndex:(NSInteger)startIndex
                         startTime:(NSNumber *)startTime
                    withCompletion:(void (^)(NSMutableArray *))completion {
    int rp = 50;

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSFetchRequest *dbMessageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [dbMessageFetchRequest setFetchLimit:rp];
    NSPredicate *predicate1;
    if (conversationId && [KMCoreSettings getContextualChatOption]) {
        predicate1 = [NSPredicate predicateWithFormat:@"conversationId = %d", [conversationId intValue]];
    } else if(isGroup) {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %d", [channelKey intValue]];
    } else {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil", contactIds];
    }

    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"deletedFlag == NO AND msgHidden == %@",@(NO)];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"contentType != %i",ALMESSAGE_CONTENT_HIDDEN];
    NSPredicate *compoundPredicate;
    if(startTime != nil){
        NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"createdAt < %lld", [startTime longLongValue]];
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3,predicate4]];
    } else {
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3]];
    }
    [dbMessageFetchRequest setPredicate:compoundPredicate];
    [dbMessageFetchRequest setFetchOffset:startIndex];
    [dbMessageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSArray *theArray = [alDBHandler executeFetchRequest:dbMessageFetchRequest withError:nil];

    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    if (theArray.count) {
        KMCoreMessageDBService* messageDBService = [[KMCoreMessageDBService alloc]init];
        for (DB_Message * theEntity in theArray) {
            KMCoreMessage * theMessage = [messageDBService createMessageEntity:theEntity];
            [messageArray insertObject:theMessage atIndex:0];
        }
    }
    completion(messageArray);
}

#pragma mark - Send message

- (void)sendMessages:(KMCoreMessage *)alMessage withCompletion:(void(^)(NSString *message, NSError *error)) completion {

    if (!alMessage) {
        NSError *messageError = [NSError errorWithDomain:@"KMCore"
                                                    code:MessageNotPresent
                                                userInfo:@{NSLocalizedDescriptionKey : @"Empty message passed"}];

        completion(nil, messageError);
        return;
    }

    //DB insert if objectID is null
    DB_Message *dbMessage;
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationTableNotification" object:alMessage userInfo:nil];

    KMCoreChannel *channel;
    if (alMessage.groupId != nil) {
        KMCoreChannelService *channelService = [[KMCoreChannelService alloc]init];
        channel  = [channelService getChannelByKey:alMessage.groupId];
    }

    if (alMessage.msgDBObjectId == nil) {
        ALSLog(ALLoggerSeverityInfo, @"Message not in DB new insertions.");
        if (channel) {
            if (channel.type != OPEN) {
                dbMessage = [messageDBService addMessage:alMessage];
            }
        } else {
            dbMessage = [messageDBService addMessage:alMessage];
        }
    } else {
        ALSLog(ALLoggerSeverityInfo, @"Message found in DB just getting it not inserting new one.");
        dbMessage = (DB_Message*)[messageDBService getMeesageById:alMessage.msgDBObjectId];
    }
    //convert to dic
    NSDictionary *messageDictionary = [alMessage dictionary];
    [self.messageClientService sendMessage:messageDictionary withCompletionHandler:^(id theJson, NSError *theError) {

        NSString *responseString = nil;

        if (!theError) {
            ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:theJson];
            ALSendMessageResponse *response = [[ALSendMessageResponse alloc] initWithJSONString:apiResponse.response];

            if (!response.isSuccess) {
                theError = [NSError errorWithDomain:@"KMCore" code:1
                                           userInfo:[NSDictionary
                                                     dictionaryWithObject:@"Error sending message"
                                                     forKey:NSLocalizedDescriptionKey]];

            } else {
                if (channel) {
                    if (channel.type != OPEN || (dbMessage != nil && dbMessage.fileMetaInfo != nil)) {
                        alMessage.msgDBObjectId = dbMessage.objectID;
                        [messageDBService updateMessageSentDetails:response.messageKey withCreatedAtTime:response.createdAt withDbMessage:dbMessage];

                    }
                } else {
                    alMessage.msgDBObjectId = dbMessage.objectID;
                    [messageDBService updateMessageSentDetails:response.messageKey withCreatedAtTime:response.createdAt withDbMessage:dbMessage];
                }

                alMessage.key = response.messageKey;
                alMessage.sentToServer = YES;
                alMessage.inProgress = NO;
                alMessage.isUploadFailed= NO;
                alMessage.status = [NSNumber numberWithInt:SENT];
            }

            if (self.delegate) {
                [self.delegate onMessageSent:alMessage];
            }

        } else {
            ALSLog(ALLoggerSeverityError, @"Got error while sending messages");
        }
        completion(responseString,theError);
    }];

}

#pragma mark - Sync latest messages with delegate

+ (void) getLatestMessageForUser:(NSString *)deviceKeyString
                    withDelegate:(id<KommunicateUpdatesDelegate>)delegate
                  withCompletion:(void (^)( NSMutableArray *, NSError *))completion {
    if (!alMsgClientService) {
        alMsgClientService = [[KMCoreMessageClientService alloc] init];
    }

    @synchronized(alMsgClientService) {

        [alMsgClientService getLatestMessageForUser:deviceKeyString withCompletion:^(ALSyncMessageFeed * syncResponse , NSError *error) {
            NSMutableArray *messageArray = nil;

            if (!error) {
                if (syncResponse.deliveredMessageKeys.count > 0) {
                    [KMCoreMessageService updateDeliveredReport:syncResponse.deliveredMessageKeys withStatus:DELIVERED];
                }
                if (syncResponse.messagesList.count > 0) {
                    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
                    messageArray = [messageDBService addMessageList:syncResponse.messagesList skipAddingMessageInDb:NO];

                    NSMutableArray<NSString *> *messageKeys = [[NSMutableArray alloc] init];
                    for (KMCoreMessage *message in syncResponse.messagesList) {
                        if (message.metadata) {
                            NSString *replyMessageKey = [message.metadata valueForKey: AL_MESSAGE_REPLY_KEY];
                            if (replyMessageKey && ![messageDBService getMessageByKey:@"key" value:replyMessageKey]) {
                                [messageKeys addObject:replyMessageKey];
                            }
                        }
                    }
                    if (messageKeys.count > 0) {
                        [[KMCoreMessageService sharedInstance] fetchReplyMessages:messageKeys withCompletion:^(NSMutableArray<KMCoreMessage *> *messages) {
                            if (messages) {
                                [messageArray addObjectsFromArray:messages];
                            }
                            [self processMessages:messageArray delegate:delegate withCompletion:^(NSMutableArray *list) {
                                [KMCoreUserDefaultsHandler setLastSyncTime:syncResponse.lastSyncTime];
                                completion(list, nil);
                            }];
                        }];
                    } else {
                        [self processMessages:messageArray delegate:delegate withCompletion:^(NSMutableArray *list) {
                            [KMCoreUserDefaultsHandler setLastSyncTime:syncResponse.lastSyncTime];
                            completion(list, nil);
                        }];
                    }
                } else {
                    [KMCoreUserDefaultsHandler setLastSyncTime:syncResponse.lastSyncTime];
                    completion(messageArray, error);
                }
            } else {
                completion(messageArray, error);
            }
        }];
    }
}

+ (void)processMessages:(NSMutableArray *)messageArray
               delegate:(id<KommunicateUpdatesDelegate>)delegate
         withCompletion:(void(^)(NSMutableArray *))completion {
    ALUserService *userService = [[ALUserService alloc] init];
    [userService processContactFromMessages:messageArray withCompletion:^{
        for (int i = (int)messageArray.count - 1; i>=0; i--) {
            KMCoreMessage *message = messageArray[i];
            if ([message isHiddenMessage] && ![message isVOIPNotificationMessage]) {
                [messageArray removeObjectAtIndex:i];
            } else if (![message isToIgnoreUnreadCountIncrement]) {
                [self incrementContactUnreadCount:message];
            }

            if (message.groupId != nil && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
                if ([message.metadata[@"action"] isEqual: @"4"]) {
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"CONVERSATION_DELETION"
                     object:message.groupId];
                }
                [[KMCoreChannelService sharedInstance] syncCallForSpecificChannelWithDelegate:delegate channelKey: message.groupId];
            }

            [self resetUnreadCountAndUpdate:message];

            if (![message isHiddenMessage] && ![message isVOIPNotificationMessage] && delegate) {
                if ([message.type isEqual: AL_OUT_BOX]) {
                    [delegate onMessageSent: message];
                } else {
                    [delegate onMessageReceived: message];
                }
            }
        }

        if (messageArray.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MESSAGE_NOTIFICATION object:messageArray userInfo:nil];
        }
        completion(messageArray);
    }];
}

+ (void)getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)( NSMutableArray *, NSError *))completion {
    [self getLatestMessageForUser:deviceKeyString withDelegate:nil withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        completion(messageArray,error);
    }];
}

+ (BOOL)incrementContactUnreadCount:(KMCoreMessage*)message {

    if (![KMCoreMessageService isIncrementRequired:message]) {
        return NO;
    }

    if (message.groupId != nil) {
        NSNumber *groupId = message.groupId;
        KMCoreChannelDBService *channelDBService =[[KMCoreChannelDBService alloc] init];
        KMCoreChannel *channel = [channelDBService loadChannelByKey:groupId];
        if (![message isResetUnreadCountMessage]) {
            channel.unreadCount = [NSNumber numberWithInt:channel.unreadCount.intValue+1];
            [channelDBService updateUnreadCountChannel:message.groupId unreadCount:channel.unreadCount];
        }
    } else {
        NSString *contactId = message.contactIds;
        ALContactService *contactService = [[ALContactService alloc] init];
        ALContact *contact = [contactService loadContactByKey:@"userId" value:contactId];
        contact.unreadCount = [NSNumber numberWithInt:[contact.unreadCount intValue] + 1];
        [contactService addContact:contact];
    }

    if (message.conversationId != nil) {
        ALConversationService *alConversationService = [[ALConversationService alloc] init];
        [alConversationService fetchTopicDetails:message.conversationId withCompletion:^(NSError *error, ALConversationProxy *proxy) {
        }];
    }
    return YES;
}

+ (BOOL)resetUnreadCountAndUpdate:(KMCoreMessage *)message {

    if ([message isResetUnreadCountMessage]) {
        KMCoreChannelDBService *channelDBService = [[KMCoreChannelDBService alloc] init];
        [channelDBService updateUnreadCountChannel:message.groupId unreadCount:[NSNumber numberWithInt:0]];
        return YES;
    }
    return NO;
}

+ (BOOL)isIncrementRequired:(KMCoreMessage *)message {

    if([message.status isEqualToNumber:[NSNumber numberWithInt:DELIVERED_AND_READ]]
       || (message.groupId && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION)
       || [message.type isEqualToString:@"5"]
       || [message isHiddenMessage]
       || [message isVOIPNotificationMessage]
       || [message.status isEqualToNumber:[NSNumber numberWithInt:READ]]) {
        return NO;
    } else {
        return YES;
    }
}


+ (void)updateDeliveredReport:(NSArray *)deliveredMessageKeys withStatus:(int)status {
    for (id key in deliveredMessageKeys) {
        KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
        [messageDBService updateMessageDeliveryReport:key withStatus:status];
    }
}

#pragma mark - Delete message

- (void)deleteMessage:(NSString *)keyString andContactId:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion {

    if (!keyString) {
        NSError *responseError = [NSError errorWithDomain:@"KMCore"
                                                     code:1
                                                 userInfo:@{NSLocalizedDescriptionKey : @"Message key is nil"}];
        completion(nil, responseError);
        return;
    }

    //db
    KMCoreDBHandler *dbHandler = [KMCoreDBHandler sharedInstance];
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc]init];
    DB_Message *dbMessage = (DB_Message *)[messageDBService getMessageByKey:@"key" value:keyString];
    [dbMessage setDeletedFlag:[NSNumber numberWithBool:YES]];
    KMCoreMessage *message = [messageDBService createMessageEntity:dbMessage];
    bool isUsedForReply = (message.getReplyType == AL_A_REPLY);

    if (isUsedForReply) {
        dbMessage.replyMessageType = [NSNumber numberWithInt:AL_REPLY_BUT_HIDDEN];
    }

    NSError *error = [dbHandler saveContext];
    if (error) {
        ALSLog(ALLoggerSeverityInfo, @"Delete Flag Not Set");
    }
    ALSLog(ALLoggerSeverityInfo, @"Deleting message for key: %@",keyString);

    [self.messageClientService deleteMessage:keyString andContactId:contactId
                              withCompletion:^(NSString *response, NSError *error) {
        if (!error) {
            //none error then delete from DB.
            if (!isUsedForReply) {
                [messageDBService deleteMessageByKey:keyString];
            }
        }
        completion(response,error);
    }];

}

#pragma mark - Delete message thread

- (void)deleteMessageThread:(NSString *)contactId orChannelKey:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion {

    if (!contactId && !channelKey) {
        NSError *responseError = [NSError errorWithDomain:@"KMCore"
                                                     code:1
                                                 userInfo:@{NSLocalizedDescriptionKey : @"UserId and channelKey is nil"}];
        completion(nil, responseError);
        return;
    }

    [self.messageClientService deleteMessageThread:contactId orChannelKey:channelKey withCompletion:^(NSString *response, NSError *error) {

        if (!error) {
            //delete sucessfull
            ALSLog(ALLoggerSeverityInfo, @"Sucessfully deleted the message thread");
            KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
            [messageDBService deleteAllMessagesByContact:contactId orChannelKey:channelKey];

            if (channelKey != nil) {
                [self.channelService setUnreadCountZeroForGroupID:channelKey];
            } else {
                [self.userService setUnreadCountZeroForContactId:contactId];
            }
        }
        completion(response, error);
    }];
}

+ (KMCoreMessage *)processFileUploadSucess:(KMCoreMessage *)message {

    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    DB_Message *dbMessage = (DB_Message*)[messageDBService getMessageByKey:@"key" value:message.key];

    dbMessage.fileMetaInfo.blobKeyString = message.fileMeta.blobKey;
    dbMessage.fileMetaInfo.thumbnailBlobKeyString = message.fileMeta.thumbnailBlobKey;
    dbMessage.fileMetaInfo.contentType = message.fileMeta.contentType;
    dbMessage.fileMetaInfo.createdAtTime = message.fileMeta.createdAtTime;
    dbMessage.fileMetaInfo.key = message.fileMeta.key;
    dbMessage.fileMetaInfo.name = message.fileMeta.name;
    dbMessage.fileMetaInfo.size = message.fileMeta.size;
    dbMessage.fileMetaInfo.suUserKeyString = message.fileMeta.userKey;
    dbMessage.fileMetaInfo.thumbnailUrl = message.fileMeta.thumbnailUrl;

    message.fileMetaKey = message.fileMeta.key;
    message.msgDBObjectId = [dbMessage objectID];

    NSError *error = [[KMCoreDBHandler sharedInstance] saveContext];
    if (error) {
        ALSLog(ALLoggerSeverityError, @"Failed to save the file meta in db %@",error);
        return nil;
    }
    return message;
}

- (void)processPendingMessages {
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];

    NSMutableArray *pendingMessageArray = [messageDBService getPendingMessages];
    ALSLog(ALLoggerSeverityInfo, @"Found pending messages: %lu",(unsigned long)pendingMessageArray.count);

    for (KMCoreMessage *alMessage in pendingMessageArray) {

        if ((!alMessage.fileMeta && !alMessage.pairedMessageKey)) {
            ALSLog(ALLoggerSeverityInfo, @"RESENDING_MESSAGE : %@", alMessage.message);
            [[KMCoreMessageService sharedInstance] sendMessages:alMessage withCompletion:^(NSString *message, NSError *error) {
                if (error) {
                    ALSLog(ALLoggerSeverityError, @"PENDING_MESSAGES_NO_SENT : %@", error);
                    return;
                }

                if (alMessage.groupId == nil) {
                    ALContact *contact = [contactDBService loadContactByKey:@"userId" value:alMessage.to];
                    if (contact && [contact isDisplayNameUpdateRequired] ) {
                        [[ALUserService sharedInstance] updateDisplayNameWith:alMessage.to withDisplayName:contact.displayName withCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
                            if (apiResponse && [apiResponse.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                                [contactDBService addOrUpdateMetadataWithUserId:alMessage.to withMetadataKey:AL_DISPLAY_NAME_UPDATED withMetadataValue:@"true"];
                            }
                        }];
                    }
                }

                ALSLog(ALLoggerSeverityInfo, @"SENT_SUCCESSFULLY....MARKED_AS_DELIVERED : %@", message);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:alMessage];
            }];
        } else if (alMessage.contentType == ALMESSAGE_CONTENT_VCARD) {
            ALSLog(ALLoggerSeverityInfo, @"REACH_PRESENT");
            DB_Message *dbMessage = (DB_Message*)[messageDBService getMessageByKey:@"key" value:alMessage.key];
            dbMessage.inProgress = [NSNumber numberWithBool:YES];
            dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];

            NSError *error = [[KMCoreDBHandler sharedInstance] saveContext];

            if (error) {
                NSLog(@"Failed to save the flags for message error %@",error);
                continue;
            }

            ALHTTPManager *httpManager = [[ALHTTPManager alloc]init];
            httpManager.attachmentProgressDelegate = self;

            NSDictionary *messageDictionary = [alMessage dictionary];
            [self.messageClientService sendPhotoForUserInfo:messageDictionary withCompletion:^(NSString *responseUrl, NSError *error) {

                if (!error) {
                    [httpManager processUploadFileForMessage:[messageDBService createMessageEntity:dbMessage] uploadURL:responseUrl];
                }
            }];
        } else {
            ALSLog(ALLoggerSeverityInfo, @"FILE_META_PRESENT : %@",alMessage.fileMeta );
        }
    }
}

#pragma mark - Sync latest messages

+ (void)syncMessages {
    if ([KMCoreUserDefaultsHandler isLoggedIn]) {
        [KMCoreMessageService getLatestMessageForUser:[KMCoreUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *messageArray, NSError *error) {

            if (error) {
                ALSLog(ALLoggerSeverityError, @"Error in fetching latest sync messages : %@",error);
            }
        }];
    }
}

+ (KMCoreMessage*)getMessagefromKeyValuePair:(NSString*)key andValue:(NSString*)value {
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    DB_Message *dbMessage = (DB_Message *)[messageDBService getMessageByKey:key value:value];
    return [messageDBService createMessageEntity:dbMessage];
}

#pragma mark - Message information with message key

- (void)getMessageInformationWithMessageKey:(NSString *)messageKey
                      withCompletionHandler:(void(^)(KMCoreMessageInfoResponse *msgInfo, NSError *theError))completion {

    if (!messageKey) {
        NSError *messageKeyError = [NSError errorWithDomain:@"KMCore"
                                                       code:MessageNotPresent
                                                   userInfo:@{NSLocalizedDescriptionKey : @"Message key passed is nil"}];
        completion(nil, messageKeyError);
        return;
    }

    [self.messageClientService getCurrentMessageInformation:messageKey
                                      withCompletionHandler:^(KMCoreMessageInfoResponse *msgInfo, NSError *theError) {

        completion(msgInfo, theError);
    }];
}

#pragma mark - Sent message sync with delegate

+ (void)getMessageSENT:(KMCoreMessage *)alMessage
          withDelegate:(id<KommunicateUpdatesDelegate>)theDelegate
        withCompletion:(void (^)( NSMutableArray *, NSError *))completion {

    KMCoreMessage *localMessage = [KMCoreMessageService getMessagefromKeyValuePair:@"key" andValue:alMessage.key];
    if (localMessage.key == nil) {
        [self getLatestMessageForUser:[KMCoreUserDefaultsHandler getDeviceKeyString]
                         withDelegate:theDelegate
                       withCompletion:^(NSMutableArray *messageArray, NSError *error) {
            completion(messageArray, error);
        }];
    }
}

#pragma mark - Sent message sync

+ (void)getMessageSENT:(KMCoreMessage *)alMessage withCompletion:(void (^)( NSMutableArray *, NSError *))completion {

    [self getMessageSENT:alMessage withDelegate:nil withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        completion(messageArray, error);
    }];
}

#pragma mark - Multi Receiver API

+ (void)multiUserSendMessage:(KMCoreMessage *)alMessage
                  toContacts:(NSMutableArray *)contactIdsArray
                    toGroups:(NSMutableArray *)channelKeysArray
              withCompletion:(void(^)(NSString *json, NSError *error)) completion {
    ALUserClientService *userClientService = [[ALUserClientService alloc] init];
    [userClientService multiUserSendMessage:[alMessage dictionary]
                                 toContacts:contactIdsArray
                                   toGroups:channelKeysArray
                             withCompletion:^(NSString *json, NSError *error) {

        if (error) {
            ALSLog(ALLoggerSeverityError, @"SERVICE_ERROR: Multi User Send Message : %@", error);
        }
        completion(json, error);
    }];
}

+ (KMCoreMessage *)createCustomTextMessageEntitySendTo:(NSString *)to withText:(NSString *)text {
    return [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_CUSTOM toSendTo:to withText:text];
}

+ (KMCoreMessage *)createHiddenMessageEntitySentTo:(NSString *)to withText:(NSString *)text {
    return [self createMessageEntityOfContentType:ALMESSAGE_CONTENT_HIDDEN toSendTo:to withText:text];
}

+ (KMCoreMessage *)createMessageEntityOfContentType:(int)contentType
                                       toSendTo:(NSString *)to
                                       withText:(NSString *)text {

    KMCoreMessage *alMessage = [KMCoreMessage new];

    alMessage.contactIds = to;//1
    alMessage.to = to;//2
    alMessage.message = text;//3
    alMessage.contentType = contentType;//4

    alMessage.type = @"5";
    alMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    alMessage.deviceKey = [KMCoreUserDefaultsHandler getDeviceKeyString ];
    alMessage.sendToDevice = NO;
    alMessage.shared = NO;
    alMessage.fileMeta = nil;
    alMessage.storeOnDevice = NO;
    alMessage.key = [[NSUUID UUID] UUIDString];
    alMessage.delivered = NO;
    alMessage.fileMetaKey = nil;

    return alMessage;
}

+ (KMCoreMessage *)createMessageWithMetaData:(NSMutableDictionary *)metaData
                          andContentType:(short)contentType
                           andReceiverId:(NSString *)receiverId
                          andMessageText:(NSString *)msgTxt {
    KMCoreMessage *alMessage = [self createMessageEntityOfContentType:contentType toSendTo:receiverId withText:msgTxt];

    alMessage.metadata = metaData;
    return alMessage;
}

- (NSUInteger)getMessagsCountForUser:(NSString *)userId {
    KMCoreMessageDBService *messageDBService = [KMCoreMessageDBService new];
    return [messageDBService getMessagesCountFromDBForUser:userId];
}

#pragma mark Get latest message for User/Channel

- (KMCoreMessage *)getLatestMessageForUser:(NSString *)userId {
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    return [messageDBService getLatestMessageForUser:userId];
}

- (KMCoreMessage *)getLatestMessageForChannel:(NSNumber *)channelKey excludeChannelOperations:(BOOL)flag {
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    return [messageDBService getLatestMessageForChannel:channelKey excludeChannelOperations:flag];
}

- (KMCoreMessage *)getKMCoreMessageByKey:(NSString *)messageReplyId {
    //GET Message From Server if not present on Server
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    DB_Message *dbMessage = (DB_Message *)[messageDBService getMessageByKey:@"key" value:messageReplyId];
    return [messageDBService createMessageEntity:dbMessage];
}

+ (void)addOpenGroupMessage:(KMCoreMessage *)alMessage withDelegate:(id<KommunicateUpdatesDelegate>)delegate {
    if (!alMessage) {
        return;
    }

    NSMutableArray *singleMessageArray = [[NSMutableArray alloc] init];
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    ALContactService *contactService = [ALContactService new];
    NSMutableArray *userNotPresentIds = [NSMutableArray new];

    [singleMessageArray addObject:alMessage];
    for (int i=0; i<singleMessageArray.count; i++) {
        KMCoreMessage *message = singleMessageArray[i];
        if (message.groupId != nil && message.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
            KMCoreChannelService *channelService = [[KMCoreChannelService alloc] init];
            [channelService syncCallForChannelWithDelegate:delegate];
            if ([message isMsgHidden]) {
                [singleMessageArray removeObjectAtIndex:i];
            }
        }

        NSMutableArray<NSString *>* replyMessageKeys = [[NSMutableArray alloc] init];
        if (message.metadata) {
            NSString *replyKey = [message.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
            if (replyKey && ![messageDBService getMessageByKey:@"key" value: replyKey] && ![replyMessageKeys containsObject: replyKey]) {
                [replyMessageKeys addObject: replyKey];
            }
        }

        [[KMCoreMessageService sharedInstance] fetchReplyMessages:replyMessageKeys withCompletion:^(NSMutableArray<KMCoreMessage *> *replyMessages) {
            if (replyMessages && replyMessages.count > 0) {
                for (int i = 0; i < replyMessages.count; i++) {
                    if (![contactService isContactExist:replyMessages[i].to]) {
                        [userNotPresentIds addObject: replyMessages[i].to];
                    }
                }
            }
            if (userNotPresentIds.count > 0) {
                ALUserService *alUserService = [ALUserService new];
                [alUserService fetchAndupdateUserDetails:userNotPresentIds withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
                    if (!theError) {
                        [[KMCoreMessageService sharedInstance] saveAndPostMessage:message withSkipMessage:YES withDelegate:delegate];
                    }
                }];
            } else {
                [[KMCoreMessageService sharedInstance] saveAndPostMessage:message withSkipMessage:YES withDelegate:delegate];
            }
        }];
    }
}

- (void)saveAndPostMessage:(KMCoreMessage *)message
           withSkipMessage:(BOOL)skip
              withDelegate:(id<KommunicateUpdatesDelegate>)delegate {

    if (message) {
        NSMutableArray *messageArray = [[NSMutableArray alloc] init];
        [messageArray addObject:message];

        KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
        [messageDBService addMessageList:messageArray skipAddingMessageInDb:skip];

        if (delegate) {
            if ([message.type isEqual: AL_OUT_BOX]) {
                [delegate onMessageSent: message];
            } else {
                [delegate onMessageReceived: message];
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MESSAGE_NOTIFICATION object:messageArray userInfo:nil];
    }
}

#pragma mark - Message list for one to one or Channel/Group

- (void)getLatestMessages:(BOOL)isNextPage
           withOnlyGroups:(BOOL)isGroup
    withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion {

    KMCoreMessageDBService *messageDbService = [[KMCoreMessageDBService alloc] init];

    [messageDbService getLatestMessages:isNextPage withOnlyGroups:isGroup withCompletionHandler:^(NSMutableArray *messageList, NSError *error) {
        completion(messageList, error);
    }];
}

- (KMCoreMessage *)handleMessageFailedStatus:(KMCoreMessage *)message {
    KMCoreMessageDBService *messageDBServce = [[KMCoreMessageDBService alloc]init];
    return [messageDBServce handleMessageFailedStatus:message];
}

#pragma mark - Get Message by key

- (KMCoreMessage *)getMessageByKey:(NSString *)messageKey {
    if (!messageKey) {
        return nil;
    }

    KMCoreMessageDBService *messageDBServce = [[KMCoreMessageDBService alloc]init];
    return [messageDBServce getMessageByKey:messageKey];
}

#pragma mark - Sync message metadata

+ (void)syncMessageMetaData:(NSString *)deviceKeyString withCompletion:(void (^)( NSMutableArray *, NSError *))completion {
    if (!alMsgClientService) {
        alMsgClientService = [[KMCoreMessageClientService alloc] init];
    }
    @synchronized(alMsgClientService) {
        [alMsgClientService getLatestMessageForUser:deviceKeyString withMetaDataSync:YES withCompletion:^(ALSyncMessageFeed *syncResponse, NSError *error) {
            NSMutableArray *messageArray = nil;

            if (!error) {
                if (syncResponse.messagesList.count > 0) {
                    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc]init];
                    for (KMCoreMessage *message in syncResponse.messagesList) {
                        [messageDBService updateMessageMetadataOfKey:message.key withMetadata:message.metadata];
                        [[NSNotificationCenter defaultCenter] postNotificationName:AL_MESSAGE_META_DATA_UPDATE object:message userInfo:nil];
                    }
                }
                [KMCoreUserDefaultsHandler setLastSyncTimeForMetaData:syncResponse.lastSyncTime];
                completion(syncResponse.messagesList, error);
            } else {
                completion(messageArray, error);
            }
        }];
    }
}

#pragma mark - Update message metadata

- (void)updateMessageMetadataOfKey:(NSString *)messageKey
                      withMetadata:(NSMutableDictionary *)metadata
                    withCompletion:(void (^)(ALAPIResponse *, NSError *))completion {

    if (!messageKey || !metadata) {
        NSError *messageKeyError = [NSError errorWithDomain:@"KMCore"
                                                       code:MessageNotPresent
                                                   userInfo:@{NSLocalizedDescriptionKey : @"Message key or meta data passed is nil"}];
        
        completion(nil, messageKeyError);
        return;
    }

    [self.messageClientService updateMessageMetadataOfKey:messageKey withMetadata:metadata withCompletion:^(id theJson, NSError *theError) {

        if (theError) {
            completion(nil, theError);
            return;
        }

        ALAPIResponse *alAPIResponse = [[ALAPIResponse alloc] initWithJSONString:theJson];
        if ([alAPIResponse.status isEqualToString:AL_RESPONSE_SUCCESS]) {
            KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
            [messageDBService updateMessageMetadataOfKey:messageKey withMetadata:metadata];
            completion(alAPIResponse, nil);
            return;
        } else {
            NSError *apiError = [NSError errorWithDomain:@"KMCore"
                                                    code:MessageNotPresent
                                                userInfo:@{NSLocalizedDescriptionKey : @"Failed to update message meta data due to api error"}];
            completion(nil, apiError);
            return;
        }
    }];
}

#pragma mark - Fetch reply message

- (void)fetchReplyMessages:(NSMutableArray<NSString *> *)keys withCompletion:(void(^)(NSMutableArray<KMCoreMessage *>* messages))completion {
    if (!keys || keys.count < 1) {
        completion(nil);
        return;
    }
    [self.messageClientService getMessagesWithkeys:keys withCompletion:^(ALAPIResponse *response, NSError *error) {
        if (error || [response.status isEqualToString:AL_RESPONSE_ERROR]) {
            completion(nil);
            return;
        }
        NSDictionary *messageDictionary = [response.response valueForKey:@"message"];
        NSMutableArray<KMCoreMessage *> *messageList = [[NSMutableArray alloc] init];
        for (NSDictionary *msgDictionary  in messageDictionary) {
            KMCoreMessage *message = [[KMCoreMessage alloc] initWithDictonary: msgDictionary];
            message.messageReplyType = [NSNumber numberWithInt:AL_REPLY_BUT_HIDDEN];
            [[[KMCoreMessageDBService alloc] init] addMessage: message];
            [messageList addObject:message];
        }
        completion(messageList);
    }];
}

- (void)onDownloadCompleted:(KMCoreMessage *)alMessage {

}

- (void)onDownloadFailed:(KMCoreMessage *)alMessage {

}

- (void)onUpdateBytesDownloaded:(int64_t)bytesReceived withMessage:(KMCoreMessage *)alMessage {

}

- (void)onUpdateBytesUploaded:(int64_t)bytesSent withMessage:(KMCoreMessage *)alMessage {

}

- (void)onUploadCompleted:(KMCoreMessage *)alMessage withOldMessageKey:(NSString *)oldMessageKey {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MESSAGE_SEND_STATUS" object:alMessage];
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
    if (alMessage.groupId == nil) {
        ALContact *contact = [contactDBService loadContactByKey:@"userId" value:alMessage.to];
        if (contact && [contact isDisplayNameUpdateRequired] ) {
            [[ALUserService sharedInstance] updateDisplayNameWith:alMessage.to withDisplayName:contact.displayName withCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
                if (apiResponse && [apiResponse.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                    [contactDBService addOrUpdateMetadataWithUserId:alMessage.to withMetadataKey:AL_DISPLAY_NAME_UPDATED withMetadataValue:@"true"];
                }
            }];
        }
    }
}

- (void)onUploadFailed:(KMCoreMessage *)alMessage {

}

#pragma mark - Delete message for all

- (void)deleteMessageForAllWithKey:(NSString *)keyString
                    withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {
    if (!keyString) {
        NSError *messageKeyNilError = [NSError errorWithDomain:@"KMCore"
                                                          code:1
                                                      userInfo:@{NSLocalizedDescriptionKey : @"Passed message key is nil"}];
        completion(nil, messageKeyNilError);
        return;
    }

    [self.messageClientService deleteMessageForAllWithKey:keyString withCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
        completion(apiResponse, error);
    }];
}

#pragma mark - Total unread message count

- (void)getTotalUnreadMessageCountWithCompletionHandler:(void (^)(NSUInteger unreadCount, NSError *error))completion {
    ALUserService *alUserService = [[ALUserService alloc] init];
    if (![KMCoreUserDefaultsHandler isInitialMessageListCallDone]) {
        KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
        [messageDBService getLatestMessages:NO
                      withCompletionHandler:^(NSMutableArray *messageListArray, NSError *error) {
            if (error) {
                completion(0, error);
                return;
            }
            NSNumber *totalUnreadCount = [alUserService getTotalUnreadCount];
            completion(totalUnreadCount.integerValue, nil);
        }];
    } else {
        NSNumber *totalUnreadCount = [alUserService getTotalUnreadCount];
        completion(totalUnreadCount.integerValue, nil);
    }
}

#pragma mark - Total unread conversation count

- (void)getTotalUnreadConversationCountWithCompletionHandler:(void (^)(NSUInteger conversationUnreadCount, NSError *error))completion {
    KMCoreMessageDBService *messageDBService = [[KMCoreMessageDBService alloc] init];
    [messageDBService getLatestMessages:NO withCompletionHandler:^(NSMutableArray *messageListArray, NSError *error) {

        if (error) {
            completion(0, error);
            return;
        }
        NSUInteger unreadCount = 0;

        KMCoreChannelService *channelService = [[KMCoreChannelService alloc] init];
        ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
        
        for (KMCoreMessage *message in messageListArray) {
            if (message.groupId &&
                message.groupId.integerValue != 0) {
                KMCoreChannel *channel = [channelService getChannelByKey:message.groupId];
                if (channel && channel.unreadCount.integerValue > 0) {
                    unreadCount += 1;
                }
            } else {
                ALContact *contact = [contactDBService loadContactByKey:@"userId" value:message.to];
                if (contact && contact.unreadCount.integerValue > 0) {
                    unreadCount += 1;
                }
            }
        }
        completion(unreadCount, nil);
    }];
}

@end
