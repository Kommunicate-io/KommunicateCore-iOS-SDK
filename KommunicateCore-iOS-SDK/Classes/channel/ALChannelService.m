//
//  ALChannelService.m
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChannelService.h"
#import "ALMessageClientService.h"
#import "ALConversationService.h"
#import "ALChannelUser.h"
#import "ALMuteRequest.h"
#import "ALAPIResponse.h"
#import "ALContactService.h"
#import "ALRealTimeUpdate.h"
#import "ALLogger.h"
#import "ALChannelCreateResponse.h"

@implementation ALChannelService

static int const AL_CHANNEL_MEMBER_BATCH_SIZE = 100;
NSString *const AL_CHANNEL_MEMBER_SAVE_STATUS = @"AL_CHANNEL_MEMBER_SAVE_STATUS";
NSString *const AL_Updated_Group_Members = @"Updated_Group_Members";
NSString *const AL_MESSAGE_LIST = @"AL_MESSAGE_LIST";
NSString *const AL_MESSAGE_SYNC = @"AL_MESSAGE_SYNC";
NSString *const AL_CHANNEL_MEMBER_CALL_COMPLETED = @"AL_CHANNEL_MEMBER_CALL_COMPLETED";

dispatch_queue_t channelUserbackgroundQueue;

+ (ALChannelService *)sharedInstance {
    static ALChannelService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALChannelService alloc] init];
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
    self.channelClientService = [[ALChannelClientService alloc] init];
    self.channelDBService = [[ALChannelDBService alloc] init];
}

- (void)callForChannelServiceForDBInsertion:(NSString *)theJson {
    ALChannelFeed *alChannelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];
    [self.channelDBService insertChannel:alChannelFeed.channelFeedsList];

    //callForChannelProxy inserting in DB...
    ALConversationService *alConversationService = [[ALConversationService alloc] init];
    [alConversationService addConversations:alChannelFeed.conversationProxyList];

    [self saveChannelUsersAndChannelDetails:alChannelFeed.channelFeedsList calledFromMessageList:YES];
}

- (void)processChildGroups:(ALChannel *)alChannel {
    //Get INFO of Child
    for (NSNumber *channelKey in alChannel.childKeys) {
        [self getChannelInformation:channelKey orClientChannelKey:nil withCompletion:^(ALChannel *alChannel3) {
            
        }];
    }
}

- (ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey{
    return [self.channelDBService loadChannelUserX:channelKey];
}

#pragma mark - Channel information

- (void)getChannelInformation:(NSNumber *)channelKey
           orClientChannelKey:(NSString *)clientChannelKey
               withCompletion:(void (^)(ALChannel *alChannel3)) completion {

    if (!channelKey
        && !clientChannelKey) {
        completion(nil);
        return;
    }

    ALChannel *alChannel1;
    if (clientChannelKey) {
        alChannel1 = [self fetchChannelWithClientChannelKey:clientChannelKey];
    } else {
        alChannel1 = [self getChannelByKey:channelKey];
    }
    
    if (alChannel1) {
        completion(alChannel1);
    } else {
        [self.channelClientService getChannelInfo:channelKey orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALChannel *channel) {
            
            if (!error) {
                [self createChannelEntry:channel fromMessageList:NO];
            }
            completion(channel);
        }];
    }
}

#pragma mark - Conversation Closed

+ (BOOL)isConversationClosed:(NSNumber *)groupId {
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    return [channelDBService isConversaionClosed:groupId];
}

#pragma mark - Channel Deleted

+ (BOOL)isChannelDeleted:(NSNumber *)groupId {
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    BOOL flag = [channelDBService isChannelDeleted:groupId];
    return flag;
}

#pragma mark - Channel Muted

+ (BOOL)isChannelMuted:(NSNumber *)groupId {
    ALChannelService *channelService = [[ALChannelService alloc] init];
    ALChannel *channel = [channelService getChannelByKey:groupId];
    return [channel isNotificationMuted];
}

#pragma mark - Login User left channel

- (BOOL)isChannelLeft:(NSNumber *)groupID {
    BOOL flag = [self.channelDBService isChannelLeft:groupID];
    return flag;
}

#pragma mark - Get channel by channelkey from Database

- (ALChannel *)getChannelByKey:(NSNumber *)channelKey {
    ALChannel *channel = [self.channelDBService loadChannelByKey:channelKey];
    return channel;
}

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)channelKey {
    return [self.channelDBService getListOfAllUsersInChannel:channelKey];
}

- (NSString *)userNamesWithCommaSeparatedForChannelkey:(NSNumber *)key {
    return [self.channelDBService userNamesWithCommaSeparatedForChannelkey: key];
}

- (NSNumber *)getOverallUnreadCountForChannel {
    return [self.channelDBService getOverallUnreadCountForChannelFromDB];
}

#pragma mark - Get channel by client channelkey from Database

- (ALChannel *)fetchChannelWithClientChannelKey:(NSString *)clientChannelKey {
    ALChannel *channel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
    return channel;
}

- (BOOL)isLoginUserInChannel:(NSNumber *)channelKey {
    NSMutableArray *memberList = [NSMutableArray arrayWithArray:[self getListOfAllUsersInChannel:channelKey]];
    return ([memberList containsObject:[ALUserDefaultsHandler getUserId]]);
}

#pragma mark - Get list of channels from Database

- (NSMutableArray *)getAllChannelList {
    return [self.channelDBService getAllChannelKeyAndName];
}

- (void)closeGroupConverstion:(NSNumber *)groupId withCompletion:(void(^)(NSError *error))completion {

    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    [metadata setObject:@"CLOSE" forKey:AL_CHANNEL_CONVERSATION_STATUS];
    
    ALChannelService *channelService = [ALChannelService new];
    [channelService updateChannel:groupId
                       andNewName:nil
                      andImageURL:nil
               orClientChannelKey:nil
               isUpdatingMetaData:YES
                         metadata:metadata
                      orChildKeys:nil
                   orChannelUsers:nil
                   withCompletion:^(NSError *error) {
        completion(error);
    }];
}

#pragma mark - Parent and sub groups method

- (NSMutableArray *)fetchChildChannelsWithParentKey:(NSNumber *)parentGroupKey {
    return [self.channelDBService fetchChildChannels:parentGroupKey];
}

- (void)addChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey withCompletion:(void(^)(id json, NSError *error))completion {
    ALSLog(ALLoggerSeverityInfo, @"ADD_CHILD :: PARENT_KEY : %@ && CHILD_KEYs : %@",parentKey,childKeyList.description);
    if (parentKey != nil) {
        __weak typeof(self) weakSelf = self;
        [self.channelClientService addChildKeyList:childKeyList andParentKey:parentKey withCompletion:^(id json, NSError *error) {
            
            if (!error) {
                for (NSNumber *childKey in childKeyList) {
                    [weakSelf.channelDBService updateChannelParentKey:childKey andWithParentKey:parentKey isAdding:YES];
                }
            }
            completion(json, error);
        }];
    }
}

- (void)removeChildKeyList:(NSMutableArray *)childKeyList
              andParentKey:(NSNumber *)parentKey
            withCompletion:(void(^)(id json, NSError *error))completion {
    ALSLog(ALLoggerSeverityInfo, @"REMOVE_CHILD :: PARENT_KEY : %@ && CHILD_KEYs : %@",parentKey,childKeyList.description);
    if (parentKey != nil) {
        [self.channelClientService removeChildKeyList:childKeyList andParentKey:parentKey withCompletion:^(id json, NSError *error) {
            
            if (!error) {
                for (NSNumber *childKey in childKeyList) {
                    [self.channelDBService updateChannelParentKey:childKey andWithParentKey:parentKey isAdding:NO];
                }
            }
            completion(json, error);
            
        }];
    }
}

#pragma mark - Add/Remove via Client keys

- (void)addClientChildKeyList:(NSMutableArray *)clientChildKeyList
                 andParentKey:(NSString *)clientParentKey
               withCompletion:(void(^)(id json, NSError *error))completion {
    ALSLog(ALLoggerSeverityInfo, @"ADD_CHILD :: PARENT_KEY : %@ && CHILD_KEYs (VIA_CLIENT) : %@",clientParentKey,clientChildKeyList.description);
    if (clientParentKey) {
        __weak typeof(self) weakSelf = self;
        [self.channelClientService addClientChildKeyList:clientChildKeyList andClientParentKey:clientParentKey withCompletion:^(id json, NSError *error) {
            
            if (!error) {
                for (NSString *childKey in clientChildKeyList) {
                    [weakSelf.channelDBService updateClientChannelParentKey:childKey andWithClientParentKey:clientParentKey isAdding:YES];
                }
            }
            completion(json, error);
            
        }];
    }
}

- (void)removeClientChildKeyList:(NSMutableArray *)clientChildKeyList
                    andParentKey:(NSString *)clientParentKey
                  withCompletion:(void(^)(id json, NSError *error))completion {
    ALSLog(ALLoggerSeverityInfo, @"REMOVE_CHILD :: PARENT_KEY : %@ && CHILD_KEYs (VIA_CLIENT) : %@",clientParentKey,clientChildKeyList.description);
    if (clientParentKey) {
        [self.channelClientService removeClientChildKeyList:clientChildKeyList andClientParentKey:clientParentKey withCompletion:^(id json, NSError *error) {
            
            if (!error) {
                for (NSString *childKey in clientChildKeyList) {
                    [self.channelDBService updateClientChannelParentKey:childKey andWithClientParentKey:clientParentKey isAdding:NO];
                }
            }
            completion(json, error);
            
        }];
    }
}


- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    
    /* GROUP META DATA DICTIONARY
     
     NSMutableDictionary *metaData = [self getChannelMetaData];
     
     NOTE : IF GROUP META DATA REQUIRE THEN REPLACE nil BY metaData
     */
    
    [self createChannel:channelName orClientChannelKey:clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:PUBLIC
            andMetaData:nil withCompletion:^(ALChannel *alChannel, NSError *error) {

        completion(alChannel, error);
    }];
}

- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    
    [self createChannel:channelName orClientChannelKey:clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:type andMetaData:metaData adminUser:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
        completion(alChannel, error);
    }];
}


- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    if (channelName != nil) {
        [self createChannel:channelName orClientChannelKey:clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:type andMetaData:metaData adminUser:adminUserId withGroupUsers:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
            completion(alChannel, error);
        }];
    } else {
        ALSLog(ALLoggerSeverityError, @"ERROR : CHANNEL NAME MISSING");
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Channel name is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, failError);
    }
}


- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withGroupUsers:(NSMutableArray *)groupRoleUsers
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    if (channelName != nil) {
        [self.channelClientService createChannel:channelName andParentChannelKey:nil orClientChannelKey:(NSString *)clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:(short)type
                                     andMetaData:metaData adminUser:adminUserId withGroupUsers:groupRoleUsers withCompletion:^(NSError *error, ALChannelCreateResponse *response) {

            if (!error) {
                response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
                [self createChannelEntry:response.alChannel fromMessageList:NO];
                completion(response.alChannel, error);
            } else {
                ALSLog(ALLoggerSeverityError, @"ERROR_IN_CHANNEL_CREATING :: %@",error);
                completion(nil, error);
            }
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Channel name is nil" forKey:NSLocalizedDescriptionKey]];
        ALSLog(ALLoggerSeverityError, @"ERROR : CHANNEL NAME MISSING");
        completion(nil, failError);
    }
}


#pragma mark - Create Broadcast Channel

- (void)createBroadcastChannelWithMembersList:(NSMutableArray *)memberArray
                                  andMetaData:(NSMutableDictionary *)metaData
                               withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    
    if (memberArray.count) {
        NSMutableArray *nameArray = [NSMutableArray new];
        ALContactService *contactService = [ALContactService new];
        
        for (NSString *userId in memberArray) {
            ALContact *alContact = [contactService loadContactByKey:@"userId" value:userId];
            [nameArray addObject:[alContact getDisplayName]];
        }
        NSString *broadcastName = @"";
        if (nameArray.count > 10) {
            NSArray *subArray = [nameArray subarrayWithRange:NSMakeRange(0, 10)];
            broadcastName = [subArray componentsJoinedByString:@","];
        } else {
            broadcastName = [nameArray componentsJoinedByString:@","];
        }

        ALChannelInfo *channelInfo = [[ALChannelInfo alloc] init];
        channelInfo.groupName = broadcastName;
        channelInfo.groupMemberList = memberArray;
        channelInfo.type = BROADCAST;
        channelInfo.metadata = metaData;

        [self createChannelWithChannelInfo:channelInfo
                            withCompletion:^(ALChannelCreateResponse *response, NSError *error) {
            if (error) {
                completion(nil, error);
                return;
            }

            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                completion(response.alChannel, nil);
            } else {
                NSError *failError = [NSError errorWithDomain:@"Applozic" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Failed to report message api error occurred." forKey:NSLocalizedDescriptionKey]];
                completion(nil, failError);
            }
        }];
    } else {
        ALSLog(ALLoggerSeverityError, @"EMPTY_BROADCAST_MEMBER_LIST");
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Empty member list is passed in broadcast." forKey:NSLocalizedDescriptionKey]];
        completion(nil, failError);
    }
}

- (NSMutableDictionary *)getChannelMetaData {
    NSMutableDictionary *groupMetaData = [NSMutableDictionary new];
    
    [groupMetaData setObject:@":adminName created group" forKey:AL_CREATE_GROUP_MESSAGE];
    [groupMetaData setObject:@":userName removed" forKey:AL_REMOVE_MEMBER_MESSAGE];
    [groupMetaData setObject:@":userName added" forKey:AL_ADD_MEMBER_MESSAGE];
    [groupMetaData setObject:@":userName joined" forKey:AL_JOIN_MEMBER_MESSAGE];
    [groupMetaData setObject:@"Group renamed to :groupName" forKey:AL_GROUP_NAME_CHANGE_MESSAGE];
    [groupMetaData setObject:@":groupName icon changed" forKey:AL_GROUP_ICON_CHANGE_MESSAGE];
    [groupMetaData setObject:@":userName left" forKey:AL_GROUP_LEFT_MESSAGE];
    [groupMetaData setObject:@":groupName deleted" forKey:AL_DELETED_GROUP_MESSAGE];
    [groupMetaData setObject:@(NO) forKey:@"HIDE"];
    
    return groupMetaData;
}

- (void)createChannel:(NSString *)channelName
  andParentChannelKey:(NSNumber *)parentChannelKey
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    
    [self createChannel:channelName andParentChannelKey:parentChannelKey orClientChannelKey:clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:type andMetaData:metaData adminUser:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
        
        completion(alChannel, error);
    }];
    
}


- (void)createChannel:(NSString *)channelName
  andParentChannelKey:(NSNumber *)parentChannelKey
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion {
    if (channelName != nil) {
        [self.channelClientService createChannel:channelName andParentChannelKey:parentChannelKey orClientChannelKey:clientChannelKey
                                  andMembersList:memberArray andImageLink:imageLink channelType:(short)type
                                     andMetaData:metaData adminUser:adminUserId withCompletion:^(NSError *error, ALChannelCreateResponse *response) {

            if (!error) {
                response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
                [self createChannelEntry:response.alChannel fromMessageList:NO];
                completion(response.alChannel, error);
            } else {
                ALSLog(ALLoggerSeverityError, @"ERROR_IN_CHANNEL_CREATING :: %@",error);
                completion(nil, error);
            }
        }];
    } else {
        ALSLog(ALLoggerSeverityError, @"ERROR : CHANNEL NAME MISSING");
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or userId is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, failError);
        return;
    }
}

#pragma mark - Add a new memeber to Channel

- (void)addMemberToChannel:(NSString *)userId
             andChannelKey:(NSNumber *)channelKey
        orClientChannelKey:(NSString *)clientChannelKey
            withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    if ((channelKey != nil || clientChannelKey != nil) && userId != nil) {
        __weak typeof(self) weakSelf = self;
        [self.channelClientService addMemberToChannel:userId orClientChannelKey:clientChannelKey
                                        andChannelKey:channelKey withCompletion:^(NSError *error, ALAPIResponse *response) {

            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                if (clientChannelKey != nil) {
                    ALChannel *alChannel = [weakSelf.channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [weakSelf.channelDBService addMemberToChannel:userId andChannelKey:alChannel.key];
                } else {
                    [weakSelf.channelDBService addMemberToChannel:userId andChannelKey:channelKey];
                }
            }
            completion(error,response);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or userId is nil while adding a member." forKey:NSLocalizedDescriptionKey]];
        completion(failError, nil);
    }
}

#pragma mark - Remove memeber from Channel

- (void)removeMemberFromChannel:(NSString *)userId
                  andChannelKey:(NSNumber *)channelKey
             orClientChannelKey:(NSString *)clientChannelKey
                 withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    if ((channelKey != nil || clientChannelKey != nil) && userId != nil) {
        [self.channelClientService removeMemberFromChannel:userId orClientChannelKey:clientChannelKey
                                             andChannelKey:channelKey withCompletion:^(NSError *error, ALAPIResponse *response) {

            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                if (clientChannelKey != nil) {
                    ALChannel *alChannel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [self.channelDBService removeMemberFromChannel:userId andChannelKey:alChannel.key];
                } else {
                    [self.channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                }
            }
            completion(error,response);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or userId is nil while removing a member from channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError, nil);
    }
}

#pragma mark - Delete Channel by admin of Channel

- (void)deleteChannel:(NSNumber *)channelKey
   orClientChannelKey:(NSString *)clientChannelKey
       withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    if (channelKey != nil || clientChannelKey != nil) {
        [self.channelClientService deleteChannel:channelKey orClientChannelKey:clientChannelKey
                                  withCompletion:^(NSError *error, ALAPIResponse *response) {

            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                if (clientChannelKey != nil) {
                    ALChannel *alChannel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [self.channelDBService deleteChannel:alChannel.key];
                } else {
                    [self.channelDBService deleteChannel:channelKey];
                }
            }
            completion(error, response);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key and clientChannelKey is nil while deleting channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError, nil);
    }
}

- (BOOL)checkAdmin:(NSNumber *)channelKey {
    ALChannel *channel = [self.channelDBService loadChannelByKey:channelKey];
    
    return [channel.adminKey isEqualToString:[ALUserDefaultsHandler getUserId]];
}

#pragma mark - Leave Channel

- (void)leaveChannel:(NSNumber *)channelKey
           andUserId:(NSString *)userId
  orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion {
    if ((channelKey != nil || clientChannelKey != nil) && userId != nil) {
        [self.channelClientService leaveChannel:channelKey orClientChannelKey:clientChannelKey
                                     withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            [self proccessLeaveResponse:channelKey andUserId:userId orClientChannelKey:clientChannelKey withResponse:response withError:error];
            completion(error);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or userId is nil while leaving Channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError);
    }
}

- (void)proccessLeaveResponse:(NSNumber *)channelKey
                    andUserId:(NSString *)userId
           orClientChannelKey:(NSString *)clientChannelKey
                 withResponse:(ALAPIResponse *) response
                    withError:(NSError*)error {
    
    if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
        if (clientChannelKey != nil) {
            ALChannel *alChannel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
            [self.channelDBService removeMemberFromChannel:userId andChannelKey:alChannel.key];
            [self.channelDBService setLeaveFlag:YES forChannel:alChannel.key];
        } else {
            [self.channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
            [self.channelDBService setLeaveFlag:YES forChannel:channelKey];
        }
        
    }
}

#pragma mark - Leave Channel with response

- (void)leaveChannelWithChannelKey:(NSNumber *)channelKey
                         andUserId:(NSString *)userId
                orClientChannelKey:(NSString *)clientChannelKey
                    withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    if ((channelKey != nil || clientChannelKey != nil) && userId != nil) {
        [self.channelClientService leaveChannel:channelKey orClientChannelKey:clientChannelKey
                                     withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            [self proccessLeaveResponse:channelKey andUserId:userId orClientChannelKey:clientChannelKey withResponse:response withError:error];
            completion(error,response);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or userId is nil while leaving Channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError, nil);
    }
}

#pragma mark - Add multiple users in Channels

- (void)addMultipleUsersToChannel:(NSMutableArray *)channelKeys
                     channelUsers:(NSMutableArray *)channelUsers
                    andCompletion:(void(^)(NSError *error))completion {
    if (channelKeys != nil && channelUsers != nil) {
        __weak typeof(self) weakSelf = self;
        [self.channelClientService addMultipleUsersToChannel:channelKeys channelUsers:channelUsers andCompletion:^(NSError *error, ALAPIResponse *response) {
            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                for (int i=0;i<[channelUsers count];i++) {
                    [weakSelf.channelDBService addMemberToChannel:channelUsers[i] andChannelKey:channelKeys.firstObject];
                }
            }
            completion(error);
        }];
    }
}

#pragma mark - Update Channel

- (void)updateChannel:(NSNumber *)channelKey
           andNewName:(NSString *)newName
          andImageURL:(NSString *)imageURL
   orClientChannelKey:(NSString *)clientChannelKey
   isUpdatingMetaData:(BOOL)flag
             metadata:(NSMutableDictionary *)metaData
          orChildKeys:(NSMutableArray *)childKeysList
       orChannelUsers:(NSMutableArray *)channelUsers
       withCompletion:(void(^)(NSError *error))completion {
    if (channelKey != nil || clientChannelKey != nil) {
        [self.channelClientService updateChannel:channelKey orClientChannelKey:clientChannelKey andNewName:newName andImageURL:imageURL metadata:metaData orChildKeys:childKeysList  orChannelUsers:(NSMutableArray *)channelUsers andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            [self proccessUpdateChannelResponse:channelKey andNewName:newName andImageURL:imageURL orClientChannelKey:clientChannelKey isUpdatingMetaData:flag metadata:metaData orChildKeys:childKeysList orChannelUsers:channelUsers withResponse:response];
            completion(error);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or clientChannelKey is nil while updating channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError);
    }
}

#pragma mark - Update Channel with response

- (void)updateChannelWithChannelKey:(NSNumber *)channelKey
                         andNewName:(NSString *)newName
                        andImageURL:(NSString *)imageURL
                 orClientChannelKey:(NSString *)clientChannelKey
                 isUpdatingMetaData:(BOOL)flag
                           metadata:(NSMutableDictionary *)metaData
                        orChildKeys:(NSMutableArray *)childKeysList
                     orChannelUsers:(NSMutableArray *)channelUsers
                     withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion {
    if (channelKey != nil || clientChannelKey != nil) {
        [self.channelClientService updateChannel:channelKey orClientChannelKey:clientChannelKey andNewName:newName andImageURL:imageURL metadata:metaData orChildKeys:childKeysList  orChannelUsers:(NSMutableArray *)channelUsers andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            [self proccessUpdateChannelResponse:channelKey andNewName:newName andImageURL:imageURL orClientChannelKey:clientChannelKey isUpdatingMetaData:flag metadata:metaData orChildKeys:childKeysList orChannelUsers:channelUsers withResponse:response];
            completion(error,response);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel key or clientChannelKey is nil while updating channel." forKey:NSLocalizedDescriptionKey]];
        completion(failError, nil);
    }
}

- (void)proccessUpdateChannelResponse:(NSNumber *)channelKey
                           andNewName:(NSString *)newName
                          andImageURL:(NSString *)imageURL
                   orClientChannelKey:(NSString *)clientChannelKey
                   isUpdatingMetaData:(BOOL)flag
                             metadata:(NSMutableDictionary *)metaData
                          orChildKeys:(NSMutableArray *)childKeysList
                       orChannelUsers:(NSMutableArray *)channelUsers
                        withResponse :(ALAPIResponse *) response {
    
    if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
        if (clientChannelKey != nil) {
            ALChannel *alChannel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
            [self.channelDBService updateChannel:alChannel.key andNewName:newName orImageURL:imageURL orChildKeys:childKeysList isUpdatingMetaData:flag orChannelUsers:channelUsers];
        } else {
            ALChannel *alChannel = [self.channelDBService loadChannelByKey:channelKey];
            [self.channelDBService updateChannel:alChannel.key andNewName:newName orImageURL:imageURL orChildKeys:childKeysList isUpdatingMetaData:flag orChannelUsers:channelUsers];
        }
        
    }
}

#pragma mark - Update Channel metadata

- (void)updateChannelMetaData:(NSNumber *)channelKey
           orClientChannelKey:(NSString *)clientChannelKey
                     metadata:(NSMutableDictionary *)metaData
               withCompletion:(void(^)(NSError *error))completion {
    
    if (channelKey != nil || clientChannelKey != nil) {
        [self.channelClientService updateChannelMetaData:channelKey orClientChannelKey:clientChannelKey metadata:metaData andCompletion:^(NSError *error, ALAPIResponse *response) {
            if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                if (clientChannelKey != nil) {
                    ALChannel *alChannel = [self.channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [self.channelDBService updateChannelMetaData:alChannel.key metaData:metaData];
                } else if (channelKey != nil) {
                    [self.channelDBService updateChannelMetaData:channelKey metaData:metaData];
                }
            }
            completion(error);
        }];
    } else {
        NSError *failError = [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Parameter channel or client key or meta data is nil" forKey:NSLocalizedDescriptionKey]];
        completion(failError);
    }
}

#pragma mark - Channel Sync

- (void)syncCallForChannel {
    [self syncCallForChannelWithDelegate:nil];
}

- (void)syncCallForChannelWithDelegate:(id<ApplozicUpdatesDelegate>)delegate {

    NSNumber *updateAtTime = [ALUserDefaultsHandler getLastSyncChannelTime];

    [self.channelClientService syncCallForChannel:updateAtTime withFetchUserDetails:YES andCompletion:^(NSError *error, ALChannelSyncResponse *response) {
        if (!error) {
            [ALUserDefaultsHandler setLastSyncChannelTime:response.generatedAt];
            [self createChannelsAndUpdateInfo:response.alChannelArray withDelegate:delegate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_CHANNEL_NAME" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_CHANNEL_METADATA" object:nil];
        }
    }];

}

#pragma mark - Mark conversation as read

- (void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion {

    if (!channelKey) {
        NSError *error = [NSError
                          errorWithDomain:@"Applozic"
                          code:1
                          userInfo:[NSDictionary dictionaryWithObject:@"Failed to mark conversation read the channelKey is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, error);
        return;
    }

    [self setUnreadCountZeroForGroupID:channelKey];
    
    NSUInteger count = [self.channelDBService markConversationAsRead:channelKey];
    ALSLog(ALLoggerSeverityInfo, @"Found %ld messages for marking as read.", (unsigned long)count);
    
    if (count == 0) {
        return;
    }
    
    [self.channelClientService markConversationAsRead:channelKey withCompletion:^(NSString *response, NSError *error) {
        completion(response,error);
    }];
    
}

- (void)setUnreadCountZeroForGroupID:(NSNumber *)channelKey {
    [self.channelDBService updateUnreadCountChannel:channelKey unreadCount:[NSNumber numberWithInt:0]];
    
    ALChannel *channel = [self.channelDBService loadChannelByKey:channelKey];
    channel.unreadCount = [NSNumber numberWithInt:0];
}

#pragma mark - Mute/Unmute Channel

- (void)muteChannel:(ALMuteRequest *)muteRequest withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    if (!muteRequest) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to mute channel ALMuteRequest is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }

    if (!muteRequest.notificationAfterTime) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic" code:1
                                            userInfo:[NSDictionary dictionaryWithObject:@"Failed to mute channel where notificationAfterTime is nil" forKey:NSLocalizedDescriptionKey]];
        completion(nil, nilError);
        return;
    }

    [self.channelClientService muteChannel:muteRequest withCompletion:^(ALAPIResponse *response, NSError *error) {
        if ([response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
            [self.channelDBService updateMuteAfterTime:muteRequest.notificationAfterTime andChnnelKey:muteRequest.id];
        }
        completion(response, error);
    }];
}

- (void)updateMuteAfterTime:(NSNumber *)notificationAfterTime
               andChnnelKey:(NSNumber *)channelKey {
    [self.channelDBService updateMuteAfterTime:notificationAfterTime andChnnelKey:channelKey];
}

- (void)getChannelInfoByIdsOrClientIds:(NSMutableArray *)channelIds
                    orClinetChannelIds:(NSMutableArray *) clientChannelIds
                        withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion {

    [self.channelClientService getChannelInfoByIdsOrClientIds:channelIds orClinetChannelIds:clientChannelIds
                                               withCompletion:^(NSMutableArray *channelInfoList, NSError *error) {

        for (ALChannel *channel in channelInfoList) {
            [self createChannelEntry:channel fromMessageList:NO];
        }
        completion(channelInfoList,error);
    }];
    
}

#pragma mark - List of Channel with category
- (void)getChannelListForCategory:(NSString *)category
                   withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion {

    if (!category) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Category is nil while fetching list channels under category"}];

        completion(nil, nilError);
        return;
    }

    [self.channelClientService getChannelListForCategory:category withCompletion:^(NSMutableArray *channelInfoList, NSError *error) {

        for (ALChannel *channel in channelInfoList) {
            [self createChannelEntry:channel fromMessageList:NO];
        }
        completion(channelInfoList,error);
    }];
}

#pragma mark - List of Channels in Application

- (void)getAllChannelsForApplications:(NSNumber *)endTime withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion {

    [self.channelClientService getAllChannelsForApplications:endTime withCompletion:^(NSMutableArray *channelInfoList, NSError *error) {
        
        for (ALChannel *channel in channelInfoList) {
            [self createChannelEntry:channel fromMessageList:NO];
        }
        completion(channelInfoList,error);
    }];
}

#pragma mark - Add member to contacts group with type

- (void)addMemberToContactGroupOfType:(NSString *)contactsGroupId
                          withMembers: (NSMutableArray *)membersArray
                        withGroupType:(short) groupType
                       withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    if (!contactsGroupId) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Contacts GroupId is nil while adding a member to contacts group"}];

        completion(nil, nilError);
        return;
    }

    [self.channelClientService addMemberToContactGroupOfType:contactsGroupId withMembers:membersArray withGroupType:groupType withCompletion:^(ALAPIResponse *response, NSError *error) {
        
        completion(response, error);
        
    }];
}

#pragma mark - Add member to contacts group

- (void)addMemberToContactGroup:(NSString *)contactsGroupId
                    withMembers:(NSMutableArray *)membersArray
                 withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    if (!contactsGroupId) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Contacts GroupId is nil while adding a member to contacts group"}];

        completion(nil, nilError);
        return;
    }

    [self.channelClientService addMemberToContactGroup:contactsGroupId
                                           withMembers:membersArray
                                        withCompletion:^(ALAPIResponse *response, NSError *error) {
        completion(response, error);
    }];
}

#pragma mark - Get members From contacts group with type

- (void)getMembersFromContactGroupOfType:(NSString *)contactsGroupId
                           withGroupType:(short)groupType
                          withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion {


    if (!contactsGroupId) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Contacts GroupId is nil while list fetching a list of memebers from contacts group"}];

        completion(nilError, nil);
        return;
    }
    
    if (contactsGroupId) {
        [self.channelClientService getMembersFromContactGroupOfType:contactsGroupId withGroupType:groupType withCompletion:^(NSError *error, ALChannel *channel) {
            
            if (!error && channel) {
                ALChannelService *channelService = [[ALChannelService alloc] init];
                [channelService createChannelEntry:channel fromMessageList:NO];
                completion(error, channel);
            } else {
                completion(error, nil);
            }
        }];
    }
}

- (NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName {
    
    if (channelName == nil) {
        return nil;
    }
    return [self.channelDBService getListOfAllUsersInChannelByNameForContactsGroup:channelName];
}

#pragma mark - Remove member From contacts group

- (void)removeMemberFromContactGroup:(NSString *)contactsGroupId
                          withUserId:(NSString *)userId
                      withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    if (!contactsGroupId || !userId) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Contacts GroupId or userId is nil while removing a memeber from contacts group"}];

        completion(nil, nilError);
        return;
    }

    [self.channelClientService removeMemberFromContactGroup:contactsGroupId withUserId:userId withCompletion:^(ALAPIResponse *response, NSError *error) {
        completion(response, error);
    }];
}

#pragma mark - Remove member From contacts group with type

- (void)removeMemberFromContactGroupOfType:(NSString *)contactsGroupId
                             withGroupType:(short)groupType
                                withUserId:(NSString *)userId
                            withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion {

    if (!contactsGroupId || !userId) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Contacts GroupId or userId is nil while removing a member from contacts group"}];

        completion(nil, nilError);
        return;
    }
    
    [self.channelClientService removeMemberFromContactGroupOfType:contactsGroupId
                                                    withGroupType:groupType
                                                       withUserId:userId
                                                   withCompletion:^(ALAPIResponse *response, NSError *error) {
        
        if (!error
            && response
            && [response.status isEqualToString:AL_RESPONSE_SUCCESS]) {

            DB_CHANNEL *dbChannel = [self.channelDBService getContactsGroupChannelByName:contactsGroupId];
            
            if (dbChannel != nil) {
                [self.channelDBService removeMemberFromChannel:userId andChannelKey:dbChannel.channelKey];
            }
        }
        completion(response, error);
    }];
    
}

#pragma mark - Get members userIds from contacts group

- (void)getMembersIdsForContactGroups:(NSArray *)contactGroupIds
                       withCompletion:(void(^)(NSError *error, NSArray *membersArray)) completion {
    NSMutableArray *memberUserIds = [NSMutableArray new];
    
    if (contactGroupIds) {
        [self.channelClientService getMultipleContactGroup:contactGroupIds withCompletion:^(NSError *error, NSArray *channels) {
            
            if (channels) {
                for (ALChannel *channel in channels) {
                    ALChannelService *channelService = [[ALChannelService alloc] init];
                    [channelService createChannelEntry:channel fromMessageList:NO];
                    [memberUserIds addObjectsFromArray:channel.membersId];
                }
                completion(nil, memberUserIds);
            } else {
                completion(error, nil);
            }
        }];
    }
}

#pragma mark - Channel information with response

- (void)getChannelInformationByResponse:(NSNumber *)channelKey
                     orClientChannelKey:(NSString *)clientChannelKey
                         withCompletion:(void (^)(NSError *error, ALChannel *alChannel3, AlChannelFeedResponse *channelResponse)) completion {

    if (!channelKey
        && !clientChannelKey) {
        NSError *nilError = [NSError errorWithDomain:@"Applozic"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Channel key or client channel key is nil"}];

        completion(nilError, nil, nil);
        return;
    }

    ALChannel *alChannel1;
    if (clientChannelKey) {
        alChannel1 = [self fetchChannelWithClientChannelKey:clientChannelKey];
    } else {
        alChannel1 = [self getChannelByKey:channelKey];
    }
    
    if (alChannel1) {
        completion(nil,alChannel1,nil);
    } else {
        [self.channelClientService getChannelInformationResponse:channelKey orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, AlChannelFeedResponse *response) {
            
            if (!error && [response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                [self createChannelEntry:response.alChannel fromMessageList:NO];
                completion(nil, response.alChannel, nil);
            } else {
                completion(error, nil, response);
            }
        }];
        
    }
}

- (NSDictionary *)metadataToTurnOffActionMessagesNotifications {
    return [self metadataToTurnOffActionMessagesNotificationsAndhideMessages:NO];
}

- (NSDictionary *)metadataToHideActionMessagesAndTurnOffNotifications {
    return [self metadataToTurnOffActionMessagesNotificationsAndhideMessages:YES];
}

- (NSDictionary *)metadataToTurnOffActionMessagesNotificationsAndhideMessages:(BOOL)hideMessages {

    // In case of just turning off the notifications, only 'Alert' key needs to be false and empty string for action messages.

    NSDictionary *basicMetadata = @{@"CREATE_GROUP_MESSAGE":@"",
                                    @"REMOVE_MEMBER_MESSAGE":@"",
                                    @"ADD_MEMBER_MESSAGE":@"",
                                    @"JOIN_MEMBER_MESSAGE":@"",
                                    @"GROUP_NAME_CHANGE_MESSAGE":@"",
                                    @"GROUP_ICON_CHANGE_MESSAGE":@"",
                                    @"GROUP_LEFT_MESSAGE":@"",
                                    @"DELETED_GROUP_MESSAGE":@"",
                                    @"Alert":@"false"
    };
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:basicMetadata];
    if (!hideMessages) {
        return metadata;
    }
    metadata[@"hide"] = @"true";
    return metadata;
}

#pragma mark - Channel Create with response

- (void)createChannelWithChannelInfo:(ALChannelInfo *)channelInfo
                      withCompletion:(void(^)(ALChannelCreateResponse *response, NSError *error))completion {
    
    if (!channelInfo.type) {
        channelInfo.type = PUBLIC;
    }
    
    if (!channelInfo.groupMemberList) {
        NSError *memberError = [NSError errorWithDomain:@"Applozic"
                                                   code:2
                                               userInfo:@{NSLocalizedDescriptionKey:@"Nil in group member list"}];
        
        completion(nil, memberError);
        return;
    }
    
    [self.channelClientService createChannel:channelInfo.groupName
                         andParentChannelKey:nil
                          orClientChannelKey:channelInfo.clientGroupId
                              andMembersList:channelInfo.groupMemberList
                                andImageLink:channelInfo.imageUrl
                                 channelType:channelInfo.type
                                 andMetaData:channelInfo.metadata
                                   adminUser:channelInfo.admin
                              withGroupUsers:channelInfo.groupRoleUsers
                              withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
        if (!error) {
            response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
            [self createChannelEntry:response.alChannel fromMessageList:NO];
            completion(response, error);
        } else {
            ALSLog(ALLoggerSeverityError, @"ERROR_IN_CHANNEL_CREATING :: %@",error);
            completion(nil, error);
        }
    }];
}

- (void)updateConversationReadWithGroupId:(NSNumber *)channelKey withDelegate:(id<ApplozicUpdatesDelegate>)delegate {
    
    [self setUnreadCountZeroForGroupID:channelKey];
    if (delegate) {
        [delegate conversationReadByCurrentUser:nil withGroupId:channelKey];
    }
    NSDictionary *dict = @{@"channelKey":channelKey};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Update_unread_count" object:dict];
}

- (void)createChannelEntry:(ALChannel *)channel fromMessageList:(BOOL)isFromMessageList {
    if (!channel) {
        return;
    }
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    [self.channelDBService createChannelEntity:channel];

    [theDBHandler saveContext];

    NSMutableArray <ALChannel *> *channelFeedArray = [[NSMutableArray alloc] init];
    [channelFeedArray addObject:channel];
    [self saveChannelUsersAndChannelDetails:channelFeedArray  calledFromMessageList:isFromMessageList];
}

- (void)saveChannelUsersAndChannelDetails:(NSMutableArray <ALChannel *>*)channelFeedsList calledFromMessageList:(BOOL)isFromMessageList {

    if (!channelFeedsList.count) {
        return;
    }

    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    dispatch_group_t group = dispatch_group_create();

    for (ALChannel *channel in channelFeedsList) {
        dispatch_group_enter(group);

        if (channel.membersName == nil) {
            channel.membersName = channel.membersId;
        }
        // As running in a background thread it's important to check if the user is loggedIn otherwise it will continue the operation even after logout
        if (!ALUserDefaultsHandler.isLoggedIn) {
            ALSLog(ALLoggerSeverityInfo, @"User is not login returing from channel");
            dispatch_group_leave(group);
            return;
        }

        [self.channelDBService deleteMembers:channel.key];

        NSPersistentContainer *container = theDBHandler.persistentContainer ;

        [container performBackgroundTask:^(NSManagedObjectContext *context) {

            int count = 0;
            __block BOOL isProccessFailed = NO;
            for (ALChannelUser *channelUser in channel.groupUsers) {

                if (isProccessFailed) {
                    ALSLog(ALLoggerSeverityError, @"Save failed will break from the for loop");
                    break;
                }

                ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
                newChannelUserX.key = channel.key;
                if (channelUser.userId != nil) {
                    newChannelUserX.userKey = channelUser.userId;
                }
                if (channelUser.parentGroupKey != nil) {
                    newChannelUserX.parentKey = channelUser.parentGroupKey;
                }
                if (channelUser.role != nil) {
                    newChannelUserX.role = channelUser.role;
                }
                if (ALUserDefaultsHandler.isLoggedIn) {
                    [self.channelDBService createChannelUserXEntity:newChannelUserX  withContext:context];
                } else {
                    // User is not login will break from the inner loop.
                    break;
                }

                count++;
                if (count % AL_CHANNEL_MEMBER_BATCH_SIZE == 0) {
                    [theDBHandler saveWithContext:context completion:^(NSError *error) {

                        if (error) {
                            isProccessFailed = YES;
                        }
                    }];
                }
            }

            [theDBHandler saveWithContext:context completion:^(NSError *error) {
                NSString *operationStatus  = @"Save operation success";
                if (error) {
                    operationStatus = @"Save operation failed";
                }
                [self sendChannelSaveStatusNotification:operationStatus withChannel:channel];
                dispatch_group_leave(group);
            }];

        }];
        [self.channelDBService addedMembersArray:channel.membersName andChannelKey:channel.key];
        [self.channelDBService removedMembersArray:channel.removeMembers andChannelKey:channel.key];
        [self processChildGroups:channel];
    }

    dispatch_group_notify(group, dispatch_get_main_queue() , ^{
        NSDictionary *messageListInfo = isFromMessageList ? @{AL_MESSAGE_LIST: @YES} : @{AL_MESSAGE_SYNC: @YES};
        [[NSNotificationCenter defaultCenter] postNotificationName:AL_CHANNEL_MEMBER_CALL_COMPLETED object:nil userInfo:messageListInfo];
    });
}

- (void)sendChannelSaveStatusNotification:(NSString *)operationStatus withChannel:(ALChannel *)channel {
    [[NSNotificationCenter defaultCenter] postNotificationName:AL_Updated_Group_Members
                                                        object:channel
                                                      userInfo: @{AL_CHANNEL_MEMBER_SAVE_STATUS : operationStatus}];
}
- (void)createChannelsAndUpdateInfo:(NSMutableArray *)channelArray withDelegate:(id<ApplozicUpdatesDelegate>)delegate {

    for (ALChannel *channelObject in channelArray) {
        // Ignore inserting unread count in sync call
        channelObject.unreadCount = 0;
        [self createChannelEntry:channelObject fromMessageList:NO];
        if (delegate) {
            [delegate onChannelUpdated:channelObject];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Update_channel_Info" object:channelObject];
    }
}

#pragma mark - List of Channels where Login user in Channel

- (void)getListOfChannelWithCompletion:(void(^)(NSMutableArray *channelArray, NSError *error))completion {

    [self.channelClientService syncCallForChannel:[ALUserDefaultsHandler getChannelListLastSyncGeneratedTime] withFetchUserDetails:NO andCompletion:^(NSError *error, ALChannelSyncResponse *response) {
        if (error) {
            completion(nil, error);
            return;
        }
        [ALUserDefaultsHandler setChannelListLastSyncGeneratedTime:response.generatedAt];
        [self createChannelsAndUpdateInfo:response.alChannelArray withDelegate:nil];
        NSMutableArray *channelArray = [self getAllChannelList];
        completion(channelArray, nil);
    }];
}

@end
