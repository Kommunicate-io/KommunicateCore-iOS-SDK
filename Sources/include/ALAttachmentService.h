//
//  ALAttachmentService.h
//  Kommunicate
//
//  Created by sunil on 25/09/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessageDBService.h"
#import "ALMessage.h"
#import "ALMessageService.h"
#import "KMCoreRealTimeUpdate.h"
#import "KommunicateClient.h"
#import "ALHTTPManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALAttachmentService : NSObject

@property (nonatomic, strong) id<KommunicateAttachmentDelegate>attachmentProgressDelegate;
@property (nonatomic, weak) id<KommunicateUpdatesDelegate> delegate;

+ (ALAttachmentService *)sharedInstance;

- (void)sendMessageWithAttachment:(ALMessage *)attachmentMessage
                     withDelegate:(id<KommunicateUpdatesDelegate>)delegate
           withAttachmentDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

- (void)downloadMessageAttachment:(ALMessage *)alMessage withDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

- (void)downloadImageThumbnail:(ALMessage *)alMessage withDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

@end

NS_ASSUME_NONNULL_END
