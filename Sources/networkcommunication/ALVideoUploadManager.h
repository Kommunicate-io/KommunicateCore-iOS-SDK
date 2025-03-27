//
//  ALVideoUploadManager.h
//  KommunicateCore
//
//  Created by Sunil on 03/05/21.
//  Copyright © 2021 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUploadTask.h"
#import "ALMessage.h"
#import "KommunicateClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALVideoUploadManager : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak) id<KommunicateAttachmentDelegate>attachmentProgressDelegate;

@property (nonatomic, weak) id<KommunicateUpdatesDelegate> delegate;

@property (nonatomic, strong) ALUploadTask *uploadTask;
@property (nonatomic, strong) ALMessageDBService *messageDatabaseService;
@property (nonatomic, strong) ALMessageClientService *clientService;
@property (nonatomic, strong) ALResponseHandler *responseHandler;

-(void)uploadTheVideo:(ALMessage *)message;
@end

NS_ASSUME_NONNULL_END
