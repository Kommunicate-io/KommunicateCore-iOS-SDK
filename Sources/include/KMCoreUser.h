//
//  KMCoreUser.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ALJson.h"

typedef enum
{
    CLIENT = 0,
    APPLOZIC = 1,
    FACEBOOK = 2,
    
} AuthenticationType;

typedef enum
{
    AL_DEVELOPMENT = 0,
    AL_DISTRIBUTION = 1,

} deviceApnsType;

typedef enum
{
    PLATFORM_ANDROID = 1,
    PLATFORM_IOS = 2,
    PLATFORM_WEB = 3,
    PLATFORM_PHONE_GAP = 4,
    PLATFORM_API = 5,
    PLATFORM_FLUTTER = 6,
    PLATFORM_REACT_NATIVE = 7,
    PLATFORM_CAPACITOR = 8,
    PLATFORM_CORDOVA = 9,
    PLATFORM_IONIC = 10,
} Platform;

@interface KMCoreUser : ALJson

@property NSString *userId;
@property NSString *email;
@property NSString *password;
@property NSString *displayName;
@property NSString *registrationId;
@property NSString *applicationId;
@property NSString *contactNumber;
@property NSString *countryCode;
@property short prefContactAPI;
@property Boolean emailVerified;
@property NSString *timezone;
@property short appVersionCode;
@property NSString *roleName;
@property short deviceType;
@property NSString *imageLink;
@property NSString *appModuleName;
@property short userTypeId;
@property short notificationMode;
@property short authenticationTypeId;
@property short unreadCountType;
@property short deviceApnsType;
@property short pushNotificationFormat;
@property BOOL enableEncryption;
@property NSNumber *contactType;
@property NSMutableArray *features;
@property NSString *notificationSoundFileName;
@property NSMutableDictionary *metadata;
@property NSNumber *platform;

- (instancetype)initWithUserId:(NSString *)userId
                     password:(NSString *)password
                        email:(NSString *)email
               andDisplayName:(NSString *)displayName;

@end

