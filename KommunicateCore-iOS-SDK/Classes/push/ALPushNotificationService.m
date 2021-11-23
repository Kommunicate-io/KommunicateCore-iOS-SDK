//
//  ALPushNotificationService.m
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALPushNotificationService.h"
#import "ALMessageDBService.h"
#import "ALUserDetail.h"
#import "ALUserDefaultsHandler.h"
#import "ALPushAssist.h"
#import "ALUserService.h"
#import "ALRegisterUserClientService.h"
#import "ALAppLocalNotifications.h"
#import "ApplozicClient.h"
#import "ALLogger.h"
#import "ALContactDBService.h"

@implementation ALPushNotificationService

- (BOOL)isApplozicNotification:(NSDictionary *)dictionary {
    NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
    if (!type.length) {
        return NO;
    }
    ALSLog(ALLoggerSeverityInfo, @"APNs GOT NEW MESSAGE & NOTIFICATION TYPE :: %@", type);
    BOOL prefixCheck = ([type hasPrefix:APPLOZIC_PREFIX]) || ([type hasPrefix:@"MT_"]);
    return (type != nil && ([self.notificationTypes.allValues containsObject:type] || prefixCheck));
}

- (BOOL)processPushNotification:(NSDictionary *)dictionary updateUI:(NSNumber *)updateUI {

    ALSLog(ALLoggerSeverityInfo, @"APNS_DICTIONARY :: %@",dictionary.description);
    ALSLog(ALLoggerSeverityInfo, @"UPDATE UI VALUE :: %@",updateUI);
    ALSLog(ALLoggerSeverityInfo, @"UPDATE UI :: %@", ([updateUI isEqualToNumber:[NSNumber numberWithInt:1]]) ? @"ACTIVE" : @"BACKGROUND/INACTIVE");

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];

    if ([self isApplozicNotification:dictionary]) {
        NSString *alertValue;
        ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
        alertValue = ([ALUserDefaultsHandler getNotificationMode] == AL_NOTIFICATION_DISABLE ? @"" : [[dictionary valueForKey:@"aps"] valueForKey:@"alert"]);

        self.alSyncCallService = [[ALSyncCallService alloc] init];
        NSMutableDictionary *alertDictionary = [[NSMutableDictionary alloc] init];
        [alertDictionary setObject:updateUI forKey:@"updateUI"];

        NSString *type = (NSString *)[dictionary valueForKey:@"AL_KEY"];
        NSString *alValueJson = (NSString *)[dictionary valueForKey:@"AL_VALUE"];

        NSData *data = [alValueJson dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;
        NSDictionary *messageDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *notificationMessage = [messageDictionary valueForKey:@"message"];
        NSDictionary *metadataDictionary = [messageDictionary valueForKey:@"messageMetaData"];

        //CHECK for any special messages...
        if ([self processMetaData:messageDictionary withAlert:alertValue withUpdateUI:updateUI]) {
            return true;
        }

        NSString *notificationId = (NSString *)[messageDictionary valueForKey:@"id"];

        if (notificationId && [ALUserDefaultsHandler isNotificationProcessd:notificationId]) {
            ALSLog(ALLoggerSeverityInfo, @"Returning from ALPUSH because notificationId is already processed... %@",notificationId);
            BOOL isInactive = ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive);
            if (isInactive &&
                ([type isEqualToString:self.notificationTypes[@(AL_SYNC)]] ||
                 [type isEqualToString:self.notificationTypes[@(AL_MESSAGE_SENT)]])) {
                ALSLog(ALLoggerSeverityInfo, @"ALAPNs : APP_IS_INACTIVE");
                if ([type isEqualToString:self.notificationTypes[@(AL_MESSAGE_SENT)]]) {
                    if (([[notificationMessage componentsSeparatedByString:@":"][1] isEqualToString:[ALUserDefaultsHandler getDeviceKeyString]])) {
                        ALSLog(ALLoggerSeverityInfo, @"APNS: Sent by self-device ignore");
                        return YES;
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self assitingNotificationMessage:notificationMessage andDictionary:alertDictionary withMetadata:metadataDictionary];
                });
            } else {
                ALSLog(ALLoggerSeverityInfo, @"ALAPNs : APP_IS_ACTIVE");
            }

            return true;
        }

        if ([type isEqualToString:self.notificationTypes[@(AL_SYNC)]]) {
            ALSLog(ALLoggerSeverityInfo, @"ALPushNotificationService's SYNC CALL");
            [alertDictionary setObject:(alertValue ? alertValue : @"") forKey:@"alertValue"];
            [self assitingNotificationMessage:notificationMessage andDictionary:alertDictionary withMetadata:metadataDictionary];
            if (state == UIApplicationStateActive) {
                [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withDelegate:self.realTimeUpdate
                                           withCompletion:^(NSMutableArray *message, NSError *error) {

                }];
            }
        } else if ([type isEqualToString:@"MESSAGE_SENT"] ||
                   [type isEqualToString:self.notificationTypes[@(AL_MESSAGE_SENT)]]) {

            if (state == UIApplicationStateActive) {

                ALSLog(ALLoggerSeverityInfo, @"APNS: APPLOZIC_02 ARRIVED");
                ALSLog(ALLoggerSeverityInfo, @"\nNotification Message:%@\n\nDeviceString:%@\n", notificationMessage,
                       [ALUserDefaultsHandler getDeviceKeyString]);

                if (([[notificationMessage componentsSeparatedByString:@":"][1] isEqualToString:[ALUserDefaultsHandler getDeviceKeyString]])) {
                    ALSLog(ALLoggerSeverityInfo, @"APNS: Sent by self-device");
                    return YES;
                }

                [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withDelegate:self.realTimeUpdate  withCompletion:^(NSMutableArray *message, NSError *error) {
                    ALSLog(ALLoggerSeverityInfo, @"APPLOZIC_02 Sync Call Completed");
                }];

            }
        } else if ([type isEqualToString:@"MT_MESSAGE_DELIVERED"] ||
                   [type isEqualToString:self.notificationTypes[@(AL_DELIVERED)]]) {

            NSArray *deliveryParts = [[messageDictionary objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString *pairedKey = deliveryParts[0];
            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED];
            if (self.realTimeUpdate) {
                ALMessage *message = [messageDBService getMessageByKey:pairedKey];
                if (message) {
                    [self.realTimeUpdate onMessageDelivered:message];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"report_DELIVERED" object:deliveryParts[0] userInfo:dictionary];
        } else if ([type isEqualToString:@"MT_MESSAGE_DELIVERED_READ"] ||
                   [type isEqualToString:self.notificationTypes[@(AL_MESSAGE_DELIVERED_AND_READ)]]) {

            NSArray *deliveryParts = [[messageDictionary objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString *pairedKey = deliveryParts[0];
            NSString *contactId = deliveryParts.count>1 ? deliveryParts[1]:nil;

            ALMessage *existingMessage = [messageDBService getMessageByKey:pairedKey];
            // Skip the Update of Delivered in case of existing message is DELIVERED_AND_READ already.
            if (existingMessage &&
                (existingMessage.status.intValue == DELIVERED_AND_READ)) {
                return true;
            }

            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED_AND_READ];
            [[ NSNotificationCenter defaultCenter] postNotificationName:@"report_DELIVERED_READ" object:deliveryParts[0] userInfo:dictionary];
            if (self.realTimeUpdate) {
                if (existingMessage) {
                    existingMessage.status = [NSNumber numberWithInt:DELIVERED];
                    [self.realTimeUpdate onMessageDeliveredAndRead:existingMessage withUserId:contactId];
                }
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_CONVERSATION_DELETED)]]) {
            [messageDBService deleteAllMessagesByContact:notificationMessage orChannelKey:nil];
        } else if ([type isEqualToString:self.notificationTypes[@(AL_DELETE_MESSAGE)]]) {

            [messageDBService deleteMessageByKey: notificationMessage];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onMessageDeleted:notificationMessage];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_CONVERSATION_DELIVERED_AND_READ)]]){

            [self.alSyncCallService updateDeliveryStatusForContact:notificationMessage withStatus:DELIVERED_AND_READ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"report_CONVERSATION_DELIVERED_READ" object:notificationMessage];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onAllMessagesRead:notificationMessage];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_CONNECTED)]]) {

            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = notificationMessage;
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"update_USER_STATUS" object:alUserDetail];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onUpdateLastSeenAtStatus: alUserDetail];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_DISCONNECTED)]]) {

            NSArray *parts = [notificationMessage componentsSeparatedByString:@","];

            ALUserDetail *alUserDetail = [[ALUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"update_USER_STATUS" object:alUserDetail];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onUpdateLastSeenAtStatus:alUserDetail];
            }
        } else if ([type isEqualToString:@"APPLOZIC_15"]) {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService syncCallForChannel];
        } else if ([type isEqualToString:self.notificationTypes[@(AL_CONVERSATION_DELETED_NEW)]] ||
                   [type isEqualToString:@"CONVERSATION_DELETED"]) {

            NSArray *parts = [notificationMessage componentsSeparatedByString:@","];
            NSString *contactID = parts[0];
            NSString *conversationID = parts[1];

            [self.alSyncCallService updateTableAtConversationDeleteForContact:contactID
                                                               ConversationID:conversationID
                                                                   ChannelKey:nil];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onConversationDelete:contactID withGroupId:0];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_GROUP_CONVERSATION_DELETED)]] ||
                   [type isEqualToString:@"GROUP_CONVERSATION_DELETED"]) {

            NSNumber *groupID = [NSNumber numberWithInt:[notificationMessage intValue]];
            [self.alSyncCallService updateTableAtConversationDeleteForContact:nil
                                                               ConversationID:nil
                                                                   ChannelKey:groupID];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onConversationDelete:nil withGroupId:groupID];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_BLOCK)]]) {
            if ([self processUserBlockNotification:messageDictionary andUserBlockFlag:YES]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_BLOCK_NOTIFICATION" object:nil];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_UNBLOCK)]]) {
            if ([self processUserBlockNotification:messageDictionary andUserBlockFlag:NO]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_UNBLOCK_NOTIFICATION" object:nil];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_TEST_NOTIFICATION)]]) {
            ALSLog(ALLoggerSeverityInfo, @"Process Push Notification APPLOZIC_20");
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_DETAIL_CHANGED)]] ||
                   [type isEqualToString:self.notificationTypes[@(AL_USER_DELETE_NOTIFICATION)]]) {
            NSString *userId = notificationMessage;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_DETAILS_UPDATE_CALL" object:userId];
            if (self.realTimeUpdate) {
                ALUserService *userService = [[ALUserService alloc] init];
                [userService updateUserDetail:userId withCompletion:^(ALUserDetail *userDetail) {
                    [self.realTimeUpdate onUserDetailsUpdate:userDetail];
                }];
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_CONVERSATION_READ)]]) {
            //Conversation read for user
            ALUserService *userService = [[ALUserService alloc] init];
            NSString *userId = [messageDictionary objectForKey:@"message"];
            [userService updateConversationReadWithUserId:userId withDelegate:self.realTimeUpdate];
        } else if ([type isEqualToString:self.notificationTypes[@(AL_GROUP_CONVERSATION_READ)]]) {
            //Conversation read for channel
            ALChannelService *channelService = [[ALChannelService alloc] init];
            NSNumber *channelKey = [NSNumber numberWithInt:[[messageDictionary objectForKey:@"message"] intValue]];
            [channelService updateConversationReadWithGroupId:channelKey withDelegate:self.realTimeUpdate];
        } else if([type isEqualToString:self.notificationTypes[@(AL_USER_MUTE_NOTIFICATION)]]){

            NSArray *parts = [[messageDictionary objectForKey:@"message"] componentsSeparatedByString:@":"];
            NSString *userId = parts[0];
            NSString *flag = parts[1];

            ALContactDBService *contactDataBaseService = [[ALContactDBService alloc] init];

            if ([flag isEqualToString:@"0"]) {
                ALUserDetail *userDetail =  [contactDataBaseService updateMuteAfterTime:0 andUserId:userId];
                if(self.realTimeUpdate){
                    [self.realTimeUpdate onUserMuteStatus:userDetail];
                }
            } else if ([flag isEqualToString:@"1"]) {
                ALUserService *userService = [[ALUserService alloc]init];
                [userService getMutedUserListWithDelegate:self.realTimeUpdate withCompletion:^(NSMutableArray *userDetailArray, NSError *error) {

                }];
            }
        } else if([type isEqualToString:self.notificationTypes[@(AL_MESSAGE_METADATA_UPDATE)]]) {
            [ALMessageService syncMessageMetaData:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *message, NSError *error) {
                ALSLog(ALLoggerSeverityInfo, @"Successfully updated message metadata");
            }];
        } else if ([type isEqualToString:self.notificationTypes[@(AL_GROUP_MUTE_NOTIFICATION)]]) {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            NSArray *parts = [[messageDictionary objectForKey:@"message"] componentsSeparatedByString:@":"];
            if (parts.count == 2) {
                NSNumber * channelKey = [NSNumber numberWithInt:[parts[0] intValue]];
                NSNumber * notificationMuteTillTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
                [channelService updateMuteAfterTime:notificationMuteTillTime andChnnelKey:channelKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:ALChannelDidChangeGroupMuteNotification object:nil userInfo:@{@"CHANNEL_KEY": channelKey}];

                if (self.realTimeUpdate) {
                    [self.realTimeUpdate onChannelMute:channelKey];
                }
            }
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_ACTIVATED)]]) {
            [ALUserDefaultsHandler deactivateLoggedInUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALLoggedInUserDidChangeDeactivateNotification object:nil userInfo:@{@"DEACTIVATED": @"false"}];
        } else if ([type isEqualToString:self.notificationTypes[@(AL_USER_DEACTIVATED)]]) {
            [ALUserDefaultsHandler deactivateLoggedInUser:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALLoggedInUserDidChangeDeactivateNotification object:nil userInfo:@{@"DEACTIVATED": @"true"}];
        } else {
            ALSLog(ALLoggerSeverityInfo, @"APNs NOTIFICATION \"%@\" IS NOT HANDLED",type);
        }
        return TRUE;
    }

    return FALSE;
}

- (void)assitingNotificationMessage:(NSString *)notificationMsg andDictionary:(NSMutableDictionary *)dict withMetadata:(NSDictionary *)messageMetaData {

    if ([self isNotificationDisabled:messageMetaData]) {
        return;
    }

    ALPushAssist *pushAssist = [[ALPushAssist alloc] init];
    if (!pushAssist.isOurViewOnTop) {
        [dict setObject:@"apple push notification.." forKey:@"Calledfrom"];
        [pushAssist assist:notificationMsg withUserInfo:dict ofUser:notificationMsg];
    } else {
        ALSLog(ALLoggerSeverityInfo, @"ASSISTING : OUR_VIEW_IS_IN_TOP");
        // Message View Controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification"
                                                            object:notificationMsg
                                                          userInfo:dict];
        //Chat View Controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationIndividualChat"
                                                            object:notificationMsg
                                                          userInfo:dict];
    }
}

- (BOOL)isNotificationDisabled:(NSDictionary *)messageMetaData {

    if (!messageMetaData) {
        return NO;
    }

    NSString *notificationFlag = [messageMetaData objectForKey:@"show"];
    return (messageMetaData && notificationFlag && [notificationFlag isEqualToString:@"false"]);
}

- (BOOL)processMetaData:(NSDictionary *)dict withAlert:alertValue withUpdateUI:(NSNumber *)updateUI {

    NSDictionary *metadataDictionary = [dict valueForKey:@"messageMetaData"];

    if (metadataDictionary &&
        [metadataDictionary valueForKey:APPLOZIC_CATEGORY_KEY] &&
        [[metadataDictionary valueForKey:APPLOZIC_CATEGORY_KEY] isEqualToString:AL_CATEGORY_PUSHNNOTIFICATION]) {
        return true;
    }
    return false;
}

- (BOOL)processUserBlockNotification:(NSDictionary *)theMessageDict andUserBlockFlag:(BOOL)flag {
    NSArray *messageArray = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@":"];
    NSString *blockType = messageArray[0];
    NSString *userId = messageArray[1];
    ALContactDBService *contactDBService = [ALContactDBService new];
    if ([blockType isEqualToString:@"BLOCKED_BY"] || [blockType isEqualToString:@"UNBLOCKED_BY"]) {
        [contactDBService setBlockByUser:userId andBlockedByState:flag];
    } else if ([blockType isEqualToString:@"BLOCKED_TO"] || [blockType isEqualToString:@"UNBLOCKED_TO"]) {
        [contactDBService setBlockUser:userId andBlockedState:flag];
    } else {
        return NO;
    }

    if (self.realTimeUpdate) {
        [self.realTimeUpdate onUserBlockedOrUnBlocked:userId andBlockFlag:flag];
    }
    return  YES;
}

- (void)notificationArrivedToApplication:(UIApplication *)application withDictionary:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateInactive) {
        /* 
         # App is transitioning from background to foreground (user taps notification), do what you need when user taps here!

         # SYNC AND PUSH DETAIL VIEW CONTROLLER
         ALSLog(ALLoggerSeverityInfo, @"APP_STATE_INACTIVE APP_DELEGATE");
         */
        [self processPushNotification:userInfo updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
    } else if (application.applicationState == UIApplicationStateActive) {
        /*
         # App is currently active, can update badges count here

         # SYNC AND PUSH DETAIL VIEW CONTROLLER
         ALSLog(ALLoggerSeverityInfo, @"APP_STATE_ACTIVE APP_DELEGATE");
         */
        [self processPushNotification:userInfo updateUI:[NSNumber numberWithInt:APP_STATE_ACTIVE]];
    } else if(application.applicationState == UIApplicationStateBackground) {
        /* # App is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here

         # SYNC ONLY
         ALSLog(ALLoggerSeverityInfo, @"APP_STATE_BACKGROUND APP_DELEGATE");
         */
        [self processPushNotification:userInfo updateUI:[NSNumber numberWithInt:APP_STATE_BACKGROUND]];
    }
}

+ (void)applicationEntersForeground {}

+ (void)userSync {
    ALUserService *userService = [ALUserService new];
    [userService blockUserSync: [ALUserDefaultsHandler getUserBlockLastTimeStamp]];
}

- (BOOL)checkForLaunchNotification:(NSDictionary *)dictionary {
    [ALRegisterUserClientService isAppUpdated];

    ALAppLocalNotifications *localNotification = [ALAppLocalNotifications appLocalNotificationHandler];
    [localNotification dataConnectionNotificationHandler];

    if (dictionary != nil) {
        NSDictionary *notification = [dictionary objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

        if (notification) {
            [self processPushNotification:notification updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
        }
    }
    return false;
}

- (NSDictionary *)notificationTypes {
    static NSDictionary *messageKeyDictionary;
    if (!messageKeyDictionary) {
        messageKeyDictionary = @{@(AL_SYNC):@"APPLOZIC_01",
                                 @(AL_MESSAGE_SENT):@"APPLOZIC_02",
                                 @(AL_DELIVERED):@"APPLOZIC_04",
                                 @(AL_DELETE_MESSAGE):@"APPLOZIC_05",
                                 @(AL_CONVERSATION_DELETED):@"APPLOZIC_06",
                                 @(AL_MESSAGE_READ):@"APPLOZIC_07",
                                 @(AL_MESSAGE_DELIVERED_AND_READ):@"APPLOZIC_08",
                                 @(AL_CONVERSATION_READ):@"APPLOZIC_09",
                                 @(AL_CONVERSATION_DELIVERED_AND_READ):@"APPLOZIC_10",
                                 @(AL_USER_CONNECTED): @"APPLOZIC_11",
                                 @(AL_USER_DISCONNECTED):@"APPLOZIC_12",
                                 @(AL_USER_BLOCK):@"APPLOZIC_16",
                                 @(AL_USER_UNBLOCK):@"APPLOZIC_17",
                                 @(AL_TEST_NOTIFICATION):@"APPLOZIC_20",
                                 @(AL_GROUP_CONVERSATION_READ):@"APPLOZIC_21",
                                 @(AL_USER_MUTE_NOTIFICATION):@"APPLOZIC_37",
                                 @(AL_USER_DETAIL_CHANGED):@"APPLOZIC_30",
                                 @(AL_USER_DELETE_NOTIFICATION):@"APPLOZIC_34",
                                 @(AL_GROUP_CONVERSATION_DELETED):@"APPLOZIC_23",
                                 @(AL_CONVERSATION_DELETED_NEW):@"APPLOZIC_27",
                                 @(AL_MESSAGE_METADATA_UPDATE):@"APPLOZIC_33",
                                 @(AL_MTEXTER_USER):@"MTEXTER_USER",
                                 @(AL_CONTACT_VERIFIED):@"MT_CONTACT_VERIFIED",
                                 @(AL_DEVICE_CONTACT_SYNC):@"MT_DEVICE_CONTACT_SYNC",
                                 @(AL_MT_EMAIL_VERIFIED):@"MT_EMAIL_VERIFIED",
                                 @(AL_DEVICE_CONTACT_MESSAGE):@"MT_DEVICE_CONTACT_MESSAGE",
                                 @(AL_CANCEL_CALL):@"MT_CANCEL_CALL",
                                 @(AL_MESSAGE):@"MT_MESSAGE",
                                 @(AL_DELETE_MULTIPLE_MESSAGE):@"MT_DELETE_MULTIPLE_MESSAGE",
                                 @(AL_SYNC_PENDING):@"MT_SYNC_PENDING",
                                 @(AL_GROUP_MUTE_NOTIFICATION):@"APPLOZIC_39",
                                 @(AL_USER_ACTIVATED):@"APPLOZIC_18",
                                 @(AL_USER_DEACTIVATED):@"APPLOZIC_19",
        };
    }
    return  messageKeyDictionary;
}

@end
