//
//  ALPushAssist.h
//  Kommunicate
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALPushAssist : NSObject

@property(nonatomic, readonly, strong) UIViewController *topViewController;

- (void)assist:(NSString *)notiMsg withUserInfo:(NSMutableDictionary *)dict ofUser:(NSString *)userId;
- (UIViewController *)topViewController;
- (BOOL)isOurViewOnTop;
- (BOOL)isMessageContainerOnTop;
- (BOOL)isVOIPViewOnTop;

+ (BOOL)isViewObjIsMsgContainerVC:(UIViewController *)viewObj;

@end
