//
//  ALMessageDBService.m
//  ChatApp
//
//  Created by Devashish on 21/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMessageDBService.h"
#import "ALContact.h"
#import "ALDBHandler.h"
#import "DB_Message.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessage.h"
#import "DB_FileMetaInfo.h"
#import "ALMessageService.h"
#import "ALContactService.h"
#import "ALMessageClientService.h"
#import "ALApplozicSettings.h"
#import "ALChannelService.h"
#import "ALChannel.h"
#import "ALUserService.h"
#import "ALUtilityClass.h"
#import "ALLogger.h"

@implementation ALMessageDBService

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

#pragma mark - Setup service

-(void)setupServices {
    self.messageService = [[ALMessageService alloc] init];
}

- (NSMutableArray *)addMessageList:(NSMutableArray *)messageList
             skipAddingMessageInDb:(BOOL)skip {
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    for (ALMessage *alMessage in messageList) {

        if (skip && !alMessage.fileMeta) {
            [messageArray addObject:alMessage];
            continue;
        }

        NSManagedObject *managedObjectMessage = [self getMessageByKey:@"key" value:alMessage.key];
        if (managedObjectMessage == nil && ![alMessage isPushNotificationMessage]) {
            alMessage.sentToServer = YES;

            DB_Message *dbMessageEntity = [self createMessageEntityForDBInsertionWithMessage:alMessage];

            if (dbMessageEntity) {
                alMessage.msgDBObjectId = dbMessageEntity.objectID;
                [messageArray addObject:alMessage];
            }

        } else if (managedObjectMessage != nil) {
            DB_Message *dbMessage = (DB_Message *)managedObjectMessage;
            if (dbMessage && [dbMessage.replyMessageType intValue] == AL_REPLY_BUT_HIDDEN) {
                int replyType = (dbMessage.metadata && [dbMessage.metadata containsString:AL_MESSAGE_REPLY_KEY]) ? AL_A_REPLY : AL_NOT_A_REPLY;
                [self updateMessageReplyType:dbMessage.key replyType: [NSNumber numberWithInt:replyType] hideFlag:NO];
            }
        }
    }

    NSError *error = [alDBHandler saveContext];
    if (error) {
        ALSLog(ALLoggerSeverityError, @"Unable to save Messages in addMessageList error :%@",error);
    }

    return messageArray;
}

#pragma mark - Add message in Database

- (DB_Message *)addMessage:(ALMessage *)message {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    DB_Message *dbMessage = [self createMessageEntityForDBInsertionWithMessage:message];

    if (dbMessage) {
        NSError *error = [alDBHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to save the message :%@",error);
            return nil;
        }

        message.msgDBObjectId = dbMessage.objectID;
        if ([message.status isEqualToNumber:[NSNumber numberWithInt:SENT]]) {
            dbMessage.status = [NSNumber numberWithInt:READ];
        }
        if (message.isAReplyMessage) {
            NSString *messageReplyId = [message.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
            DB_Message *replyMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageReplyId];
            if (replyMessage) {
                replyMessage.replyMessageType = [NSNumber numberWithInt:AL_A_REPLY];
                NSError *error = [alDBHandler saveContext];
                if (error) {
                    ALSLog(ALLoggerSeverityError, @"Failed to update the reply type in the message :%@",error);
                }
            }
        }
    }

    return dbMessage;
}

- (NSManagedObject *)getMeesageById:(NSManagedObjectID *)objectID {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSManagedObject *messageManagedObject = [alDBHandler existingObjectWithID:objectID];
    return messageManagedObject;
}

- (void)updateDeliveryReportForContact:(NSString *)contactId
                            withStatus:(int)status {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *dbMessasgeEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_Message"];

    if (dbMessasgeEntity) {

        NSMutableArray *predicateArray = [[NSMutableArray alloc] init];

        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@",contactId];
        [predicateArray addObject:predicate1];

        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"status != %i and sentToServer ==%@",
                                   DELIVERED_AND_READ,[NSNumber numberWithBool:YES]];
        [predicateArray addObject:predicate3];

        NSCompoundPredicate *resultantPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];

        [fetchRequest setEntity:dbMessasgeEntity];
        [fetchRequest setPredicate:resultantPredicate];
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (result.count > 0) {
            ALSLog(ALLoggerSeverityInfo, @"Found Messages to update to DELIVERED_AND_READ in DB :%lu",(unsigned long)result.count);
            for (DB_Message *dbMessage in result) {
                [dbMessage setStatus:[NSNumber numberWithInt:status]];
            }

            NSError *error = [alDBHandler saveContext];

            if (error) {
                ALSLog(ALLoggerSeverityError, @"Unable to save STATUS OF managed objects. %@, %@", error, error.localizedDescription);
            }
        }
    }
}

#pragma mark - Update message Delivery report in Database

- (void)updateMessageDeliveryReport:(NSString *)messageKeyString
                         withStatus:(int)status {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

    NSManagedObject *dbMessage = [self getMessageByKey:@"key" value:messageKeyString];

    if (dbMessage) {
        [dbMessage setValue:@(status) forKey:@"status"];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Error in updating Message Delivery Report %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"Update message delivery report in DB update Success %@", messageKeyString);
        }
    }
}

- (void)updateMessageSyncStatus:(NSString *)keyString {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSManagedObject *dbMessage = [self getMessageByKey:@"keyString" value:keyString];
    if (dbMessage) {
        [dbMessage setValue:@"1" forKey:@"isSent"];
        NSError *error = [alDBHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityInfo, @"Message deliverd status updated Failed  %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"Message found and maked as deliverd");
        }
    }
}

#pragma mark - Delete message by messagekey

- (void)deleteMessageByKey:(NSString *)keyString {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSManagedObject *message = [self getMessageByKey:@"key" value:keyString];

    if (message) {
        [alDBHandler deleteObject:message];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityInfo, @"Failed to delete the message got some error: %@", error);
        }
    } else {
        ALSLog(ALLoggerSeverityInfo, @"Failed to delete the Message not found with this key: %@", keyString);
    }
}

#pragma mark - Delete all messages for user or group

- (void)deleteAllMessagesByContact:(NSString *)contactId
                      orChannelKey:(NSNumber *)key {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *dbMessageEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_Message"];

    if (dbMessageEntity) {
        NSPredicate *predicate;
        if (key != nil) {
            predicate = [NSPredicate predicateWithFormat:@"groupId = %@",key];
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService setUnreadCountZeroForGroupID:key];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"contactId = %@ AND groupId = %@",contactId,nil];
            ALUserService *userService = [[ALUserService alloc] init];
            [userService setUnreadCountZeroForContactId:contactId];
        }

        [fetchRequest setEntity:dbMessageEntity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result =  [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (result.count > 0) {

            for (DB_Message *message in result) {
                [alDBHandler deleteObject:message];
            }

            NSError *deleteError = [alDBHandler saveContext];

            if (deleteError) {
                ALSLog(ALLoggerSeverityError, @"Unable to save managed object context %@, %@", deleteError, deleteError.localizedDescription);
            }
        }
    }
}

#pragma mark - Message table is empty

- (BOOL)isMessageTableEmpty {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSEntityDescription *dbMessageEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_Message"];
    if (dbMessageEntity) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:dbMessageEntity];
        [fetchRequest setIncludesPropertyValues:NO];
        [fetchRequest setIncludesSubentities:NO];
        NSUInteger count = [alDBHandler countForFetchRequest:fetchRequest];
        return !(count >0);
    }
    return true;
}

#pragma mark - Delete all objects in Database tables

- (void)deleteAllObjectsInCoreData {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSArray *allEntities = alDBHandler.managedObjectModel.entities;
    if (allEntities.count) {
        for (NSEntityDescription *entityDescription in allEntities) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entityDescription];

            fetchRequest.includesPropertyValues = NO;
            fetchRequest.includesSubentities = NO;
            NSError *fetchError = nil;
            NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];

            if (fetchError) {
                ALSLog(ALLoggerSeverityError, @"Error requesting items from Core Data: %@", [fetchError localizedDescription]);
                return;
            }

            for (NSManagedObject *managedObject in result) {
                [alDBHandler deleteObject:managedObject];
            }

            NSError *saveError = [alDBHandler saveContext];
            if (saveError) {
                ALSLog(ALLoggerSeverityError, @"Error deleting %@ - error:%@", saveError, [saveError localizedDescription]);
            }
        }
    }
}

#pragma mark - Get Database message by message key

- (NSManagedObject *)getMessageByKey:(NSString *)key value:(NSString *)value {

    //Runs at MessageList viewing/opening...ONLY FIRST TIME AND if delete an msg
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *dbMessageEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_Message"];
    if (dbMessageEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
        NSPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]];
        [fetchRequest setEntity:dbMessageEntity];
        [fetchRequest setPredicate:resultPredicate];
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count > 0) {
            NSManagedObject* message = [result objectAtIndex:0];
            return message;
        }
    }
    return nil;
}

#pragma mark - ALMessagesViewController DB Operations.

- (void)getMessages:(NSMutableArray *)subGroupList {
    if ([self isMessageTableEmpty] ||
        [ALApplozicSettings getCategoryName] ||
        ![ALUserDefaultsHandler isInitialMessageListCallDone]) {
        [self fetchAndRefreshFromServer:subGroupList];
    } else  {
        /// Db is synced
        /// Fetch data from db
        if (subGroupList && [ALApplozicSettings getSubGroupLaunchFlag]) {
            /// case for sub group
            [self fetchSubGroupConversations:subGroupList];
        } else {
            [self fetchConversationsGroupByContactId];
        }
    }
}

- (void)fetchAndRefreshFromServer:(NSMutableArray *)subGroupList {
    [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray *theArray) {

        if (success) {
            /// save data into the db
            [self addMessageList:theArray skipAddingMessageInDb:NO];
            /// set yes to userdefaults
            [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
            /// add default contacts
            /// fetch data from db
            if (subGroupList && [ALApplozicSettings getSubGroupLaunchFlag]) {
                [self fetchSubGroupConversations:subGroupList];
            } else {
                [self fetchConversationsGroupByContactId];
            }
        }
    }];
}

- (void)fetchAndRefreshQuickConversationWithCompletion:(void (^)( NSMutableArray *, NSError *))completion {
    NSString *deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];

    [ALMessageService getLatestMessageForUser:deviceKeyString withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch the latest messages for user with error: %@",error);
            completion (nil, error);
            return;
        }
        [self.delegate updateMessageList:messageArray];

        completion (messageArray, error);
    }];

}

#pragma mark - Helper methods

- (void)syncConverstionDBWithCompletion:(void(^)(BOOL success , NSMutableArray *theArray)) completion {

    [self.messageService getMessagesListGroupByContactswithCompletionService:^(NSMutableArray *messages, NSError *error) {

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch the list of messages group by contacts with error: %@",error);
            completion(NO, nil);
            return;
        }
        completion(YES, messages);
    }];
}

- (void)getLatestMessagesWithCompletion:(void(^)(NSMutableArray *theArray, NSError *error)) completion {
    [self.messageService getMessagesListGroupByContactswithCompletionService:^(NSMutableArray *messages, NSError *error) {
        completion(messages, error);
    }];
}

- (NSArray *)getMessageList:(int)messageCount messageTypeOnlyReceived:(BOOL)received {

    // Get the latest record
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [messageRequest setResultType:NSDictionaryResultType];
    [messageRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    if(received) {
        /// Load messages with type received
        [messageRequest setPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",@"4",@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
    } else {
        /// No type restriction
        [messageRequest setPredicate:[NSPredicate predicateWithFormat:@"deletedFlag == %@ AND contentType != %i AND msgHidden == %@",@(NO), ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
    }

    NSArray *messageArray = [alDBHandler executeFetchRequest:messageRequest withError:nil];
    /// Trim the message list
    if (messageArray.count > 0) {
        return [messageArray subarrayWithRange:NSMakeRange(0, MIN(messageCount, messageArray.count))];
    }

    return nil;
}

- (void)fetchConversationsGroupByContactId {
    [self fetchLatestConversationsGroupByContactId :NO];
}

- (NSMutableArray *)fetchLatestConversationsGroupByContactId:(BOOL)isFetchOnCreatedAtTime {

    ALConversationListRequest *conversationListRequest = [[ALConversationListRequest alloc] init];

    NSMutableArray *sortedArray = [self fetchLatestMessagesFromDatabaseWithRequestList:conversationListRequest];

    if (self.delegate && [self.delegate respondsToSelector:@selector(getMessagesArray:)]) {
        [self.delegate getMessagesArray:sortedArray];
    }

    return sortedArray;
}

- (NSMutableArray *)fetchLatestMessagesFromDatabaseWithRequestList:(ALConversationListRequest *)conversationListRequest {

    NSPredicate *predicateCreatedAt;
    if (conversationListRequest.endTimeStamp
        && conversationListRequest.startTimeStamp == nil) {
        predicateCreatedAt = [NSPredicate predicateWithFormat:@"createdAt < %@",conversationListRequest.endTimeStamp];
    } else if (conversationListRequest.startTimeStamp != nil) {
        predicateCreatedAt = [NSPredicate predicateWithFormat:@"createdAt >= %@",conversationListRequest.startTimeStamp];
    }

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    /// get all unique contacts
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [messageFetchRequest setResultType:NSDictionaryResultType];
    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    if (predicateCreatedAt) {
        [messageFetchRequest setPredicate:predicateCreatedAt];
    }

    [messageFetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"groupId", nil]];
    [messageFetchRequest setReturnsDistinctResults:YES];

    NSError *fetchError = nil;
    NSArray *theArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:&fetchError];
    NSMutableArray *messagesArray = [NSMutableArray new];
    if (theArray.count > 0) {
        /// get latest record
        for (NSDictionary *messageDictionary in theArray) {
            NSFetchRequest *dbMessageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
            if ([messageDictionary[@"groupId"] intValue]==0) {
                continue;
            }
            if ([ALApplozicSettings getCategoryName]) {
                ALChannel *channel =  [[ALChannelService new] getChannelByKey:[NSNumber numberWithInt:[messageDictionary[@"groupId"] intValue]]];
                if(![channel isPartOfCategory:[ALApplozicSettings getCategoryName]]) {
                    continue;
                }
            }
            [dbMessageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
            [dbMessageFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%d AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",
                                                 [messageDictionary[@"groupId"] intValue],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
            [dbMessageFetchRequest setFetchLimit:1];

            NSArray *groupMessageArray = [alDBHandler executeFetchRequest:dbMessageFetchRequest withError:nil];
            if (groupMessageArray.count > 0) {
                DB_Message *dbMessageEntity = groupMessageArray.firstObject;
                if (groupMessageArray.count) {
                    ALMessage *alMessage = [self createMessageEntity:dbMessageEntity];
                    [messagesArray addObject:alMessage];
                }
            }
        }
    }
    /// Find all message only have contact ...
    NSFetchRequest *userMessageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [userMessageFetchRequest setResultType:NSDictionaryResultType];
    NSPredicate *groupRemovePredicate = [NSPredicate predicateWithFormat:@"groupId=%d OR groupId=nil",0];

    if (predicateCreatedAt) {
        NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateCreatedAt, groupRemovePredicate]];
        [userMessageFetchRequest setPredicate:compoundPredicate];
    } else {
        [userMessageFetchRequest setPredicate:groupRemovePredicate];
    }

    [userMessageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [userMessageFetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"contactId", nil]];
    [userMessageFetchRequest setReturnsDistinctResults:YES];

    NSArray *userMessageArray = [alDBHandler executeFetchRequest:userMessageFetchRequest withError:nil];

    if (userMessageArray.count > 0) {
        for (NSDictionary *theDictionary in userMessageArray) {

            NSFetchRequest *dbMessageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
            [dbMessageFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@ and groupId=nil and deletedFlag == %@ AND contentType != %i AND msgHidden == %@",theDictionary[@"contactId"],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];

            [dbMessageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
            [dbMessageFetchRequest setFetchLimit:1];

            NSArray *fetchArray =  [alDBHandler executeFetchRequest:dbMessageFetchRequest withError:nil];
            if (fetchArray.count > 0) {
                DB_Message *dbMessageEntity = fetchArray.firstObject;
                if (fetchArray.count) {
                    ALMessage *alMessage = [self createMessageEntity:dbMessageEntity];
                    [messagesArray addObject:alMessage];
                }
            }
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortedMessageArray = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[messagesArray sortedArrayUsingDescriptors:sortedMessageArray] mutableCopy];

    return sortedArray;
}

- (DB_Message *)createMessageEntityForDBInsertionWithMessage:(ALMessage *)alMessage {

    //Runs at MessageList viewing/opening... ONLY FIRST TIME
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

    DB_Message *dbMessageEntity = (DB_Message *)[alDBHandler insertNewObjectForEntityForName:@"DB_Message"];

    if (dbMessageEntity) {
        dbMessageEntity.contactId = alMessage.contactIds;
        dbMessageEntity.createdAt =  alMessage.createdAtTime;
        dbMessageEntity.deviceKey = alMessage.deviceKey;
        dbMessageEntity.status = [NSNumber numberWithInt:([dbMessageEntity.type isEqualToString:@"5"] ? READ
                                                          : alMessage.status.intValue)];

        dbMessageEntity.isSentToDevice = [NSNumber numberWithBool:alMessage.sendToDevice];
        dbMessageEntity.isShared = [NSNumber numberWithBool:alMessage.shared];
        dbMessageEntity.isStoredOnDevice = [NSNumber numberWithBool:alMessage.storeOnDevice];
        dbMessageEntity.key = alMessage.key;
        dbMessageEntity.messageText = alMessage.message;
        dbMessageEntity.userKey = alMessage.userKey;
        dbMessageEntity.to = alMessage.to;
        dbMessageEntity.type = alMessage.type;
        dbMessageEntity.delivered = [NSNumber numberWithBool:alMessage.delivered];
        dbMessageEntity.sentToServer = [NSNumber numberWithBool:alMessage.sentToServer];
        dbMessageEntity.filePath = alMessage.imageFilePath;
        dbMessageEntity.inProgress = [NSNumber numberWithBool:alMessage.inProgress];
        dbMessageEntity.isUploadFailed=[ NSNumber numberWithBool:alMessage.isUploadFailed];
        dbMessageEntity.contentType = alMessage.contentType;
        dbMessageEntity.deletedFlag=[NSNumber numberWithBool:alMessage.deleted];
        dbMessageEntity.conversationId = alMessage.conversationId;
        dbMessageEntity.pairedMessageKey = alMessage.pairedMessageKey;
        dbMessageEntity.metadata = alMessage.metadata.description;
        dbMessageEntity.msgHidden = [NSNumber numberWithBool:[alMessage isHiddenMessage]];
        dbMessageEntity.replyMessageType = alMessage.messageReplyType;
        dbMessageEntity.source = alMessage.source;

        if (alMessage.getGroupId != nil) {
            dbMessageEntity.groupId = alMessage.groupId;
        }
        if (alMessage.fileMeta != nil) {
            DB_FileMetaInfo *fileInfo =  [self createFileMetaInfoEntityForDBInsertionWithMessage:alMessage.fileMeta];
            dbMessageEntity.fileMetaInfo = fileInfo;
        }
    }
    return dbMessageEntity;
}

- (DB_FileMetaInfo *)createFileMetaInfoEntityForDBInsertionWithMessage:(ALFileMetaInfo *)fileInfo {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    DB_FileMetaInfo *fileMetaInfo = (DB_FileMetaInfo *)[alDBHandler insertNewObjectForEntityForName:@"DB_FileMetaInfo"];

    if (fileMetaInfo) {
        fileMetaInfo.blobKeyString = fileInfo.blobKey;
        fileMetaInfo.thumbnailBlobKeyString = fileInfo.thumbnailBlobKey;
        fileMetaInfo.contentType = fileInfo.contentType;
        fileMetaInfo.createdAtTime = fileInfo.createdAtTime;
        fileMetaInfo.key = fileInfo.key;
        fileMetaInfo.name = fileInfo.name;
        fileMetaInfo.size = fileInfo.size;
        fileMetaInfo.suUserKeyString = fileInfo.userKey;
        fileMetaInfo.thumbnailUrl = fileInfo.thumbnailUrl;
        fileMetaInfo.url = fileInfo.url;
    }

    return fileMetaInfo;
}

- (ALMessage *)createMessageEntity:(DB_Message *)dbMessage {

    if (!dbMessage) {
        return nil;
    }
    ALMessage *alMessage = [ALMessage new];

    alMessage.msgDBObjectId = [dbMessage objectID];
    alMessage.key = dbMessage.key;
    alMessage.deviceKey = dbMessage.deviceKey;
    alMessage.userKey = dbMessage.userKey;
    alMessage.to = dbMessage.to;
    alMessage.message = dbMessage.messageText;
    alMessage.sendToDevice = dbMessage.isSentToDevice.boolValue;
    alMessage.shared = dbMessage.isShared.boolValue;
    alMessage.createdAtTime = dbMessage.createdAt;
    alMessage.type = dbMessage.type;
    alMessage.contactIds = dbMessage.contactId;
    alMessage.storeOnDevice = dbMessage.isStoredOnDevice.boolValue;
    alMessage.inProgress =dbMessage.inProgress.boolValue;
    alMessage.status = dbMessage.status;
    alMessage.imageFilePath = dbMessage.filePath;
    alMessage.delivered = dbMessage.delivered.boolValue;
    alMessage.sentToServer = dbMessage.sentToServer.boolValue;
    alMessage.isUploadFailed = dbMessage.isUploadFailed.boolValue;
    alMessage.contentType = dbMessage.contentType;

    alMessage.deleted = dbMessage.deletedFlag.boolValue;
    alMessage.groupId = dbMessage.groupId;
    alMessage.conversationId = dbMessage.conversationId;
    alMessage.pairedMessageKey = dbMessage.pairedMessageKey;
    alMessage.metadata = [alMessage getMetaDataDictionary:dbMessage.metadata];
    alMessage.msgHidden = [dbMessage.msgHidden boolValue];
    alMessage.source = [dbMessage source];
    alMessage.messageReplyType = dbMessage.replyMessageType;

    /// file meta info
    if (dbMessage.fileMetaInfo) {
        ALFileMetaInfo *theFileMeta = [ALFileMetaInfo new];
        theFileMeta.blobKey = dbMessage.fileMetaInfo.blobKeyString;
        theFileMeta.thumbnailBlobKey = dbMessage.fileMetaInfo.thumbnailBlobKeyString;
        theFileMeta.contentType = dbMessage.fileMetaInfo.contentType;
        theFileMeta.createdAtTime = dbMessage.fileMetaInfo.createdAtTime;
        theFileMeta.key = dbMessage.fileMetaInfo.key;
        theFileMeta.name = dbMessage.fileMetaInfo.name;
        theFileMeta.size = dbMessage.fileMetaInfo.size;
        theFileMeta.userKey = dbMessage.fileMetaInfo.suUserKeyString;
        theFileMeta.thumbnailUrl = dbMessage.fileMetaInfo.thumbnailUrl;
        theFileMeta.thumbnailFilePath = dbMessage.fileMetaInfo.thumbnailFilePath;
        theFileMeta.url = dbMessage.fileMetaInfo.url;
        alMessage.fileMeta = theFileMeta;
    }
    return alMessage;
}

- (void)updateFileMetaInfo:(ALMessage *)alMessage {
    DB_Message *dbMessage = (DB_Message*)[self getMeesageById:alMessage.msgDBObjectId];
    if (dbMessage) {
        dbMessage.fileMetaInfo.key = alMessage.fileMeta.key;
        dbMessage.fileMetaInfo.blobKeyString = alMessage.fileMeta.blobKey;
        dbMessage.fileMetaInfo.thumbnailBlobKeyString = alMessage.fileMeta.thumbnailBlobKey;
        dbMessage.fileMetaInfo.contentType = alMessage.fileMeta.contentType;
        dbMessage.fileMetaInfo.createdAtTime = alMessage.fileMeta.createdAtTime;
        dbMessage.fileMetaInfo.key = alMessage.fileMeta.key;
        dbMessage.fileMetaInfo.name = alMessage.fileMeta.name;
        dbMessage.fileMetaInfo.size = alMessage.fileMeta.size;
        dbMessage.fileMetaInfo.suUserKeyString = alMessage.fileMeta.userKey;
        dbMessage.fileMetaInfo.url = alMessage.fileMeta.url;
        [[ALDBHandler sharedInstance] saveContext];
    }
}

- (NSMutableArray *)getMessageListForContactWithCreatedAt:(MessageListRequest *)messageListRequest {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate1;

    if ([ALApplozicSettings getContextualChatOption] &&
        messageListRequest.conversationId != nil &&
        messageListRequest.conversationId.integerValue != 0) {
        if (messageListRequest.channelKey != nil) {
            predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@ && conversationId = %i",messageListRequest.channelKey,messageListRequest.conversationId];
        } else {
            predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && conversationId = %i",messageListRequest.userId,messageListRequest.conversationId];
        }
    } else if (messageListRequest.channelKey != nil) {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@",messageListRequest.channelKey];
    } else {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil ",messageListRequest.userId];
    }

    NSPredicate *predicateDeletedCheck=[NSPredicate predicateWithFormat:@"deletedFlag == NO"];

    NSPredicate *predicateForHiddenMessages = [NSPredicate predicateWithFormat:@"msgHidden == %@", @(NO)];

    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"createdAt < 0"];

    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2, predicateDeletedCheck,predicateForHiddenMessages]];

    if (messageListRequest.endTimeStamp
        != nil) {
        NSPredicate *predicateForEndTimeStamp= [NSPredicate predicateWithFormat:@"createdAt < %@",messageListRequest.endTimeStamp];
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicateForEndTimeStamp, predicateDeletedCheck,predicateForHiddenMessages]];
    }

    if (messageListRequest.startTimeStamp != nil) {
        NSPredicate *predicateCreatedAtForStartTime  = [NSPredicate predicateWithFormat:@"createdAt >= %@",messageListRequest.startTimeStamp];
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicateCreatedAtForStartTime, predicateDeletedCheck,predicateForHiddenMessages]];
    }
    messageFetchRequest.predicate = compoundPredicate;

    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    messageFetchRequest.fetchLimit = 200;

    NSArray *messageArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:nil];
    NSMutableArray *msgArray = [[NSMutableArray alloc]init];
    if (messageArray.count) {
        for (DB_Message *theEntity in messageArray) {
            ALMessage *alMessage = [self createMessageEntity:theEntity];
            [msgArray addObject:alMessage];
        }
    }
    return msgArray;
}

#pragma mark - Get all attachment messages

- (NSMutableArray *)getAllMessagesWithAttachmentForContact:(NSString *)contactId
                                             andChannelKey:(NSNumber *)channelKey
                                 onlyDownloadedAttachments:(BOOL)onlyDownloaded {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate1;

    if (channelKey != nil) {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@", channelKey];
    } else {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@", contactId];
    }

    NSPredicate *predicateDeletedCheck =[NSPredicate predicateWithFormat:@"deletedFlag == NO"];

    NSPredicate *predicateForFileMeta = [NSPredicate predicateWithFormat:@"fileMetaInfo != nil"];
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithArray: @[predicate1, predicateDeletedCheck, predicateForFileMeta]];

    if (onlyDownloaded) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"filePath != nil"];
        [predicates addObject:predicate2];
    }

    messageFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    NSArray *messages = [alDBHandler executeFetchRequest:messageFetchRequest withError:nil];
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    if (messages.count > 0) {
        for (DB_Message * theEntity in messages) {
            ALMessage * alMessage = [self createMessageEntity:theEntity];
            [messageArray addObject:alMessage];
        }
    }

    return messageArray;
}


#pragma mark - Pending messages

- (NSMutableArray *)getPendingMessages {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    messageFetchRequest.predicate = [NSPredicate predicateWithFormat:@"sentToServer = %@ and type= %@ and deletedFlag = %@",@"0",@"5",@(NO)];

    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];

    NSArray *messages = [alDBHandler executeFetchRequest:messageFetchRequest withError:nil];

    NSMutableArray *messageArray = [[NSMutableArray alloc]init];

    if (messages.count > 0) {
        for (DB_Message *dbMessage in messages) {
            ALMessage *alMessage = [self createMessageEntity:dbMessage];
            if ([alMessage.groupId isEqualToNumber:[NSNumber numberWithInt:0]]) {
                ALSLog(ALLoggerSeverityInfo, @"groupId is coming as 0..setting it null" );
                alMessage.groupId = NULL;
            }
            [messageArray addObject:alMessage];
            ALSLog(ALLoggerSeverityInfo, @"Pending Message status:%@",alMessage.status);
        }
    }

    ALSLog(ALLoggerSeverityInfo, @"Found the number of pending messages: %lu",(unsigned long)messageArray.count);
    return messageArray;
}

- (NSUInteger)getMessagesCountFromDBForUser:(NSString *)userId {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil",userId];
    [messageFetchRequest setPredicate:predicate];
    NSUInteger count = [alDBHandler countForFetchRequest:messageFetchRequest];
    return count;

}

#pragma mark - Get latest message for User/Channel

- (ALMessage *)getLatestMessageForUser:(NSString *)userId {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %@ and groupId = nil and deletedFlag = %@",userId,@(NO)];
    [messageFetchRequest setPredicate:predicate];
    [messageFetchRequest setFetchLimit:1];
    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSError *fetchError = nil;
    NSArray *messagesArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:&fetchError];

    if(messagesArray.count) {
        DB_Message *dbMessage = [messagesArray objectAtIndex:0];
        ALMessage *alMessage = [self createMessageEntity:dbMessage];
        return alMessage;
    }

    return nil;
}

- (ALMessage *)getLatestMessageForChannel:(NSNumber *)channelKey
                 excludeChannelOperations:(BOOL)flag {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId = %@ and deletedFlag = %@",channelKey,@(NO)];

    if (flag) {
        predicate = [NSPredicate predicateWithFormat:@"groupId = %@ and deletedFlag = %@ and contentType != %i",channelKey,@(NO),ALMESSAGE_CHANNEL_NOTIFICATION];
    }

    [messageFetchRequest setPredicate:predicate];
    [messageFetchRequest setFetchLimit:1];

    [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSError *fetchError = nil;
    NSArray *messagesArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:&fetchError];

    if (messagesArray.count) {
        DB_Message *dbMessage = [messagesArray objectAtIndex:0];
        ALMessage *alMessage = [self createMessageEntity:dbMessage];
        return alMessage;
    }

    return nil;
}


/////////////////////////////  FETCH CONVERSATION WITH PAGE SIZE  /////////////////////////////

- (void)fetchConversationfromServerWithCompletion:(void(^)(BOOL flag))completionHandler {
    [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray *theArray) {

        if (!success) {
            completionHandler(success);
            return;
        }

        [self addMessageList:theArray skipAddingMessageInDb:NO];
        [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
        [self fetchConversationsGroupByContactId];

        completionHandler(success);

    }];
}

/************************************
 FETCH LATEST MESSSAGE FOR SUB GROUPS
 ************************************/

- (void)fetchSubGroupConversations:(NSMutableArray *)subGroupList {
    NSMutableArray *subGroupMessageArray = [NSMutableArray new];

    for (ALChannel *alChannel in subGroupList) {
        ALMessage *alMessage = [self getLatestMessageForChannel:alChannel.key excludeChannelOperations:NO];
        if (alMessage) {
            [subGroupMessageArray addObject:alMessage];
            if (alChannel.type == GROUP_OF_TWO) {
                NSMutableArray *clientKeyArray = [[alChannel.clientChannelKey componentsSeparatedByString:@":"] mutableCopy];

                if (![clientKeyArray containsObject:[ALUserDefaultsHandler getUserId]]) {
                    [subGroupMessageArray removeObject:alMessage];
                }
            }
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortedMessageArray = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[subGroupMessageArray sortedArrayUsingDescriptors:sortedMessageArray] mutableCopy];

    if ([self.delegate respondsToSelector:@selector(getMessagesArray:)]) {
        [self.delegate getMessagesArray:sortedArray];
    }
}

- (void)updateMessageReplyType:(NSString *)messageKeyString replyType:(NSNumber *)type hideFlag:(BOOL)flag {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

    DB_Message *replyMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKeyString];

    if (replyMessage) {
        replyMessage.replyMessageType = type;
        replyMessage.msgHidden = [NSNumber numberWithBool:flag];

        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Unable to save replytype  %@, %@", error, error.localizedDescription);
        }
    }
}

#pragma mark - Get message by message key

- (ALMessage*)getMessageByKey:(NSString*)messageKey {
    DB_Message *dbMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKey];
    return [self createMessageEntity:dbMessage];
}

- (void)updateMessageSentDetails:(NSString *)messageKeyString withCreatedAtTime:(NSNumber *)createdAtTime withDbMessage:(DB_Message *)dbMessage {

    if (!dbMessage) {
        return;
    }

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    dbMessage.key = messageKeyString;
    dbMessage.inProgress = [NSNumber numberWithBool:NO];
    dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
    dbMessage.createdAt = createdAtTime;

    dbMessage.sentToServer=[NSNumber numberWithBool:YES];
    dbMessage.status = [NSNumber numberWithInt:SENT];
    [alDBHandler saveContext];
}

#pragma mark - Message list

- (void)getLatestMessages:(BOOL)isNextPage withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion {

    if (!isNextPage) {

        if ([self isMessageTableEmpty] ||
            ![ALUserDefaultsHandler isInitialMessageListCallDone]) {
            [self fetchAndRefreshFromServerWithCompletion:^(NSMutableArray *theArray, NSError *error) {
                completion(theArray,error);
            }];
        } else {
            completion([self fetchLatestConversationsGroupByContactId:NO],nil);
        }
    } else {
        [self fetchAndRefreshFromServerWithCompletion:^(NSMutableArray *theArray, NSError *error) {
            completion(theArray,error);

        }];
    }
}

- (void)fetchAndRefreshFromServerWithCompletion:(void(^)(NSMutableArray *theArray, NSError *error)) completion {

    if (![ALUserDefaultsHandler getFlagForAllConversationFetched]) {
        [self getLatestMessagesWithCompletion:^(NSMutableArray *messageArray, NSError *error) {

            if (!error) {
                // save data into the db
                [self addMessageList:messageArray skipAddingMessageInDb:NO];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                //fetch data from db
                completion([self fetchLatestConversationsGroupByContactId:YES], error);
                return;
            } else {
                completion(nil, error);
            }
        }];
    } else {
        completion(nil, nil);
    }
}

#pragma mark - Message list for one to one or Channel/Group

- (void)getLatestMessages:(BOOL)isNextPage
           withOnlyGroups:(BOOL)isGroup
    withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion {

    if (!isNextPage) {

        if ([self isMessageTableEmpty] ||
            ![ALUserDefaultsHandler isInitialMessageListCallDone]) {
            [self fetchLatestMesssagesFromServer:isGroup withCompletion:^(NSMutableArray *theArray, NSError *error) {
                completion(theArray,error);
            }];
        } else {
            completion([self fetchLatestMesssagesFromDb:isGroup],nil);
        }
    } else {
        [self fetchLatestMesssagesFromServer:isGroup withCompletion:^(NSMutableArray *theArray, NSError *error) {
            completion(theArray, error);
        }];
    }
}

- (void)fetchLatestMesssagesFromServer:(BOOL)isGroupMesssages
                        withCompletion:(void(^)(NSMutableArray *theArray, NSError *error)) completion {

    if(![ALUserDefaultsHandler getFlagForAllConversationFetched]){
        [self getLatestMessagesWithCompletion:^(NSMutableArray *messageArray, NSError *error) {

            if (!error) {
                // save data into the db
                [self addMessageList:messageArray skipAddingMessageInDb:NO];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                //fetch data from db
                completion([self fetchLatestMesssagesFromDb:isGroupMesssages], error);
                return;
            } else {
                completion(nil, error);
            }
        }];
    } else {
        completion(nil,nil);
    }
}

- (NSMutableArray *)fetchLatestMesssagesFromDb:(BOOL)isGroupMessages {

    NSMutableArray *messagesArray = nil;

    if (isGroupMessages) {
        messagesArray =  [self getLatestMessagesForGroup];
    } else {
        messagesArray = [self getLatestMessagesForContact];
    }

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortedMessageArray = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[messagesArray sortedArrayUsingDescriptors:sortedMessageArray] mutableCopy];

    return sortedArray;
}

- (NSMutableArray *)getLatestMessagesForContact {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSMutableArray *messagesArray = [NSMutableArray new];

    // Find all message only have contact ...
    NSFetchRequest *dbMessageRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [dbMessageRequest setResultType:NSDictionaryResultType];
    [dbMessageRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId=%d OR groupId=nil",0]];
    [dbMessageRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [dbMessageRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"contactId", nil]];
    [dbMessageRequest setReturnsDistinctResults:YES];

    NSError *fetchError = nil;
    NSArray *userMessageArray = [alDBHandler executeFetchRequest:dbMessageRequest withError:&fetchError];

    if (fetchError) {
        ALSLog(ALLoggerSeverityError, @"Failed to fetch Latest Messages For Contact : %@", fetchError);
        return messagesArray;
    }

    for (NSDictionary *messageDictionary in userMessageArray) {

        NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
        [messageFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@ and groupId=nil and deletedFlag == %@ AND contentType != %i AND msgHidden == %@",messageDictionary[@"contactId"],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];

        [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [messageFetchRequest setFetchLimit:1];

        NSArray *fetchArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:nil];

        if (fetchArray.count) {
            DB_Message *dbMessageEntity = fetchArray.firstObject;
            ALMessage *alMessage = [self createMessageEntity:dbMessageEntity];
            [messagesArray addObject:alMessage];
        }
    }
    return messagesArray;
}

- (NSMutableArray *)getLatestMessagesForGroup {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSMutableArray *messagesArray = [NSMutableArray new];

    // get all unique contacts
    NSFetchRequest *dbMessageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [dbMessageFetchRequest setResultType:NSDictionaryResultType];
    [dbMessageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [dbMessageFetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"groupId", nil]];
    [dbMessageFetchRequest setReturnsDistinctResults:YES];

    NSError *fetchError = nil;
    NSArray *messageArray = [alDBHandler executeFetchRequest:dbMessageFetchRequest withError:&fetchError];

    if (fetchError) {
        ALSLog(ALLoggerSeverityError, @"Failed to fetch the message array %@", fetchError);
        return messagesArray;
    }

    // get latest record
    for (NSDictionary *messageDictionary in messageArray) {
        NSFetchRequest *messageFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];

        if ([messageDictionary[@"groupId"] intValue] == 0) {
            continue;
        }

        if ([ALApplozicSettings getCategoryName]) {
            ALChannel *channel = [[ALChannelService new] getChannelByKey:[NSNumber numberWithInt:[messageDictionary[@"groupId"] intValue]]];
            if (![channel isPartOfCategory:[ALApplozicSettings getCategoryName]]) {
                continue;
            }
        }
        [messageFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [messageFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%d AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",
                                           [messageDictionary[@"groupId"] intValue],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
        [messageFetchRequest setFetchLimit:1];

        NSArray *groupMessageArray = [alDBHandler executeFetchRequest:messageFetchRequest withError:nil];
        if (groupMessageArray.count) {
            DB_Message *dbMessageEntity = groupMessageArray.firstObject;
            ALMessage *alMessage = [self createMessageEntity:dbMessageEntity];
            [messagesArray addObject:alMessage];
        }
    }
    return messagesArray;
}

- (ALMessage *)handleMessageFailedStatus:(ALMessage *)message {
    if (!message.msgDBObjectId) {
        return nil;
    }
    message.inProgress = NO;
    message.isUploadFailed = YES;
    message.sentToServer = NO;
    DB_Message *dbMessage = (DB_Message*)[self getMessageByKey:@"key" value:message.key];
    if (dbMessage) {
        dbMessage.inProgress = [NSNumber numberWithBool:NO];
        dbMessage.isUploadFailed = [NSNumber numberWithBool:YES];
        dbMessage.sentToServer= [NSNumber numberWithBool:NO];
        [[ALDBHandler sharedInstance] saveContext];
    }
    return message;
}

- (ALMessage *)writeDataAndUpdateMessageInDb:(NSData *)data
                                 withMessage:(ALMessage *)message
                                withFileFlag:(BOOL)isFile {
    ALMessage *messageObject = message;
    DB_Message *messageEntity = (DB_Message *)[self getMessageByKey:@"key" value:messageObject.key];

    NSData *imageData;
    if (![messageObject.fileMeta.contentType hasPrefix:@"image"]) {
        imageData = data;
    } else {
        imageData = [ALUtilityClass compressImage:data];
    }

    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *componentsArray = [messageObject.fileMeta.name componentsSeparatedByString:@"."];
    NSString *fileExtension = [componentsArray lastObject];
    NSString *filePath;

    if (isFile) {
        filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_local.%@", messageObject.key, fileExtension]];

        // If 'save video to gallery' is enabled then save to gallery
        if ([ALApplozicSettings isSaveVideoToGalleryEnabled]) {
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, nil, nil);
        }

        NSString *fileName = [NSString stringWithFormat:@"%@_local.%@", messageObject.key, fileExtension];
        if (messageEntity) {
            messageEntity.inProgress = [NSNumber numberWithBool:NO];
            messageEntity.isUploadFailed = [NSNumber numberWithBool:NO];
            messageEntity.filePath = fileName;
        } else {
            messageObject.inProgress = NO;
            messageObject.isUploadFailed = NO;
            messageObject.imageFilePath = fileName;
        }
    } else {
        filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumbnail_local.%@", messageObject.key, fileExtension]];

        NSString *fileName = [NSString stringWithFormat:@"%@_thumbnail_local.%@", messageObject.key, fileExtension];
        if (messageEntity) {
            messageEntity.fileMetaInfo.thumbnailFilePath = fileName;
        } else {
            messageObject.fileMeta.thumbnailFilePath = fileName;
        }
    }

    [imageData writeToFile:filePath atomically:YES];

    if (messageEntity) {
        [[ALDBHandler sharedInstance] saveContext];
        return [[ALMessageDBService new] createMessageEntity:messageEntity];
    }
    return messageObject;
}

- (DB_Message*)addAttachmentMessage:(ALMessage *)message {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
    DB_Message *dbMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:message];

    if (dbMessageEntity) {
        message.msgDBObjectId = [dbMessageEntity objectID];
        dbMessageEntity.inProgress = [NSNumber numberWithBool:YES];
        dbMessageEntity.isUploadFailed = [NSNumber numberWithBool:NO];
        NSError *error = [alDBHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to save the Attachment Message : %@", message.key);
            return nil;
        }
    }
    return dbMessageEntity;
}

#pragma mark - Update message metadata

- (void)updateMessageMetadataOfKey:(NSString *)messageKey
                      withMetadata:(NSMutableDictionary *)metadata {
    ALSLog(ALLoggerSeverityInfo, @"Updating message metadata in local db for key : %@", messageKey);
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

    DB_Message *dbMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKey];
    if (dbMessage) {
        dbMessage.metadata = metadata.description;
        if (metadata != nil && [metadata objectForKey:@"hiddenStatus"] != nil) {
            dbMessage.msgHidden = [NSNumber numberWithBool: [[metadata objectForKey:@"hiddenStatus"] isEqualToString:@"true"]];
        }

        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Unable to save metadata in local db : %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"Message metadata has been updated successfully in local db");
        }
    }
}

@end
