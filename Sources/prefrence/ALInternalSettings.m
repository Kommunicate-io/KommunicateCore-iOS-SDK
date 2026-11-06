//
//  ALInternalSettings.m
//  Kommunicate
//
//  Created by apple on 13/05/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import "ALInternalSettings.h"
#import "ALUtilityClass.h"

@implementation ALInternalSettings

+ (void)setRegistrationStatusMessage:(NSString *)message {
    NSUserDefaults *userDefaults = [ALInternalSettings getUserDefaults];
    [userDefaults setValue:message forKey:KM_CORE_REGISTRATION_STATUS_MESSAGE];
    [userDefaults synchronize];
}

+ (NSString*)getRegistrationStatusMessage {
    NSUserDefaults *userDefaults = [ALInternalSettings getUserDefaults];
    NSString *pushRegistrationStatusMessage  =  [userDefaults valueForKey:KM_CORE_REGISTRATION_STATUS_MESSAGE];
    return pushRegistrationStatusMessage  != nil ? pushRegistrationStatusMessage : AL_REGISTERED;
}

+ (NSUserDefaults *)getUserDefaults {
    static NSUserDefaults *userDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[ALUtilityClass getAppGroupsName]];
    });
    return userDefaults;
}

@end
