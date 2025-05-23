//
//  KMCoreMessageDBService.h
//  ChatApp
//
//  Created by Devashish on 21/09/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_FileMetaInfo.h"
#import "DB_Message.h"
#import "KMCoreMessage.h"
#import "ALFileMetaInfo.h"
#import "MessageListRequest.h"
#import "ALConversationListRequest.h"

@class KMCoreMessageService;

@protocol KMCoreMessagesDelegate <NSObject>

- (void)getMessagesArray:(NSMutableArray*)messagesArray;

- (void)updateMessageList:(NSMutableArray*)messagesArray;

@end

@interface KMCoreMessageDBService : NSObject

@property(nonatomic,weak) id <KMCoreMessagesDelegate>delegate;

@property(nonatomic, retain) KMCoreMessageService *messageService;

//Add Message APIS
- (NSMutableArray *)addMessageList:(NSMutableArray *)messageList skipAddingMessageInDb:(BOOL)skip;
- (DB_Message *)addMessage:(KMCoreMessage *)message;
- (void)getMessages:(NSMutableArray *)subGroupList;
- (void)fetchConversationsGroupByContactId;
- (void)fetchAndRefreshQuickConversationWithCompletion:(void (^)(NSMutableArray *, NSError *))completion;
- (void)fetchAndRefreshFromServerWithCompletion:(void(^)(NSMutableArray *theArray, NSError *error)) completion;
- (void)getLatestMessagesWithCompletion:(void(^)(NSMutableArray *theArray, NSError *error)) completion;

- (NSManagedObject *)getMeesageById:(NSManagedObjectID *)objectID;
- (NSManagedObject *)getMessageByKey:(NSString *)key value:(NSString*) value;

- (NSMutableArray *)getMessageListForContactWithCreatedAt:(MessageListRequest *)messageListRequest;

- (NSMutableArray *)getAllMessagesWithAttachmentForContact:(NSString *)contactId
                                             andChannelKey:(NSNumber *)channelKey
                                 onlyDownloadedAttachments:(BOOL)onlyDownloaded;

- (NSMutableArray *)getPendingMessages;

/**
 * Returns a list of last messages (Group by Contact)
 *
 * @param messageCount The Number of messages required.
 * @param received If YES, messages will be of type received. If NO, then messages can be of type received or sent.
 * @return An array containing the list of messages.
 */
- (NSArray *)getMessageList:(int)messageCount
    messageTypeOnlyReceived:(BOOL)received;

//update Message APIS
- (void)updateMessageDeliveryReport:(NSString *)messageKeyString withStatus:(int)status;
- (void)updateDeliveryReportForContact:(NSString *)contactId withStatus:(int)status;
- (void)updateMessageSyncStatus:(NSString *)keyString;
- (void)updateFileMetaInfo:(KMCoreMessage *)alMessage;

//Delete Message APIS
- (void)deleteMessageByKey:(NSString *)keyString;
- (void)deleteAllMessagesByContact:(NSString *)contactId orChannelKey:(NSNumber *)key;

//Generic APIS
- (BOOL)isMessageTableEmpty;
- (void)deleteAllObjectsInCoreData;

- (DB_Message *)createMessageEntityForDBInsertionWithMessage:(KMCoreMessage *)alMessage;
- (DB_FileMetaInfo *)createFileMetaInfoEntityForDBInsertionWithMessage:(ALFileMetaInfo *)fileInfo;
- (KMCoreMessage *)createMessageEntity:(DB_Message *)dbMessage;
- (KMCoreMessage*)getMessageByKey:(NSString *)messageKey;

- (NSMutableArray *)fetchLatestConversationsGroupByContactId :(BOOL)isFetchOnCreatedAtTime;

- (void)fetchConversationfromServerWithCompletion:(void(^)(BOOL flag))completionHandler;

- (NSUInteger)getMessagesCountFromDBForUser:(NSString *)userId;

- (KMCoreMessage *)getLatestMessageForUser:(NSString *)userId;

- (KMCoreMessage *)getLatestMessageForChannel:(NSNumber *)channelKey excludeChannelOperations:(BOOL)flag;

- (void)updateMessageReplyType:(NSString *)messageKeyString replyType:(NSNumber *)type hideFlag:(BOOL)flag;

- (void)updateMessageSentDetails:(NSString *)messageKeyString
               withCreatedAtTime:(NSNumber *)createdAtTime
                   withDbMessage:(DB_Message *)dbMessage;

- (void)getLatestMessages:(BOOL)isNextPage withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion;

- (void)getLatestMessages:(BOOL)isNextPage
           withOnlyGroups:(BOOL)isGroup
    withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion;

- (KMCoreMessage *)handleMessageFailedStatus:(KMCoreMessage *)message;

- (DB_Message *)addAttachmentMessage:(KMCoreMessage *)message;

- (void)updateMessageMetadataOfKey:(NSString *)messageKey withMetadata:(NSMutableDictionary *)metadata;

- (KMCoreMessage *)writeDataAndUpdateMessageInDb:(NSData *)data withMessage:(KMCoreMessage *)message withFileFlag:(BOOL)isFile;

/// Returns a list of last messages for group and contact based on the startTime or endTime
/// @param conversationListRequest Used for passing the startTime or endTime
- (NSMutableArray *)fetchLatestMessagesFromDatabaseWithRequestList:(ALConversationListRequest *)conversationListRequest;

@end
