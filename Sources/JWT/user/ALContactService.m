//
//  ALContactService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactService.h"
#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserService.h"

@implementation ALContactService

- (instancetype)init {
    self = [super init];
    self.alContactDBService = [[ALContactDBService alloc] init];
    return self;
}

#pragma mark Deleting APIS
//For purgeing single contacts
- (BOOL)purgeContact:(ALContact *)contact {
    return [self.alContactDBService purgeContact:contact];
}


//For purgeing multiple contacts
- (BOOL)purgeListOfContacts:(NSArray *)contacts {
    return [self.alContactDBService purgeListOfContacts:contacts];
}


//For delting all contacts at once
- (BOOL)purgeAllContact {
    return  [self.alContactDBService purgeAllContact];
}

#pragma mark Update APIS
- (BOOL)updateContact:(ALContact *)contact {

    if (!contact.userId || contact.userId.length == 0) {
        return NO;
    }
    return [self.alContactDBService updateContactInDatabase:contact];
}

- (BOOL)setUnreadCountInDB:(ALContact *)contact {
    return [self.alContactDBService setUnreadCountDB:contact];
}

- (BOOL)updateListOfContacts:(NSArray *)contacts {
    if (!contacts || contacts.count == 0) {
        return NO;
    }
    return [self.alContactDBService updateListOfContacts:contacts];
}

- (NSNumber *)getOverallUnreadCountForContact {
    return [self.alContactDBService getOverallUnreadCountForContactsFromDB];
}

- (BOOL)isContactExist:(NSString *)value {

    DB_CONTACT *contact= [self.alContactDBService getContactByKey:@"userId" value:value];
    return contact != nil && contact.userId != nil;
}
#pragma mark update OR insert contact

- (BOOL)updateOrInsert:(ALContact *)contact {
    return ([self isContactExist:contact.userId]) ? [self updateContact:contact] : [self addContact:contact];
}

- (void)updateOrInsertListOfContacts:(NSMutableArray *)contacts {
    
    for (ALContact *conatct in contacts) {
        [self updateOrInsert:conatct];
    }
}

#pragma mark addition APIS
- (BOOL)addListOfContacts:(NSArray *)contacts {
    return [self.alContactDBService addListOfContacts:contacts];
}

- (BOOL)addContact:(ALContact *)userContact {

    if (!userContact.userId || userContact.userId.length == 0) {
        return NO;
    }

    return [self.alContactDBService addContactInDatabase:userContact];

}

#pragma mark fetching APIS
- (ALContact *)loadContactByKey:(NSString *)key value:(NSString *)value {
    if (!key || !value) {
        return nil;
    }
    return [self.alContactDBService loadContactByKey:key value:value];
}

#pragma mark fetching or save
- (ALContact *)loadOrAddContactByKeyWithDisplayName:(NSString *)contactId value:(NSString*)displayName {
    
    DB_CONTACT *dbContact = [self.alContactDBService getContactByKey:@"userId" value:contactId];
    
    ALContact *contact = [[ALContact alloc] init];
    if (!dbContact) {
        contact.userId = contactId;
        contact.displayName = displayName;
        NSMutableDictionary * metadata = [[NSMutableDictionary alloc] init];
        [metadata setObject:@"false" forKey:AL_DISPLAY_NAME_UPDATED];
        contact.metadata = metadata;
        [self addContact:contact];
        return contact;
    }

    contact.userId = dbContact.userId;
    contact.fullName = dbContact.fullName;
    contact.contactNumber = dbContact.contactNumber;
    contact.contactImageUrl = dbContact.contactImageUrl;
    contact.email = dbContact.email;
    contact.localImageResourceName = dbContact.localImageResourceName;
    contact.connected = dbContact.connected;
    contact.lastSeenAt = dbContact.lastSeenAt;
    contact.unreadCount= dbContact.unreadCount;
    contact.userStatus = dbContact.userStatus;
    contact.deletedAtTime = dbContact.deletedAtTime;
    contact.roleType = dbContact.roleType;
    contact.metadata = [contact getMetaDataDictionary:dbContact.metadata];

    if (![displayName isEqualToString:dbContact.displayName]) { // Both display name are not same then update
        [self.alContactDBService addOrUpdateMetadataWithUserId:contactId withMetadataKey:AL_DISPLAY_NAME_UPDATED withMetadataValue:@"false"];
        
        if (contact.metadata != nil) {
            [contact.metadata setObject:@"false" forKey:AL_DISPLAY_NAME_UPDATED];
        }
        contact.displayName = displayName;
    } else {
        contact.displayName = dbContact.displayName;
    }
    contact.status = dbContact.status;
    return contact;
}

- (BOOL)isUserDeleted:(NSString *)userId {
    if (!userId) {
        return NO;
    }
    return [self.alContactDBService isUserDeleted:userId];
}

- (ALUserDetail *)updateMuteAfterTime:(NSNumber *)notificationAfterTime andUserId:(NSString *)userId {
    return  [self.alContactDBService updateMuteAfterTime:notificationAfterTime andUserId:userId];
}
@end
