//
//  ALMessageClientService.h
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALMessageList.h"
#import "ALSyncMessageFeed.h"
#import "MessageListRequest.h"
#import "ALMessageInfoResponse.h"
#import "ALContactDBService.h"
#import "ALSearchRequest.h"
#import "ALResponseHandler.h"

@interface ALMessageClientService : NSObject

@property (nonatomic, strong) ALResponseHandler *responseHandler;

- (void)addWelcomeMessage:(NSNumber *)channelKey;

- (void)getLatestMessageGroupByContact:(NSUInteger)mainPageSize
                             startTime:(NSNumber *)startTime
                        withCompletion:(void(^)(ALMessageList *alMessageList, NSError *error))completion;

- (void)getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray *messages, NSError *error)) completion;

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
               withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion;

- (void)sendPhotoForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString *message, NSError *error)) completion;

- (void)getLatestMessageForUser:(NSString *)deviceKeyString withCompletion:(void (^)(ALSyncMessageFeed *, NSError *))completion;

- (void)deleteMessage:(NSString *)keyString
         andContactId:(NSString *)contactId
       withCompletion:(void (^)(NSString *, NSError *))completion;

- (void)deleteMessageThread:(NSString *)contactId
               orChannelKey:(NSNumber *)channelKey
             withCompletion:(void (^)(NSString *, NSError *))completion;

- (void)sendMessage:(NSDictionary *)userInfo withCompletionHandler:(void(^)(id theJson, NSError *theError))completion;

- (void)getCurrentMessageInformation:(NSString *)messageKey
               withCompletionHandler:(void(^)(ALMessageInfoResponse *msgInfo, NSError *theError))completion;

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
                withOpenGroup:(BOOL)isOpenGroup
               withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion;

- (void)downloadImageUrl:(NSString *)blobKey withCompletion:(void(^)(NSString *fileURL, NSError *error)) completion;

- (void)downloadImageUrlV2:(NSString *)blobKey isS3URL:(BOOL)isS3URL withCompletion:(void(^)(NSString *fileURL, NSError *error)) completion;

- (void)downloadImageThumbnailUrl:(NSString *)url
                          blobKey:(NSString *)blobKey
                       completion:(void(^)(NSString *fileURL, NSError *error)) completion;

- (void)downloadImageThumbnailUrl:(ALMessage *)message
                   withCompletion:(void(^)(NSString *fileURL, NSError *error)) completion DEPRECATED_ATTRIBUTE;
- (void)downloadImageThumbnailUrlV2:(NSString *)url
                            isS3URL:(BOOL)isS3URL
                          blobKey:(NSString *)blobKey
                       completion:(void(^)(NSString *fileURL, NSError *error)) completion;

- (void)getLatestMessageForUser:(NSString *)deviceKeyString
               withMetaDataSync:(BOOL)isMetaDataUpdate
                 withCompletion:(void (^)( ALSyncMessageFeed *, NSError *))completion;

- (void)updateMessageMetadataOfKey:(NSString*) messageKey
                      withMetadata:(NSMutableDictionary *)metadata
                    withCompletion:(void(^)(id theJson, NSError *theError))completion;

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
                     isSearch:(BOOL)flag
               withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion;

- (void)searchMessage:(NSString *)key withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion;

- (void)searchMessageWith:(ALSearchRequest *)request withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion;

- (void)getMessagesWithkeys:(NSMutableArray<NSString *> *)keys
              withCompletion:(void(^)(ALAPIResponse* response, NSError *error))completion;

- (void)deleteMessageForAllWithKey:(NSString *)keyString
                    withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;

@end
