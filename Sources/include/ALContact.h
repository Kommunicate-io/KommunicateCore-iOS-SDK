//
//  ALContact.h
//  ChatApp
//
//  Created by shaik riyaz on 15/08/15.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

static NSString *const AL_DISPLAY_NAME_UPDATED = @"AL_DISPLAY_NAME_UPDATED";

@interface ALContact : ALJson

@property (nonatomic,retain) NSString *userId;

@property (nonatomic,retain) NSString *fullName;

@property (nonatomic,retain) NSString *contactNumber;

@property (nonatomic,retain) NSString *displayName;

@property (nonatomic,retain) NSString *contactImageUrl;

@property (nonatomic,retain) NSString *email;

@property(nonatomic,retain) NSString *localImageResourceName;

@property (nonatomic, retain) NSString *userStatus;

@property(nonatomic,retain)NSString *applicationId;

@property (nonatomic) BOOL connected;

@property (nonatomic,retain) NSNumber *lastSeenAt;

@property (nonatomic,strong) NSNumber *unreadCount;

@property (nonatomic) BOOL block;
@property (nonatomic) BOOL blockBy;
@property (nonatomic,retain) NSNumber *userTypeId;
@property (nonatomic,retain) NSNumber *contactType;
@property (nonatomic,retain) NSNumber *deletedAtTime;
@property (nonatomic,retain) NSMutableDictionary *metadata;
@property (nonatomic,retain) NSNumber *roleType;
@property (nonatomic, strong) NSNumber *notificationAfterTime;
@property (nonatomic, strong) NSNumber *status;

- (instancetype)initWithDict:(NSDictionary * )dictionary;
- (void)populateDataFromDictonary:(NSDictionary *)dict;

- (NSString *)getDisplayName;
- (NSMutableDictionary *)getMetaDataDictionary:(NSString *)string;

- (BOOL)isNotificationMuted;
- (BOOL)isChatDisabled;
- (BOOL)isDisplayNameUpdateRequired;
- (NSMutableDictionary *)appendMetadataIn:(NSString *)metadataString;
- (BOOL)isDeleted;
@end
