//
//  ALMQTTConversationService.m
//  Kommunicate
//
//  Created by Kommunicate on 11/27/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "ALMQTTConversationService.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALConstant.h"
#import "ALMessage.h"
#import "ALMessageDBService.h"
#import "KMCoreUserDetail.h"
#import "ALPushAssist.h"
#import "ALChannelService.h"
#import "ALContactDBService.h"
#import "ALMessageService.h"
#import "ALUserService.h"
#import "NSData+AES.h"
#import "ALDataNetworkConnection.h"
#import "ALPushNotificationService.h"
#import "ALRegisterUserClientService.h"
#import "ALAuthService.h"
#import "ALDataNetworkConnection.h"
#import "ALLogger.h"

static NSString *const MQTT_TOPIC_STATUS = @"status-v2";
static NSString *const MQTT_ENCRYPTION_SUB_KEY = @"encr-";
static NSString *const observeSupportGroupMessage = @"observeSupportGroupMessage";
NSString *const ALChannelDidChangeGroupMuteNotification = @"ALChannelDidChangeGroupMuteNotification";
NSString *const ALLoggedInUserDidChangeDeactivateNotification = @"ALLoggedInUserDidChangeDeactivateNotification";
NSString *const AL_MESSAGE_STATUS_TOPIC = @"message-status";

@implementation ALMQTTConversationService

/*
 Notification types :

 MESSAGE_RECEIVED("APPLOZIC_01"),
 MESSAGE_SENT("APPLOZIC_02"),
 MESSAGE_SENT_UPDATE("APPLOZIC_03"),
 MESSAGE_DELIVERED("APPLOZIC_04"),
 MESSAGE_DELETED("APPLOZIC_05"),
 CONVERSATION_DELETED("APPLOZIC_06"),
 MESSAGE_READ("APPLOZIC_07"),
 MESSAGE_DELIVERED_AND_READ("APPLOZIC_08"),
 CONVERSATION_READ("APPLOZIC_09"),
 CONVERSATION_DELIVERED_AND_READ("APPLOZIC_10"),
 USER_CONNECTED("APPLOZIC_11"),
 USER_DISCONNECTED("APPLOZIC_12"),
 GROUP_DELETED("APPLOZIC_13"),
 GROUP_LEFT("APPLOZIC_14"),
 GROUP_SYNC("APPLOZIC_15"),
 USER_BLOCKED("APPLOZIC_16"),
 USER_UN_BLOCKED("APPLOZIC_17"),
 ACTIVATED("APPLOZIC_18"),
 DEACTIVATED("APPLOZIC_19"),
 REGISTRATION("APPLOZIC_20"),
 GROUP_CONVERSATION_READ("APPLOZIC_21"),
 GROUP_MESSAGE_DELETED("APPLOZIC_22"),
 GROUP_CONVERSATION_DELETED("APPLOZIC_23"),
 APPLOZIC_TEST("APPLOZIC_24"),
 USER_ONLINE_STATUS("APPLOZIC_25"),
 CONTACT_SYNC("APPLOZIC_26"),
 CONVERSATION_DELETED_NEW("APPLOZIC_27"),
 CONVERSATION_DELIVERED_AND_READ_NEW("APPLOZIC_28"),
 CONVERSATION_READ_NEW("APPLOZIC_29"),
 USER_DETAIL_CHANGED("APPLOZIC_30"),
 MESSAGE_METADATA_UPDATE("APPLOZIC_33"),
 USER_DELETE_NOTIFICATION("APPLOZIC_34"),
 USER_MUTE_NOTIFICATION("APPLOZIC_37");

 */

+ (ALMQTTConversationService *)sharedInstance {
    static ALMQTTConversationService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALMQTTConversationService alloc] init];
        sharedInstance.alSyncCallService = [[ALSyncCallService alloc] init];
    });
    return sharedInstance;
}

- (NSString *)getNotificationObjectFromMessage:(ALMessage *)message {
    if (message.groupId != nil) {
        return [NSString stringWithFormat:@"AL_GROUP:%@:%@",message.groupId.stringValue,message.contactIds];
    } else if (message.conversationId != nil) {
        return [NSString stringWithFormat:@"%@:%@",message.contactIds,message.conversationId.stringValue];
    } else {
        return [[NSString alloc] initWithString:message.contactIds];
    }
}

- (void)connectToMQTTWithCompletionHandler:(void (^)(BOOL isConnected,NSError *errror))completion {

    @try
    {
        if (![KMCoreUserDefaultsHandler isLoggedIn]) {
            NSError *userIsNotLoginErrror =  [NSError errorWithDomain:@"KMCore" code:1 userInfo:[NSDictionary dictionaryWithObject:@"User is not logged in" forKey:NSLocalizedDescriptionKey]];
            completion(false, userIsNotLoginErrror);
            return;
        }

        if (self.session && self.session.status == MQTTSessionStatusConnecting ) {
            NSError *sessionConnectingError = [NSError errorWithDomain:@"KMCore" code:1 userInfo:@{NSLocalizedDescriptionKey : @"MQTT session connection in progress"}];
            completion(false, sessionConnectingError);
            return;
        }

        if (self.session && (self.session.status == MQTTSessionEventConnected || self.session.status == MQTTSessionStatusConnected)) {
            ALSLog(ALLoggerSeverityInfo, @"MQTT : IGNORING REQUEST, ALREADY CONNECTED");
            completion(true, nil);
            return;
        }

        ALAuthService *authService = [[ALAuthService alloc] init];
        [authService validateAuthTokenAndRefreshWithCompletion:^(NSError *error) {

            if (error) {
                completion(false, error);
                return;
            }

            ALSLog(ALLoggerSeverityInfo, @"MQTT : CONNECTING_MQTT_SERVER");
            self.session = [[MQTTSession alloc]init];
            self.session.clientId = [NSString stringWithFormat:@"%@-%f",
                                     [KMCoreUserDefaultsHandler getUserKeyString],fmod([[NSDate date] timeIntervalSince1970], 10.0)];

            NSString *willMsg = [NSString stringWithFormat:@"%@,%@,%@",[KMCoreUserDefaultsHandler getUserKeyString],[KMCoreUserDefaultsHandler getDeviceKeyString],@"0"];

            if ([KMCoreUserDefaultsHandler getAuthToken]) {
                self.session.userName = [KMCoreUserDefaultsHandler getApplicationKey];
                self.session.password = [KMCoreUserDefaultsHandler getAuthToken];
            }

            self.session.willFlag = YES;
            self.session.willTopic = MQTT_TOPIC_STATUS;
            self.session.willMsg = [willMsg dataUsingEncoding:NSUTF8StringEncoding];
            self.session.willQoS = MQTTQosLevelAtMostOnce;
            [self.session setDelegate:self];

            MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
            transport.host = MQTT_URL;
            transport.port = [MQTT_PORT intValue];
            self.session.transport = transport;
            ALSLog(ALLoggerSeverityInfo, @"MQTT : WAITING_FOR_CONNECT...");

            [self.session connectWithConnectHandler:^(NSError *error) {

                if (error != nil) {
                    completion(false, error);
                    return;
                }

                ALSLog(ALLoggerSeverityInfo, @"MQTT : CONNECTED");

                NSString *publishString = [NSString stringWithFormat:@"%@,%@,%@", [KMCoreUserDefaultsHandler getUserKeyString], [KMCoreUserDefaultsHandler getDeviceKeyString],@"1"];

                [self.session publishAndWaitData:[publishString dataUsingEncoding:NSUTF8StringEncoding] onTopic:MQTT_TOPIC_STATUS retain:NO qos:MQTTQosLevelAtMostOnce timeout:30];

                completion(true, nil);
            }];
        }];
    } @catch (NSException *e) {
        ALSLog(ALLoggerSeverityError, @"MQTT : EXCEPTION_IN_CONNECTION :: %@", e.description);
    }
}

- (void)subscribeToConversation {
    [self subscribeToConversationWithTopic:[KMCoreUserDefaultsHandler getUserKeyString]];
}

- (void)subscribeToConversationWithTopic:(NSString *) topic {
    [self subscribeToConversationWithTopic:topic withCompletionHandler:^(BOOL subscribed, NSError *error) {
        if (error) {
            ALSLog(ALLoggerSeverityError, @"MQTT : ERROR_IN_SUBSCRIBE :: %@", error.description);
            if ([error.description  isEqual: @"MQTT CONNACK: bad user name or password"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT_UNAUTHORIZED_USER"
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
    }];
}

- (void)subscribeToConversationWithTopic:(NSString *)topic withCompletionHandler:(void (^)(BOOL subscribed, NSError *error))completion {

    dispatch_async(dispatch_get_main_queue (),^{
        @try {
            if (![KMCoreUserDefaultsHandler isLoggedIn]) {
                NSError *userIsNotLoginErrror = [NSError errorWithDomain:@"KMCore" code:1 userInfo:@{NSLocalizedDescriptionKey : @"User is not logged in"}];
                completion(false, userIsNotLoginErrror);
                return;
            }

            [self connectToMQTTWithCompletionHandler:^(BOOL isConnected, NSError *error) {

                if (error != nil) {
                    ALSLog(ALLoggerSeverityError, @"MQTT : subscribe to conversation error :: %@", error.description);
                    completion(false, error);
                    return;
                }

                if (isConnected) {
                    ALSLog(ALLoggerSeverityInfo, @"MQTT : SUBSCRIBING TO CONVERSATION TOPICS");

                    NSDictionary<NSString *, NSNumber *> *subscribeTopicsDictionary = [[NSMutableDictionary alloc] init];

                    if ([KMCoreUserDefaultsHandler getUserEncryptionKey]) {
                        [subscribeTopicsDictionary setValue:@(MQTTQosLevelAtMostOnce) forKey:[NSString stringWithFormat:@"%@%@",MQTT_ENCRYPTION_SUB_KEY, topic]];
                    }

                    if (!topic) {
                        NSError *topicNilError = [NSError errorWithDomain:@"KMCore" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Failed to subscribe topic is nil"}];
                        completion(false, topicNilError);
                        return;
                    }

                    [subscribeTopicsDictionary setValue:@(MQTTQosLevelAtMostOnce) forKey:topic];
                    /// Subscribe to both the topics with encr prefix and without encr prefix

                    [self.session subscribeToTopics:subscribeTopicsDictionary subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {

                        if (error) {
                            completion(false, error);
                            return;
                        }

                        [KMCoreUserDefaultsHandler setLoggedInUserSubscribedMQTT:YES];
                        [self.mqttConversationDelegate mqttDidConnected];
                        if (self.realTimeUpdate) {
                            [self.realTimeUpdate onMqttConnected];
                        }
                        completion(true, nil);
                    }];
                }
            }];
        }
        @catch (NSException *e) {
            ALSLog(ALLoggerSeverityError, @"MQTT : EXCEPTION_IN_SUBSCRIBE :: %@", e.description);
        }
    });
}

- (void)session:(MQTTSession*)session newMessage:(NSData*)data onTopic:(NSString*)topic {
    ALSLog(ALLoggerSeverityInfo, @"MQTT: GOT_NEW_MESSAGE");
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {

    if (![KMCoreUserDefaultsHandler getUserKeyString]) {
        return;
    }

    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc]init];

    NSString *fullMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if ([KMCoreUserDefaultsHandler getUserEncryptionKey] && [topic hasPrefix:MQTT_ENCRYPTION_SUB_KEY]) {

        ALSLog(ALLoggerSeverityInfo, @"Key : %@",  [KMCoreUserDefaultsHandler getUserEncryptionKey]);
        NSData *base64DecodedData = [[NSData alloc] initWithBase64EncodedData:data options:0];
        NSData *theData = [base64DecodedData AES128DecryptedDataWithKey:[KMCoreUserDefaultsHandler getUserEncryptionKey]];
        NSString *dataToString = [NSString stringWithUTF8String:[theData bytes]];
        ALSLog(ALLoggerSeverityInfo, @"Data to String : %@",  dataToString);
        data = [dataToString dataUsingEncoding:NSUTF8StringEncoding];

        ALSLog(ALLoggerSeverityInfo, @"MQTT_GOT_NEW_MESSAGE after decyption : %@", dataToString);
    }

    ALSLog(ALLoggerSeverityInfo, @"MQTT_GOT_NEW_MESSAGE : %@", fullMessage);

    if (!fullMessage) {
        return;
    }

    NSError *error = nil;
    NSDictionary *theMessageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSString *type = [theMessageDict objectForKey:@"type"];
    ALSLog(ALLoggerSeverityInfo, @"MQTT_NOTIFICATION_TYPE :: %@",type);
    NSString *notificationId = (NSString*)[theMessageDict valueForKey:@"id"];

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        ALSLog(ALLoggerSeverityInfo, @"Returing coz Application State is Background OR Our View is NOT on Top");
        if ([topic hasPrefix:@"typing"]) {
            [self subProcessTyping:fullMessage];
        }
        return;
    }

    if (notificationId && [KMCoreUserDefaultsHandler isNotificationProcessd:notificationId]) {
        ALSLog(ALLoggerSeverityInfo, @"MQTT : NOTIFICATION-ID ALREADY PROCESSED :: %@",notificationId);
        return;
    }

    if ([topic hasPrefix:@"typing"]) {
        [self subProcessTyping:fullMessage];
    } else {
        if ([type isEqualToString: @"MESSAGE_RECEIVED"] || [type isEqualToString:pushNotificationService.notificationTypes[@(AL_SYNC)]]) {

            ALPushAssist *pushAssist = [[ALPushAssist alloc] init];
            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:[theMessageDict objectForKey:@"message"]];
            
            if (alMessage.isConversationDeleted) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CONVERSATION_DELETED" object:alMessage];
            }
            
            if ([alMessage isHiddenMessage]) {
                ALSLog(ALLoggerSeverityInfo, @"< HIDDEN MESSAGE RECEIVED >");
                [ALMessageService getLatestMessageForUser:[KMCoreUserDefaultsHandler getDeviceKeyString] withDelegate:self.realTimeUpdate
                                           withCompletion:^(NSMutableArray *message, NSError *error) { }];
            } else {
                NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
                [notificationDictionary setObject:[alMessage getLastMessage] forKey:@"alertValue"];
                [notificationDictionary setObject:[NSNumber numberWithInt:APP_STATE_ACTIVE] forKey:@"updateUI"];

                if (alMessage.groupId != nil) {
                    ALChannelService *channelService = [[ALChannelService alloc] init];
                    [channelService getChannelInformation:alMessage.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {

                        if (alChannel && alChannel.type == OPEN) {
                            if (alMessage.deviceKey && [alMessage.deviceKey isEqualToString:[KMCoreUserDefaultsHandler getDeviceKeyString]]) {
                                ALSLog(ALLoggerSeverityInfo, @"MQTT : RETURNING,GOT MY message");
                                return;
                            }

                            [ALMessageService addOpenGroupMessage:alMessage withDelegate:self.realTimeUpdate];
                            if (!pushAssist.isOurViewOnTop) {
                                [notificationDictionary setObject:@"mqtt" forKey:@"Calledfrom"];
                                [pushAssist assist:[self getNotificationObjectFromMessage:alMessage] withUserInfo:notificationDictionary ofUser:alMessage.contactIds];
                            } else {
                                [self.alSyncCallService syncCall:alMessage withDelegate:self.realTimeUpdate];
                                [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
                            }
                        } else {
                            [self syncReceivedMessage: alMessage withNSMutableDictionary:notificationDictionary];
                        }
                    }];
                } else {
                    [self syncReceivedMessage: alMessage withNSMutableDictionary:notificationDictionary];
                }
            }
        } else if ([type isEqualToString:@"MESSAGE_SENT"] || [type isEqualToString:pushNotificationService.notificationTypes[@(AL_MESSAGE_SENT)]]) {
            NSDictionary *message = [theMessageDict objectForKey:@"message"];
            ALMessage *alMessage = [[ALMessage alloc] initWithDictonary:message];

            ALSLog(ALLoggerSeverityInfo, @"ALMESSAGE's DeviceKey : %@ \n Current DeviceKey : %@", alMessage.deviceKey, [KMCoreUserDefaultsHandler getDeviceKeyString]);
            if (alMessage.deviceKey && [alMessage.deviceKey isEqualToString:[KMCoreUserDefaultsHandler getDeviceKeyString]]) {
                ALSLog(ALLoggerSeverityInfo, @"MQTT : RETURNING, SENT_BY_SELF_DEVICE");
                return;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:observeSupportGroupMessage object:alMessage];

            [ALMessageService getMessageSENT:alMessage withDelegate: self.realTimeUpdate withCompletion:^(NSMutableArray *messageArray, NSError *error) {

                if (messageArray.count > 0) {
                    [self.alSyncCallService syncCall:alMessage];
                    [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
                }
            }];

            NSString *key = [message valueForKey:@"pairedMessageKey"];
            NSString *contactID = [message valueForKey:@"contactIds"];
            [self.alSyncCallService updateMessageDeliveryReport:key withStatus:SENT];
            [self.mqttConversationDelegate delivered:key contactId:contactID withStatus:SENT];

        } else if ([type isEqualToString:@"MESSAGE_DELIVERED"] || [type isEqualToString:pushNotificationService.notificationTypes[@(AL_DELIVERED)]]) {

            NSArray *deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString *pairedKey = deliveryParts[0];
            NSString *contactId = (deliveryParts.count > 1) ? deliveryParts[1] : nil;

            ALMessageDBService *messageDataBaseService = [[ALMessageDBService alloc] init];
            ALMessage *existingMessage = [messageDataBaseService getMessageByKey:pairedKey];
            // Skip the Update of Delivered in case of existing message is DELIVERED_AND_READ already.
            if (existingMessage &&
                (existingMessage.status.intValue == DELIVERED_AND_READ)) {
                return;
            }

            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED];
            [self.mqttConversationDelegate delivered:pairedKey contactId:contactId withStatus:DELIVERED];

            if (existingMessage) {
                existingMessage.status = [NSNumber numberWithInt:DELIVERED];
                [self.realTimeUpdate onMessageDelivered:existingMessage];
            }
        } else if ([type isEqualToString:@"MESSAGE_DELETED"] ||
                   [type isEqualToString:pushNotificationService.notificationTypes[@(AL_DELETE_MESSAGE)]]) {
            NSString *messageKey = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@","][0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_MESSAGE_DELETED" object:messageKey];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onMessageDeleted:messageKey];
            }
        } else if ([type isEqualToString:@"MESSAGE_DELIVERED_READ"] ||
                   [type isEqualToString:pushNotificationService.notificationTypes[@(AL_MESSAGE_DELIVERED_AND_READ)]]) {
            NSArray  *deliveryParts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString *pairedKey = deliveryParts[0];
            NSString *contactId = deliveryParts.count>1 ? deliveryParts[1]:nil;

            [self.alSyncCallService updateMessageDeliveryReport:pairedKey withStatus:DELIVERED_AND_READ];
            [self.mqttConversationDelegate delivered:pairedKey contactId:contactId withStatus:DELIVERED_AND_READ];
            if (self.realTimeUpdate) {
                ALMessageDBService *messageDbService = [[ALMessageDBService alloc]init];
                ALMessage*message = [messageDbService getMessageByKey:pairedKey];
                if (message) {
                    [self.realTimeUpdate onMessageDeliveredAndRead:message withUserId:contactId];
                }
            }
        } else if ([type isEqualToString:@"CONVERSATION_DELIVERED_AND_READ"] ||
                   [type isEqualToString:pushNotificationService.notificationTypes[@(AL_CONVERSATION_DELIVERED_AND_READ)]]) {
            NSString *contactId = [theMessageDict objectForKey:@"message"];
            [self.alSyncCallService updateDeliveryStatusForContact: contactId withStatus:DELIVERED_AND_READ];
            [self.mqttConversationDelegate updateStatusForContact:contactId withStatus:DELIVERED_AND_READ];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onAllMessagesRead:contactId];
            }
        } else if ([type isEqualToString:@"USER_CONNECTED"]||[type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_CONNECTED)]]) {
            KMCoreUserDetail *alUserDetail = [[KMCoreUserDetail alloc] init];
            alUserDetail.userId = [theMessageDict objectForKey:@"message"];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] *1000];
            alUserDetail.connected = YES;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onUpdateLastSeenAtStatus: alUserDetail];
            }
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_DISCONNECTED)]]) {
            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];

            KMCoreUserDetail *alUserDetail = [[KMCoreUserDetail alloc] init];
            alUserDetail.userId = parts[0];
            alUserDetail.lastSeenAtTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
            alUserDetail.connected = NO;
            [self.alSyncCallService updateConnectedStatus: alUserDetail];
            [self.mqttConversationDelegate updateLastSeenAtStatus: alUserDetail];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onUpdateLastSeenAtStatus: alUserDetail];
            }
        } else if ([type isEqualToString:@"APPLOZIC_15"]) {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            [channelService syncCallForChannel];
            // TODO HANDLE
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_CONVERSATION_DELETED_NEW)]] ||
                   [type isEqualToString:@"CONVERSATION_DELETED"]) {

            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@","];
            NSString *contactID = parts[0];
            NSString *conversationID = parts[1];

            [self.alSyncCallService updateTableAtConversationDeleteForContact:contactID
                                                               ConversationID:conversationID
                                                                   ChannelKey:nil];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onConversationDelete:contactID withGroupId:nil];
            }

        } else if ([type isEqualToString:@"GROUP_CONVERSATION_DELETED"] ||
                   [type isEqualToString:pushNotificationService.notificationTypes[@(AL_GROUP_CONVERSATION_DELETED)]]) {

            NSNumber *groupID = [NSNumber numberWithInt:[[theMessageDict objectForKey:@"message"] intValue]];
            [self.alSyncCallService updateTableAtConversationDeleteForContact:nil
                                                               ConversationID:nil
                                                                   ChannelKey:groupID];
            if (self.realTimeUpdate) {
                [self.realTimeUpdate onConversationDelete:nil withGroupId:groupID];
            }
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_BLOCK)]]) {
            [self processUserBlockNotification:theMessageDict andUserBlockFlag:YES];
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_UNBLOCK)]]) {
            [self processUserBlockNotification:theMessageDict andUserBlockFlag:NO];
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_DETAIL_CHANGED)]] ||
                   [type isEqualToString: pushNotificationService.notificationTypes[@(AL_USER_DELETE_NOTIFICATION)]]) {
            //          FETCH USER DETAILS and UPDATE DB AND REAL-TIME
            NSString *userId = [theMessageDict objectForKey:@"message"];
            [self.mqttConversationDelegate updateUserDetail:userId];
            if (self.realTimeUpdate) {
                ALUserService *userService = [[ALUserService alloc] init];
                [userService updateUserDetail:userId withCompletion:^(KMCoreUserDetail *userDetail) {
                    [self.realTimeUpdate onUserDetailsUpdate:userDetail];
                }];
            }
        } else if ([type isEqualToString:@"APPLOZIC_31"]) {
            // BROADCAST MESSAGE : MESSAGE_DELIVERED
        } else if ([type isEqualToString:@"APPLOZIC_32"]) {
            // BROADCAST MESSAGE : MESSAGE_DELIVERED_AND_READ
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_MESSAGE_METADATA_UPDATE)]]) { // MESSAGE_METADATA_UPDATE
            @try {
                NSDictionary *messageDict = [theMessageDict objectForKey:@"message"];
                ALMessage *alMessage = [[ALMessage alloc] initWithDictonary: messageDict];
                if (alMessage.groupId != nil) {
                    ALChannelService *channelService = [[ALChannelService alloc] init];
                    ALChannel *channel = [channelService getChannelByKey:alMessage.groupId];
                    if (channel && channel.isOpenGroup) {
                        if (alMessage.hasAttachment) {
                            ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
                            [messageDBService updateMessageMetadataOfKey:alMessage.key withMetadata:alMessage.metadata];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:AL_MESSAGE_META_DATA_UPDATE object:alMessage userInfo:nil];
                    } else {
                        [self.alSyncCallService syncMessageMetadata];
                    }
                } else {
                    [self.alSyncCallService syncMessageMetadata];
                }
            } @catch (NSException *exp) {
                ALSLog(ALLoggerSeverityError, @"Error while conversating dictionary to message: %@", exp.description);
            }
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_CONVERSATION_READ)]]) {
            //Conversation read for user
            ALUserService *channelService = [[ALUserService alloc]init];
            NSString *userId = [theMessageDict objectForKey:@"message"];
            [channelService updateConversationReadWithUserId:userId withDelegate:self.realTimeUpdate];

        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_GROUP_CONVERSATION_READ)]]) {
            //Conversation read for channel
            ALChannelService *channelService = [[ALChannelService alloc]init];
            NSNumber *channelKey = [NSNumber numberWithInt:[[theMessageDict objectForKey:@"message"] intValue]];
            [channelService updateConversationReadWithGroupId:channelKey withDelegate:self.realTimeUpdate];
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_MUTE_NOTIFICATION)]]) {

            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@":"];
            NSString *userId = parts[0];
            NSString *flag = parts[1];
            ALContactDBService *contactDataBaseService = [[ALContactDBService alloc] init];

            if ([flag isEqualToString:@"0"]) {
                KMCoreUserDetail *userDetail =  [contactDataBaseService updateMuteAfterTime:0 andUserId:userId];
                if (self.realTimeUpdate) {
                    [self.realTimeUpdate onUserMuteStatus:userDetail];
                }

            } else if ([flag isEqualToString:@"1"]) {
                ALUserService *userService = [[ALUserService alloc]init];
                [userService getMutedUserListWithDelegate:self.realTimeUpdate withCompletion:^(NSMutableArray *userDetailArray, NSError *error) {

                }];
            }
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_GROUP_MUTE_NOTIFICATION)]]) {
            ALChannelService *channelService = [[ALChannelService alloc] init];
            NSArray *parts = [[theMessageDict objectForKey:@"message"] componentsSeparatedByString:@":"];
            if (parts.count == 2) {
                NSNumber *channelKey = [NSNumber numberWithInt:[parts[0] intValue]];
                NSNumber *notificationMuteTillTime = [NSNumber numberWithDouble:[parts[1] doubleValue]];
                [channelService updateMuteAfterTime:notificationMuteTillTime andChnnelKey:channelKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:ALChannelDidChangeGroupMuteNotification object:nil userInfo:@{@"CHANNEL_KEY": channelKey}];

                if (self.realTimeUpdate) {
                    [self.realTimeUpdate onChannelMute:channelKey];
                }
            }
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_ACTIVATED)]]) {
            [KMCoreUserDefaultsHandler deactivateLoggedInUser:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALLoggedInUserDidChangeDeactivateNotification object:nil userInfo:@{@"DEACTIVATED": @"false"}];
        } else if ([type isEqualToString:pushNotificationService.notificationTypes[@(AL_USER_DEACTIVATED)]]) {
            [KMCoreUserDefaultsHandler deactivateLoggedInUser:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALLoggedInUserDidChangeDeactivateNotification object:nil userInfo:@{@"DEACTIVATED": @"true"}];
        } else if ([type isEqualToString: @"APPLOZIC_25"] ){
            NSString *message = [theMessageDict objectForKey:@"message"];
            NSArray *typingParts = [message componentsSeparatedByString:@","];
            NSString *userId = typingParts[0];
            NSString *status = typingParts[1];
            [self.mqttConversationDelegate userOnlineStatusChanged:userId status:status];
        } else {
            ALSLog(ALLoggerSeverityInfo, @"MQTT NOTIFICATION \"%@\" IS NOT HANDLED",type);
        }
    }
}

- (void)subProcessTyping:(NSString *)fullMessage {
    NSArray *typingParts = [fullMessage componentsSeparatedByString:@","];
    NSString *applicationKey = typingParts[0]; //Note: will get used once we support messaging from one app to another
    NSString *userId = typingParts[1];
    BOOL typingStatus = [typingParts[2] boolValue];
    if (![userId isEqualToString:[KMCoreUserDefaultsHandler getUserId]]) {
        [self.mqttConversationDelegate updateTypingStatus:applicationKey userId:userId status:typingStatus];
        if (self.realTimeUpdate) {
            [self.realTimeUpdate onUpdateTypingStatus:userId status:typingStatus];
        }
    }
}

- (void)processUserBlockNotification:(NSDictionary *)theMessageDict andUserBlockFlag:(BOOL)flag {
    NSArray *mqttMessageArray = [[theMessageDict valueForKey:@"message"] componentsSeparatedByString:@":"];
    NSString *BlockType = mqttMessageArray[0];
    NSString *userId = mqttMessageArray[1];
    ALContactDBService *dbService = [ALContactDBService new];
    if ([BlockType isEqualToString:@"BLOCKED_BY"] || [BlockType isEqualToString:@"UNBLOCKED_BY"]) {
        [dbService setBlockByUser:userId andBlockedByState:flag];
    } else if ([BlockType isEqualToString:@"BLOCKED_TO"] || [BlockType isEqualToString:@"UNBLOCKED_TO"]) {
        [dbService setBlockUser:userId andBlockedState:flag];
    } else {
        return;
    }

    [self.mqttConversationDelegate reloadDataForUserBlockNotification:userId andBlockFlag:flag];
    if (self.realTimeUpdate) {
        [self.realTimeUpdate onUserBlockedOrUnBlocked:userId andBlockFlag:flag];
    }
}

- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray *)qoss {
    ALSLog(ALLoggerSeverityInfo, @"subscribed");
}

- (void)connected:(MQTTSession *)session {

}

- (void)connectionClosed:(MQTTSession *)session {
    ALSLog(ALLoggerSeverityInfo, @"MQTT : CONNECTION CLOSED (MQTT DELEGATE)");
    [self.mqttConversationDelegate mqttConnectionClosed];
    if (self.realTimeUpdate) {
        [self.realTimeUpdate onMqttConnectionClosed];
    }
}

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
}

- (void)sendTypingStatus:(NSString *)applicationKey userID:(NSString *)userId andChannelKey:(NSNumber *)channelKey typing:(BOOL)typing {
    if (!self.session) {
        return;
    }
    if (channelKey) {
        ALSLog(ALLoggerSeverityInfo, @"Sending typing status %d to channel: %@", typing, channelKey);
    } else {
        ALSLog(ALLoggerSeverityInfo, @"Sending typing status %d to user: %@", typing, userId);
    }

    NSString *dataString = [NSString stringWithFormat:@"%@,%@,%i", [KMCoreUserDefaultsHandler getApplicationKey],
                            [KMCoreUserDefaultsHandler getUserId], typing ? 1 : 0];

    NSString *topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], userId];

    if (channelKey != nil) {
        topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], channelKey];
    }
    ALSLog(ALLoggerSeverityInfo, @"MQTT_PUBLISH :: %@",topicString);

    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.session publishData:data onTopic:topicString retain:NO qos:MQTTQosLevelAtMostOnce];
}

- (BOOL)publishCustomData:(NSString *)dataString
            withTopicName:(NSString *)topic {
    @try {
        if (!self.session ||
            !(self.session.status == MQTTSessionStatusConnected) ||
            ![ALDataNetworkConnection checkDataNetworkAvailable] ||
            !dataString ||
            !topic) {
            return NO;
        }

        ALSLog(ALLoggerSeverityInfo, @"Sending custom data to topic : %@", topic);

        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [self.session publishData:data
                          onTopic:topic
                           retain:NO
                              qos:MQTTQosLevelAtMostOnce];
        return YES;
    }  @catch (NSException *exp) {
        ALSLog(ALLoggerSeverityError, @"Exception in publishCustomData :: %@", exp.description);
    }
    return NO;
}

- (BOOL)messageReadStatusPublishWithMessageKey:(NSString *)messageKey {

    if (!messageKey) {
        return NO;
    }

    ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
    ALMessage *message = [messageDBService getMessageByKey:messageKey];

    if (!message) {
        return NO;
    }

    NSString *dataString = [NSString stringWithFormat:@"%@,%@,%i",
                            [KMCoreUserDefaultsHandler getUserId],
                            message.pairedMessageKey,
                            READ];

    BOOL isReadStatusPublished = [self publishCustomData:dataString
                                           withTopicName:AL_MESSAGE_STATUS_TOPIC];

    if (isReadStatusPublished) {
        ALUserService *userService = [[ALUserService alloc] init];
        [userService markConversationReadInDataBaseWithMessage:message];
    }
    return isReadStatusPublished;
}

- (void)unsubscribeToConversation {
    NSString *userKey = [KMCoreUserDefaultsHandler getUserKeyString];
    [self unsubscribeToConversation: userKey];
}

- (BOOL)unsubscribeToConversation: (NSString *)userKey {
    return [self unsubscribeToConversationForUser: userKey WithTopic: [KMCoreUserDefaultsHandler getUserKeyString]];
}

- (void)publishOfflineStatus {
    NSString *publishString = [NSString stringWithFormat:@"%@,%@,%@", [KMCoreUserDefaultsHandler getUserKeyString], [KMCoreUserDefaultsHandler getDeviceKeyString],@"0"];

    [self.session publishAndWaitData:[publishString dataUsingEncoding:NSUTF8StringEncoding] onTopic:MQTT_TOPIC_STATUS retain:NO qos:MQTTQosLevelAtMostOnce timeout:30];
}

- (void)unsubscribeToConversationWithTopic:(NSString *)topic {
    NSString *userKey = [KMCoreUserDefaultsHandler getUserKeyString];
    [self unsubscribeToConversationForUser: userKey WithTopic: topic];
}

- (BOOL)unsubscribeToConversationForUser:(NSString *)userKey WithTopic:(NSString *)topic {
    @try {
        if (self.session == nil) {
            return NO;
        }

        NSMutableArray<NSString *> *topicsArray = [[NSMutableArray alloc] init];
        
        if (![KMCoreSettings isAgentAppConfigurationEnabled]){
            [self publishOfflineStatus];
        }

        if ([KMCoreUserDefaultsHandler getUserEncryptionKey]) {
            [topicsArray addObject:[NSString stringWithFormat:@"%@%@",MQTT_ENCRYPTION_SUB_KEY, topic]];
        }

        if (topic) {
            [topicsArray addObject:topic];
        }

        /// Unsubscribe from both the topics with encr prefix and without encr prefix
        if (topicsArray.count) {
            [self.session unsubscribeTopics: [topicsArray copy]];
        }

        [self.session closeWithDisconnectHandler:^(NSError *error) {
            if (error) {
                ALSLog(ALLoggerSeverityError, @"MQTT : ERROR WHIlE DISCONNECTING FROM MQTT %@", error);
            }
            ALSLog(ALLoggerSeverityInfo, @"MQTT : DISCONNECTED FROM MQTT");
        }];
        return YES;
    } @catch (NSException *exp) {
        ALSLog(ALLoggerSeverityError, @"Exception in unsubscribe conversation :: %@", exp.description);
    }
    return NO;
}

- (void)subscribeToChannelConversation:(NSNumber *)channelKey {
    ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/USER_SUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (),^{
        @try {
            if (!self.session && self.session.status == MQTTSessionStatusConnected) {
                ALSLog(ALLoggerSeverityInfo, @"MQTT_SESSION_NULL");
                return;
            }
            NSString *topicString = @"";
            if (channelKey != nil) {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], channelKey];
            } else {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], [KMCoreUserDefaultsHandler getUserId]];
                [KMCoreUserDefaultsHandler setLoggedInUserSubscribedMQTT:YES];
            }
            [self.session subscribeToTopic:topicString atLevel:MQTTQosLevelAtMostOnce];
            ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/USER_SUBSCRIBING_COMPLETE");
        } @catch (NSException *exp) {
            ALSLog(ALLoggerSeverityError, @"Exception in subscribing channel :: %@", exp.description);
        }
    });
}

- (void)unSubscribeToChannelConversation:(NSNumber *)channelKey {
    @try {
        ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/USER_UNSUBSCRIBING");
        dispatch_async(dispatch_get_main_queue (), ^{

            if (!self.session) {
                ALSLog(ALLoggerSeverityInfo, @"MQTT_SESSION_NULL");
                return;
            }
            NSString *topicString = @"";
            if (channelKey != nil) {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], channelKey];
            } else {
                topicString = [NSString stringWithFormat:@"typing-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], [KMCoreUserDefaultsHandler getUserId]];
                [KMCoreUserDefaultsHandler setLoggedInUserSubscribedMQTT:NO];
            }
            [self.session unsubscribeTopic:topicString];
            ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/USER_UNSUBSCRIBED_COMPLETE");
        });
    } @catch (NSException *exp) {
        ALSLog(ALLoggerSeverityError, @"Exception in unsubscribing to typing conversation :: %@", exp.description);
    }
}

- (void)subscribeToOpenChannel:(NSNumber *)channelKey {
    ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/OPEN_GROUP_SUBSCRIBING");
    dispatch_async(dispatch_get_main_queue (),^{
        @try {
            if (!self.session && self.session.status == MQTTSessionStatusConnected) {
                ALSLog(ALLoggerSeverityInfo, @"MQTT_SESSION_NULL");
                return;
            }
            NSString *openGroupString = @"";
            if (channelKey != nil) {
                openGroupString = [NSString stringWithFormat:@"group-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], channelKey];
            }

            [self.session subscribeToTopic:openGroupString atLevel:MQTTQosLevelAtMostOnce];
            ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/OPEN_GROUP_SUBSCRIBTION_COMPLETE");
        } @catch (NSException *exp) {
            ALSLog(ALLoggerSeverityError, @"Exception in subscribing channel :: %@", exp.description);
        }
    });
}

- (void)unSubscribeToOpenChannel:(NSNumber *)channelKey {
    @try {
        ALSLog(ALLoggerSeverityInfo, @"MQTT_/OPEN_GROUP_UNSUBSCRIBING");
        dispatch_async(dispatch_get_main_queue (), ^{

            if (!self.session) {
                ALSLog(ALLoggerSeverityInfo, @"MQTT_SESSION_NULL");
                return;
            }
            NSString *topicString = @"";
            if (channelKey != nil) {
                topicString = [NSString stringWithFormat:@"group-%@-%@", [KMCoreUserDefaultsHandler getApplicationKey], channelKey];
            }
            [self.session unsubscribeTopic:topicString];
            ALSLog(ALLoggerSeverityInfo, @"MQTT_CHANNEL/OPEN_GROUP_UNSUBSCRIBTION_COMPLETE");
        });
    } @catch (NSException *exp) {
        ALSLog(ALLoggerSeverityError, @"Exception in unsubscribe Open Channel :: %@", exp.description);
    }
}

- (void)syncReceivedMessage:(ALMessage *)alMessage withNSMutableDictionary:(NSMutableDictionary *)nsMutableDictionary {

    ALPushAssist *pushAssist = [[ALPushAssist alloc] init];

    [ALMessageService getLatestMessageForUser:[KMCoreUserDefaultsHandler getDeviceKeyString]
                                 withDelegate:self.realTimeUpdate
                               withCompletion:^(NSMutableArray *message, NSError *error) {

        ALSLog(ALLoggerSeverityInfo, @"ALMQTTConversationService SYNC CALL");
        if (!pushAssist.isOurViewOnTop) {
            [nsMutableDictionary setObject:@"mqtt" forKey:@"Calledfrom"];
            [pushAssist assist:[self getNotificationObjectFromMessage:alMessage] withUserInfo:nsMutableDictionary ofUser:alMessage.contactIds];
        } else {
            [self.alSyncCallService syncCall:alMessage];
            [self.mqttConversationDelegate syncCall:alMessage andMessageList:nil];
        }

    }];
}
- (BOOL)shouldRetry {
    BOOL isInBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    return !isInBackground && [ALDataNetworkConnection checkDataNetworkAvailable];
}

- (void)retryConnection {
    if (![self shouldRetry]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self subscribeToConversation];
    });
}

- (void)retryConnectionWithTopic:(NSString *)topic {
    if (![self shouldRetry]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self subscribeToConversationWithTopic: topic];
    });
}

@end
