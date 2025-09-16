//
//  ALAttachmentService.h
//  Kommunicate
//
//  Created by sunil on 25/09/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreMessageDBService.h"
#import "KMCoreMessage.h"
#import "KMCoreMessageService.h"
#import "KMCoreRealTimeUpdate.h"
#import "KommunicateClient.h"
#import "ALHTTPManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALAttachmentService : NSObject

@property (nonatomic, strong) id<KommunicateAttachmentDelegate>attachmentProgressDelegate;
@property (nonatomic, weak) id<KommunicateUpdatesDelegate> delegate;

+ (ALAttachmentService *)sharedInstance;

- (void)sendMessageWithAttachment:(KMCoreMessage *)attachmentMessage
                     withDelegate:(id<KommunicateUpdatesDelegate>)delegate
           withAttachmentDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

- (void)downloadMessageAttachment:(KMCoreMessage *)alMessage withDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

- (void)downloadImageThumbnail:(KMCoreMessage *)alMessage withDelegate:(id<KommunicateAttachmentDelegate>)attachmentProgressDelegate;

@end

NS_ASSUME_NONNULL_END
