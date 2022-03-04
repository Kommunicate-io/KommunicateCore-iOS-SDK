//
//  ApplozicClient.m
//  Applozic
//
//  Created by Sunil on 12/03/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import "ApplozicClient.h"
#import "ALAttachmentService.h"
#import "ALPushNotificationService.h"
#import "ALMQTTConversationService.h"
#import "ALRegisterUserClientService.h"

@implementation ApplozicClient {
    ALMQTTConversationService *alMQTTConversationService;
    ALAttachmentService *alAttachmentService;
    ALPushNotificationService *alPushNotificationService;
}

NSString *const ApplozicClientDomain = @"ApplozicClient";

#pragma mark - Init with AppId

- (instancetype)initWithApplicationKey:(NSString *)applicationKey {
    self = [super init];
    if (self) {
        [ALUserDefaultsHandler setApplicationKey:applicationKey];
        [self setUpServices];
    }
    return self;
}

#pragma mark - Init with AppId and delegate

- (instancetype)initWithApplicationKey:(NSString *)applicationKey withDelegate:(id<ApplozicUpdatesDelegate>)delegate {
    self = [super init];
    if (self) {
        [ALUserDefaultsHandler setApplicationKey:applicationKey];
        alPushNotificationService = [[ALPushNotificationService alloc] init];
        self.delegate = delegate;
        alPushNotificationService.realTimeUpdate = delegate;
        alMQTTConversationService = [ALMQTTConversationService sharedInstance];
        alMQTTConversationService.realTimeUpdate = delegate;
        [self setUpServices];
    }
    return self;
}

- (void)setUpServices {

    //TO-DO move this call later to a differnt method
    [ALApplozicSettings setupSuiteAndMigrate];

    _messageService = [ALMessageService sharedInstance];
    _messageService.delegate = self.delegate;
    _messageDbService = [ALMessageDBService new];
    _userService = [ALUserService sharedInstance];
    _channelService = [ALChannelService sharedInstance];
    alAttachmentService = [ALAttachmentService sharedInstance];
}

#pragma mark - Login

- (void)loginUser:(ALUser *)alUser withCompletion:(void(^)(ALRegistrationResponse *registrationResponse, NSError *error))completion {

    if (![ALUserDefaultsHandler getApplicationKey]) {
        NSError *applicationKeyNilError = [NSError errorWithDomain:ApplozicClientDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"AppID or ApplicationKey is nil its not passed"}];
        completion(nil, applicationKeyNilError);
        return;
    } else if (!alUser) {
        NSError *alUserNilError = [NSError errorWithDomain:ApplozicClientDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"ALUser object is nil"}];
        completion(nil, alUserNilError);
        return;
    } else if (!alUser.userId) {
        NSError *userIdNilError = [NSError errorWithDomain:ApplozicClientDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"UserId is nil"}];
        completion(nil, userIdNilError);
        return;
    }

    [alUser setApplicationId:[ALUserDefaultsHandler getApplicationKey]];
    [alUser setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];

    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {

        NSLog(@"USER_REGISTRATION_RESPONSE :: %@", rResponse);
        if (error) {
            NSLog(@"ERROR_USER_REGISTRATION :: %@",error.description);
            completion(nil, error);
            return;
        }

        if (![rResponse isRegisteredSuccessfully]) {
            NSError *passError = [NSError errorWithDomain:rResponse.message code:0 userInfo:nil];
            completion(rResponse, passError);
            return;
        }
        completion(rResponse, error);
    }];
}


#pragma mark - Logout

- (void)logoutUserWithCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {

    ALRegisterUserClientService *alUserClientService = [[ALRegisterUserClientService alloc] init];

    if ([ALUserDefaultsHandler getDeviceKeyString]) {
        [alUserClientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
            completion(error, response);
        }];
    }
}


#pragma mark - Update APN's device token to applozic

- (void)updateApnDeviceTokenWithCompletion:(NSString *)apnDeviceToken
                            withCompletion:(void(^)(ALRegistrationResponse *registrationResponse, NSError *error))completion {
    if (![ALUserDefaultsHandler getApplicationKey]) {
        NSError *applicationKeyNilError = [NSError errorWithDomain:ApplozicClientDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"AppID or ApplicationKey is nil its not passed"}];
        completion(nil, applicationKeyNilError);
        return;
    } else if (!apnDeviceToken) {
        NSError *apnsTokenError = [NSError errorWithDomain:ApplozicClientDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"APNs device token is nil"}];
        completion(nil, apnsTokenError);
        return;
    }

    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService updateApnDeviceTokenWithCompletion:apnDeviceToken withCompletion:^(ALRegistrationResponse *response, NSError *error) {

        if (error) {
            NSLog(@"REGISTRATION ERROR :: %@",error.description);
            completion(nil, error);
            return;
        }
        NSLog(@"Registration response from server : %@", response);
        completion(response, error);

    }];

}

#pragma mark - Messages list

- (void)getLatestMessages:(BOOL)isNextPage withCompletionHandler: (void(^)(NSMutableArray *messageList, NSError *error)) completion {
    [_messageDbService getLatestMessages:isNextPage withCompletionHandler:^(NSMutableArray *messageListArray, NSError *error) {
        completion(messageListArray, error);
    }];
}


#pragma mark - Message thread

- (void)getMessages:(MessageListRequest *)messageListRequest
withCompletionHandler: (void(^)(NSMutableArray *messageList, NSError *error)) completion {
    [_messageService getMessageListForUser:messageListRequest  withCompletion:^(NSMutableArray *messages, NSError *error, NSMutableArray *userDetailArray) {
        completion(messages, error);
    }];
}



#pragma mark - Converstion read mark group and one to one

- (void)markConversationReadForGroup:(NSNumber *)groupId withCompletion:(void(^)(NSString *response, NSError *error)) completion {
    if (groupId != nil && groupId.integerValue != 0) {
        [_channelService markConversationAsRead:groupId withCompletion:^(NSString *conversationResponse, NSError *error) {

            if (error) {
                NSLog(@"Error while marking messages as read channel %@",groupId);
                completion(conversationResponse, error);
            } else {
                [self->_userService processResettingUnreadCount];
                completion(conversationResponse, nil);
            }
        }];
    }
}

- (void)markConversationReadForOnetoOne:(NSString *)userId withCompletion:(void(^)(NSString *response, NSError *error)) completion {

    if (userId) {
        [_userService markConversationAsRead:userId withCompletion:^(NSString *conversationResponse, NSError *error) {
            if (error) {
                NSLog(@"Error while marking messages as read for contact %@", userId);
                completion(nil, error);
            } else {
                [self->_userService processResettingUnreadCount];
                completion(conversationResponse, nil);
            }
        }];
    }
}

#pragma mark - Send text message

- (void)sendTextMessage:(ALMessage*)alMessage withCompletion:(void(^)(ALMessage *message, NSError *error))completion {

    if (!alMessage) {
        NSError *messageError = [NSError errorWithDomain:ApplozicClientDomain
                                                    code:MessageNotPresent
                                                userInfo:@{NSLocalizedDescriptionKey : @"Empty message passed"}];

        completion(nil, messageError);
        return;
    }

    [_messageService sendMessages:alMessage withCompletion:^(NSString *message, NSError *error) {
        if (error) {
            NSLog(@"SEND_MSG_ERROR :: %@",error.description);
            completion(nil, error);
            return;
        }
        if (self.delegate) {
            [self.delegate onMessageSent:alMessage];
        }
        completion(alMessage, error);
    }];

}

#pragma mark - Send Attachment message

- (void)sendMessageWithAttachment:(ALMessage *)attachmentMessage {
    
    if (!attachmentMessage || !attachmentMessage.imageFilePath) {
        return;
    }
    [alAttachmentService sendMessageWithAttachment:attachmentMessage withDelegate:self.delegate withAttachmentDelegate:self.attachmentProgressDelegate];
}

#pragma mark - Download Attachment message

- (void)downloadMessageAttachment:(ALMessage *)alMessage {
    if (!alMessage) {
        return;
    }
    [alAttachmentService downloadMessageAttachment:alMessage withDelegate:self.attachmentProgressDelegate];
}

#pragma mark - Channel/Group methods

- (void)createChannelWithChannelInfo:(ALChannelInfo *)channelInfo
                      withCompletion:(void(^)(ALChannelCreateResponse *response, NSError *error))completion {

    ALChannelService *channelService = [[ALChannelService alloc] init];
    [channelService createChannelWithChannelInfo:channelInfo withCompletion:^(ALChannelCreateResponse *response, NSError *error) {
        completion(response, error);
    }];
}

- (void)removeMemberFromChannelWithUserId:(NSString *)userId
                            andChannelKey:(NSNumber *)channelKey
                       orClientChannelKey:(NSString *)clientChannelKey
                           withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {

    ALChannelService *alChannelService = [[ALChannelService alloc] init];
    [alChannelService removeMemberFromChannel:userId andChannelKey:channelKey
                           orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALAPIResponse *response) {
        completion(error, response);
    }];
}

- (void)leaveMemberFromChannelWithUserId:(NSString *)userId
                           andChannelKey:(NSNumber *)channelKey
                      orClientChannelKey:(NSString *)clientChannelKey
                          withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {

    ALChannelService *alChannelService = [[ALChannelService alloc] init];
    [alChannelService leaveChannelWithChannelKey:channelKey andUserId:userId orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALAPIResponse *response) {
        completion(error, response);
    }];

}

- (void)addMemberToChannelWithUserId:(NSString *)userId
                       andChannelKey:(NSNumber *)channelKey
                  orClientChannelKey:(NSString *)clientChannelKey
                      withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {

    ALChannelService *alChannelService = [[ALChannelService alloc] init];
    [alChannelService addMemberToChannel:userId andChannelKey:channelKey orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALAPIResponse *response) {
        completion(error, response);
    }];

}

- (void)updateChannelWithChannelKey:(NSNumber *)channelKey
                         andNewName:(NSString *)newName
                        andImageURL:(NSString *)imageURL
                 orClientChannelKey:(NSString *)clientChannelKey
                 isUpdatingMetaData:(BOOL)flag
                           metadata:(NSMutableDictionary *)metaData
                     orChannelUsers:(NSMutableArray *)channelUsers
                     withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    ALChannelService *alChannelService = [[ALChannelService alloc] init];
    [alChannelService updateChannelWithChannelKey:channelKey andNewName:newName andImageURL:imageURL orClientChannelKey:clientChannelKey isUpdatingMetaData:flag metadata:metaData orChildKeys:nil orChannelUsers:channelUsers withCompletion:^(NSError *error, ALAPIResponse *response) {
        completion(error, response);
    }];

}

- (void)getChannelInformationWithChannelKey:(NSNumber *)channelKey
                         orClientChannelKey:(NSString *)clientChannelKey
                             withCompletion:(void(^)(NSError *error, ALChannel *alChannel, AlChannelFeedResponse *channelResponse))completion {

    ALChannelService *channelService = [[ALChannelService alloc]init];
    [channelService getChannelInformationByResponse:channelKey orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALChannel *alChannel, AlChannelFeedResponse *channelResponse) {
        completion(error, alChannel, channelResponse);
    }];

}

#pragma mark - User block

- (void)blockUserWithUserId:(NSString *)userId withCompletion:(void(^)(NSError *error, BOOL userBlock))completion{

    [_userService blockUser:userId withCompletionHandler:^(NSError *error, BOOL userBlock) {
        completion(error, userBlock);
    }];
}

#pragma mark - User unblock

- (void)unBlockUserWithUserId:(NSString *)userId withCompletion:(void(^)(NSError *error, BOOL userUnblock))completion{

    [_userService unblockUser:userId withCompletionHandler:^(NSError *error, BOOL userUnblock) {
        completion(error, userUnblock);
    }];
}

#pragma mark - Mute/Unmute Channel

- (void)muteChannelOrUnMuteWithChannelKey:(NSNumber *)channelKey
                                  andTime:(NSNumber *)notificationTime
                           withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    ALMuteRequest *alMuteRequest = [ALMuteRequest new];
    alMuteRequest.id = channelKey;
    alMuteRequest.notificationAfterTime= notificationTime;

    ALChannelService *alChannelService = [[ALChannelService alloc]init];
    [alChannelService muteChannel:alMuteRequest withCompletion:^(ALAPIResponse *response, NSError *error) {
        completion(response, error);
    }];

}

#pragma mark - APN's notification process

- (void)notificationArrivedToApplication:(UIApplication*)application withDictionary:(NSDictionary *)userInfo {

    if (alPushNotificationService) {
        [alPushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
    }
}

#pragma mark - Subscribe To Conversation for real time updates

- (void)subscribeToConversation {
    if (alMQTTConversationService) {
        [alMQTTConversationService subscribeToConversation];
    }
}

#pragma mark - Unsubscribe To Conversation from real time updates

- (void)unsubscribeToConversation {
    if (alMQTTConversationService) {
        [alMQTTConversationService unsubscribeToConversation];
    }
}

#pragma mark - Subscribe To typing status for one to one chat

- (void)subscribeToTypingStatusForOneToOne {
    if (alMQTTConversationService) {
        [alMQTTConversationService subscribeToChannelConversation:nil];
    }
}

#pragma mark - Subscribe To typing status for Channel/Group chat

- (void)subscribeToTypingStatusForChannel:(NSNumber *)channelKey {
    if (alMQTTConversationService) {
        [alMQTTConversationService subscribeToChannelConversation:channelKey];
    }
}

#pragma mark - Unsubscribe To typing status events for one to one

- (void)unSubscribeToTypingStatusForOneToOne {
    if (alMQTTConversationService) {
        [alMQTTConversationService unSubscribeToChannelConversation:nil];
    }
}

#pragma mark - Unsubscribe To typing status events for Channel/Group

- (void)unSubscribeToTypingStatusForChannel:(NSNumber *)chanelKey {
    if (alMQTTConversationService) {
        [alMQTTConversationService unSubscribeToChannelConversation:chanelKey];
    }
}

- (void)sendTypingStatusForChannelKey:(NSNumber *)chanelKey
                           withTyping:(BOOL)isTyping {
    if (alMQTTConversationService) {
        [alMQTTConversationService sendTypingStatus:nil userID:nil andChannelKey:chanelKey typing:isTyping];
    }
}

- (void)sendTypingStatusForUserId:(NSString *)userId withTyping:(BOOL)isTyping {
    if (alMQTTConversationService) {
        [alMQTTConversationService sendTypingStatus:nil userID:userId andChannelKey:nil typing:isTyping];
    }
}

#pragma mark - Send typing status event for one to one or Channel/Group chat

- (void)sendTypingStatusForUserId:(NSString *)userId orForGroupId:(NSNumber*)channelKey withTyping:(BOOL)isTyping {
    if (channelKey != nil) {
        [self sendTypingStatusForChannelKey:channelKey withTyping:isTyping];
    } else if (userId) {
        [self sendTypingStatusForUserId:userId withTyping:isTyping];
    }
}

#pragma mark - Message list for one to one or Channel/Group

- (void)getLatestMessages:(BOOL)isNextPage
           withOnlyGroups:(BOOL)isGroup
    withCompletionHandler:(void(^)(NSMutableArray *messageList, NSError *error)) completion {

    ALMessageService *messageService = [[ALMessageService alloc] init];
    [messageService getLatestMessages:isNextPage withOnlyGroups:isGroup withCompletionHandler:^(NSMutableArray *messageList, NSError *error) {
        completion(messageList, error);
    }];
}

@end
