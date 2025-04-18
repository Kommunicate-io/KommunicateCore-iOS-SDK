//
//  ALContactDBService.h
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALContact.h"
#import "DB_CONTACT.h"
#import "KMCoreUserDetail.h"
#import "ALUserBlocked.h"
#import "ALContactsResponse.h"
#import "KMCoreRealTimeUpdate.h"


@interface ALContactDBService : NSObject

- (BOOL)purgeListOfContacts:(NSArray *)contacts;

- (BOOL)purgeContact:(ALContact *)contact;

- (BOOL)purgeAllContact;

- (BOOL)updateListOfContacts:(NSArray *)contacts;

- (BOOL)updateContactInDatabase:(ALContact *)contact;

- (BOOL)addListOfContacts:(NSArray *)contacts;

- (BOOL)addContactInDatabase:(ALContact *)userContact;

- (void)updateConnectedStatus:(NSString *)userId lastSeenAt:(NSNumber *)lastSeenAt connected:(BOOL)connected;

- (DB_CONTACT *)getContactByKey:(NSString *)key value:(NSString *)value;

- (ALContact *)loadContactByKey:(NSString *)key value:(NSString *)value;

- (void)addUserDetails:(NSMutableArray *)userDetails;

- (BOOL)updateUserDetail:(KMCoreUserDetail *)userDetail;

- (BOOL)updateLastSeenDBUpdate:(KMCoreUserDetail *)userDetail;

- (NSUInteger)markConversationAsDeliveredAndRead:(NSString *)contactId;
- (NSArray *)getUnreadMessagesForIndividual:(NSString *)contactId;
- (BOOL)setBlockUser:(NSString *)userId andBlockedState:(BOOL)flag;
- (BOOL)setBlockByUser:(NSString *)userId andBlockedByState:(BOOL)flag;
- (void)blockAllUserInList:(NSMutableArray *)userList;
- (void)blockByUserInList:(NSMutableArray *)userList;
- (NSMutableArray *)getListOfBlockedUsers;

- (BOOL)setUnreadCountDB:(ALContact *)contact;

- (NSMutableArray *)updateFilteredContacts:(ALContactsResponse *)contactsResponse withLoadContact:(BOOL)isLoadContactFromDb;

- (NSMutableArray *)getAllContactsFromDB;
- (NSNumber *)getOverallUnreadCountForContactsFromDB;
- (BOOL)isUserDeleted:(NSString *)userId;
- (void)addUserDetailsWithoutUnreadCount:(NSMutableArray *)userDetails;
- (KMCoreUserDetail *)updateMuteAfterTime:(NSNumber *)notificationAfterTime andUserId:(NSString *)userId;
- (NSMutableArray *)addMuteUserDetailsWithDelegate:(id<KommunicateUpdatesDelegate>)delegate withNSDictionary:(NSDictionary *)jsonNSDictionary;
- (BOOL)addOrUpdateMetadataWithUserId:(NSString *)userId withMetadataKey:(NSString *)key withMetadataValue:(NSString *)value;
@end
