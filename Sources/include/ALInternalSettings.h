//
//  ALInternalSettings.h
//  Applozic
//
//  Created by Sunil on 13/05/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const AL_REGISTRATION_STATUS_MESSAGE = @"com.applozic.userdefault.REGISTRATION_STATUS_MESSAGE";

static NSString *const AL_REGISTERED = @"AL_REGISTERED";

@interface ALInternalSettings : NSObject

+ (void)setRegistrationStatusMessage:(NSString *)message;
+ (NSString *)getRegistrationStatusMessage;

@end
