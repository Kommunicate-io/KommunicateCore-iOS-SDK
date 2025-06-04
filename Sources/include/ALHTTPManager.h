//
//  ALHTTPManager.h
//  Kommunicate
//
//  Created by apple on 25/03/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUploadTask.h"
#import "ALDownloadTask.h"
#import "KMCoreMessage.h"
#import "KommunicateClient.h"

@interface ALHTTPManager : NSObject <NSURLSessionDataDelegate,NSURLSessionDelegate>

@property (nonatomic, weak) id<KommunicateAttachmentDelegate>attachmentProgressDelegate;

@property (nonatomic, weak) id<KommunicateUpdatesDelegate> delegate;

@property (nonatomic, strong) NSMutableData *buffer;

@property (nonatomic) NSUInteger *length;

@property (nonatomic) ALUploadTask *uploadTask;

@property (nonatomic) ALDownloadTask *downloadTask;

@property (nonatomic, strong) ALResponseHandler *responseHandler;

- (void)processDownloadForMessage:(KMCoreMessage *)alMessage isAttachmentDownload:(BOOL)attachmentDownloadFlag;

- (void)processUploadFileForMessage:(KMCoreMessage *)message uploadURL:(NSString *)uploadURL;

- (void)uploadProfileImage:(UIImage *)profileImage
             withFilePath:(NSString *)filePath
                uploadURL:(NSString *)uploadURL
           withCompletion:(void(^)(NSData *data, NSError *error)) completion;

@end
