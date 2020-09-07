//
//  ALContactDBService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALConstant.h"
#import "DB_Message.h"
#import "SearchResultCache.h"

@implementation ALContactDBService

#pragma mark - Delete Contacts API -

- (BOOL)purgeListOfContacts:(NSArray *)contacts {
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self purgeContact:contact];
        
        if (!result) {
            
            ALSLog(ALLoggerSeverityInfo, @"Failure to delete the contacts");
            break;
        }
    }
    
    return result;
}

- (BOOL)purgeContact:(ALContact *)contact {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];

        [fetchRequest setEntity:entity];

        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (fetchError) {
            return NO;
        }
        if (result.count) {

            for (DB_CONTACT *userContact in result) {
                [dbHandler deleteObject:userContact];
            }

            NSError *deleteError = [dbHandler saveContext];
            if (deleteError) {
                ALSLog(ALLoggerSeverityError, @" Unable to save managed object context %@, %@", deleteError, deleteError.localizedDescription);
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)purgeAllContact
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    if (entity) {
        [fetchRequest setEntity:entity];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (fetchError) {
            return NO;
        }
        if (result.count) {
            for (DB_CONTACT *userContact in result) {
                [dbHandler deleteObject:userContact];
            }

            NSError *deleteError = [dbHandler saveContext];

            if (deleteError) {
                ALSLog(ALLoggerSeverityError, @"Unable to save managed object context. %@, %@", deleteError, deleteError.localizedDescription);
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Update Contacts API -

- (BOOL)updateListOfContacts:(NSArray *)contacts {
    
    BOOL result = NO;
    
    for (ALContact *contact in contacts) {
        
        result = [self updateContact:contact];

        if (!result) {
            ALSLog(ALLoggerSeverityInfo, @"Failure to update the contacts %@",contact.userId);
        }
    }
    
    return result;
}

- (BOOL)updateContact:(ALContact *)contact {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];
    if (entity) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];

        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"updateContactFERROR :%@",fetchError);
            return NO;
        }

        for (DB_CONTACT * userContact in result) {

            userContact.userId = contact.userId;
            if (contact.email) {
                userContact.email = contact.email;
            }
            if (contact.fullName) {
                userContact.fullName = contact.fullName;
            }
            if (contact.contactNumber) {
                userContact.contactNumber = contact.contactNumber;
            }
            if (contact.contactImageUrl) {
                userContact.contactImageUrl = contact.contactImageUrl;
            }

            if (contact.unreadCount != nil &&
                [contact.unreadCount  compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
                userContact.unreadCount = contact.unreadCount;
            }

            userContact.userStatus = contact.userStatus;
            userContact.connected = contact.connected;
            if (contact.displayName) {
                userContact.displayName = contact.displayName;
            }
            if (contact.contactType) {
                userContact.contactType = contact.contactType;
            }
            userContact.localImageResourceName = contact.localImageResourceName;
            if (contact.deletedAtTime) {
                userContact.deletedAtTime = contact.deletedAtTime;
            }
            userContact.roleType = contact.roleType;

            userContact.metadata =  [contact appendMetadataIn:userContact.metadata].description;

            if (contact.notificationAfterTime && [contact.notificationAfterTime longValue]>0) {
                userContact.notificationAfterTime = contact.notificationAfterTime;
            }
            userContact.status = contact.status;
        }

        NSError *error = [dbHandler saveContext];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"updateContactFERROR :%@",error);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

-(BOOL)setUnreadCountDB:(ALContact*)contact {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",contact.userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"DB fetch error while set unreadcount :%@",fetchError);
            return NO;
        }
        NSError *error = nil;
        if(result.count > 0) {
            DB_CONTACT * dbContact = [result objectAtIndex:0];
            dbContact.unreadCount = [NSNumber numberWithInt:0];
            error = [dbHandler saveContext];
        }

        if (error) {
            ALSLog(ALLoggerSeverityError, @"DB ERROR :%@",error);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Add Contacts API -

- (BOOL)addListOfContacts:(NSArray *)contacts {

    BOOL result = NO;

    for (ALContact *contact in contacts) {

        result = [self addContact:contact];

        if (!result) {
            ALSLog(ALLoggerSeverityInfo, @"Failure to add/update the contacts %@",contact.userId);
        }
    }

    return result;
}

- (ALContact *) loadContactByKey:(NSString *) key
                           value:(NSString*) value {
    if (!value) {
        return nil;
    }
    ALContact *cachedContact = [[SearchResultCache shared] getContactWithId: value];
    if (cachedContact != nil) {
        return cachedContact;
    }
    
    DB_CONTACT *dbContact = [self getContactByKey:key value:value];
    ALContact *contact = [[ALContact alloc] init];

    if (!dbContact) {
        contact.userId = value;
        contact.displayName = value;
        return contact;
    }
    contact.userId = dbContact.userId;
    contact.fullName = dbContact.fullName;
    contact.contactNumber = dbContact.contactNumber;
    contact.displayName = dbContact.displayName;
    contact.contactImageUrl = dbContact.contactImageUrl;
    contact.email = dbContact.email;
    contact.localImageResourceName = dbContact.localImageResourceName;
    contact.connected = dbContact.connected;
    contact.lastSeenAt = dbContact.lastSeenAt;
    contact.unreadCount=dbContact.unreadCount;
    contact.block = dbContact.block;
    contact.blockBy = dbContact.blockBy;
    contact.userStatus = dbContact.userStatus;
    contact.deletedAtTime = dbContact.deletedAtTime;
    contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];
    contact.roleType = dbContact.roleType;
    contact.notificationAfterTime = dbContact.notificationAfterTime;
    contact.status = dbContact.status;
    return contact;
}


- (DB_CONTACT *)getContactByKey:(NSString *) key
                          value:(NSString*) value {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",key,value];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count > 0) {
            DB_CONTACT* dbContact = [result objectAtIndex:0];
            return dbContact;
        }
    }
    return nil;
}

-(BOOL)addContact:(ALContact *)userContact {
    DB_CONTACT* existingContact = [self getContactByKey:@"userId" value:[userContact userId]];
    if (existingContact) {
        [self updateContact:userContact];
        return(NO);
    }
    return([self insertNewContact:userContact]);
}


-(void)addUserDetails:(NSMutableArray *)userDetails {
    for (ALUserDetail *theUserDetail in userDetails) {
        [self updateUserDetail:theUserDetail];
    }
}

-(void)addUserDetailsWithoutUnreadCount:(NSMutableArray *)userDetails {
    for (ALUserDetail *theUserDetail in userDetails) {
        theUserDetail.unreadCount = 0;
        [self updateUserDetail:theUserDetail];
    }
}


-(NSMutableArray *)addMuteUserDetailsWithDelegate:(id<ApplozicUpdatesDelegate>)delegate withNSDictionary:(NSDictionary *)jsonNSDictionary {
    NSMutableArray * userDetailArray = [NSMutableArray new];

    for (NSDictionary * theDictionary in jsonNSDictionary) {
        ALUserDetail * userDetail = [[ALUserDetail alloc] initWithDictonary:theDictionary];
        userDetail.unreadCount = 0;
        [self updateUserDetail:userDetail];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Update_user_mute_info" object:userDetail];
        if(delegate){
            [delegate onUserMuteStatus:userDetail];
        }
        [userDetailArray addObject:userDetail];
    }
    
    return userDetailArray;

}

-(void) updateConnectedStatus: (NSString *) userId
                   lastSeenAt:(NSNumber *) lastSeenAt
                    connected: (BOOL) connected {
    ALUserDetail *ob = [[ALUserDetail alloc] init];
    ob.lastSeenAtTime = lastSeenAt;
    ob.connected =  connected;
    ob.userId = userId;
    
    [self updateUserDetail:ob];
}

-(BOOL)updateUserDetail:(ALUserDetail *)userDetail {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"DB ERROR in fetching the result for contact:%@", fetchError);
            return NO;
        }

        if (result.count > 0) {

            DB_CONTACT * dbContact = [result objectAtIndex:0];
            dbContact.lastSeenAt = userDetail.lastSeenAtTime;
            dbContact.connected = userDetail.connected;
            if (userDetail.unreadCount != nil &&
                [userDetail.unreadCount  compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
                dbContact.unreadCount = userDetail.unreadCount;
            }

            if (userDetail.displayName) {
                dbContact.displayName = userDetail.displayName;
            }
            dbContact.contactImageUrl = userDetail.imageLink;
            dbContact.contactNumber = userDetail.contactNumber;
            dbContact.userStatus = userDetail.userStatus;
            dbContact.deletedAtTime = userDetail.deletedAtTime;
            dbContact.metadata =  [userDetail appendMetadataIn:dbContact.metadata].description;
            dbContact.roleType = userDetail.roleType;

            if (userDetail.notificationAfterTime &&
                [userDetail.notificationAfterTime longValue]>0) {
                dbContact.notificationAfterTime = userDetail.notificationAfterTime;
            }
            dbContact.status = userDetail.status;
        } else {
            // Add contact in DB.
            ALContact * contact = [[ALContact alloc] init];
            contact.userId = userDetail.userId;
            contact.unreadCount = userDetail.unreadCount;
            contact.lastSeenAt = userDetail.lastSeenAtTime;
            contact.displayName = userDetail.displayName;
            contact.contactImageUrl = userDetail.imageLink;
            contact.contactNumber = userDetail.contactNumber;
            contact.connected = userDetail.connected;
            contact.userStatus = userDetail.userStatus;
            contact.deletedAtTime = userDetail.deletedAtTime;
            contact.roleType = userDetail.roleType;
            contact.metadata = userDetail.metadata;

            if (userDetail.notificationAfterTime &&
                [userDetail.notificationAfterTime longValue]>0) {
                contact.notificationAfterTime = userDetail.notificationAfterTime;
            }
            contact.status = userDetail.status;
            [self addContact:contact];
        }

        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"DB ERROR :%@",error);
            return NO;
        }
    }
    return YES;
}

-(BOOL)updateLastSeenDBUpdate:(ALUserDetail *)userDetail {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDetail.userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (result.count > 0) {
            DB_CONTACT * dbContact = [result objectAtIndex:0];
            dbContact.connected = userDetail.connected;
            dbContact.lastSeenAt = userDetail.lastSeenAtTime;
            NSError *error = [dbHandler saveContext];
            if (error) {
                ALSLog(ALLoggerSeverityError, @"DB ERROR :%@",error);
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

-(NSUInteger)markConversationAsDeliveredAndRead:(NSString*)contactId {
    NSArray *messages =  [self getUnreadMessagesForIndividual:contactId];

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    for (DB_Message *dbMessage in messages) {
        dbMessage.status = @(DELIVERED_AND_READ);
    }
    if (messages.count > 0) {
        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR(IF-ANY) WHILE UPDATING DELIVERED_AND_READ : %@",error.description);
            return 0;
        }
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForIndividual:(NSString *)contactId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];

    if (entity) {
        NSPredicate *predicate;
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];

        if (contactId) {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%@",@"contactId",contactId];
            NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"groupId==%d OR groupId==%@",0,NULL];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2,predicate3]];
        } else {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
        }
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        return [dbHandler executeFetchRequest:fetchRequest withError:nil];
    }
    return nil;
}

-(BOOL)setBlockUser:(NSString *)userId
    andBlockedState:(BOOL)flag {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if(result.count > 0)
        {
            DB_CONTACT *resultDBContact = [result objectAtIndex:0];
            resultDBContact.block = flag;
            NSError *error = [dbHandler saveContext];
            if (error) {
                ALSLog(ALLoggerSeverityError, @"DB ERROR FOR BLOCKING/UNBLOCKING USER %@ :%@",userId, error);
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

-(void)blockAllUserInList:(NSMutableArray *)userList {
    for(ALUserBlocked *userBlocked in userList) {
        [self setBlockUser:userBlocked.blockedTo andBlockedState:userBlocked.userBlocked];
    }
}

-(void)blockByUserInList:(NSMutableArray *)userList {
    for(ALUserBlocked *userBlocked in userList) {
        [self setBlockByUser:userBlocked.blockedBy andBlockedByState:userBlocked.userblockedBy];
    }
}

-(BOOL)setBlockByUser:(NSString *)userId
    andBlockedByState:(BOOL)flag {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];

    NSError *fetchError = nil;
    NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];

    if (result.count > 0) {
        DB_CONTACT *resultDBContact = [result objectAtIndex:0];
        resultDBContact.blockBy = flag;
        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"DB ERROR FOR BLOCKED BY USER %@ :%@", userId, error);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

-(NSMutableArray *)getListOfBlockedUsers {
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    NSMutableArray * userList = [[NSMutableArray alloc] init];
    if (entity) {
        [fetchRequest setEntity:entity];

        NSError *fetchError = nil;
        NSArray *userArray = [theDBHandler executeFetchRequest:fetchRequest withError:&fetchError];

        if (userArray.count) {
            for(DB_CONTACT *contact in userArray) {
                if(contact.block)
                {
                    [userList addObject:contact.userId];
                }
            }
        } else {
            ALSLog(ALLoggerSeverityInfo, @"NO BLOCKED USER FOUND");
        }
    }

    return userList;
}

-(NSMutableArray*)updateFilteredContacts:(ALContactsResponse *)contactsResponse withLoadContact:(BOOL)isLoadContactFromDb {
    NSMutableArray * contactArray = [NSMutableArray new];
    for (ALUserDetail * userDetail in contactsResponse.userDetailList) {
        userDetail.unreadCount = 0;
        [self updateUserDetail:userDetail];
        if (isLoadContactFromDb) {
            ALContact * contact = [self loadContactByKey:@"userId" value: userDetail.userId];
            [contactArray addObject:contact];
        }
    }
    return contactArray;
}

-(NSMutableArray *)getAllContactsFromDB {
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId !=%@ AND deletedAtTime == nil",[ALUserDefaultsHandler getUserId]];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    [theRequest setPredicate:predicate];
    [theRequest setReturnsDistinctResults:YES];

    NSMutableArray * contactList = [NSMutableArray new];
    NSError *fetchError = nil;
    NSArray *userArray = [theDbHandler executeFetchRequest:theRequest withError:&fetchError];

    if (userArray.count) {
        for (DB_CONTACT * dbContact in userArray)
        {
            ALContact *contact = [[ALContact alloc] init];

            contact.userId = dbContact.userId;
            contact.fullName = dbContact.fullName;
            contact.contactNumber = dbContact.contactNumber;
            contact.displayName = dbContact.displayName;
            contact.contactImageUrl = dbContact.contactImageUrl;
            contact.email = dbContact.email;
            contact.localImageResourceName = dbContact.localImageResourceName;
            contact.unreadCount = dbContact.unreadCount;
            contact.userStatus = dbContact.userStatus;
            contact.connected = dbContact.connected;
            contact.deletedAtTime = dbContact.deletedAtTime;
            contact.roleType = dbContact.roleType;
            contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];
            contact.notificationAfterTime =  dbContact.notificationAfterTime;
            contact.status = dbContact.status;
            [contactList addObject:contact];
        }
    }
    return contactList;
}

-(NSNumber *)getOverallUnreadCountForContactsFromDB {
    NSNumber * unreadCount;
    int count = 0;
    NSMutableArray * contactArray = [NSMutableArray arrayWithArray:[self getAllContactsFromDB]];
    for (ALContact *contact in contactArray) {
        count = count + [contact.unreadCount intValue];
    }
    unreadCount = [NSNumber numberWithInt:count];
    return unreadCount;
}

-(BOOL)isUserDeleted:(NSString *)userId {
    ALContact * contact = [self loadContactByKey:@"userId" value:userId];
    return contact.deletedAtTime ? YES : NO;
}

-(DB_CONTACT*)replaceContact:(DB_CONTACT*)originalContact
                        with:(ALContact*)updatedContact {
    originalContact.userId = updatedContact.userId;
    originalContact.fullName = updatedContact.fullName;
    originalContact.contactNumber = updatedContact.contactNumber;
    originalContact.displayName = updatedContact.displayName;
    originalContact.email = updatedContact.email;
    originalContact.contactImageUrl = updatedContact.contactImageUrl;
    originalContact.localImageResourceName = updatedContact.localImageResourceName;
    originalContact.unreadCount = updatedContact.unreadCount ? updatedContact.unreadCount : [NSNumber numberWithInt:0];
    originalContact.lastSeenAt = updatedContact.lastSeenAt;
    originalContact.userStatus = updatedContact.userStatus;
    originalContact.connected = updatedContact.connected;
    originalContact.contactType = updatedContact.contactType;
    originalContact.userTypeId = updatedContact.userTypeId;
    originalContact.deletedAtTime = updatedContact.deletedAtTime;
    originalContact.metadata = updatedContact.metadata.description;
    originalContact.roleType = updatedContact.roleType;
    if (updatedContact.notificationAfterTime &&
        [updatedContact.notificationAfterTime longValue]>0) {
        originalContact.notificationAfterTime = updatedContact.notificationAfterTime;
    }
    originalContact.status = updatedContact.status;
    return originalContact;
}

-(BOOL)insertNewContact:(ALContact*)contact {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    DB_CONTACT * dbContact = (DB_CONTACT *)[dbHandler insertNewObjectForEntityForName:@"DB_CONTACT"];

    if (dbContact) {
        dbContact = [self replaceContact:dbContact with:contact];

        NSError *error = [dbHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"addContact DB ERROR :%@",error);
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

-(ALUserDetail *)updateMuteAfterTime:(NSNumber*)notificationAfterTime andUserId:(NSString*)userId
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    DB_CONTACT* dbContact = [self getContactByKey:@"userId" value:userId];
    
    if(dbContact){
        dbContact.notificationAfterTime = notificationAfterTime;
        [dbHandler saveContext];
    }
    
    return [self getUserDetailFromDbContact:dbContact];
}

-(ALUserDetail *)getUserDetailFromDbContact:(DB_CONTACT *)dbContact{
    
    ALUserDetail *userDetail = [[ALUserDetail alloc] init];
    userDetail.userId = dbContact.userId;
    userDetail.contactNumber = dbContact.contactNumber;
    userDetail.imageLink = dbContact.contactImageUrl;
    userDetail.displayName = dbContact.displayName;
    userDetail.unreadCount = dbContact.unreadCount;
    userDetail.userStatus = dbContact.userStatus;
    userDetail.connected = dbContact.connected;
    userDetail.deletedAtTime = dbContact.deletedAtTime;
    userDetail.roleType = dbContact.roleType;
    userDetail.notificationAfterTime =  dbContact.notificationAfterTime;
    userDetail.status = dbContact.status;
    return userDetail;
}

-(BOOL)addOrUpdateMetadataWithUserId:(NSString *) userId withMetadataKey:(NSString *) key withMetadataValue:(NSString *) value {

    BOOL isSuccess = NO;
    if ([userId length] == 0) {
        return isSuccess;
    }

    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CONTACT"];

    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];

        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if(result.count > 0) {
            DB_CONTACT * dbContact = [result objectAtIndex:0];

            NSString * metadataString = dbContact.metadata;
            if (!metadataString) {
                NSMutableDictionary *metadata = [[NSMutableDictionary alloc]init];
                [metadata setObject:value forKey:key];
                dbContact.metadata = metadata.description;
                NSError *error = nil;
                error = [dbHandler saveContext];
                if (error) {
                    ALSLog(ALLoggerSeverityError, @"DB ERROR in Add meta data :%@",error);
                    return NO;
                }
                return YES;
            }

            ALContact * contact = [[ALContact alloc] init];
            NSMutableDictionary * existingMetadata = [contact getMetaDataDictionary:metadataString];

            if (existingMetadata) {
                [existingMetadata setObject:value forKey:key];
                dbContact.metadata = existingMetadata.description;
                NSError *error = nil;
                error = [dbHandler saveContext];
                if (error) {
                    ALSLog(ALLoggerSeverityError, @"DB ERROR in update meta data :%@",error);
                    return NO;
                }
                return YES;
            }
        }
    }

    return isSuccess;
}

@end
