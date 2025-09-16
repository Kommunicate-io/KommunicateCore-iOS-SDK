//
//  ALVideoUploadManager.h
//  KommunicateCore
//
//  Created by Sunil on 03/05/21.
//  Copyright © 2021 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUploadTask.h"
#import "KMCoreMessage.h"
#import "KommunicateClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALVideoUploadManager : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak) id<KommunicateAttachmentDelegate>attachmentProgressDelegate;

@property (nonatomic, weak) id<KommunicateUpdatesDelegate> delegate;

@property (nonatomic, strong) ALUploadTask *uploadTask;
@property (nonatomic, strong) KMCoreMessageDBService *messageDatabaseService;
@property (nonatomic, strong) KMCoreMessageClientService *clientService;
@property (nonatomic, strong) ALResponseHandler *responseHandler;

-(void)uploadTheVideo:(KMCoreMessage *)message;
@end

NS_ASSUME_NONNULL_END
