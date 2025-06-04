//
//  KMCoreMessageWrapper.h
//  Kommunicate
//
//  Created by Adarsh Kumar Mishra on 12/14/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "KMCoreMessage.h"
#import "KommunicateClient.h"

@protocol MessageServiceWrapperDelegate <NSObject>

@optional

- (void)updateBytesDownloaded:(NSUInteger)bytesReceived;
- (void)updateBytesUploaded:(NSUInteger)bytesSent;
- (void)uploadDownloadFailed:(KMCoreMessage *)alMessage;
- (void)uploadCompleted:(KMCoreMessage *)alMessage;
- (void)DownloadCompleted:(KMCoreMessage *)alMessage;

@end

@interface KMCoreMessageServiceWrapper : NSObject

@property (strong, nonatomic) id <MessageServiceWrapperDelegate> messageServiceDelegate;

- (void)sendTextMessage:(NSString *)text andtoContact:(NSString *)toContactId;

- (void)sendTextMessage:(NSString *)messageText andtoContact:(NSString *)contactId orGroupId:(NSNumber *)channelKey;

- (void)sendMessage:(KMCoreMessage *)alMessage
withAttachmentAtLocation:(NSString *)attachmentLocalPath
andWithStatusDelegate:(id)statusDelegate
     andContentType:(short)contentype;

- (void)downloadMessageAttachment:(KMCoreMessage*)alMessage;

- (KMCoreMessage *)createMessageEntityOfContentType:(int)contentType
                                       toSendTo:(NSString *)to
                                       withText:(NSString *)text;

@end
