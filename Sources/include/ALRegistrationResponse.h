//
//  ALRegistrationResponse.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"

@interface ALRegistrationResponse : KMCoreJson

@property NSString *message;
@property NSString *deviceKey;
@property NSString *userKey;
@property NSString *contactNumber;
@property NSString *lastSyncTime;
@property NSString *currentTimeStamp;
@property NSString *brokerURL;
@property NSString *imageLink;
@property NSString *statusMessage;
@property NSString *encryptionKey;
@property short pricingPackage;
@property NSString *displayName;
@property NSString* notificationSoundFileName;
@property NSMutableDictionary *metadata;
@property NSString *roleName;
@property short roleType;
@property NSString *userEncryptionKey;
@property NSString *authToken;

- (BOOL)isRegisteredSuccessfully;

@end
