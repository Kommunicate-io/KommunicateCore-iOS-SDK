//
//  ALSyncCallService.h
//  Kommunicate
//
//  Created by Kommunicate on 12/14/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreMessage.h"
#import "KMCoreUserDetail.h"
#import "KMCoreRealTimeUpdate.h"

@interface ALSyncCallService : NSObject

- (void)updateMessageDeliveryReport:(NSString *)messageKey withStatus:(int)status;

- (void)updateDeliveryStatusForContact:(NSString *)contactId withStatus:(int)status;

- (void)syncCall:(KMCoreMessage *)alMessage;

- (void)syncCall:(KMCoreMessage *)alMessage withDelegate:(id<KommunicateUpdatesDelegate>)theDelegate;

- (void)updateConnectedStatus:(KMCoreUserDetail *)alUserDetail;

- (void)updateTableAtConversationDeleteForContact:(NSString *)contactID
                                   ConversationID:(NSString *)conversationID
                                       ChannelKey:(NSNumber *)channelKey;
- (void)syncMessageMetadata;

@end
