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
#import "ALAudioVideoBaseVC.h"
#import "ALChannelService.h"
#import "ALChannel.h"
#import "ALUserService.h"
#import "ALUtilityClass.h"

@implementation ALMessageDBService

//Add message APIS
-(NSMutableArray *) addMessageList:(NSMutableArray*) messageList
             skipAddingMessageInDb:(BOOL)skip {
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];

    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    for (ALMessage * theMessage in messageList) {

        if (skip && !theMessage.fileMeta) {
            [messageArray addObject:theMessage];
            continue;
        }

        NSManagedObject *message = [self getMessageByKey:@"key" value:theMessage.key];
        if (message==nil && ![theMessage isPushNotificationMessage]) {
            theMessage.sentToServer = YES;

            DB_Message * theMessageEntity = [self createMessageEntityForDBInsertionWithMessage:theMessage];

            if (theMessageEntity) {
                theMessage.msgDBObjectId = theMessageEntity.objectID;
                [messageArray addObject:theMessage];
            }

        } else if (message != nil) {
            DB_Message* dbMessage = (DB_Message*)message;
            if (dbMessage && [dbMessage.replyMessageType intValue] == AL_REPLY_BUT_HIDDEN) {
                int replyType = (dbMessage.metadata && [dbMessage.metadata containsString:AL_MESSAGE_REPLY_KEY]) ? AL_A_REPLY : AL_NOT_A_REPLY;
                [self updateMessageReplyType:dbMessage.key replyType: [NSNumber numberWithInt:replyType] hideFlag:NO];
            }
        }
    }

    NSError * error = [theDBHandler saveContext];
    if(error){
        ALSLog(ALLoggerSeverityError, @"Unable to save error :%@",error);
    }

    return messageArray;
}


-(DB_Message*)addMessage:(ALMessage*) message {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_Message* dbMessag = [self createMessageEntityForDBInsertionWithMessage:message];

    if (dbMessag) {
        NSError * error = [theDBHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to save the message :%@",error);
            return nil;
        }

        message.msgDBObjectId = dbMessag.objectID;
        if ([message.status isEqualToNumber:[NSNumber numberWithInt:SENT]]) {
            dbMessag.status = [NSNumber numberWithInt:READ];
        }
        if (message.isAReplyMessage) {
            NSString * messageReplyId = [message.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
            DB_Message * replyMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageReplyId];
            if (replyMessage) {
                replyMessage.replyMessageType = [NSNumber numberWithInt:AL_A_REPLY];
                NSError * error = [theDBHandler saveContext];
                if (error) {
                    ALSLog(ALLoggerSeverityError, @"Failed to update the reply type in the message :%@",error);
                }
            }

        }
    }

    return dbMessag;
}

-(NSManagedObject *)getMeesageById:(NSManagedObjectID *)objectID {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    NSManagedObject *obj = [theDBHandler existingObjectWithID:objectID];
    return obj;
}

-(void)updateDeliveryReportForContact:(NSString *)contactId
                           withStatus:(int)status {

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];

    if (entity) {

        NSMutableArray * predicateArray = [[NSMutableArray alloc] init];

        NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@",contactId];
        [predicateArray addObject:predicate1];

        NSPredicate * predicate3 = [NSPredicate predicateWithFormat:@"status != %i and sentToServer ==%@",
                                    DELIVERED_AND_READ,[NSNumber numberWithBool:YES]];
        [predicateArray addObject:predicate3];

        NSCompoundPredicate * resultantPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];

        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:resultantPredicate];
        NSError * fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (result.count > 0) {
            ALSLog(ALLoggerSeverityInfo, @"Found Messages to update to DELIVERED_AND_READ in DB :%lu",(unsigned long)result.count);
            for (DB_Message *message in result) {
                [message setStatus:[NSNumber numberWithInt:status]];
            }

            NSError *error = [dbHandler saveContext];

            if (error) {
                ALSLog(ALLoggerSeverityError, @"Unable to save STATUS OF managed objects. %@, %@", error, error.localizedDescription);
            }
        }
    }
}

//update Message APIS
-(void)updateMessageDeliveryReport:(NSString*)messageKeyString
                        withStatus:(int)status {

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSManagedObject* message = [self getMessageByKey:@"key"  value:messageKeyString];

    if (message) {
        [message setValue:@(status) forKey:@"status"];
        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Error in updating Message Delivery Report %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"updateMessageDeliveryReport DB update Success %@", messageKeyString);
        }
    }
}


-(void)updateMessageSyncStatus:(NSString*) keyString{

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSManagedObject* message = [self getMessageByKey:@"keyString" value:keyString];
    if (message) {
        [message setValue:@"1" forKey:@"isSent"];
        NSError *error = [dbHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityInfo, @"Message deliverd status updated Failed  %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"message found and maked as deliverd");
        }
    }
}


//Delete Message APIS

-(void) deleteMessageByKey:(NSString*) keyString {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSManagedObject* message = [self getMessageByKey:@"key" value:keyString];

    if (message) {
        [dbHandler deleteObject:message];
        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityInfo, @"Failed to delete the message %@",error);
        }
    } else {
        ALSLog(ALLoggerSeverityInfo, @"message not found with this key");
    }
}

-(void) deleteAllMessagesByContact: (NSString*) contactId
                      orChannelKey:(NSNumber *)key {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];

    if (entity) {
        NSPredicate *predicate;
        if (key != nil) {
            predicate = [NSPredicate predicateWithFormat:@"groupId = %@",key];
            [ALChannelService setUnreadCountZeroForGroupID:key];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"contactId = %@ AND groupId = %@",contactId,nil];
            [ALUserService setUnreadCountZeroForContactId:contactId];
        }

        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result =  [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (result.count > 0) {

            for (DB_Message *message in result) {
                [dbHandler deleteObject:message];
            }

            NSError *deleteError = [dbHandler saveContext];

            if (deleteError) {
                ALSLog(ALLoggerSeverityError, @"Unable to save managed object context %@, %@", deleteError, deleteError.localizedDescription);
            }
        }
    }
}

//Generic APIS
-(BOOL) isMessageTableEmpty {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];
    if (entity) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPropertyValues:NO];
        [fetchRequest setIncludesSubentities:NO];
        NSUInteger count = [dbHandler countForFetchRequest:fetchRequest];
        return !(count >0);
    }
    return true;
}

- (void)deleteAllObjectsInCoreData {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSArray *allEntities = dbHandler.managedObjectModel.entities;
    if (allEntities.count) {
        for (NSEntityDescription *entityDescription in allEntities) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entityDescription];

            fetchRequest.includesPropertyValues = NO;
            fetchRequest.includesSubentities = NO;
            NSError *fetchError = nil;
            NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

            if (fetchError) {
                ALSLog(ALLoggerSeverityError, @"Error requesting items from Core Data: %@", [fetchError localizedDescription]);
                return;
            }

            for (NSManagedObject *managedObject in result) {
                [dbHandler deleteObject:managedObject];
            }

            NSError * saveError = [dbHandler saveContext];
            if (saveError) {
                ALSLog(ALLoggerSeverityError, @"Error deleting %@ - error:%@", saveError, [saveError localizedDescription]);
            }
        }
    }
}

- (NSManagedObject *)getMessageByKey:(NSString *) key value:(NSString*) value{

    //Runs at MessageList viewing/opening...ONLY FIRST TIME AND if delete an msg
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
        NSPredicate * resultPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:resultPredicate];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count > 0) {
            NSManagedObject* message = [result objectAtIndex:0];
            return message;
        }
    }
    return nil;
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - ALMessagesViewController DB Operations.
//------------------------------------------------------------------------------------------------------------------

-(void)getMessages:(NSMutableArray *)subGroupList
{
    if ([self isMessageTableEmpty] || [ALApplozicSettings getCategoryName] || ![ALUserDefaultsHandler isInitialMessageListCallDone])  // db is not synced
    {
        [self fetchAndRefreshFromServer:subGroupList];
    } else  { /// Db is synced
        /// Fetch data from db
        if (subGroupList && [ALApplozicSettings getSubGroupLaunchFlag]) { /// case for sub group
            [self fetchSubGroupConversations:subGroupList];
        } else {
            [self fetchConversationsGroupByContactId];
        }
    }
}

-(void)fetchAndRefreshFromServer:(NSMutableArray *)subGroupList {
    [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray * theArray) {

        if (success) {
            /// save data into the db
            [self addMessageList:theArray skipAddingMessageInDb:NO];
            /// set yes to userdefaults
            [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
            /// add default contacts
            /// fetch data from db
            if(subGroupList && [ALApplozicSettings getSubGroupLaunchFlag]) {
                [self fetchSubGroupConversations:subGroupList];
            } else {
                [self fetchConversationsGroupByContactId];
            }
        }
    }];
}

-(void)fetchAndRefreshQuickConversationWithCompletion:(void (^)( NSMutableArray *, NSError *))completion {
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];

    [ALMessageService getLatestMessageForUser:deviceKeyString withCompletion:^(NSMutableArray *messageArray, NSError *error) {
        if (error) {
            ALSLog(ALLoggerSeverityError, @"GetLatestMsg Error%@",error);
            completion (nil, error);
            return;
        }
        [self.delegate updateMessageList:messageArray];

        completion (messageArray,error);
    }];

}
//------------------------------------------------------------------------------------------------------------------
#pragma mark -  Helper methods
//------------------------------------------------------------------------------------------------------------------

-(void)syncConverstionDBWithCompletion:(void(^)(BOOL success , NSMutableArray * theArray)) completion {
    [ALMessageService getMessagesListGroupByContactswithCompletionService:^(NSMutableArray *messages, NSError *error) {

        if (error) {
            ALSLog(ALLoggerSeverityError, @"%@",error);
            completion(NO,nil);
            return ;
        }
        completion(YES, messages);
    }];
}


-(void)getLatestMessagesWithCompletion:(void(^)( NSMutableArray * theArray,NSError *error)) completion {
    [ALMessageService getMessagesListGroupByContactswithCompletionService:^(NSMutableArray *messages, NSError *error) {
        completion(messages, error);
    }];
}

-(NSArray*)getMessageList:(int)messageCount
  messageTypeOnlyReceived:(BOOL)received {

    // Get the latest record
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setResultType:NSDictionaryResultType];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    if(received) {
        /// Load messages with type received
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"type == %@ AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",@"4",@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
    } else {
        /// No type restriction
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"deletedFlag == %@ AND contentType != %i AND msgHidden == %@",@(NO), ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
    }

    NSArray * theArray = [theDbHandler executeFetchRequest:theRequest withError:nil];
    /// Trim the message list
    if (theArray.count > 0) {
        return [theArray subarrayWithRange:NSMakeRange(0, MIN(messageCount, theArray.count))];
    }

    return nil;
}

-(void)fetchConversationsGroupByContactId {
    [self fetchLatestConversationsGroupByContactId :NO];
}


-(NSMutableArray*)fetchLatestConversationsGroupByContactId:(BOOL)isFetchOnCreatedAtTime {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    /// get all unique contacts
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setResultType:NSDictionaryResultType];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"groupId", nil]];
    [theRequest setReturnsDistinctResults:YES];

    NSError * fetchError = nil;
    NSArray * theArray = [theDbHandler executeFetchRequest:theRequest withError:&fetchError];
    NSMutableArray *messagesArray = [NSMutableArray new];
    if (theArray.count > 0) {
        /// get latest record
        for (NSDictionary * theDictionary in theArray) {
            NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
            if ([theDictionary[@"groupId"] intValue]==0) {
                continue;
            }
            if ([ALApplozicSettings getCategoryName]) {
                ALChannel* channel=  [[ALChannelService new] getChannelByKey:[NSNumber numberWithInt:[theDictionary[@"groupId"] intValue]]];
                if(![channel isPartOfCategory:[ALApplozicSettings getCategoryName]]) {
                    continue;
                }
            }
            [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
            [theRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%d AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",
                                      [theDictionary[@"groupId"] intValue],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
            [theRequest setFetchLimit:1];

            NSArray * groupMsgArray = [theDbHandler executeFetchRequest:theRequest withError:nil];
            if (groupMsgArray.count > 0) {
                DB_Message * theMessageEntity = groupMsgArray.firstObject;
                if (groupMsgArray.count) {
                    ALMessage * theMessage = [self createMessageEntity:theMessageEntity];
                    [messagesArray addObject:theMessage];
                }
            }
        }
    }
    /// Find all message only have contact ...
    NSFetchRequest * theRequest1 = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest1 setResultType:NSDictionaryResultType];
    [theRequest1 setPredicate:[NSPredicate predicateWithFormat:@"groupId=%d OR groupId=nil",0]];
    [theRequest1 setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest1 setPropertiesToFetch:[NSArray arrayWithObjects:@"contactId", nil]];
    [theRequest1 setReturnsDistinctResults:YES];

    NSArray * userMsgArray = [theDbHandler executeFetchRequest:theRequest1 withError:nil];

    if (userMsgArray.count > 0) {
        for (NSDictionary * theDictionary in userMsgArray) {

            NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
            [theRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@ and groupId=nil and deletedFlag == %@ AND contentType != %i AND msgHidden == %@",theDictionary[@"contactId"],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];

            [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
            [theRequest setFetchLimit:1];

            NSArray * fetchArray =  [theDbHandler executeFetchRequest:theRequest withError:nil];
            if (fetchArray.count > 0) {
                DB_Message * theMessageEntity = fetchArray.firstObject;
                if(fetchArray.count) {
                    ALMessage * theMessage = [self createMessageEntity:theMessageEntity];
                    [messagesArray addObject:theMessage];
                }
            }
        }
    }

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[messagesArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    if (self.delegate && [self.delegate respondsToSelector:@selector(getMessagesArray:)]) {
        [self.delegate getMessagesArray:sortedArray];
    }

    return sortedArray;
}


-(DB_Message *) createMessageEntityForDBInsertionWithMessage:(ALMessage *) theMessage {

    //Runs at MessageList viewing/opening... ONLY FIRST TIME
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];

    DB_Message * theMessageEntity = (DB_Message *)[theDBHandler insertNewObjectForEntityForName:@"DB_Message"];

    if (theMessageEntity) {
        theMessageEntity.contactId = theMessage.contactIds;
        theMessageEntity.createdAt =  theMessage.createdAtTime;
        theMessageEntity.deviceKey = theMessage.deviceKey;
        theMessageEntity.status = [NSNumber numberWithInt:([theMessageEntity.type isEqualToString:@"5"] ? READ
                                                           : theMessage.status.intValue)];

        theMessageEntity.isSentToDevice = [NSNumber numberWithBool:theMessage.sendToDevice];
        theMessageEntity.isShared = [NSNumber numberWithBool:theMessage.shared];
        theMessageEntity.isStoredOnDevice = [NSNumber numberWithBool:theMessage.storeOnDevice];
        theMessageEntity.key = theMessage.key;
        theMessageEntity.messageText = theMessage.message;
        theMessageEntity.userKey = theMessage.userKey;
        theMessageEntity.to = theMessage.to;
        theMessageEntity.type = theMessage.type;
        theMessageEntity.delivered = [NSNumber numberWithBool:theMessage.delivered];
        theMessageEntity.sentToServer = [NSNumber numberWithBool:theMessage.sentToServer];
        theMessageEntity.filePath = theMessage.imageFilePath;
        theMessageEntity.inProgress = [NSNumber numberWithBool:theMessage.inProgress];
        theMessageEntity.isUploadFailed=[ NSNumber numberWithBool:theMessage.isUploadFailed];
        theMessageEntity.contentType = theMessage.contentType;
        theMessageEntity.deletedFlag=[NSNumber numberWithBool:theMessage.deleted];
        theMessageEntity.conversationId = theMessage.conversationId;
        theMessageEntity.pairedMessageKey = theMessage.pairedMessageKey;
        theMessageEntity.metadata = theMessage.metadata.description;
        theMessageEntity.msgHidden = [NSNumber numberWithBool:[theMessage isHiddenMessage]];
        theMessageEntity.replyMessageType = theMessage.messageReplyType;
        theMessageEntity.source = theMessage.source;

        if (theMessage.getGroupId) {
            theMessageEntity.groupId = theMessage.groupId;
        }
        if (theMessage.fileMeta != nil) {
            DB_FileMetaInfo *  fileInfo =  [self createFileMetaInfoEntityForDBInsertionWithMessage:theMessage.fileMeta];
            theMessageEntity.fileMetaInfo = fileInfo;
        }
    }
    return theMessageEntity;
}

-(DB_FileMetaInfo *) createFileMetaInfoEntityForDBInsertionWithMessage:(ALFileMetaInfo *) fileInfo {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_FileMetaInfo * fileMetaInfo = (DB_FileMetaInfo *)[theDBHandler insertNewObjectForEntityForName:@"DB_FileMetaInfo"];

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

-(ALMessage *) createMessageEntity:(DB_Message *) theEntity {

    if (!theEntity) {
        return nil;
    }
    ALMessage * theMessage = [ALMessage new];

    theMessage.msgDBObjectId = [theEntity objectID];
    theMessage.key = theEntity.key;
    theMessage.deviceKey = theEntity.deviceKey;
    theMessage.userKey = theEntity.userKey;
    theMessage.to = theEntity.to;
    theMessage.message = theEntity.messageText;
    theMessage.sendToDevice = theEntity.isSentToDevice.boolValue;
    theMessage.shared = theEntity.isShared.boolValue;
    theMessage.createdAtTime = theEntity.createdAt;
    theMessage.type = theEntity.type;
    theMessage.contactIds = theEntity.contactId;
    theMessage.storeOnDevice = theEntity.isStoredOnDevice.boolValue;
    theMessage.inProgress =theEntity.inProgress.boolValue;
    theMessage.status = theEntity.status;
    theMessage.imageFilePath = theEntity.filePath;
    theMessage.delivered = theEntity.delivered.boolValue;
    theMessage.sentToServer = theEntity.sentToServer.boolValue;
    theMessage.isUploadFailed = theEntity.isUploadFailed.boolValue;
    theMessage.contentType = theEntity.contentType;

    theMessage.deleted=theEntity.deletedFlag.boolValue;
    theMessage.groupId = theEntity.groupId;
    theMessage.conversationId = theEntity.conversationId;
    theMessage.pairedMessageKey = theEntity.pairedMessageKey;
    theMessage.metadata = [theMessage getMetaDataDictionary:theEntity.metadata];
    theMessage.msgHidden = [theEntity.msgHidden boolValue];
    theMessage.source = [theEntity source];
    theMessage.messageReplyType = theEntity.replyMessageType;

    /// file meta info
    if (theEntity.fileMetaInfo) {
        ALFileMetaInfo * theFileMeta = [ALFileMetaInfo new];
        theFileMeta.blobKey = theEntity.fileMetaInfo.blobKeyString;
        theFileMeta.thumbnailBlobKey = theEntity.fileMetaInfo.thumbnailBlobKeyString;
        theFileMeta.contentType = theEntity.fileMetaInfo.contentType;
        theFileMeta.createdAtTime = theEntity.fileMetaInfo.createdAtTime;
        theFileMeta.key = theEntity.fileMetaInfo.key;
        theFileMeta.name = theEntity.fileMetaInfo.name;
        theFileMeta.size = theEntity.fileMetaInfo.size;
        theFileMeta.userKey = theEntity.fileMetaInfo.suUserKeyString;
        theFileMeta.thumbnailUrl = theEntity.fileMetaInfo.thumbnailUrl;
        theFileMeta.thumbnailFilePath = theEntity.fileMetaInfo.thumbnailFilePath;
        theFileMeta.url = theEntity.fileMetaInfo.url;
        theMessage.fileMeta = theFileMeta;
    }
    return theMessage;
}

-(void) updateFileMetaInfo:(ALMessage *) almessage
{
    DB_Message * db_Message = (DB_Message*)[self getMeesageById:almessage.msgDBObjectId];
    if (db_Message) {
        almessage.fileMetaKey = almessage.fileMeta.key;
        db_Message.fileMetaInfo.blobKeyString = almessage.fileMeta.blobKey;
        db_Message.fileMetaInfo.thumbnailBlobKeyString = almessage.fileMeta.thumbnailBlobKey;
        db_Message.fileMetaInfo.contentType = almessage.fileMeta.contentType;
        db_Message.fileMetaInfo.createdAtTime = almessage.fileMeta.createdAtTime;
        db_Message.fileMetaInfo.key = almessage.fileMeta.key;
        db_Message.fileMetaInfo.name = almessage.fileMeta.name;
        db_Message.fileMetaInfo.size = almessage.fileMeta.size;
        db_Message.fileMetaInfo.suUserKeyString = almessage.fileMeta.userKey;
        db_Message.fileMetaInfo.url = almessage.fileMeta.url;
        [[ALDBHandler sharedInstance] saveContext];
    }
}


-(NSMutableArray *)getMessageListForContactWithCreatedAt:(MessageListRequest *)messageListRequest
{
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate1;

    if ([ALApplozicSettings getContextualChatOption] &&
        messageListRequest.conversationId &&
        messageListRequest.conversationId != 0) {
        if (messageListRequest.channelKey) {
            predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@ && conversationId = %i",messageListRequest.channelKey,messageListRequest.conversationId];
        } else {
            predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && conversationId = %i",messageListRequest.userId,messageListRequest.conversationId];
        }
    } else if (messageListRequest.channelKey) {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@",messageListRequest.channelKey];
    } else {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil ",messageListRequest.userId];
    }

    NSPredicate* predicateDeletedCheck=[NSPredicate predicateWithFormat:@"deletedFlag == NO"];

    NSPredicate *predicateForHiddenMessages = [NSPredicate predicateWithFormat:@"msgHidden == %@", @(NO)];

    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"createdAt < 0"];

    NSCompoundPredicate * compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2, predicateDeletedCheck,predicateForHiddenMessages]];;

    if (messageListRequest.endTimeStamp) {
        NSPredicate *predicateForEndTimeStamp= [NSPredicate predicateWithFormat:@"createdAt < %@",messageListRequest.endTimeStamp];
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicateForEndTimeStamp, predicateDeletedCheck,predicateForHiddenMessages]];
    }

    if (messageListRequest.startTimeStamp) {
        NSPredicate *predicateCreatedAtForStartTime  = [NSPredicate predicateWithFormat:@"createdAt >= %@",messageListRequest.startTimeStamp];
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicateCreatedAtForStartTime, predicateDeletedCheck,predicateForHiddenMessages]];
    }
    theRequest.predicate = compoundPredicate;

    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    theRequest.fetchLimit = 200;

    NSArray * messageArray =  [theDbHandler executeFetchRequest:theRequest withError:nil];
    NSMutableArray * msgArray =  [[NSMutableArray alloc]init];
    if (messageArray.count) {
        for (DB_Message * theEntity in messageArray) {
            ALMessage * theMessage = [self createMessageEntity:theEntity];
            [msgArray addObject:theMessage];
        }
    }
    return msgArray;
}

-(NSMutableArray *)getAllMessagesWithAttachmentForContact:(NSString *)contactId
                                            andChannelKey:(NSNumber *)channelKey
                                onlyDownloadedAttachments: (BOOL )onlyDownloaded {
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate1;

    if (channelKey) {
        predicate1 = [NSPredicate predicateWithFormat:@"groupId = %@",channelKey];
    } else {
        predicate1 = [NSPredicate predicateWithFormat:@"contactId = %@",contactId];
    }

    NSPredicate* predicateDeletedCheck=[NSPredicate predicateWithFormat:@"deletedFlag == NO"];

    NSPredicate *predicateForFileMeta = [NSPredicate predicateWithFormat:@"fileMetaInfo != nil"];
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithArray: @[predicate1, predicateDeletedCheck, predicateForFileMeta]];

    if (onlyDownloaded) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"filePath != nil"];
        [predicates addObject:predicate2];
    }

    theRequest.predicate =[NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    NSArray * messages =  [theDbHandler executeFetchRequest:theRequest withError:nil];
    NSMutableArray * msgArray =  [[NSMutableArray alloc]init];
    if (messages.count > 0) {
        for (DB_Message * theEntity in messages) {
            ALMessage * theMessage = [self createMessageEntity:theEntity];
            [msgArray addObject:theMessage];
        }
    }

    return msgArray;
}


-(NSMutableArray *)getPendingMessages {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    theRequest.predicate = [NSPredicate predicateWithFormat:@"sentToServer = %@ and type= %@ and deletedFlag = %@",@"0",@"5",@(NO)];

    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];

    NSArray * messages =  [theDbHandler executeFetchRequest:theRequest withError:nil];

    NSMutableArray * msgArray = [[NSMutableArray alloc]init];

    if (messages.count > 0) {
        for (DB_Message * theEntity in messages) {
            ALMessage * theMessage = [self createMessageEntity:theEntity];
            if([theMessage.groupId isEqualToNumber:[NSNumber numberWithInt:0]]) {
                ALSLog(ALLoggerSeverityInfo, @"groupId is coming as 0..setting it null" );
                theMessage.groupId = NULL;
            }
            [msgArray addObject:theMessage]; ALSLog(ALLoggerSeverityInfo, @"Pending Message status:%@",theMessage.status);
        }
    }

    ALSLog(ALLoggerSeverityInfo, @" get pending messages ...getPendingMessages ..%lu",(unsigned long)msgArray.count);
    return msgArray;
}

-(NSUInteger)getMessagesCountFromDBForUser:(NSString *)userId {
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"contactId = %@ && groupId = nil",userId];
    [theRequest setPredicate:predicate];
    NSUInteger count = [theDbHandler countForFetchRequest:theRequest];
    return count;

}

//============================================================================================================
#pragma mark GET LATEST MESSAGE FOR USER/CHANNEL
//============================================================================================================

-(ALMessage *)getLatestMessageForUser:(NSString *)userId {
    ALDBHandler *dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %@ and groupId = nil and deletedFlag = %@",userId,@(NO)];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSError *fetchError = nil;
    NSArray *messagesArray = [dbHandler executeFetchRequest:request withError:&fetchError];

    if(messagesArray.count) {
        DB_Message * dbMessage = [messagesArray objectAtIndex:0];
        ALMessage * alMessage = [self createMessageEntity:dbMessage];
        return alMessage;
    }

    return nil;
}

-(ALMessage *)getLatestMessageForChannel:(NSNumber *)channelKey
                excludeChannelOperations:(BOOL)flag {
    ALDBHandler *dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId = %@ and deletedFlag = %@",channelKey,@(NO)];

    if (flag) {
        predicate = [NSPredicate predicateWithFormat:@"groupId = %@ and deletedFlag = %@ and contentType != %i",channelKey,@(NO),ALMESSAGE_CHANNEL_NOTIFICATION];
    }

    [request setPredicate:predicate];
    [request setFetchLimit:1];

    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

    NSError *fetchError = nil;
    NSArray *messagesArray = [dbHandler executeFetchRequest:request withError:&fetchError];

    if(messagesArray.count) {
        DB_Message * dbMessage = [messagesArray objectAtIndex:0];
        ALMessage * alMessage = [self createMessageEntity:dbMessage];
        return alMessage;
    }

    return nil;
}


/////////////////////////////  FETCH CONVERSATION WITH PAGE SIZE  /////////////////////////////

-(void)fetchConversationfromServerWithCompletion:(void(^)(BOOL flag))completionHandler {
    [self syncConverstionDBWithCompletion:^(BOOL success, NSMutableArray * theArray) {

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

-(void)fetchSubGroupConversations:(NSMutableArray *)subGroupList {
    NSMutableArray * subGroupMsgArray = [NSMutableArray new];

    for(ALChannel * alChannel in subGroupList) {
        ALMessage * alMessage = [self getLatestMessageForChannel:alChannel.key excludeChannelOperations:NO];
        if (alMessage) {
            [subGroupMsgArray addObject:alMessage];
            if (alChannel.type == GROUP_OF_TWO) {
                NSMutableArray * array = [[alChannel.clientChannelKey componentsSeparatedByString:@":"] mutableCopy];

                if (![array containsObject:[ALUserDefaultsHandler getUserId]]) {
                    [subGroupMsgArray removeObject:alMessage];
                }
            }
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[subGroupMsgArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    if ([self.delegate respondsToSelector:@selector(getMessagesArray:)]) {
        [self.delegate getMessagesArray:sortedArray];
    }
}


-(void) updateMessageReplyType:(NSString*)messageKeyString replyType : (NSNumber *) type hideFlag:(BOOL)flag {

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    DB_Message * replyMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKeyString];

    if (replyMessage) {
        replyMessage.replyMessageType = type;
        replyMessage.msgHidden = [NSNumber numberWithBool:flag];

        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Unable to save replytype  %@, %@", error, error.localizedDescription);
        }
    }
}


-(ALMessage*) getMessageByKey:(NSString*)messageKey {
    DB_Message * dbMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKey];
    return  [self createMessageEntity:dbMessage];
}

-(void) updateMessageSentDetails:(NSString*)messageKeyString withCreatedAtTime : (NSNumber *) createdAtTime withDbMessage:(DB_Message *) dbMessage {

    if(!dbMessage){
        return;
    }

    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    dbMessage.key = messageKeyString;
    dbMessage.inProgress = [NSNumber numberWithBool:NO];
    dbMessage.isUploadFailed = [NSNumber numberWithBool:NO];
    dbMessage.createdAt = createdAtTime;

    dbMessage.sentToServer=[NSNumber numberWithBool:YES];
    dbMessage.status = [NSNumber numberWithInt:SENT];
    [theDBHandler saveContext];
}

-(void) getLatestMessages:(BOOL)isNextPage withCompletionHandler: (void(^)(NSMutableArray * messageList, NSError *error)) completion {

    if (!isNextPage) {

        if ([self isMessageTableEmpty] || ![ALUserDefaultsHandler isInitialMessageListCallDone])  // db is not synced
        {
            [self fetchAndRefreshFromServerWithCompletion:^(NSMutableArray * theArray,NSError *error) {
                completion(theArray,error);
            }];
        } else {
            completion([self fetchLatestConversationsGroupByContactId:NO],nil);
        }
    } else {
        [self fetchAndRefreshFromServerWithCompletion:^(NSMutableArray * theArray,NSError *error) {
            completion(theArray,error);

        }];
    }
}

-(void)fetchAndRefreshFromServerWithCompletion:(void(^)(NSMutableArray * theArray,NSError *error)) completion {

    if(![ALUserDefaultsHandler getFlagForAllConversationFetched]){
        [self getLatestMessagesWithCompletion:^(NSMutableArray * theArray,NSError *error) {

            if (!error) {
                // save data into the db
                [self addMessageList:theArray skipAddingMessageInDb:NO];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                //fetch data from db
                completion([self fetchLatestConversationsGroupByContactId:YES],error);
                return ;
            }else{
                completion(nil,error);
            }
        }];
    } else {
        completion(nil,nil);
    }
}


-(void) getLatestMessages:(BOOL)isNextPage withOnlyGroups:(BOOL)isGroup withCompletionHandler: (void(^)(NSMutableArray * messageList, NSError *error)) completion{

    if (!isNextPage) {

        if ([self isMessageTableEmpty] || ![ALUserDefaultsHandler isInitialMessageListCallDone])  // db is not synced
        {
            [self fetchLatestMesssagesFromServer:isGroup withCompletion:^(NSMutableArray * theArray,NSError *error) {
                completion(theArray,error);
            }];
        } else {
            completion([self fetchLatestMesssagesFromDb:isGroup],nil);
        }
    } else {
        [self fetchLatestMesssagesFromServer:isGroup withCompletion:^(NSMutableArray * theArray,NSError *error) {
            completion(theArray,error);

        }];
    }
}

-(void)fetchLatestMesssagesFromServer:(BOOL) isGroupMesssages
                       withCompletion:(void(^)(NSMutableArray * theArray,NSError *error)) completion {

    if(![ALUserDefaultsHandler getFlagForAllConversationFetched]){
        [self getLatestMessagesWithCompletion:^(NSMutableArray * theArray,NSError *error) {

            if (!error) {
                // save data into the db
                [self addMessageList:theArray skipAddingMessageInDb:NO];
                // set yes to userdefaults
                [ALUserDefaultsHandler setBoolForKey_isConversationDbSynced:YES];
                // add default contacts
                //fetch data from db
                completion([self fetchLatestMesssagesFromDb:isGroupMesssages],error);
                return ;
            } else {
                completion(nil,error);
            }
        }];
    } else {
        completion(nil,nil);
    }
}

-(NSMutableArray*)fetchLatestMesssagesFromDb :(BOOL) isGroupMessages {

    NSMutableArray *messagesArray = [NSMutableArray new];

    if (isGroupMessages) {
        messagesArray =  [self getLatestMessagesForGroup];
    } else {
        messagesArray = [self getLatestMessagesForContact];
    }

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[messagesArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];

    return sortedArray;
}

-(NSMutableArray *) getLatestMessagesForContact {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSMutableArray *messagesArray = [NSMutableArray new];

    // Find all message only have contact ...
    NSFetchRequest * theRequest1 = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest1 setResultType:NSDictionaryResultType];
    [theRequest1 setPredicate:[NSPredicate predicateWithFormat:@"groupId=%d OR groupId=nil",0]];
    [theRequest1 setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest1 setPropertiesToFetch:[NSArray arrayWithObjects:@"contactId", nil]];
    [theRequest1 setReturnsDistinctResults:YES];

    NSError *fetchError = nil;
    NSArray *userMsgArray = [theDbHandler executeFetchRequest:theRequest1 withError:&fetchError];

    if (fetchError) {
        ALSLog(ALLoggerSeverityError, @"Failed to fetch Latest Messages For Contact : %@", fetchError);
        return messagesArray;
    }

    for (NSDictionary * theDictionary in userMsgArray) {

        NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId = %@ and groupId=nil and deletedFlag == %@ AND contentType != %i AND msgHidden == %@",theDictionary[@"contactId"],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];

        [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [theRequest setFetchLimit:1];

        NSArray *fetchArray = [theDbHandler executeFetchRequest:theRequest withError:nil];

        if (fetchArray.count) {
            DB_Message * theMessageEntity = fetchArray.firstObject;
            ALMessage * theMessage = [self createMessageEntity:theMessageEntity];
            [messagesArray addObject:theMessage];
        }
    }
    return messagesArray;
}

-(NSMutableArray*) getLatestMessagesForGroup {

    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSMutableArray *messagesArray = [NSMutableArray new];

    // get all unique contacts
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];
    [theRequest setResultType:NSDictionaryResultType];
    [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
    [theRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"groupId", nil]];
    [theRequest setReturnsDistinctResults:YES];

    NSError *fetchError = nil;
    NSArray *messageArray = [theDbHandler executeFetchRequest:theRequest  withError:&fetchError];

    if (fetchError) {
        ALSLog(ALLoggerSeverityError, @"Failed to fetch the message array %@", fetchError);
        return messagesArray;
    }

    // get latest record
    for (NSDictionary * theDictionary in messageArray) {
        NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_Message"];

        if ([theDictionary[@"groupId"] intValue]==0) {
            continue;
        }

        if ([ALApplozicSettings getCategoryName]) {
            ALChannel* channel=  [[ALChannelService new] getChannelByKey:[NSNumber numberWithInt:[theDictionary[@"groupId"] intValue]]];
            if (![channel isPartOfCategory:[ALApplozicSettings getCategoryName]]) {
                continue;
            }

        }
        [theRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
        [theRequest setPredicate:[NSPredicate predicateWithFormat:@"groupId==%d AND deletedFlag == %@ AND contentType != %i AND msgHidden == %@",
                                  [theDictionary[@"groupId"] intValue],@(NO),ALMESSAGE_CONTENT_HIDDEN,@(NO)]];
        [theRequest setFetchLimit:1];

        NSArray *groupMsgArray = [theDbHandler executeFetchRequest:theRequest withError:nil];
        if (groupMsgArray.count) {
            DB_Message * theMessageEntity = groupMsgArray.firstObject;
            ALMessage * theMessage = [self createMessageEntity:theMessageEntity];
            [messagesArray addObject:theMessage];
        }
    }
    return messagesArray;
}

-(ALMessage *)handleMessageFailedStatus:(ALMessage *)message {
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
        dbMessage.sentToServer= [NSNumber numberWithBool:NO];;
        [[ALDBHandler sharedInstance] saveContext];
    }
    return message;
}

-(ALMessage*)writeDataAndUpdateMessageInDb:(NSData*)data
                               withMessage:(ALMessage *)message
                              withFileFlag:(BOOL)isFile {
    ALMessage * messageObject = message;
    DB_Message *messageEntity = (DB_Message*)[self getMessageByKey:@"key" value:messageObject.key];

    NSData *imageData;
    if (![messageObject.fileMeta.contentType hasPrefix:@"image"]) {
        imageData = data;
    } else {
        imageData = [ALUtilityClass compressImage: data];
    }

    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *componentsArray = [messageObject.fileMeta.name componentsSeparatedByString:@"."];
    NSString *fileExtension = [componentsArray lastObject];
    NSString * filePath;

    if (isFile) {
        filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_local.%@", messageObject.key,fileExtension]];

        // If 'save video to gallery' is enabled then save to gallery
        if([ALApplozicSettings isSaveVideoToGalleryEnabled]) {
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, nil, nil);
        }

        NSString * fileName = [NSString stringWithFormat:@"%@_local.%@", messageObject.key, fileExtension];
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

        filePath  = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumbnail_local.%@", messageObject.key, fileExtension]];

        NSString * fileName =  [NSString stringWithFormat:@"%@_thumbnail_local.%@", messageObject.key, fileExtension];
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


-(DB_Message*)addAttachmentMessage:(ALMessage*)message{

    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc] init];
    DB_Message * theMessageEntity = [messageDBService createMessageEntityForDBInsertionWithMessage:message];

    if (theMessageEntity) {
        message.msgDBObjectId = [theMessageEntity objectID];
        theMessageEntity.inProgress = [NSNumber numberWithBool:YES];
        theMessageEntity.isUploadFailed = [NSNumber numberWithBool:NO];
        NSError * error = [theDBHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to save the Attachment Message : %@", message.key);
            return nil;
        }
    }
    return theMessageEntity;
}

- (void)updateMessageMetadataOfKey:(NSString *)messageKey
                      withMetadata:(NSMutableDictionary *)metadata {
    ALSLog(ALLoggerSeverityInfo, @"Updating message metadata in local db for key : %@", messageKey);
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    DB_Message * dbMessage = (DB_Message *)[self getMessageByKey:@"key" value:messageKey];
    if (dbMessage) {
        dbMessage.metadata = metadata.description;
        if(metadata != nil && [metadata objectForKey:@"hiddenStatus"] != nil){
            dbMessage.msgHidden = [NSNumber numberWithBool: [[metadata objectForKey:@"hiddenStatus"] isEqualToString:@"true"]];
        }

        NSError * error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Unable to save metadata in local db : %@", error);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"Message metadata has been updated successfully in local db");
        }
    }
}

@end
