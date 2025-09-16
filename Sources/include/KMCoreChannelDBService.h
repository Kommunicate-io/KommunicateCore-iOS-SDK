//
//  KMCoreChannelDBService.h
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//  class for databse actios for group

#import <Foundation/Foundation.h>
#import "KMCoreChannel.h"
#import "DB_CHANNEL.h"
#import "DB_CHANNEL_USER_X.h"
#import "KMCoreDBHandler.h"
#import "KMCoreChannelUserX.h"
#import "KMCoreConversationProxy.h"
#import "DB_ConversationProxy.h"
#import "KMCoreSettings.h"
#import "KMCoreRealTimeUpdate.h"

@interface KMCoreChannelDBService : NSObject

- (void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

- (void)insertChannel:(NSMutableArray *)channelList;

- (DB_CHANNEL *)createChannelEntity:(KMCoreChannel *)channel;

- (void)insertChannelUserX:(NSMutableArray *)channelUserX;

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(KMCoreChannelUserX *)channelUserXList;

- (NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey;

- (KMCoreChannel *)loadChannelByKey:(NSNumber *)key;

- (KMCoreChannel *)getChannelByKey:(NSNumber *)key;

- (NSString *)userNamesWithCommaSeparatedForChannelkey:(NSNumber *)key;

- (KMCoreChannel *)checkChannelEntity:(NSNumber *)channelKey;

- (void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey;

- (void)deleteChannel:(NSNumber *)channelKey;

- (NSMutableArray *)getAllChannelKeyAndName;

- (void)updateChannel:(NSNumber *)channelKey
           andNewName:(NSString *)newName
           orImageURL:(NSString *)imageURL
          orChildKeys:(NSMutableArray *)childKeysList
   isUpdatingMetaData:(BOOL)flag
       orChannelUsers:(NSMutableArray *)channelUsers;

- (void)updateChannelMetaData:(NSNumber *)channelKey metaData:(NSMutableDictionary *)newMetaData;

- (void)updatePlatformSource:(NSNumber *)channelKey platformSource:(NSString *)newPlatformSource;

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key;
//New Added...
- (NSUInteger)markConversationAsRead:(NSNumber*)channelKey;

- (NSArray *)getUnreadMessagesForGroup:(NSNumber*)groupId;

- (void)updateUnreadCountChannel:(NSNumber *)channelKey unreadCount:(NSNumber *)unreadCount;

- (void)setLeaveFlag:(BOOL)flag forChannel:(NSNumber *)groupId;

- (BOOL)isChannelLeft:(NSNumber *)groupId;

- (BOOL)isChannelDeleted:(NSNumber *)groupId;
- (BOOL)isConversaionClosed:(NSNumber *)groupId;

- (BOOL)isAdminBroadcastChannel:(NSNumber *)groupId;

- (void)updateParentForChildKeys:(NSArray<NSNumber *> *)childKeys
              andWithParentKey:(NSNumber *)parentKey
                        isAdding:(BOOL)flag;

- (void)updateClientChannelParentKey:(NSString *)clientChildKey
             andWithClientParentKey:(NSString *)clientParentKey
                            isAdding:(BOOL)flag;

- (NSNumber *)getOverallUnreadCountForChannelFromDB;

- (KMCoreChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey;

- (void)removedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey;

- (void)addedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey;

- (NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey;

- (void)updateMuteAfterTime:(NSNumber *)notificationAfterTime andChnnelKey:(NSNumber *)channelKey;

- (DB_CHANNEL_USER_X *)getChannelUserX:(NSNumber *)channelKey;

- (KMCoreChannelUserX *)loadChannelUserX:(NSNumber *)channelKey;

- (KMCoreChannelUserX *)loadChannelUserXByUserId:(NSNumber *)channelKey andUserId:(NSString *)userId;

- (void)updateParentKeyInChannelUserX:(NSNumber *)channelKey andWithParentKey:(NSNumber *)parentKey addUserId:(NSString *)userId;

- (void)updateRoleInChannelUserX:(NSNumber *)channelKey andUserId:(NSString *)userId withRoleType:(NSNumber *)role;

- (NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName;

- (DB_CHANNEL *)getContactsGroupChannelByName:(NSString *)channelName;
- (NSMutableArray *)getGroupUsersInChannel:(NSNumber *)key;

- (void)fetchChannelMembersAsyncWithChannelKey:(NSNumber*)channelKey witCompletion:(void(^)(NSMutableArray *membersArray))completion;

- (void)getUserInSupportGroup:(NSNumber *)channelKey withCompletion:(void(^)(NSString *userId)) completion;

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(KMCoreChannelUserX *)channelUserX withContext:(NSManagedObjectContext *)context;

- (void)deleteMembers:(NSNumber *)key;

@end
