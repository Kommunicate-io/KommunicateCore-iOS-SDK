//
// ALChannelService.h
// Kommunicate
//
// Created by devashish on 04/01/2016.
// Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChannelFeed.h"
#import "ALChannelDBService.h"
#import "ALChannelClientService.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALChannelSyncResponse.h"
#import "AlChannelFeedResponse.h"
#import "KMCoreRealTimeUpdate.h"
#import "ALChannelInfo.h"
#import "ALChannelClientService.h"

static NSString *const AL_CREATE_GROUP_MESSAGE = @"CREATE_GROUP_MESSAGE";
static NSString *const AL_REMOVE_MEMBER_MESSAGE = @"REMOVE_MEMBER_MESSAGE";
static NSString *const AL_ADD_MEMBER_MESSAGE = @"ADD_MEMBER_MESSAGE";
static NSString *const AL_JOIN_MEMBER_MESSAGE = @"JOIN_MEMBER_MESSAGE";
static NSString *const AL_GROUP_NAME_CHANGE_MESSAGE = @"GROUP_NAME_CHANGE_MESSAGE";
static NSString *const AL_GROUP_ICON_CHANGE_MESSAGE = @"GROUP_ICON_CHANGE_MESSAGE";
static NSString *const AL_GROUP_LEFT_MESSAGE = @"GROUP_LEFT_MESSAGE";
static NSString *const AL_DELETED_GROUP_MESSAGE = @"DELETED_GROUP_MESSAGE";

@interface ALChannelService : NSObject

extern NSString *const AL_CHANNEL_MEMBER_SAVE_STATUS;
extern NSString *const AL_Updated_Group_Members;
extern NSString *const AL_CHANNEL_MEMBER_CALL_COMPLETED;
extern NSString *const AL_MESSAGE_LIST;
extern NSString *const AL_MESSAGE_SYNC;

+ (ALChannelService *)sharedInstance;

@property (nonatomic, strong) ALChannelClientService *channelClientService;

@property (nonatomic, strong) ALChannelDBService *channelDBService;

- (void)callForChannelServiceForDBInsertion:(id)theJson;

/// This method is used to fetch information of a channel like a channel name, imageUrl of a channel, type of channel, and other information.
/// @param channelKey Pass the channelkey or groupId that is required to get the channel information.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion On successful fetch it will have ALChannel object else on an error in fetching it will be nil.
- (void)getChannelInformation:(NSNumber *)channelKey
           orClientChannelKey:(NSString *)clientChannelKey
               withCompletion:(void (^)(ALChannel *alChannel3)) completion;

/// This method is used for fetching the information of the channel from the local database.
/// @param channelKey Pass the channelkey or groupId that is required to get the channel information.
/// @return it returns ALChannel object it has information of a channel.
- (ALChannel *)getChannelByKey:(NSNumber *)channelKey;

/// This method is used to get the list of users userId from a channel by channelKey.
/// @param channelKey Pass the channelkey or groupId that is required to get the channel members userId.
/// @return it returns NSMutableArray has users who are in the channel.
- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)channelKey;

/// This is the internal method to get the group member's name to show in a navigation bar.
- (NSString *)userNamesWithCommaSeparatedForChannelkey:(NSNumber *)key;

/// This method is used to fetch information of channel like channel name,imageUrl of chanel, type of channel and other information.
/// @param channelKey Pass the channelkey or groupId that is required to get the channel information.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion Pass the ALChannel will have information of the channel else error in case of NSError.
- (void)getChannelInformationByResponse:(NSNumber *)channelKey
                     orClientChannelKey:(NSString *)clientChannelKey
                         withCompletion:(void (^)(NSError *error,
                                                  ALChannel *alChannel3,
                                                  AlChannelFeedResponse *channelResponse)) completion;

/// This method is used to create a channel where it needs the below details to pass while creating.
/// @param channelName Pass the channel name that wanted to be set for the channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's the URL of the channel image that wanted to see in the channel profile image.
/// @param completion if an error is nil then the group is created successfully it has ALChannel information of channel else some error while creating if an error is not nil.
- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Use createChannelWithChannelInfo:withCompletion instead");

/// This method is used to create a channel where it needs below details to pass while creating.
/// @param channelName Pass the channel name that wanted to be set for the channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's URL of channel image that wanted to see in the channel profile image.
/// @param type Pass type of group wanted to create
/// Types of the group. PRIVATE = 1,PUBLIC = 2, OPEN = 6
/// @param metaData It's extra information can be added in channel.
/// @param completion if error is nil then group is created successfully it has ALChannel infomration of channel else some error while creating if error is not nil.
- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Use createChannelWithChannelInfo:withCompletion instead");

/// This method is used to create a channel where it needs the below details to pass while creating.
/// @param channelName Pass the channel name that you want to set for the channel.
/// @param parentChannelKey if you have a parent key if the channel you want to link to parent channel then pass parent channel key
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's URL of channel image that wanted to see in the channel profile image.
/// @param type Pass type of group wanted to create
/// Types of the group. PRIVATE = 1,PUBLIC = 2, OPEN = 6
/// @param metaData It's extra information can be added in channel.
/// @param completion If an error is nil then a group is created successfully it has ALChannel information of channel else some error while creating if an error is not nil.
- (void)createChannel:(NSString *)channelName
  andParentChannelKey:(NSNumber *)parentChannelKey
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Use createChannelWithChannelInfo:withCompletion instead");

/// This method is used to create a channel where it needs the below details to pass while creating
/// @param channelName Pass the channel name that wanted to be set for the channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's URL of channel image that wanted to see in the channel profile image.
/// @param type Pass type of group wanted to create
/// Types of the group. PRIVATE = 1,PUBLIC = 2, OPEN = 6
/// @param metaData It's extra information can be added in channel.
/// @param adminUserId If you want to make any member as admin while creating then you can pass the userId of that member.
/// @param completion if an error is a nil then a group is created successfully it has ALChannel information of channel else some error while creating if an error is not nil.
- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Use createChannelWithChannelInfo:withCompletion instead");

/// This method is used for creating a channel with parent channelKey
/// @param channelName Pass the channel name that wanted to be set for the channel.
/// @param parentChannelKey If you have a parent key if the channel you want to link to parent channel then pass the parent channel key
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's URL of channel image that wanted to see in the channel profile image.
/// @param type Pass type of group wanted to create
/// Types of the group. PRIVATE = 1,PUBLIC = 2, OPEN = 6
/// @param metaData It's extra information can be added in channel.
/// @param adminUserId if you want to make any member as admin while creating then you can pass the userId of that member.
/// @param completion if an error is a nil then a group is created successfully it has ALChannel information of channel else some error while creating if an error is not nil.
- (void)createChannel:(NSString *)channelName
  andParentChannelKey:(NSNumber *)parentChannelKey
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("Use createChannelWithChannelInfo:withCompletion instead");

/// This method is used to add a member to a channel.
/// @param userId Pass the userId that wanted to add in a channel.
/// @param channelKey Pass channelkey or groupId that is required for adding a member in a channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion it has error and ALAPIResponse where you can check if an error is not nil else in ALAPIResponse there is the status to check if its success or failure.
- (void)addMemberToChannel:(NSString *)userId
             andChannelKey:(NSNumber *)channelKey
        orClientChannelKey:(NSString *)clientChannelKey
            withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

/// This method is used to remove a member from a channel.
/// @param userId Pass the userId that wanted to remove from a channel.
/// @param channelKey Pass the channelkey or groupId that is required for removing a member from a channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion It has error and ALAPIResponse where you can check if an error is not nil else in ALAPIResponse there is the status to check if its success or failure.
- (void)removeMemberFromChannel:(NSString *)userId
                  andChannelKey:(NSNumber *)channelKey
             orClientChannelKey:(NSString *)clientChannelKey
                 withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

/// This method is used to delete a channel from the server. Only the group admin can call this method.
/// @param channelKey If channelkey or groupId that is required for deleting a channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion It has error and ALAPIResponse where you can check if an error is not nil else in ALAPIResponse there is the status to check if its success or failure.
- (void)deleteChannel:(NSNumber *)channelKey
   orClientChannelKey:(NSString *)clientChannelKey
       withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

- (BOOL)checkAdmin:(NSNumber *)channelKey;

/// This method is used for leaving a member from channel.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @param userId Pass login userId here to leave from channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion it has the error where you can check if an error is not nil the user is left from channel.
- (void)leaveChannel:(NSNumber *)channelKey
           andUserId:(NSString *)userId
  orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion;

/// This method is used for addeding mutliple users in group/channel.
/// @param channelKeys Pass channelKey or array of channelKeys.
/// @param channelUsers Pass userIds that wanted to add in channels or channel.
/// @param completion If error is not nil then member will be added succesful else if any error then it will have NSError.
- (void)addMultipleUsersToChannel:(NSMutableArray *)channelKeys
                     channelUsers:(NSMutableArray *)channelUsers
                    andCompletion:(void(^)(NSError *error))completion;

/// This is an internal method for sync channels from the server
- (void)syncCallForChannel;

/// This method is used to update channel information like name, imageUrl, etc.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @param newName It's the new channel name of a channel.
/// @param imageURL Image URL will be channel profile image.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param flag If your updating metadata pass YES or NO.
/// @param metaData It's extra information that can be updated or added to the channel.
/// @param childKeysList its list of child keys if you have created subgroups.
/// @param channelUsers NSMutableArray of ALChannelUser object
///
/// ALChannelUser * alChannelUsers = [ALChannelUser new];
/// alChannelUsers.role = [NSNumber numberWithInt:1]; // USER = 0,ADMIN = 1,MODERATOR = 2,MEMBER = 3
/// alChannelUsers.userId = userId; //user to update the role
/// NSMutableArray *channelUsers = [NSMutableArray new];
/// [channelUsers addObject:alChannelUsers.dictionary];
/// @param completion It has the error where you can check if an error is not nil if it's updated successfully.
- (void)updateChannel:(NSNumber *)channelKey
           andNewName:(NSString *)newName
          andImageURL:(NSString *)imageURL
   orClientChannelKey:(NSString *)clientChannelKey
   isUpdatingMetaData:(BOOL)flag
             metadata:(NSMutableDictionary *)metaData
          orChildKeys:(NSMutableArray *)childKeysList
       orChannelUsers:(NSMutableArray *)channelUsers
       withCompletion:(void(^)(NSError *error))completion;

/// This method is used to update channel metadata.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param metaData Its extra information can be updated or added in channel.
/// @param completion it has an error where you can check if an error is not nil if it's updated successfully
- (void)updateChannelMetaData:(NSNumber *)channelKey
           orClientChannelKey:(NSString *)clientChannelKey
                     metadata:(NSMutableDictionary *)metaData
               withCompletion:(void(^)(NSError *error))completion;

/// This method is used to mark the conversation as read in the channel.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @param completion It has a response and error if an error is a nil then Conversation is marked successfully
- (void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

/// This method is used to check if the logged-in user is left from a channel or not. It will return YES or NO.
/// @param groupID Pass the channel key can get from ALChannel object as channel.key.
/// @return it will return YES OR NO if the login member is channel or not
- (BOOL)isChannelLeft:(NSNumber *)groupID;

/// This method is used to check if the channel is deleted or not.
/// @param groupId Pass the channel key can get from ALChannel object as channel.key.
/// @return it will return YES or NO if the channel is deleted or not.
+ (BOOL)isChannelDeleted:(NSNumber *)groupId;

/// This method is used to check a channel is closed or not.
/// @param groupId Pass the channel key can get from ALChannel object as channel.key.
/// @return it will return YES OR NO if the conversation Closed in a channel.
+ (BOOL)isConversationClosed:(NSNumber *)groupId;

/// This method is used to close the channel conversation.
/// @param groupId Pass the channel key can get from ALChannel object as channel.key.
/// @param completion If error is nil then the channel is closed else error in closing group.
- (void)closeGroupConverstion:(NSNumber *)groupId withCompletion:(void(^)(NSError *error))completion;

/// This method is used to check if the channel is muted or not.
/// @param groupId Pass the channel key can get from ALChannel object as channel.key.
/// @return it will return YES OR NO if the channel is muted or not.
+ (BOOL)isChannelMuted:(NSNumber *)groupId;

/// This method is internal, used to set channel unread cout to zero.
- (void)setUnreadCountZeroForGroupID:(NSNumber *)channelKey;

/// This method is used to fetch the total unread count of channels.
/// @return NSNumber the total unread count of the channel.
- (NSNumber *)getOverallUnreadCountForChannel;

/// This method is used to fetch the channel information by channelClientKey.
/// @param clientChannelKey Pass the channel key can get from ALChannel object as channel.key.
/// @return It wil return the channel information ALChannel object.
- (ALChannel *)fetchChannelWithClientChannelKey:(NSString *)clientChannelKey;

/// This method is used to check if the logged-in user is in the channel or not.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @return it will return YES OR NO if the user is in a channel or not.
- (BOOL)isLoginUserInChannel:(NSNumber *)channelKey;

/// This method is used to get all channels for the logged-in user from the local database.
/// @return it will return the NSMutableArray of AlChannel object.
- (NSMutableArray *)getAllChannelList;

/// This method is used to fetch the child channels under the parent key.
/// @param parentGroupKey Pass parent channelKey to get the channels.
/// @return It will return the NSMutableArray of AlChannel object.
- (NSMutableArray *)fetchChildChannelsWithParentKey:(NSNumber *)parentGroupKey;

/// This method is used for internal purpose.
- (void)processChildGroups:(ALChannel *)alChannel;

/// This method is used to add child keys to the parent key.
/// @param childKeyList NSMutableArray list of child channelKeys to the parent wanted to add.
/// @param parentKey Pass the parent channelKey.
/// @param completion if error is nil then its added successfully.
- (void)addChildKeyList:(NSMutableArray *)childKeyList
           andParentKey:(NSNumber *)parentKey
         withCompletion:(void(^)(id json, NSError *error))completion;

/// This method is used to remove the child keys from parent channelKey where it was added to the parent.
/// @param childKeyList NSMutableArray list of child channelKeys to the parent wanted to remove from parentKey.
/// @param parentKey Pass the parent channelKey.
/// @param completion If error is nil then its removed successfully.
- (void)removeChildKeyList:(NSMutableArray *)childKeyList
              andParentKey:(NSNumber *)parentKey
            withCompletion:(void(^)(id json, NSError *error))completion;

/// This method is used to add child keys to client Parent Key.
/// @param clientChildKeyList Llist of client child channelKeys to the parent wanted to add.
/// @param clientParentKey Pass the client parent channelKey
/// @param completion If an error is nil then its added successfully else error.
- (void)addClientChildKeyList:(NSMutableArray *)clientChildKeyList
                 andParentKey:(NSString *)clientParentKey
               withCompletion:(void(^)(id json, NSError *error))completion;

/// This method is used to remove the child keys from client ParentKey where it was added to the child keys to parent.
/// @param clientChildKeyList NSMutableArray list of client child channelKeys to the parent wanted to remove from clientParentKey.
/// @param clientParentKey Pass the clientParentKey in case if you have channelParentKey.
/// @param completion if an error is nil then its removed successfully.
- (void)removeClientChildKeyList:(NSMutableArray *)clientChildKeyList
                    andParentKey:(NSString *)clientParentKey
                  withCompletion:(void(^)(id json, NSError *error))completion;

/// This method is used to mute or unmute the channel.
/// @param muteRequest Its an object of ALMuteRequest where you need to pass channelKey and notificationTime its time you want to mute from or unmute.
/// ALMuteRequest * alMuteRequest = [ALMuteRequest new];
/// alMuteRequest.id = channelKey;
/// alMuteRequest.notificationAfterTime= notificationTime;
/// @param completion If an error is nil then check for ALAPIResponse it has status where if its success or error.
- (void)muteChannel:(ALMuteRequest *)muteRequest withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

/// This method is used to create a broadcast channel.
/// @param memberArray Pass member userId whom wanted to add in the broadcast channel.
/// @param metaData Its extra information can be added in channel.
/// @param completion If an error is nil, Then the channel is created successfully else some error in creating a channel.
- (void)createBroadcastChannelWithMembersList:(NSMutableArray *)memberArray
                                  andMetaData:(NSMutableDictionary *)metaData
                               withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

- (ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey;

/// This method is used to fetch channel information from channelKeys array or clientChannelKey array.
/// @param channelIds Pass channelKeys array to get the list of channel information.
/// @param clientChannelIds If you have list of clientChannelKey then pass to get channel information.
/// @param completion If error is nil and channelInfoList count is > 0 then you have channels information in NSMutableArray its type is ALChannel object.
- (void)getChannelInfoByIdsOrClientIds:(NSMutableArray *)channelIds
                    orClinetChannelIds:(NSMutableArray *)clientChannelIds
                        withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion;

/// This method is used to fetch the list of channel information by Category.
/// @param category Pass category that you want to get the channels from category.
/// @param completion If an error is a nil and the channelInfoList count is > 0 then you have channels information in NSMutableArray its type is ALChannel object.
- (void)getChannelListForCategory:(NSString *)category
                   withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion;

/// This method is used to fetch the channels from the applications.
/// @param endTime Pass endTime to to fetch next set of channels.
/// @param completion If error is nil and channelInfoList count is > 0 then it has channel object in array.
- (void)getAllChannelsForApplications:(NSNumber*)endTime withCompletion:(void(^)(NSMutableArray *channelInfoList, NSError *error))completion;

/// This method is used to add or create contacts group with a user, type, and name.
/// @param contactsGroupId Pass the contactsGroupId which will be a unique string.
/// @param membersArray Pass members userId that you want to add.
/// @param groupType Pass type as 9 for contacts group.
/// @param completion If error is nil and ALAPIResponse has status if its success then member is added in contacts group.
- (void)addMemberToContactGroupOfType:(NSString *)contactsGroupId
                          withMembers:(NSMutableArray *)membersArray
                       withGroupType :(short)groupType
                       withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

/// This method is used to add or create contacts group with default type.
/// @param contactsGroupId Pass contactsGroupId which will be unique string.
/// @param membersArray Pass members userId that you want to add.
/// @param completion If error is nil and ALAPIResponse has status if its success then member is added in contacts group.
- (void)addMemberToContactGroup:(NSString *)contactsGroupId
                    withMembers:(NSMutableArray *)membersArray
                 withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

/// This method is used to get the members from contacts group with the type where it will have members id who are in this contacts group
/// @param contactGroupId Pass contactsGroupId which will be unique string.
/// @param groupType Pass type as 9 for contacts group.
/// @param completion if error is nil and ALAPIResponse has status if its success then you will get members userId who are in contacts group.
- (void)getMembersFromContactGroupOfType:(NSString *)contactGroupId
                           withGroupType:(short)groupType
                          withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion;

/// This method is for internal purpose to get the members by channel name.
/// @param channelName Pass the client channel id or channel name to fetch the users from contacts group.
- (NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName;

/// This method is used to remove a member from the contacts group.
/// @param contactsGroupId Pass contactsGroupId which will be unique string.
/// @param userId Pass the user wanted to remove the member from the contacts group
/// @param completion If error is nil and ALAPIResponse has status if its success then member is removed from contacts group.
- (void)removeMemberFromContactGroup:(NSString *)contactsGroupId
                         withUserId :(NSString *)userId
                      withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

/// This method is used to remove a member from contacts group with type.
/// @param contactsGroupId Pass contactsGroupId which will be unique string.
/// @param groupType Pass type as 9 for contacts group.
/// @param userId Pass the userId that wanted to remove from contacts group.
/// @param completion if error is nil and ALAPIResponse has status if its success then member is removed from contacts group else If the error is there then NSError will not be nil.
- (void)removeMemberFromContactGroupOfType:(NSString *)contactsGroupId
                             withGroupType:(short) groupType
                               withUserId :(NSString *)userId
                            withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

/// This method is used to get the members from multiple contacts groups.
/// @param contactGroupIds Pass contactGroupIds to get the member userIds.
/// @param completion If error is nil it will have list of memberIds in channel/group else it will have NSError.
- (void)getMembersIdsForContactGroups:(NSArray *)contactGroupIds withCompletion:(void(^)(NSError *error, NSArray *membersArray)) completion;

/// This method is used to create a channel where it needs the below details to pass while creating a channel.
/// @param channelName Pass the channel name that wanted to be set for the channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param memberArray Pass the members userId that wanted to add in a channel.
/// @param imageLink It's URL of channel image that wanted to see in the channel profile image.
/// @param type Pass type of group wanted to create.
/// Types of the group. PRIVATE = 1, PUBLIC = 2, OPEN = 6
/// @param metaData It's extra information can be added in channel.
/// @param adminUserId If you want to make any member as admin while creating then you can pass the userId of that member.
/// @param groupRoleUsers Pass roles of a member in a channel during creating channel.
/// @param completion f an error is nil then a group is created successfully it has ALChannel information of channel else some error while creating if an error is not nil.
- (void)createChannel:(NSString *)channelName
   orClientChannelKey:(NSString *)clientChannelKey
       andMembersList:(NSMutableArray *)memberArray
         andImageLink:(NSString *)imageLink
          channelType:(short)type
          andMetaData:(NSMutableDictionary *)metaData
            adminUser:(NSString *)adminUserId
       withGroupUsers:(NSMutableArray *)groupRoleUsers
       withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

/// Returns a dictionary containing required key value pairs to turn off the notifications
/// for all the group action messages.
- (NSDictionary *)metadataToTurnOffActionMessagesNotifications;

/// Returns a dictionary containing required key-value pairs to hide all the action messages.
/// and turn off the notifications for them.
- (NSDictionary *)metadataToHideActionMessagesAndTurnOffNotifications;

/// This method is used for leaving a member from channel.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @param userId Pass loggedIn userId here to leave from channel.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param completion It has error and ALAPIResponse where you can check if an error is not nil else in ALAPIResponse there is the status to check if its success or error.
- (void)leaveChannelWithChannelKey:(NSNumber *)channelKey
                         andUserId:(NSString *)userId
                orClientChannelKey:(NSString *)clientChannelKey
                    withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

/// This method is used to update channel information like name, imageUrl etc.
/// @param channelKey Pass the channel key can get from ALChannel object as channel.key.
/// @param newName its new channel name of a channel.
/// @param imageURL Will be channel profile image.
/// @param clientChannelKey Pass the clientChannelKey in case if the channelkey is not present else it will be nil.
/// @param flag If your updating metadata then pass YES or NO.
/// @param metaData It's extra information can be updated or added in channel.
/// @param childKeysList Its list of child keys if you have created subgroups.
/// @param channelUsers NSMutableArray of ALChannelUser object.
/// @param completion It has error and ALAPIResponse where you can check if error is not nil else in ALAPIResponse there is status to check if its success or failed.
- (void)updateChannelWithChannelKey:(NSNumber *)channelKey
                         andNewName:(NSString *)newName
                        andImageURL:(NSString *)imageURL
                 orClientChannelKey:(NSString *)clientChannelKey
                 isUpdatingMetaData:(BOOL)flag
                           metadata:(NSMutableDictionary *)metaData
                        orChildKeys:(NSMutableArray *)childKeysList
                     orChannelUsers:(NSMutableArray *)channelUsers
                     withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

/// This method is used for internal purpose.
/// @param delegate For real time updates callback will be triggered for channel update
- (void)syncCallForChannelWithDelegate:(id<KommunicateUpdatesDelegate>)delegate;

- (void)updateConversationReadWithGroupId:(NSNumber *)channelKey withDelegate:(id<KommunicateUpdatesDelegate>)delegate;

/// This method is used for creating a channel.
/// @param channelInfo Pass the ALChannelInfo which will have details for creating a channel.
/// @param completion Once the group/channel is created successful then ALChannelCreateResponse else it will have NSError.
- (void)createChannelWithChannelInfo:(ALChannelInfo *)channelInfo withCompletion:(void(^)(ALChannelCreateResponse *response, NSError *error))completion;

- (void)createChannelEntry:(ALChannel*)channel fromMessageList:(BOOL)isFromMessageList;

- (void)saveChannelUsersAndChannelDetails:(NSMutableArray <ALChannel *>*)channelFeedsList calledFromMessageList:(BOOL)isFromMessageList;

- (void)updateMuteAfterTime:(NSNumber*)notificationAfterTime
               andChnnelKey:(NSNumber*)channelKey;

/// This method will return all the channels for the logged-in user.
/// @param completion will have a channel array of ALChannel or will have an error in case of while fetching channels.
- (void)getListOfChannelWithCompletion:(void(^)(NSMutableArray *channelArray, NSError * error))completion;
@end
