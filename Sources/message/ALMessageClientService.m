//
//  ALMessageClientService.m
//  ChatApp
//
//  Created by devashish on 02/10/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALMessageClientService.h"
#import "ALConstant.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALMessage.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageDBService.h"
#import "ALDBHandler.h"
#import "ALChannelService.h"
#import "ALSyncMessageFeed.h"
#import "ALUtilityClass.h"
#import "ALConversationService.h"
#import "MessageListRequest.h"
#import "ALUserBlockResponse.h"
#import "ALUserService.h"
#import "NSString+Encode.h"
#import "ALApplozicSettings.h"
#import "ALConnectionQueueHandler.h"
#import "ALApplozicSettings.h"
#import "ALSearchResultCache.h"
#import "ALLogger.h"

@implementation ALMessageClientService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

-(void)setupServices {
    self.responseHandler = [[ALResponseHandler alloc] init];
}

- (void)downloadImageUrl:(NSString *)blobKey
          withCompletion:(void(^)(NSString *fileURL, NSError *error)) completion {
    [self getURLRequestForImage:blobKey withCompletion:^(NSMutableURLRequest *urlRequest, NSString *fileUrl) {

        if (!urlRequest
            && !fileUrl) {

            NSError *urlError = [NSError errorWithDomain:@"Applozic"
                                                    code:1
                                                userInfo:@{NSLocalizedDescriptionKey : @"Failed to get the download url"}];

            completion(nil, urlError);
            return;
        }

        if (urlRequest) {
            [self.responseHandler authenticateAndProcessRequest:urlRequest andTag:@"FILE DOWNLOAD URL" WithCompletionHandler:^(id theJson, NSError *theError) {

                if (theError) {
                    completion(nil, theError);
                    return;
                }
                NSString *imageDownloadURL = (NSString *)theJson;
                ALSLog(ALLoggerSeverityInfo, @"Response URL for image or attachment : %@",imageDownloadURL);
                completion(imageDownloadURL, nil);
            }];
        } else {
            completion(fileUrl, nil);
        }
    }];

}

- (void)getURLRequestForImage:(NSString *)blobKey
                        withCompletion:(void(^)(NSMutableURLRequest *urlRequest, NSString *fileUrl)) completion {

    NSMutableURLRequest *urlRequest = nil;
    if ([ALApplozicSettings isGoogleCloudServiceEnabled]) {
        NSString *fileURLString = [NSString stringWithFormat:@"%@/files/url",KBASE_FILE_URL];
        NSString *blobParamString = [@"" stringByAppendingFormat:@"key=%@",blobKey];
        urlRequest = [ALRequestHandler createGETRequestWithUrlString:fileURLString paramString:blobParamString];
        completion(urlRequest, nil);
    } else if ([ALApplozicSettings isS3StorageServiceEnabled]) {
        NSString *fileURLString = [NSString stringWithFormat:@"%@/rest/ws/file/url",KBASE_FILE_URL];
        NSString *blobParamString = [@"" stringByAppendingFormat:@"key=%@",blobKey];
        urlRequest = [ALRequestHandler createGETRequestWithUrlString:fileURLString paramString:blobParamString];
        completion(urlRequest, nil);
    } else if ([ALApplozicSettings isStorageServiceEnabled]) {
        NSString *fileURLString = [NSString stringWithFormat:@"%@%@%@",KBASE_FILE_URL,AL_IMAGE_DOWNLOAD_ENDPOINT,blobKey];
        completion(nil, fileURLString);
        return;
    } else {
        NSString *fileURLString = [NSString stringWithFormat:@"%@/rest/ws/aws/file/%@",KBASE_FILE_URL,blobKey];
        completion(nil, fileURLString);
        return;
    }
}

- (NSMutableURLRequest *)getURLRequestForThumbnail:(NSString *)blobKey {
    if (blobKey == nil) {
        return nil;
    }
    if ([ALApplozicSettings isGoogleCloudServiceEnabled]) {
        NSString *fileURLString = [NSString stringWithFormat:@"%@/files/url",KBASE_FILE_URL];
        NSString *blobParamString = [@"" stringByAppendingFormat:@"key=%@",blobKey];
        return [ALRequestHandler createGETRequestWithUrlString:fileURLString paramString:blobParamString];
    } else if([ALApplozicSettings isS3StorageServiceEnabled]) {
        NSString *fileURLString = [NSString stringWithFormat:@"%@/rest/ws/file/url",KBASE_FILE_URL];
        NSString *blobParamString = [@"" stringByAppendingFormat:@"key=%@",blobKey];
        return [ALRequestHandler createGETRequestWithUrlString:fileURLString paramString:blobParamString];
    }
    return nil;
}

- (void)downloadImageThumbnailUrl:(NSString *)url blobKey:(NSString *)blobKey completion:(void (^)(NSString *, NSError *))completion {
    NSMutableURLRequest *urlRequest = [self getURLRequestForThumbnail:blobKey];
    if (urlRequest) {
        [self.responseHandler authenticateAndProcessRequest:urlRequest
                                                     andTag:@"FILE DOWNLOAD URL"
                                      WithCompletionHandler:^(id theJson, NSError *theError) {
            if (theError) {
                completion(nil, theError);
                return;
            }
            NSString *imageDownloadURL = (NSString *)theJson;
            ALSLog(ALLoggerSeverityInfo, @"Response URL For Thumbnail is : %@", imageDownloadURL);
            completion(imageDownloadURL, nil);
        }];
    } else {
        completion(url, nil);
    }
}

- (void)downloadImageThumbnailUrl:(ALMessage *)message
                   withCompletion:(void(^)(NSString *fileURL, NSError *error)) completion {
    [self downloadImageThumbnailUrl:message.fileMeta.thumbnailUrl
                            blobKey:message.fileMeta.thumbnailBlobKey
                         completion:^(NSString *fileURL, NSError *error) {
        completion(fileURL, error);
    }];
}

- (void)addWelcomeMessage:(NSNumber *)channelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService *messageDBService = [[ALMessageDBService alloc]init];

    ALMessage *alMessage = [ALMessage new];

    alMessage.contactIds = @"applozic";//1
    alMessage.to = @"applozic";//2
    alMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    alMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString];
    alMessage.sendToDevice = NO;
    alMessage.shared = NO;
    alMessage.fileMeta = nil;
    alMessage.status = [NSNumber numberWithInt:READ];
    alMessage.key = @"welcome-message-temp-key-string";
    alMessage.delivered=NO;
    alMessage.fileMetaKey = @"";//4
    alMessage.contentType = 0;
    alMessage.status = [NSNumber numberWithInt:DELIVERED_AND_READ];
    if (channelKey!=nil) {
        alMessage.type=@"101";
        alMessage.message=@"You have created a new group, Say something!!";
        alMessage.groupId = channelKey;
    } else {
        alMessage.type = @"4";
        alMessage.message = @"Welcome to Applozic! Drop a message here or contact us at devashish@applozic.com for any queries. Thanks";//3
        alMessage.groupId = nil;
    }
    [messageDBService createMessageEntityForDBInsertionWithMessage:alMessage];
    [alDBHandler saveContext];

}

- (void)getLatestMessageGroupByContact:(NSUInteger)mainPageSize
                             startTime:(NSNumber *)startTime
                        withCompletion:(void(^)(ALMessageList *alMessageList, NSError *error)) completion {
    ALSLog(ALLoggerSeverityInfo, @"\nGet Latest Messages \t State:- User Login ");

    NSString *messageListURLString = [NSString stringWithFormat:@"%@/rest/ws/message/list",KBASE_URL];

    NSString *messageListParamString = [NSString stringWithFormat:@"startIndex=%@&mainPageSize=%lu&deletedGroupIncluded=%@",
                                        @"0",(unsigned long)mainPageSize,@(YES)];

    if (startTime != nil) {
        messageListParamString = [NSString stringWithFormat:@"startIndex=%@&mainPageSize=%lu&endTime=%@&deletedGroupIncluded=%@",
                                  @"0", (unsigned long)mainPageSize, startTime,@(YES)];
    }
    if ([ALApplozicSettings getCategoryName]) {
        messageListParamString = [messageListParamString stringByAppendingString:[NSString stringWithFormat:@"&category=%@",
                                                                                  [ALApplozicSettings getCategoryName]]];
    }

    NSMutableURLRequest *messageListRequest = [ALRequestHandler createGETRequestWithUrlString:messageListURLString paramString:messageListParamString];

    [self.responseHandler authenticateAndProcessRequest:messageListRequest andTag:@"GET MESSAGES GROUP BY CONTACT" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            completion(nil, theError);
            return;
        }

        ALMessageList *messageListResponse = [[ALMessageList alloc] initWithJSONString:theJson];
        ALSLog(ALLoggerSeverityInfo, @"Message list response JSON : %@",theJson);

        if (theJson) {
            [ALUserDefaultsHandler setInitialMessageListCallDone:YES];
            if (messageListResponse.userDetailsList) {
                ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];
                [alContactDBService addUserDetails:messageListResponse.userDetailsList];
            }
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService callForChannelServiceForDBInsertion:theJson];

            /// Save the last message created time for calling the message list API.
            /// Next time onwards this saved time will be used. as the start time

            if (messageListResponse.messageList.count > 0) {
                ALMessage *lastMessage = (ALMessage *)[messageListResponse.messageList lastObject];
                [ALUserDefaultsHandler setLastMessageListTime:lastMessage.createdAtTime];
            }
        }
        //USER BLOCK SYNC CALL
        ALUserService *userService = [ALUserService new];
        [userService blockUserSync: [ALUserDefaultsHandler getUserBlockLastTimeStamp]];

        completion(messageListResponse, nil);

    }];
}

- (void)getMessagesListGroupByContactswithCompletion:(void(^)(NSMutableArray *messages, NSError *error)) completion {
    ALSLog(ALLoggerSeverityInfo, @"\nGet Latest Messages \t State:- User Opens Message List View");
    NSString *messageListURLString = [NSString stringWithFormat:@"%@/rest/ws/message/list", KBASE_URL];

    NSString *messageListParamString = [NSString stringWithFormat:@"startIndex=%@&deletedGroupIncluded=%@",@"0",@(YES)];

    NSMutableURLRequest *messageListRequest = [ALRequestHandler createGETRequestWithUrlString:messageListURLString paramString:messageListParamString];
    [self.responseHandler authenticateAndProcessRequest:messageListRequest andTag:@"GET MESSAGES GROUP BY CONTACT" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            completion(nil, theError);
            return;
        }

        ALMessageList *messageListResponse = [[ALMessageList alloc] initWithJSONString:theJson];

        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService callForChannelServiceForDBInsertion:theJson];
        completion(messageListResponse.messageList , nil);
    }];

}

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
                withOpenGroup:(BOOL)isOpenGroup
               withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion {
    NSString *messageURLString = [NSString stringWithFormat:@"%@/rest/ws/message/list",KBASE_URL];

    NSMutableURLRequest *messageThreadRequest = [ALRequestHandler createGETRequestWithUrlString:messageURLString paramString:messageListRequest.getParamString];

    [self.responseHandler authenticateAndProcessRequest:messageThreadRequest andTag:@"GET MESSAGES LIST FOR USERID" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            ALSLog(ALLoggerSeverityError, @"MSG_LIST ERROR :: %@",theError.description);
            completion(nil, theError, nil);
            return;
        }

        if (!(messageListRequest.channelType == OPEN)) {
            if (messageListRequest.channelKey != nil) {
                [ALUserDefaultsHandler setServerCallDoneForMSGList:true forContactId:[messageListRequest.channelKey stringValue]];
            } else {
                [ALUserDefaultsHandler setServerCallDoneForMSGList:true forContactId:messageListRequest.userId];
            }
        }

        if (messageListRequest.conversationId != nil) {
            [ALUserDefaultsHandler setServerCallDoneForMSGList:true forContactId:[messageListRequest.conversationId stringValue]];
        }

        ALMessageList *messageListResponse = [[ALMessageList alloc] initWithJSONString:theJson
                                                                         andWithUserId:messageListRequest.userId
                                                                          andWithGroup:messageListRequest.channelKey];

        ALMessageDBService *alMessageDBService = [[ALMessageDBService alloc] init];
        [alMessageDBService addMessageList:messageListResponse.messageList skipAddingMessageInDb:isOpenGroup];
        ALConversationService *alConversationService = [[ALConversationService alloc] init];
        [alConversationService addConversations:messageListResponse.conversationPxyList];

        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService callForChannelServiceForDBInsertion:theJson];
        ALSLog(ALLoggerSeverityInfo, @"Message thread response : %@",(NSString *)theJson);
        completion(messageListResponse.messageList, nil, messageListResponse.userDetailsList);
    }];
}

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
               withCompletion:(void (^)(NSMutableArray *, NSError *, NSMutableArray *))completion {
    ALChannel *channel = nil;
    if (messageListRequest.channelKey != nil) {
        channel = [[ALChannelService sharedInstance] getChannelByKey:messageListRequest.channelKey];
    }

    [self getMessageListForUser:messageListRequest withOpenGroup:(channel != nil && channel.type == OPEN) withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {

        completion(messages, error, userDetailArray);

    }];
}

- (void)sendPhotoForUserInfo:(NSDictionary *)userInfo withCompletion:(void(^)(NSString *message, NSError *error)) completion {
    if (ALApplozicSettings.isStorageServiceEnabled) {
        NSString *fileUploadURLString = [NSString stringWithFormat:@"%@%@", KBASE_FILE_URL, AL_IMAGE_UPLOAD_ENDPOINT];
        completion(fileUploadURLString, nil);
    } else if (ALApplozicSettings.isS3StorageServiceEnabled) {
        NSString *fileUploadURLString = [NSString stringWithFormat:@"%@%@", KBASE_FILE_URL, AL_CUSTOM_STORAGE_IMAGE_UPLOAD_ENDPOINT];
        completion(fileUploadURLString, nil);
    } else if (ALApplozicSettings.isGoogleCloudServiceEnabled){
        NSString *fileUploadURLString = [NSString stringWithFormat:@"%@%@", KBASE_FILE_URL, AL_IMAGE_UPLOAD_ENDPOINT];
        completion(fileUploadURLString, nil);
    } else {
        NSString *fileUploadURLString = [NSString stringWithFormat:@"%@/rest/ws/aws/file/url",KBASE_FILE_URL];

        NSMutableURLRequest *fileURLRequest = [ALRequestHandler createGETRequestWithUrlString:fileUploadURLString paramString:nil];

        [self.responseHandler authenticateAndProcessRequest:fileURLRequest andTag:@"CREATE FILE URL" WithCompletionHandler:^(id theJson, NSError *theError) {

            if (theError) {
                completion(nil, theError);
                return;
            }

            NSString *imagePostingURL = (NSString *)theJson;
            ALSLog(ALLoggerSeverityInfo, @"Upload Image or attachment URL : %@",imagePostingURL);
            completion(imagePostingURL, nil);
        }];
    }
}

- (void) getLatestMessageForUser:(NSString *)deviceKeyString
                  withCompletion:(void (^)( ALSyncMessageFeed *, NSError *))completion {
    [self getLatestMessageForUser:deviceKeyString withMetaDataSync:NO withCompletion:^(ALSyncMessageFeed *syncResponse, NSError *nsError) {
        completion(syncResponse,nsError);
    }];
}

- (void)deleteMessage:(NSString *)keyString
         andContactId:(NSString *)contactId
       withCompletion:(void (^)(NSString *, NSError *))completion {
    NSString *deleteMessageURLString = [NSString stringWithFormat:@"%@/rest/ws/message/delete",KBASE_URL];
    NSString *deleteMessageParamString = [NSString stringWithFormat:@"key=%@&userId=%@",keyString,[contactId urlEncodeUsingNSUTF8StringEncoding]];
    NSMutableURLRequest *deleteMessageRequest = [ALRequestHandler createGETRequestWithUrlString:deleteMessageURLString paramString:deleteMessageParamString];

    [self.responseHandler authenticateAndProcessRequest:deleteMessageRequest andTag:@"DELETE_MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            completion(nil,theError);
            return;
        }

        NSString *status = (NSString *)theJson;
        ALSLog(ALLoggerSeverityInfo, @"Response of delete message: %@", status);
        if ([status isEqualToString:AL_RESPONSE_SUCCESS]) {
            completion(status, nil);
            return;
        } else {
            NSError *responseError = [NSError errorWithDomain:@"Applozic"
                                                         code:1
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Failed to delete the message due to internal error"}];
            completion(nil, responseError);
            return;
        }
    }];
}

- (void)deleteMessageThread:(NSString *)contactId
               orChannelKey:(NSNumber *)channelKey
             withCompletion:(void (^)(NSString *, NSError *))completion {
    NSString *deleteThreadURLString = [NSString stringWithFormat:@"%@/rest/ws/message/delete/conversation",KBASE_URL];
    NSString *deleteThreadParamString;
    if (channelKey != nil) {
        deleteThreadParamString = [NSString stringWithFormat:@"groupId=%@",channelKey];
    } else {
        deleteThreadParamString = [NSString stringWithFormat:@"userId=%@",[contactId urlEncodeUsingNSUTF8StringEncoding]];
    }
    NSMutableURLRequest *deleteThreadRequest = [ALRequestHandler createGETRequestWithUrlString:deleteThreadURLString paramString:deleteThreadParamString];

    [self.responseHandler authenticateAndProcessRequest:deleteThreadRequest andTag:@"DELETE_MESSAGE_THREAD" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Error in delete message thread: %@", theError.description);
            completion(nil, theError);
            return;
        }
        NSString *status = (NSString *)theJson;
        ALSLog(ALLoggerSeverityInfo, @"Response of delete message thread: %@", (NSString *)theJson);
        if ([status isEqualToString:AL_RESPONSE_SUCCESS]) {
            ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
            [dbService deleteAllMessagesByContact:contactId orChannelKey:channelKey];
            completion(status, nil);
            return;
        } else {
            NSError *responseError = [NSError errorWithDomain:@"Applozic"
                                                         code:1
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Failed to delete the message thread due to internal error"}];
            completion(nil, responseError);
            return;
        }
    }];

}

- (void)sendMessage:(NSDictionary *)userInfo
withCompletionHandler:(void(^)(id theJson, NSError *theError))completion {
    NSString *messageSendURLString = [NSString stringWithFormat:@"%@/rest/ws/message/v2/send",KBASE_URL];
    NSString *messageSendParamString = [ALUtilityClass generateJsonStringFromDictionary:userInfo];

    NSMutableURLRequest *messageSendRequest = [ALRequestHandler createPOSTRequestWithUrlString:messageSendURLString paramString:messageSendParamString];

    [self.responseHandler authenticateAndProcessRequest:messageSendRequest andTag:@"SEND MESSAGE" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            completion(nil,theError);
            return;
        }
        completion(theJson,nil);
    }];
}

- (void)getCurrentMessageInformation:(NSString *)messageKey
               withCompletionHandler:(void(^)(ALMessageInfoResponse *msgInfo, NSError *theError))completion {
    NSString *messageInfoURLString = [NSString stringWithFormat:@"%@/rest/ws/message/info", KBASE_URL];
    NSString *messageKeyParamString = [NSString stringWithFormat:@"key=%@", messageKey];

    NSMutableURLRequest *messageInfoRequest = [ALRequestHandler createGETRequestWithUrlString:messageInfoURLString paramString:messageKeyParamString];

    [self.responseHandler authenticateAndProcessRequest:messageInfoRequest andTag:@"MESSSAGE_INFORMATION" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Error in message information API: %@", theError);
            completion(nil, theError);
        } else {
            ALSLog(ALLoggerSeverityInfo, @"Response of Message information API JSON : %@", (NSString *)theJson);
            ALMessageInfoResponse *messageInfoObject = [[ALMessageInfoResponse alloc] initWithJSONString:(NSString *)theJson];
            completion(messageInfoObject, theError);
        }
    }];
}

- (void)getLatestMessageForUser:(NSString *)deviceKeyString
               withMetaDataSync:(BOOL)isMetaDataUpdate
                 withCompletion:(void (^)( ALSyncMessageFeed *, NSError *))completion {
    if (!deviceKeyString) {
        NSError *deviceKeyNilError = [NSError
                                      errorWithDomain:@"Applozic"
                                      code:1
                                      userInfo:[NSDictionary
                                                dictionaryWithObject:@"Device key is nil"
                                                forKey:NSLocalizedDescriptionKey]];
        completion(nil, deviceKeyNilError);
        return;
    }
    NSString *messageSyncURLString = [NSString stringWithFormat:@"%@/rest/ws/message/sync",KBASE_URL];
    NSString *lastSyncTime;
    NSString *messageSyncParamString;
    if (isMetaDataUpdate) {
        lastSyncTime = [NSString stringWithFormat:@"%@", [ALUserDefaultsHandler getLastSyncTimeForMetaData]];
        messageSyncParamString = [NSString stringWithFormat:@"lastSyncTime=%@&metadataUpdate=true",lastSyncTime];
    } else {
        lastSyncTime = [NSString stringWithFormat:@"%@", [ALUserDefaultsHandler getLastSyncTime]];
        messageSyncParamString = [NSString stringWithFormat:@"lastSyncTime=%@",lastSyncTime];
    }

    ALSLog(ALLoggerSeverityInfo, @"LAST SYNC TIME IN CALL :  %@", lastSyncTime);

    NSMutableURLRequest *messageSyncRequest = [ALRequestHandler createGETRequestWithUrlString:messageSyncURLString paramString:messageSyncParamString];
    [self.responseHandler authenticateAndProcessRequest:messageSyncRequest andTag:@"SYNC LATEST MESSAGE URL" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            [ALUserDefaultsHandler setMsgSyncRequired:YES];
            completion(nil,theError);
            return;
        }

        [ALUserDefaultsHandler setMsgSyncRequired:NO];
        ALSyncMessageFeed *syncResponse = [[ALSyncMessageFeed alloc] initWithJSONString:theJson];
        ALSLog(ALLoggerSeverityInfo, @"LATEST_MESSAGE_JSON: %@", (NSString *)theJson);
        completion(syncResponse,nil);
    }];
}

- (void)updateMessageMetadataOfKey:(NSString *)messageKey
                      withMetadata:(NSMutableDictionary *)metadata
                    withCompletion:(void (^)(id, NSError *))completion {
    ALSLog(ALLoggerSeverityInfo, @"Updating message metadata for message : %@", messageKey);
    NSString *metadataURLString = [NSString stringWithFormat:@"%@/rest/ws/message/update/metadata",KBASE_URL];
    NSMutableDictionary *messageMetadata = [NSMutableDictionary new];

    [messageMetadata setObject:messageKey forKey:@"key"];
    [messageMetadata setObject:metadata forKey:@"metadata"];

    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:messageMetadata options:0 error:&error];
    NSString *metadataParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];

    NSMutableURLRequest *metadataUpdateRequest = [ALRequestHandler createPOSTRequestWithUrlString:metadataURLString paramString:metadataParamString];

    [self.responseHandler authenticateAndProcessRequest:metadataUpdateRequest andTag:@"UPDATE_MESSAGE_METADATA" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            ALSLog(ALLoggerSeverityError,@"Error while updating message metadata: %@", theError);
            completion(nil, theError);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"Message metadata updated successfully with result : %@", theJson);
        completion(theJson, nil);
    }];
}

- (void)searchMessage:(NSString *)key
       withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion {
    ALSLog(ALLoggerSeverityInfo, @"Search messages with %@", key);
    NSString *messageSearchURLString = [NSString stringWithFormat:@"%@/rest/ws/group/support", KBASE_URL];
    NSString *messageSearchParamString = [NSString stringWithFormat:@"search=%@", [key urlEncodeUsingNSUTF8StringEncoding]];

    NSMutableURLRequest *messageURLRequest = [ALRequestHandler
                                              createGETRequestWithUrlString: messageSearchURLString
                                              paramString: messageSearchParamString];

    [self.responseHandler
     authenticateAndProcessRequest: messageURLRequest
     andTag: @"Search messages"
     WithCompletionHandler: ^(id theJson, NSError *theError) {
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Search messages ERROR :: %@",theError.description);
            completion(nil, theError);
            return;
        }
        if (![[theJson valueForKey:@"status"] isEqualToString:AL_RESPONSE_SUCCESS]) {
            ALSLog(ALLoggerSeverityError, @"Search messages ERROR :: %@",theError.description);
            NSError *error = [NSError
                              errorWithDomain:@"Applozic"
                              code:1
                              userInfo:[NSDictionary
                                        dictionaryWithObject:@"Status fail in response"
                                        forKey:NSLocalizedDescriptionKey]];
            completion(nil, error);
            return;
        }
        NSString *response = [theJson valueForKey: @"response"];
        if (response == nil) {
            ALSLog(ALLoggerSeverityError, @"Search messages RESPONSE is nil");
            NSError *error = [NSError errorWithDomain:@"response is nil" code:0 userInfo:nil];
            completion(nil, error);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"Search messages RESPONSE :: %@", (NSString *)theJson);
        NSMutableArray<ALMessage *> *messages = [NSMutableArray new];
        NSDictionary *messageDictionary = [response valueForKey: @"message"];
        for (NSDictionary *dict in messageDictionary) {
            ALMessage *message = [[ALMessage alloc] initWithDictonary: dict];
            [messages addObject: message];
        }
        ALChannelFeed *channelFeed = [[ALChannelFeed alloc] initWithJSONString: response];
        [[ALSearchResultCache shared] saveChannels: channelFeed.channelFeedsList];
        completion(messages, nil);
        return;
    }];
}

- (void)searchMessageWith:(ALSearchRequest *)request
           withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion {

    if (!request.searchText || request.searchText.length == 0 ) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary
                                    dictionaryWithObject:@"Search text is empty or nil"
                                    forKey:NSLocalizedDescriptionKey]];
        completion(nil, error);
        return;
    }

    NSString *messageSerarchURLString = [NSString stringWithFormat:@"%@/rest/ws/message/search", KBASE_URL];
    NSString *messageSearchParamString = [request getParamString];

    NSMutableURLRequest *messageURLRequest = [ALRequestHandler
                                              createGETRequestWithUrlString:messageSerarchURLString
                                              paramString: messageSearchParamString];

    [self.responseHandler
     authenticateAndProcessRequest: messageURLRequest
     andTag: @"Search messages"
     WithCompletionHandler: ^(id theJson, NSError *theError) {
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Search messages ERROR :: %@",theError.description);
            completion(nil, theError);
            return;
        }
        if (![[theJson valueForKey:@"status"] isEqualToString:AL_RESPONSE_SUCCESS]) {
            ALSLog(ALLoggerSeverityError, @"Search messages ERROR :: %@",theError.description);
            NSError *error = [NSError
                              errorWithDomain:@"Applozic"
                              code:1
                              userInfo:[NSDictionary
                                        dictionaryWithObject:@"Status fail in response"
                                        forKey:NSLocalizedDescriptionKey]];
            completion(nil, error);
            return;
        }
        NSString *response = [theJson valueForKey: @"response"];
        if (response == nil) {
            ALSLog(ALLoggerSeverityError, @"Search messages RESPONSE is nil");
            NSError *error = [NSError errorWithDomain:@"response is nil" code:0 userInfo:nil];
            completion(nil, error);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"Search messages RESPONSE :: %@", (NSString *)theJson);
        NSMutableArray<ALMessage *> *messages = [NSMutableArray new];
        NSDictionary *messageDictionary = [response valueForKey: @"message"];
        for (NSDictionary *dict in messageDictionary) {
            ALMessage *message = [[ALMessage alloc] initWithDictonary: dict];
            [messages addObject: message];
        }
        ALChannelFeed *channelFeed = [[ALChannelFeed alloc] initWithJSONString: response];
        [[ALSearchResultCache shared] saveChannels: channelFeed.channelFeedsList];
        completion(messages, nil);
        return;
    }];
}

- (void)getMessageListForUser:(MessageListRequest *)messageListRequest
                     isSearch:(BOOL)flag
               withCompletion:(void (^)(NSMutableArray<ALMessage *> *, NSError *))completion {
    NSString *messageThreadURLString = [NSString stringWithFormat: @"%@/rest/ws/message/list", KBASE_URL];
    NSMutableURLRequest *messageThreadRequest = [ALRequestHandler
                                                 createGETRequestWithUrlString: messageThreadURLString
                                                 paramString: messageListRequest.getParamString];

    [self.responseHandler authenticateAndProcessRequest:messageThreadRequest andTag:@"Messages for searched conversation" WithCompletionHandler:^(id theJson, NSError *theError) {

        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Error while getting messages :: %@", theError.description);
            completion(nil, theError);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"Messages fetched succesfully :: %@", (NSString *)theJson);

        NSDictionary *messageDictionary = [theJson valueForKey:@"message"];
        NSMutableArray<ALMessage *> *messages = [NSMutableArray new];
        for (NSDictionary *dict in messageDictionary) {
            ALMessage *message = [[ALMessage alloc] initWithDictonary:dict];
            [messages addObject: message];
        }

        NSDictionary *userDetailDictionary = [theJson valueForKey:@"userDetails"];
        NSMutableArray<ALUserDetail *> *userDetails = [NSMutableArray new];
        for (NSDictionary *dict in userDetailDictionary) {
            ALUserDetail *userDetail = [[ALUserDetail alloc] initWithDictonary: dict];
            [userDetails addObject: userDetail];
        }
        [[ALSearchResultCache shared] saveUserDetails: userDetails];

        ALChannelFeed *alChannelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];

        ALConversationService *alConversationService = [[ALConversationService alloc] init];
        [alConversationService addConversations:alChannelFeed.conversationProxyList];

        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService saveChannelUsersAndChannelDetails:alChannelFeed.channelFeedsList calledFromMessageList:YES];
        completion(messages, nil);
    }];
}

- (void)getMessagesWithkeys:(NSMutableArray<NSString *> *)keys withCompletion:(void (^)(ALAPIResponse *, NSError *))completion {
    NSString *messageInfoURLString = [NSString stringWithFormat:@"%@/rest/ws/message/detail", KBASE_URL];
    NSMutableString *paramMessageKeyString = [[NSMutableString alloc] init];
    for (NSString *key in keys) {
        [paramMessageKeyString appendString: [NSString stringWithFormat:@"keys=%@&", key]];
    }

    if (keys.count > 0) {
        /// We have an extra ampersand.
        [paramMessageKeyString deleteCharactersInRange:NSMakeRange([paramMessageKeyString length] - 1, 1)];
    }
    NSMutableURLRequest *messageInfoRequest = [ALRequestHandler createGETRequestWithUrlString: messageInfoURLString paramString: paramMessageKeyString];

    [self.responseHandler authenticateAndProcessRequest:messageInfoRequest andTag:@"Get hidden messages" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Fetching message error %@", (NSString *)theJson);
            completion(nil, theError);
            return;
        }
        ALAPIResponse *response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        ALSLog(ALLoggerSeverityInfo, @"Messages fetched successfully %@", (NSString *)theJson);
        completion(response, nil);
    }];
}

- (void)deleteMessageForAllWithKey:(NSString *)keyString
                    withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {
    NSString *deleteAllURLString = [NSString stringWithFormat:@"%@/rest/ws/message/v2/delete",KBASE_URL];
    NSString *deleteAllParamString = [NSString stringWithFormat:@"key=%@&deleteForAll=true", keyString];

    NSMutableURLRequest *deleteAllRequest = [ALRequestHandler createGETRequestWithUrlString:deleteAllURLString paramString:deleteAllParamString];

    [self.responseHandler authenticateAndProcessRequest:deleteAllRequest andTag:@"DELETE_MESSAGE_FOR_ALL" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        if (theError) {
            completion(nil, theError);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"Response for delete message for all: %@", (NSString *)theJson);
        ALAPIResponse *response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
            completion(response, nil);
        } else {
            NSError *responseError = [NSError errorWithDomain:@"Applozic"
                                                         code:1
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Failed to delete the message for all"}];
            completion(nil, responseError);
        }
    }];
}

@end
