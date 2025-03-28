//
//  ALInternalSettings.h
//  Kommunicate
//
//  Created by Sunil on 13/05/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const KM_CORE_REGISTRATION_STATUS_MESSAGE = @"io.kommunicate.core.userdefault.REGISTRATION_STATUS_MESSAGE";

static NSString *const AL_REGISTERED = @"AL_REGISTERED";

@interface ALInternalSettings : NSObject

+ (void)setRegistrationStatusMessage:(NSString *)message;
+ (NSString *)getRegistrationStatusMessage;

@end
