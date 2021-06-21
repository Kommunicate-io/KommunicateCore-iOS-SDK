//
//  ALPushNotificationHandler.h
//  ApplozicCore
//
//  Created by apple on 17/02/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChatLauncher.h"

@interface ALPushNotificationHandler : NSObject
@property(nonatomic,strong) ALChatLauncher * chatLauncher;

+ (ALPushNotificationHandler *)shared;
- (void)dataConnectionNotificationHandler;
- (void)notificationTapped:(NSString *)contactId
               withGroupId:(NSNumber *)groupID
        withConversationId:(NSNumber *)conversationId
notificationTapActionDisable:(BOOL) isTapActionDisabled;

@end
