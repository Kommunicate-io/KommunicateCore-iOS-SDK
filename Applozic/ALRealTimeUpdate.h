//
//  ALRealTimeUpdate.h
//  Applozic
//
//  Created by Sunil on 08/03/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALUserDetail.h"

@protocol ApplozicUpdatesDelegate <NSObject>

-(void) onMessageReceived:(ALMessage *) alMessage;
-(void) onMessageSent:(ALMessage *) alMessage;
-(void) onUserDetailsUpdate:(ALUserDetail *) userDetail;
-(void) onMessageDelivered:(ALMessage *) message;
-(void) onMessageDeleted:(NSString *) messageKey;
-(void) onMessageDeliveredAndRead:(NSString *) userId;
-(void) onConversationDelete:(NSString *) userId withGroupId: (NSNumber*) groupId;
-(void) onConversationRead:(NSString *) userId;
-(void) onUpdateTypingStatus:(NSString *) userId status: (BOOL) status;
-(void) onUpdateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) onUserBlockedOrUnBlocked:(NSString *)userId andBlockFlag:(BOOL)flag;

@optional
-(void) onMqttConnectionClosed;
-(void) onMqttConnected;
@end

@interface ALRealTimeUpdate : NSObject

@end
