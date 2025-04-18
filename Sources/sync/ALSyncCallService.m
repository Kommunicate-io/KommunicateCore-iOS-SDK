//
//  ALSyncCallService.m
//  Kommunicate
//
//  Created by Kommunicate on 12/14/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "ALSyncCallService.h"
#import "ALMessageDBService.h"
#import "ALContactDBService.h"
#import "ALChannelService.h"
#import "ALMessageService.h"
#import "ALLogger.h"

@implementation ALSyncCallService


- (void)updateMessageDeliveryReport:(NSString *)messageKey withStatus:(int)status {
    ALMessageDBService *alMessageDBService = [[ALMessageDBService alloc] init];
    [alMessageDBService updateMessageDeliveryReport:messageKey withStatus:status];
    ALSLog(ALLoggerSeverityInfo, @"delivery report for %@", messageKey);
    //Todo: update ui
}

- (void)updateDeliveryStatusForContact:(NSString *)contactId withStatus:(int)status {
    ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
    [messageDBService updateDeliveryReportForContact:contactId withStatus:status];
    //Todo: update ui
}

- (void)syncCall:(ALMessage *)alMessage withDelegate:(id<KommunicateUpdatesDelegate>)delegate {
    
    if (delegate) {
        if (alMessage.groupId != nil && alMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION) {
            [[ALChannelService sharedInstance] syncCallForChannelWithDelegate:delegate];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MQTT_APPLOZIC_01" object:alMessage];
}

- (void)syncCall:(ALMessage *)alMessage {
    [self syncCall:alMessage withDelegate:nil];
}

- (void)updateConnectedStatus:(KMCoreUserDetail *)alUserDetail {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userUpdate" object:alUserDetail];
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
    [contactDBService updateLastSeenDBUpdate:alUserDetail];
}

- (void)updateTableAtConversationDeleteForContact:(NSString *)contactID
                                   ConversationID:(NSString *)conversationID
                                       ChannelKey:(NSNumber *)channelKey {
    
    ALMessageDBService *messageDBService = [[ALMessageDBService alloc] init];
    [messageDBService deleteAllMessagesByContact:contactID orChannelKey:channelKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONVERSATION_DELETION"
                                                        object:(contactID ? contactID :channelKey)];
    
}

- (void)syncMessageMetadata {
    [ALMessageService syncMessageMetaData:[KMCoreUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray *message, NSError *error) {
        ALSLog(ALLoggerSeverityInfo, @"Successfully updated message metadata");
        [[NSNotificationCenter defaultCenter] postNotificationName:AL_GROUP_MESSAGE_METADATA_UPDATE object:message userInfo:nil];
    }];
}

@end
