//
//  SearchResultCache.m
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 02/07/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSearchResultCache.h"

@implementation ALSearchResultCache

static ALSearchResultCache *sharedInstance = nil;
NSCache<NSNumber *, ALChannel *> *channelCache;
NSCache<NSString *, ALContact *> *contactCache;

+ (ALSearchResultCache *)shared {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[ALSearchResultCache alloc] init];
        channelCache = [[NSCache alloc] init];
        contactCache = [[NSCache alloc] init];
    });
    return sharedInstance;
}

- (void)saveChannels:(NSMutableArray<ALChannel *> *)channels {
    for (ALChannel *channel in channels) {
        [channelCache setObject:channel forKey:channel.key];
    }
}

- (void)saveUserDetails:(NSMutableArray<KMCoreUserDetail *> *)userDetails {
    for (KMCoreUserDetail *userDetail in userDetails) {
        ALContact *contact = [self parseUserDetail: userDetail];
        [contactCache setObject: contact forKey: contact.userId];
    }
}

- (ALContact *)parseUserDetail: (KMCoreUserDetail *)userDetail {
    ALContact *contact = [[ALContact alloc] init];
    contact.userId = userDetail.userId;
    contact.connected = userDetail.connected;
    contact.lastSeenAt = userDetail.lastSeenAtTime;
    contact.unreadCount = userDetail.unreadCount;
    contact.displayName = userDetail.displayName;
    contact.contactImageUrl = userDetail.imageLink;
    contact.contactNumber = userDetail.contactNumber;
    contact.userStatus = userDetail.userStatus;
    contact.userTypeId = userDetail.userTypeId;
    contact.deletedAtTime = userDetail.deletedAtTime;
    contact.roleType = userDetail.roleType;
    contact.metadata = userDetail.metadata;

    if (userDetail.notificationAfterTime && [userDetail.notificationAfterTime longValue]>0) {
        contact.notificationAfterTime = userDetail.notificationAfterTime;
    }
    return contact;
}

- (ALChannel *)getChannelWithId:(NSNumber *)key {
    return [channelCache objectForKey: key];
}

- (ALContact *)getContactWithId:(NSString *)key {
    return [contactCache objectForKey: key];
}

@end
