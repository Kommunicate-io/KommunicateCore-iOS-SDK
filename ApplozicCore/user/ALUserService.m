//
//  ALUserService.m
//  Applozic
//
//  Created by Divjyot Singh on 05/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

static int CONTACT_PAGE_SIZE = 100;

#import "ALUserService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALUtilityClass.h"
#import "ALSyncMessageFeed.h"
#import "ALMessageDBService.h"
#import "ALMessageList.h"
#import "ALMessageClientService.h"
#import "ALMessageService.h"
#import "ALContactDBService.h"
#import "ALLastSeenSyncFeed.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserClientService.h"
#import "ALUserDetail.h"
#import "ALMessageDBService.h"
#import "ALContactService.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "NSString+Encode.h"
#import "ALUser.h"
#import "ALLogger.h"

@implementation ALUserService
{
}

+ (ALUserService *)sharedInstance {
    static ALUserService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALUserService alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

#pragma mark - Setup services

-(void)setupServices {
    self.userClientService = [[ALUserClientService alloc] init];
    self.channelService = [[ALChannelService alloc] init];
    self.contactDBService = [[ALContactDBService alloc] init];
    self.contactService = [[ALContactService alloc] init];
}

#pragma mark - Fetch users from messages

- (void)processContactFromMessages:(NSArray *)messagesArr withCompletion:(void(^)(void))completionMark {
    
    NSMutableOrderedSet *contactIdsArray = [[NSMutableOrderedSet alloc] init ];
    
    for (ALMessage *alMessage in messagesArr) {
        NSString *contactId = alMessage.contactIds;
        if (contactId.length > 0 && ![self.contactService isContactExist:contactId]) {
            [contactIdsArray addObject:contactId];
        }
    }
    
    if ([contactIdsArray count] == 0) {
        completionMark();
        return;
    }
    
    NSMutableArray *userIdArray = [NSMutableArray arrayWithArray:[contactIdsArray array]];
    [self fetchAndupdateUserDetails:userIdArray withCompletion:^(NSMutableArray *userDetailArray, NSError *error) {
        if(error || !userDetailArray){
            completionMark();
            return;
        }
        completionMark();
    }];
}

#pragma mark - Fetch last seen status of users

- (void)getLastSeenUpdateForUsers:(NSNumber *)lastSeenAt withCompletion:(void(^)(NSMutableArray *))completionMark {
    
    [self.userClientService userLastSeenDetail:lastSeenAt withCompletion:^(ALLastSeenSyncFeed *messageFeed) {
        NSMutableArray *lastSeenUpdateArray = messageFeed.lastSeenArray;
        for (ALUserDetail *userDetail in lastSeenUpdateArray){
            userDetail.unreadCount = 0;
            [self.contactDBService updateUserDetail:userDetail];
        }
        completionMark(lastSeenUpdateArray);
    }];
}

- (void)userDetailServerCall:(NSString *)contactId withCompletion:(void(^)(ALUserDetail *))completionMark {
    
    if (!contactId) {
        completionMark(nil);
        return;
    }
    
    [self.userClientService userDetailServerCall:contactId withCompletion:^(ALUserDetail *userDetail) {
        completionMark(userDetail);
    }];
}

#pragma mark - Update user detail

- (void)updateUserDetail:(NSString *)userId withCompletion:(void(^)(ALUserDetail *userDetail))completionMark {
    [self userDetailServerCall:userId withCompletion:^(ALUserDetail *userDetail) {
        
        if (userDetail) {
            userDetail.unreadCount = 0;
            [self.contactDBService updateUserDetail:userDetail];
        }
        completionMark(userDetail);
    }];
}

#pragma mark - Update phone number, email of user with admin user

- (void)updateUser:(NSString *)phoneNumber email:(NSString *)email ofUser:(NSString *)userId withCompletion:(void (^)(BOOL))completion {
    [self.userClientService updateUser:phoneNumber email:email ofUser:userId withCompletion:^(id theJson, NSError *theError) {
        if (theJson) {
            /// Updation success.
            ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
            if (!contact) {
                completion(NO);
                return;
            }
            if (email) {
                [contact setEmail:email];
            }
            if (phoneNumber) {
                [contact setContactNumber:phoneNumber];
            }
            [self.contactDBService updateContactInDatabase:contact];
            completion(YES);
            return;
        }
        completion(NO);
    }];
}

- (void)updateUserDisplayName:(ALContact *)alContact {
    if (alContact.userId && alContact.displayName) {
        [self.userClientService updateUserDisplayName:alContact withCompletion:^(id theJson, NSError *theError) {
            
            if (theError) {
                ALSLog(ALLoggerSeverityError, @"GETTING ERROR in SEVER CALL FOR DISPLAY NAME");
            } else {
                ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:theJson];
                ALSLog(ALLoggerSeverityInfo, @"RESPONSE_STATUS :: %@", apiResponse.status);
            }
        }];
    } else {
        return;
    }
}

#pragma mark - Update display name user who is not registered

- (void)updateDisplayNameWith:(NSString *)userId
              withDisplayName:(NSString *)displayName
               withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error)) completion {
    
    if (!userId || !displayName) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"UserId or display name details is missing" forKey:NSLocalizedDescriptionKey]];
        completion(nil, error);
        return;
    }
    
    ALContact *contact = [[ALContact alloc] init];
    contact.userId = userId;
    contact.displayName = displayName;
    
    [self.userClientService updateUserDisplayName:contact withCompletion:^(id theJson, NSError *theError) {
        
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"GETTING ERROR in SEVER CALL FOR DISPLAY NAME");
            completion(nil, theError);
        } else {
            ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:theJson];
            ALSLog(ALLoggerSeverityInfo, @"RESPONSE_STATUS :: %@", apiResponse.status);
            completion(apiResponse, nil);
        }
    }];
}

#pragma mark - Mark Conversation as read

- (void)markConversationAsRead:(NSString *)contactId withCompletion:(void (^)(NSString *, NSError *))completion {
    
    if (!contactId) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"Failed to mark conversation read userId is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, error);
        return;
    }
    
    [self setUnreadCountZeroForContactId:contactId];
    
    NSUInteger count = [self.contactDBService markConversationAsDeliveredAndRead:contactId];
    ALSLog(ALLoggerSeverityInfo, @"Found %ld messages for marking as read.", (unsigned long)count);
    
    if (count == 0) {
        return;
    }
    [self.userClientService markConversationAsReadforContact:contactId withCompletion:^(NSString *response, NSError *error){
        completion(response,error);
    }];
    
}

- (void)setUnreadCountZeroForContactId:(NSString *)contactId {
    ALContact *contact = [self.contactService loadContactByKey:@"userId" value:contactId];
    contact.unreadCount = [NSNumber numberWithInt:0];
    [self.contactService setUnreadCountInDB:contact];
}

#pragma mark - Mark message as read

- (void)markMessageAsRead:(ALMessage *)alMessage
       withPairedkeyValue:(NSString *)pairedkeyValue
           withCompletion:(void (^)(NSString *, NSError *))completion {
    
    if (!alMessage) {
        NSError *apiError = [NSError
                             errorWithDomain:@"Applozic"
                             code:1
                             userInfo:[NSDictionary dictionaryWithObject:@"Failed to mark message as read ALMessage passed as nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, apiError);
        return;
    }
    
    if (!pairedkeyValue) {
        NSError *apiError = [NSError
                             errorWithDomain:@"Applozic"
                             code:1
                             userInfo:[NSDictionary dictionaryWithObject:@"Failed to mark message as read pairedMessageKey passed as nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, apiError);
        return;
    }
    
    
    [self markConversationReadInDataBaseWithMessage:alMessage];
    //Server Call
    [self.userClientService markMessageAsReadforPairedMessageKey:pairedkeyValue withCompletion:^(NSString *response, NSError *error) {
        ALSLog(ALLoggerSeverityInfo, @"Response Marking Message :%@",response);
        
        if (error) {
            completion(nil, error);
            return;
        }
        
        if ([response isEqualToString:AL_RESPONSE_SUCCESS]) {
            completion(response, nil);
        } else {
            NSError *apiError = [NSError
                                 errorWithDomain:@"Applozic"
                                 code:1
                                 userInfo:[NSDictionary dictionaryWithObject:@"Failed to mark message as read api error occurred" forKey:NSLocalizedDescriptionKey]];
            completion(nil, apiError);
            return;
        }
    }];
}

- (void)markConversationReadInDataBaseWithMessage:(ALMessage *)alMessage {
    
    if (alMessage.groupId != NULL) {
        [self.channelService setUnreadCountZeroForGroupID:alMessage.groupId];
        ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
        [channelDBService markConversationAsRead:alMessage.groupId];
    } else {
        [self setUnreadCountZeroForContactId:alMessage.contactIds];
        [self.contactDBService markConversationAsDeliveredAndRead:alMessage.contactIds];
        //  TODO: Mark message read&delivered in DB not whole conversation
    }
}

#pragma mark - Block user

- (void)blockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userBlock))completion {
    if (!userId) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"Failed to block user where userId is nil" forKey:NSLocalizedDescriptionKey]];
        completion(error, NO);
        return;
    }
    [self.userClientService userBlockServerCall:userId withCompletion:^(NSString *json, NSError *error) {
        
        if (!error) {
            ALAPIResponse *forBlockUserResponse = [[ALAPIResponse alloc] initWithJSONString:json];
            if ([forBlockUserResponse.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                [self.contactDBService setBlockUser:userId andBlockedState:YES];
                completion(error, YES);
                return;
            } else {
                NSError *apiError = [NSError
                                     errorWithDomain:@"Applozic"
                                     code:1
                                     userInfo:[NSDictionary dictionaryWithObject:@"Failed to block user api error occurred" forKey:NSLocalizedDescriptionKey]];
                completion(apiError, NO);
                return;
            }
        }
        completion(error, NO);
    }];
}

#pragma mark - Block/Unblock sync

- (void)blockUserSync:(NSNumber *)lastSyncTime {
    [self.userClientService userBlockSyncServerCall:lastSyncTime withCompletion:^(NSString *json, NSError *error) {
        
        if (!error) {
            ALUserBlockResponse *userBlockResponse = [[ALUserBlockResponse alloc] initWithJSONString:(NSString *)json];
            [self updateBlockUserStatusToLocalDB:userBlockResponse];
            [ALUserDefaultsHandler setUserBlockLastTimeStamp:userBlockResponse.generatedAt];
        }
    }];
}

- (void)updateBlockUserStatusToLocalDB:(ALUserBlockResponse *)userblock {
    [self.contactDBService blockAllUserInList:userblock.blockedUserList];
    [self.contactDBService blockByUserInList:userblock.blockByUserList];
}

#pragma mark - Unblock user

- (void)unblockUser:(NSString *)userId withCompletionHandler:(void(^)(NSError *error, BOOL userUnblock))completion {
    
    if (!userId) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"Failed to unblock user where userId is nil" forKey:NSLocalizedDescriptionKey]];
        completion(error, NO);
        return;
    }
    
    [self.userClientService userUnblockServerCall:userId withCompletion:^(NSString *json, NSError *error) {
        
        if (!error) {
            ALAPIResponse *forBlockUserResponse = [[ALAPIResponse alloc] initWithJSONString:json];
            if ([forBlockUserResponse.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                [self.contactDBService setBlockUser:userId andBlockedState:NO];
                completion(error, YES);
                return;
            } else {
                NSError *apiError = [NSError
                                     errorWithDomain:@"Applozic"
                                     code:1
                                     userInfo:[NSDictionary dictionaryWithObject:@"Failed to unblock user api error occurred" forKey:NSLocalizedDescriptionKey]];
                completion(apiError, NO);
                return;
            }
        }
        completion(error, NO);
    }];
}

- (NSMutableArray *)getListOfBlockedUserByCurrentUser {
    NSMutableArray *blockedUsersList = [self.contactDBService getListOfBlockedUsers];
    return blockedUsersList;
}

#pragma mark - Fetch Registered contacts

- (void)getListOfRegisteredUsersWithCompletion:(void(^)(NSError *error))completion {
    NSNumber *startTime;
    if (![ALUserDefaultsHandler isContactServerCallIsDone]) {
        startTime = 0;
    } else {
        startTime = [ALApplozicSettings getStartTime];
    }
    NSUInteger pageSize = (NSUInteger)CONTACT_PAGE_SIZE;
    
    [self.userClientService getListOfRegisteredUsers:startTime andPageSize:pageSize withCompletion:^(ALContactsResponse *response, NSError *error) {
        
        if (error) {
            completion(error);
            return;
        }
        
        [ALApplozicSettings setStartTime:response.lastFetchTime];
        [self.contactDBService updateFilteredContacts:response withLoadContact:NO];
        completion(error);
        
    }];
    
}

#pragma mark - Fetch Online contacts

- (void)fetchOnlineContactFromServer:(void(^)(NSMutableArray *array, NSError *error))completion {
    [self.userClientService fetchOnlineContactFromServer:[ALApplozicSettings getOnlineContactLimit] withCompletion:^(id json, NSError *error) {
        
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSDictionary *JSONDictionary = (NSDictionary *)json;
        NSMutableArray *contactArray = [NSMutableArray new];
        if (JSONDictionary.count) {
            ALUserDetail *userDetail = [ALUserDetail new];
            [userDetail parsingDictionaryFromJSON:JSONDictionary];
            NSString *paramString = userDetail.userIdString;
            
            [self.userClientService subProcessUserDetailServerCall:paramString withCompletion:^(NSMutableArray *userDetailArray, NSError *error) {
                
                if (error) {
                    completion(nil, error);
                    return;
                }
                for (ALUserDetail *userDetail in userDetailArray) {
                    [self.contactDBService updateUserDetail: userDetail];
                    ALContact *contact = [self.contactDBService loadContactByKey:@"userId" value:userDetail.userId];
                    [contactArray addObject:contact];
                }
                completion(contactArray, error);
            }];
        } else {
            completion(contactArray, nil);
        }
    }];
}

#pragma mark - Over all unread count (CHANNEL + CONTACTS)

- (NSNumber *)getTotalUnreadCount {
    NSNumber *contactUnreadCount = [self.contactService getOverallUnreadCountForContact];
    
    ALChannelService *channelService = [ALChannelService new];
    NSNumber *channelUnreadCount = [channelService getOverallUnreadCountForChannel];
    
    int totalCount = [contactUnreadCount intValue] + [channelUnreadCount intValue];
    NSNumber *unreadCount = [NSNumber numberWithInt:totalCount];
    
    return unreadCount;
}

- (void)resettingUnreadCountWithCompletion:(void (^)(NSString *json, NSError *error))completion {
    [self.userClientService readCallResettingUnreadCountWithCompletion:^(NSString *json, NSError *error) {
        
        completion(json, error);
    }];
}

#pragma mark - Update user display, profile image or user status

- (void)updateUserDisplayName:(NSString *)displayName
                 andUserImage:(NSString *)imageLink
                   userStatus:(NSString *)status
               withCompletion:(void (^)(id theJson, NSError *error))completion {
    
    if (!displayName && !imageLink && !status) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to update login user details the parameters passed are nil"
                                                                                 forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }
    
    [self.userClientService updateUserDisplayName:displayName andUserImageLink:imageLink userStatus:status metadata: nil withCompletion:^(id theJson, NSError *error) {
        completion(theJson, error);
    }];
}

#pragma mark - Fetch Users Detail

- (void)fetchAndupdateUserDetails:(NSMutableArray *)userArray withCompletion:(void (^)(NSMutableArray *array, NSError *error))completion {
    
    ALUserDetailListFeed *userDetailListFeed = [ALUserDetailListFeed new];
    [userDetailListFeed setArray:userArray];
    
    [self.userClientService subProcessUserDetailServerCallPOST:userDetailListFeed withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
        
        if (userDetailArray && userDetailArray.count) {
            [self.contactDBService addUserDetailsWithoutUnreadCount:userDetailArray];
        }
        completion(userDetailArray, theError);
    }];
}

#pragma mark - User Detail

- (void)getUserDetail:(NSString*)userId withCompletion:(void(^)(ALContact *contact))completion {
    
    if (!userId) {
        completion(nil);
        return;
    }
    
    if (![self.contactService isContactExist:userId]) {
        ALSLog(ALLoggerSeverityError, @"Contact not found fetching for user: %@", userId);
        
        [self userDetailServerCall:userId withCompletion:^(ALUserDetail *alUserDetail) {
            [self.contactDBService updateUserDetail:alUserDetail];
            ALContact *alContact = [self.contactDBService loadContactByKey:@"userId" value:userId];
            completion(alContact);
        }];
    } else {
        ALSLog(ALLoggerSeverityInfo, @"Contact is found for user: %@", userId);
        ALContact *alContact = [self.contactDBService loadContactByKey:@"userId" value:userId];
        completion(alContact);
    }
}

#pragma mark - Update user password

- (void)updatePassword:(NSString *)oldPassword
      withNewPassword :(NSString *)newPassword
        withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {
    
    if (!oldPassword || !newPassword) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to update old password or new password is nil"
                                                                                 forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }
    
    [self.userClientService updatePassword:oldPassword withNewPassword:newPassword withCompletion:^(ALAPIResponse *alAPIResponse, NSError *theError) {
        
        if (!theError) {
            if ([alAPIResponse.status isEqualToString:AL_RESPONSE_ERROR]) {
                NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                        userInfo:[NSDictionary dictionaryWithObject:@"ERROR IN UPDATING PASSWORD"
                                                                                             forKey:NSLocalizedDescriptionKey]];
                completion(alAPIResponse, reponseError);
                return;
            }
            [ALUserDefaultsHandler setPassword:newPassword];
        }
        completion(alAPIResponse, theError);
    }];
}

- (void)processResettingUnreadCount {
    ALUserService *userService = [ALUserService new];
    int count = [[userService getTotalUnreadCount] intValue];
    if (count == 0) {
        [userService resettingUnreadCountWithCompletion:^(NSString *json, NSError *error) {
        }];
    }
}

#pragma mark - User or Contact search

- (void)getListOfUsersWithUserName:(NSString *)userName withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {
    
    if (!userName) {
        NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                userInfo:[NSDictionary dictionaryWithObject:@"Error userName is nil " forKey:NSLocalizedDescriptionKey]];
        completion(nil, reponseError);
        return;
    }
    
    [self.userClientService getListOfUsersWithUserName:userName withCompletion:^(ALAPIResponse *response, NSError *error) {
        
        if (error) {
            completion(response, error);
            return;
        }
        if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
            
            NSMutableArray *userDetailArray = (NSMutableArray*)response.response;
            for (NSDictionary *userDeatils in userDetailArray) {
                ALUserDetail *userDeatil = [[ALUserDetail alloc] initWithDictonary:userDeatils];
                userDeatil.unreadCount = 0;
                [self.contactDBService updateUserDetail:userDeatil];
            }
            completion(response, error);
            return;
        }
        NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                userInfo:[NSDictionary dictionaryWithObject:@"Failed to fetch users due to api error occurred" forKey:NSLocalizedDescriptionKey]];
        
        completion(nil, reponseError);
    }];
}

- (void)updateConversationReadWithUserId:(NSString *)userId withDelegate:(id<ApplozicUpdatesDelegate>)delegate {
    
    [self setUnreadCountZeroForContactId:userId];
    if (delegate) {
        [delegate conversationReadByCurrentUser:userId withGroupId:nil];
    }
    NSDictionary *dict = @{@"userId":userId};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Update_unread_count" object:dict];
}

#pragma mark - Muted user list.

- (void)getMutedUserListWithDelegate:(id<ApplozicUpdatesDelegate>)delegate
                      withCompletion:(void (^)(NSMutableArray *, NSError *))completion {
    
    [self.userClientService getMutedUserListWithCompletion:^(id theJson, NSError *error) {
        
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSArray *jsonArray = [NSArray arrayWithArray:(NSArray *)theJson];
        NSMutableArray *userDetailArray = [NSMutableArray new];
        
        if (jsonArray.count) {
            NSDictionary *jsonDictionary = (NSDictionary *)theJson;
            userDetailArray = [self.contactDBService addMuteUserDetailsWithDelegate:delegate withNSDictionary:jsonDictionary];
        }
        completion(userDetailArray, error);
    }];
}

#pragma mark - Mute or Unmute user.

- (void)muteUser:(ALMuteRequest *)alMuteRequest
  withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {
    
    if (!alMuteRequest) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to mute user ALMuteRequest is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }
    
    
    if (!alMuteRequest.userId || !alMuteRequest.notificationAfterTime) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to mute user where userId or notificationAfterTime is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }
    
    
    [self.userClientService muteUser:alMuteRequest withCompletion:^(ALAPIResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if (response && [response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
            [self.contactService updateMuteAfterTime:alMuteRequest.notificationAfterTime andUserId:alMuteRequest.userId];
            completion(response, error);
            return;
        }
        
        NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                userInfo:[NSDictionary dictionaryWithObject:@"Failed to mute user api error occurred" forKey:NSLocalizedDescriptionKey]];
        completion(nil, reponseError);
    }];
}

#pragma mark - Report user for message.

- (void)reportUserWithMessageKey:(NSString *)messageKey
                  withCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {
    
    if (!messageKey) {
        NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                userInfo:[NSDictionary dictionaryWithObject:@"Failed to report message the key is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, reponseError);
        return;
    }
    
    [self.userClientService reportUserWithMessageKey:messageKey withCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
        completion(apiResponse, error);
    }];
}

- (void)disableChat:(BOOL)disable withCompletion:(void (^)(BOOL, NSError *))completion {
    ALContact *alContact = [self.contactDBService loadContactByKey:@"userId" value:[ALUserDefaultsHandler getUserId]];
    if (!alContact) {
        ALSLog(ALLoggerSeverityError, @"Contact details of logged-in user not present");
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"Contact not present" forKey:NSLocalizedDescriptionKey]];
        completion(NO, error);
        return;
    }
    NSMutableDictionary *metadata;
    if (alContact != nil && alContact.metadata != nil) {
        metadata = alContact.metadata;
    } else {
        metadata = [[NSMutableDictionary alloc] init];
    }
    [metadata setObject:[NSNumber numberWithBool:disable] forKey: AL_DISABLE_USER_CHAT];
    ALUser *user = [[ALUser alloc] init];
    [user setMetadata: metadata];
    [self.userClientService updateUserDisplayName:nil andUserImageLink:nil userStatus:nil metadata:metadata withCompletion:^(id theJson, NSError *error) {
        if (!error) {
            [self.contactDBService updateContactInDatabase: alContact];
            [ALUserDefaultsHandler disableChat: disable];
            completion(YES, nil);
        } else {
            ALSLog(ALLoggerSeverityError, @"Error while disabling chat for user");
            completion(NO, error);
        }
    }];
}

#pragma mark - Registered users/contacts in Application

- (void)getListOfRegisteredContactsWithNextPage:(BOOL)nextPage
                                 withCompletion:(void(^)(NSMutableArray *contactArray, NSError *error))completion {
    
    if (![ALUserDefaultsHandler isLoggedIn]) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"User is not logged in" forKey:NSLocalizedDescriptionKey]];
        completion(nil, error);
        return;
    }
    NSUInteger pageSize = (NSUInteger)CONTACT_PAGE_SIZE;
    NSNumber *startTime;
    if (nextPage) {
        startTime = [ALApplozicSettings getStartTime];
    } else {
        startTime = 0;
    }
    [self.userClientService getListOfRegisteredUsers:startTime
                                         andPageSize:pageSize
                                      withCompletion:^(ALContactsResponse *response, NSError *error) {
        
        if (error) {
            completion(nil, error);
            return;
        }
        
        [ALApplozicSettings setStartTime:response.lastFetchTime];
        NSMutableArray *nextPageContactArray = [self.contactDBService updateFilteredContacts:response
                                                                             withLoadContact:nextPage];
        if (nextPage) {
            completion(nextPageContactArray, nil);
        } else {
            NSMutableArray *contcatArray = [self.contactDBService getAllContactsFromDB];
            completion(contcatArray, error);
        }
    }];
}

@end
