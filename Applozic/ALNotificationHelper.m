//
//  ALNotificationHelper.m
//  Applozic
//
//  Created by apple on 19/12/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import "ALNotificationHelper.h"
#import <ApplozicCore/ApplozicCore.h>
#import <Applozic/ALSearchResultViewController.h>
#import "ALTabViewController.h"

@implementation ALNotificationHelper

-(BOOL)isApplozicViewControllerOnTop {

    ALPushAssist * alPushAssist = [[ALPushAssist alloc]init];
    NSString* topViewControllerName = NSStringFromClass(alPushAssist.topViewController.class);
    BOOL isApplozicVCOnTop =  ([topViewControllerName hasPrefix:@"AL"]
                               || [topViewControllerName hasPrefix:@"Applozic"]
                               || [topViewControllerName isEqualToString:@"CNContactPickerViewController"]
                               || [topViewControllerName isEqualToString:@"CAMImagePickerCameraViewController"]
                               || [topViewControllerName isEqualToString:@"PHPickerViewController"]
                               || [alPushAssist isOurViewOnTop]
                               || [[alPushAssist.topViewController presentingViewController] isKindOfClass:ALTabViewController.class]);

    if (!isApplozicVCOnTop) {
        /// Get the childViewControllers if the chat view is launched directly and check rootVC is ALChatViewController
        NSArray<UIViewController *> *childViewControllers = [alPushAssist.topViewController presentingViewController].childViewControllers;
        if (childViewControllers.count) {
            UIViewController * firstViewController = childViewControllers.firstObject;
            if ([firstViewController isKindOfClass:ALChatViewController.class]) {
                return YES;
            }
        }
    }

    return isApplozicVCOnTop;
}

-(void)handlerNotificationClick:(NSString *)contactId withGroupId:(NSNumber *)groupID withConversationId:(NSNumber *)conversationId notificationTapActionDisable:(BOOL)isTapActionDisabled {

    ALPushAssist * alPushAssist = [[ALPushAssist alloc]init];
    if (isTapActionDisabled || [alPushAssist isVOIPViewOnTop]) {
        ALSLog(ALLoggerSeverityInfo, @"Notification tap is disabled");
        return;
    }

    if (groupID != nil) {
        contactId = nil;
        conversationId = nil;
    }

    if ([alPushAssist.topViewController isKindOfClass:[ALMessagesViewController class]]
        || ([alPushAssist.topViewController isKindOfClass:[ALSearchResultViewController class]]
            && [alPushAssist.topViewController presentingViewController])) {

        [self openConversationViewFromListVC:contactId withGroupId:groupID withConversationId:conversationId];

    } else if ([alPushAssist.topViewController isKindOfClass:[ALChatViewController class]]) {

        ALChatViewController * viewController = (ALChatViewController*)alPushAssist.topViewController;
        [viewController refreshViewOnNotificationTap:contactId withChannelKey:groupID withConversationId:conversationId];

    } else if ([alPushAssist.topViewController isKindOfClass:[ALUserProfileVC class]]) {
        ALChatLauncher *chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[ALUserDefaultsHandler getApplicationKey]];
        [chatLauncher launchIndividualChat:contactId
                               withGroupId:groupID
                        withConversationId:conversationId andViewControllerObject:alPushAssist.topViewController
                               andWithText:nil];
    } else if ([alPushAssist.topViewController isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]) {
        ALChatLauncher *chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[ALUserDefaultsHandler getApplicationKey]];
        [chatLauncher launchIndividualChat:contactId
                               withGroupId:groupID
                        withConversationId:conversationId andViewControllerObject:alPushAssist.topViewController
                               andWithText:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkControllerAndDismissIfRequired:alPushAssist.topViewController withCompletion:^(BOOL handleClick) {
                if(handleClick) {
                    [self handlerNotificationClick:contactId withGroupId:groupID withConversationId:conversationId notificationTapActionDisable:isTapActionDisabled];
                }
            }];

        });
    }

}

-(void)openConversationViewFromListVC:(NSString *)contactId withGroupId:(NSNumber *)groupID withConversationId:(NSNumber *)conversationId {
    dispatch_async(dispatch_get_main_queue(), ^{

        ALPushAssist *alPushAssist = [[ALPushAssist alloc] init];
        ALMessagesViewController* messagesViewController = (ALMessagesViewController*)alPushAssist.topViewController;

        messagesViewController.channelKey = groupID;
        messagesViewController.userIdToLaunch = contactId;
        messagesViewController.conversationId = conversationId;

        [messagesViewController createDetailChatViewControllerWithUserId:messagesViewController.userIdToLaunch withGroupId:messagesViewController.channelKey withConversationId:messagesViewController.conversationId];
    });

}

-(void)checkControllerAndDismissIfRequired:(UIViewController*)viewController withCompletion:(void(^)(BOOL handleClick))completion {

    if(![self isApplozicViewControllerOnTop]){
        completion(NO);
        return;
    }

    if ([viewController isKindOfClass:[ALMessagesViewController class]]
        || [viewController isKindOfClass: [ALChatViewController class]]) {
        completion(YES);
        return;
    }

    if (viewController.navigationController != nil
        && [viewController.navigationController popViewControllerAnimated:NO] != nil) {
        completion(YES);
        return;
    }
    [viewController dismissViewControllerAnimated:YES completion:^ {
        completion(YES);
    }];
}

@end
