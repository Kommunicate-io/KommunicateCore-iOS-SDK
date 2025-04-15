//
//  ALPushAssist.m
//  Kommunicate
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALPushAssist.h"

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"
#import "KMCoreUserDetail.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALAppLocalNotifications.h"
#import "ALLogger.h"

@implementation ALPushAssist
// WHEN NON-APPLOZIC VIEWs OPENED
- (void)assist:(NSString *)notiMsg withUserInfo:(NSMutableDictionary *)dict ofUser:(NSString*)userId {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotificationAndLaunchChat"
                                                        object:notiMsg
                                                      userInfo:dict];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:@"showNotificationAndLaunchChat"];
}

- (BOOL)isOurViewOnTop {
    NSArray *VCList = [KMCoreSettings getListOfViewControllers];
    if (VCList) {
        for (NSString * className in VCList) {
            if ([self.topViewController isKindOfClass:NSClassFromString(className)]) {
                return YES;
            }
        }
    }
    return [self isVOIPViewOnTop] || [self isMessageContainerOnTop];
}

- (BOOL)isMessageContainerOnTop {
    return ([self.topViewController isKindOfClass:NSClassFromString([KMCoreSettings getMsgContainerVC])]);
}

- (BOOL)isVOIPViewOnTop {
    ALSLog(ALLoggerSeverityInfo, @"VOIP_VIEW : %@",self.topViewController);
    return ([self.topViewController isKindOfClass:NSClassFromString([KMCoreSettings getAudioVideoClassName])]);
}

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController*)rootViewController;
        
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
        
    } else if (rootViewController.presentedViewController) {
        
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
        
    } else {
        return rootViewController;
    }
}

+ (BOOL)isViewObjIsMsgContainerVC:(UIViewController *)viewObj {
    return ([viewObj isKindOfClass:NSClassFromString([KMCoreSettings getMsgContainerVC])]);
}

@end
