//
//  ALApplicationInfo.m
//  Kommunicate
//
//  Created by Mukesh Thawani on 05/06/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import "ALApplicationInfo.h"
#import "ALUtilityClass.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALConstant.h"

@implementation ALApplicationInfo


- (BOOL)isChatSuspended {
    BOOL debugflag = [ALUtilityClass isThisDebugBuild];

    if (debugflag) {
        return NO;
    }
    if ([KMCoreUserDefaultsHandler getUserPricingPackage] == AL_CLOSED
       || [KMCoreUserDefaultsHandler getUserPricingPackage] == AL_BETA
       || [KMCoreUserDefaultsHandler getUserPricingPackage] == AL_SUSPENDED) {
        return YES;
    }
    return NO;
}

- (BOOL)showPoweredByMessage {
    BOOL debugflag = [ALUtilityClass isThisDebugBuild];
    if (debugflag) {
        return NO;
    }
    if ([KMCoreUserDefaultsHandler getUserPricingPackage] == AL_STARTER) {
        return YES;
    }
    return NO;
}

@end
