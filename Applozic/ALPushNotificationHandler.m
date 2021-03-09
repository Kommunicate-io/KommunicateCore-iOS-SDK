//
//  ALPushNotificationHandler.m
//  ApplozicCore
//
//  Created by apple on 17/02/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALPushNotificationHandler.h"
#import "ALNotificationHelper.h"
#import <ApplozicCore/ApplozicCore.h>

@implementation ALPushNotificationHandler

+(ALPushNotificationHandler *) shared {
    static ALPushNotificationHandler * handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
    });
    return handler;
}

-(void)dataConnectionNotificationHandler {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(thirdPartyNotificationHandler:)
     name:@"showNotificationAndLaunchChat"
     object:nil];
}


// To DISPLAY THE NOTIFICATION ONLY ...from 3rd Party View.
-(void)thirdPartyNotificationHandler:(NSNotification *)notification
{
    if([ALApplozicSettings isSwiftFramework]) {
        return;
    }

    NSNumber *groupId = nil;
    NSString *contactId = nil;
    NSNumber *conversationId = nil;
    NSArray *notificationComponents = [notification.object componentsSeparatedByString:@":"];

    if(notificationComponents.count>2)
    {
        NSString *groupIdString = notificationComponents[1];
        groupId = [NSNumber numberWithInt:groupIdString.intValue];
        contactId = notificationComponents[2];
    } else if(notificationComponents.count == 2) {
        NSString *conversationIdString = notificationComponents[1];
        conversationId = [NSNumber numberWithInt:conversationIdString.intValue];
        contactId = notificationComponents[0];
    }else {
        contactId = notification.object;
    }
    NSDictionary *userInfo = notification.userInfo;
    NSNumber * updateUI = [userInfo valueForKey:@"updateUI"];
    NSString * alertValue = [userInfo valueForKey:@"alertValue"];

    if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]])
    {
        ALSLog(ALLoggerSeverityInfo, @"App launched from Background....Directly opening view from %@",userInfo);

        if(conversationId != nil){
            ALConversationService * conversationService = [[ALConversationService alloc]init];
            [conversationService fetchTopicDetails:conversationId withCompletion:^(NSError *error, ALConversationProxy *proxy) {
                if(error == nil){
                    [self notificationTapped:contactId withGroupId:groupId withConversationId: conversationId notificationTapActionDisable:NO]; //
                }else{
                    ALSLog(ALLoggerSeverityInfo, @"Error in fetching conversation :: %@",error);
                }
            }];
        }else{
            [self notificationTapped:contactId withGroupId:groupId withConversationId: conversationId notificationTapActionDisable:NO]; // Directly launching Chat
        }
        return;
    }

    if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]])
    {
        if( alertValue || alertValue.length >0)
        {
            ALSLog(ALLoggerSeverityInfo, @"posting to notification....%@",notification.userInfo);
            if (groupId && [ALChannelService isChannelMuted:groupId])
            {
                return;
            }
            if(groupId){

                [[ALChannelService new] getChannelInformation:groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel3) {
                    [ALUtilityClass thirdDisplayNotificationTS:alertValue andForContactId:contactId withGroupId:groupId completionHandler:^(BOOL handle) {
                        if (handle) {
                            [self notificationTapped:contactId
                                         withGroupId:groupId
                                  withConversationId:conversationId
                        notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
                        }
                    }];
                }];
            }else{
                if(conversationId != nil){
                    ALConversationService * conversationService = [[ALConversationService alloc]init];
                    [conversationService fetchTopicDetails:conversationId withCompletion:^(NSError *error, ALConversationProxy *proxy) {
                        if(error == nil){
                            [ALUtilityClass thirdDisplayNotificationTS:alertValue andForContactId:contactId withGroupId:groupId completionHandler:^(BOOL handle) {
                                if (handle) {
                                    [self notificationTapped:contactId
                                                 withGroupId:groupId
                                          withConversationId:proxy.Id
                                notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
                                }
                            }];
                        }else{
                            ALSLog(ALLoggerSeverityInfo, @"Error in fetching conversation :: %@",error);
                        }
                    }];

                }else{
                    [ALUtilityClass thirdDisplayNotificationTS:alertValue
                                               andForContactId:contactId
                                                   withGroupId:groupId completionHandler:^(BOOL handle) {
                        if (handle) {
                            [self notificationTapped:contactId
                                         withGroupId:groupId
                                  withConversationId:conversationId
                        notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
                        }
                    }];
                }
            }
        }
        else
        {
            ALSLog(ALLoggerSeverityInfo, @"Nil Alert Value");
        }
    }
    if([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_BACKGROUND]])
    {
        if(alertValue || alertValue.length >0)
        {
            ALPushAssist* assitant = [[ALPushAssist alloc] init];
            ALSLog(ALLoggerSeverityInfo, @"APP_STATE_BACKGROUND :: %@",notification.userInfo);
            if(!assitant.isOurViewOnTop)
            {
           //     [ALUtilityClass thirdDisplayNotificationTS:alertValue andForContactId:self.contactId withGroupId:groupId delegate:self];
            }
        }
    }
}

-(void)notificationTapped:(NSString *)contactId withGroupId:(NSNumber *)groupID withConversationId:(NSNumber *)conversationId notificationTapActionDisable:(BOOL) isTapActionDisabled
{
    ALPushAssist* pushAssistant = [[ALPushAssist alloc] init];
    ALSLog(ALLoggerSeverityInfo, @"Chat Launch Contact ID: %@",contactId);

    ALNotificationHelper * notificationHelper = [[ALNotificationHelper alloc]init];

    if(notificationHelper.isApplozicViewControllerOnTop) {
        [notificationHelper handlerNotificationClick:contactId withGroupId:groupID withConversationId:conversationId notificationTapActionDisable:isTapActionDisabled];
        return;
    }

    if (!isTapActionDisabled) {
        self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[ALUserDefaultsHandler getApplicationKey]];
        [self.chatLauncher launchIndividualChat:contactId withGroupId:groupID withConversationId:conversationId andViewControllerObject:pushAssistant.topViewController andWithText:nil];
    }
}


@end
