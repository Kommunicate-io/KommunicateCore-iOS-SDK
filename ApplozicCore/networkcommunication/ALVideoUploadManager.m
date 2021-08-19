//
//  ALVideoUploadManager.m
//  ApplozicCore
//
//  Created by Sunil on 03/05/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALVideoUploadManager.h"
#import "ALConnectionQueueHandler.h"
#import "ALMessage.h"
#import "ALUtilityClass.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALLogger.h"
#import "ALMessageClientService.h"
#import "ALHTTPManager.h"

@implementation ALVideoUploadManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

-(void)setupServices {
    self.messageDatabaseService  = [[ALMessageDBService alloc]init];
    self.clientService = [[ALMessageClientService alloc] init];
    self.responseHandler = [[ALResponseHandler alloc] init];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {

    if (self->_uploadTask != nil) {

        DB_Message *dbMessage = (DB_Message*)[self.messageDatabaseService getMessageByKey:@"key" value:self->_uploadTask.identifier];
        ALMessage *message = [self.messageDatabaseService createMessageEntity:dbMessage];

        NSError *jsonError = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];

        if (jsonError == nil) {
            ALMessage *fileMetaMessage = [[ALMessage alloc] init];
            ALFileMetaInfo *fileMeta = [[ALFileMetaInfo alloc] init];
            fileMetaMessage.fileMeta = fileMeta;

            if (ALApplozicSettings.isS3StorageServiceEnabled) {
                [fileMetaMessage.fileMeta populate:jsonDictionary];
            } else {
                NSDictionary *fileInfo = [jsonDictionary objectForKey:@"fileMeta"];
                [fileMetaMessage.fileMeta populate:fileInfo];
            }

            /// Update the current message for thumbnail
            message.fileMeta.thumbnailFilePath = self.uploadTask.videoThumbnailName;
            message.fileMeta.thumbnailUrl = fileMetaMessage.fileMeta.thumbnailUrl;
            message.fileMeta.thumbnailBlobKey = fileMetaMessage.fileMeta.blobKey;

            /// Update the db message  for thumbnail
            dbMessage.fileMetaInfo.thumbnailBlobKeyString = message.fileMeta.thumbnailBlobKey;
            dbMessage.fileMetaInfo.thumbnailFilePath = self.uploadTask.videoThumbnailName;
            dbMessage.fileMetaInfo.thumbnailUrl = message.fileMeta.thumbnailUrl;

            NSDictionary *userInfo = [message dictionary];
            [[ALDBHandler sharedInstance] saveContext];

            [self.clientService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *url, NSError *error) {

                if (error) {
                    [self handleUploadFailedStateWithMessage:message];
                    return;
                }

                ALHTTPManager *httpManager = [[ALHTTPManager alloc] init];
                httpManager.attachmentProgressDelegate = self.attachmentProgressDelegate;
                httpManager.delegate = self.delegate;
                [httpManager processUploadFileForMessage:message uploadURL:url];

            }];
        } else {
            [self handleUploadFailedStateWithMessage:message];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)startSession:(NSURLSession *)session
         withRequest:(NSURLRequest *)urlRequest {

    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:session];

    if ([[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] containsObject:session]) {
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest: urlRequest];
        [sessionDataTask resume];
    }
}

- (void)uploadTheVideo:(ALMessage *)message {
    NSMutableArray *urlSessionArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];

    for (NSURLSession *session in urlSessionArray) {
        NSURLSessionConfiguration *config = session.configuration;
        NSArray *sessionConfigurationIdentifier =  [config.identifier componentsSeparatedByString:@","];
        if (sessionConfigurationIdentifier && sessionConfigurationIdentifier.count > 1) {
            //Check if message key are same and first argumnent is not THUMBNAIL and FILE
            if (![sessionConfigurationIdentifier[0] isEqual: @"THUMBNAIL"]
                && ![sessionConfigurationIdentifier[0] isEqual: @"FILE"]
                && [sessionConfigurationIdentifier[1] isEqualToString: message.key]) {
                ALSLog(ALLoggerSeverityInfo, @"Already present in upload video Queue returing for key %@",message.key);
                return;
            }
        }
    }

    /// If the thumbnailUrl exist then will directly upload the video else will upload the thumbnail and call the video upload.
    if (message.fileMeta.thumbnailUrl.length > 0 &&
        message.fileMeta.thumbnailFilePath.length > 0) {
        [self.clientService sendPhotoForUserInfo:nil withCompletion:^(NSString *url, NSError *error) {
            if (error) {
                [self handleUploadFailedStateWithMessage:message];
                return;
            }

            ALHTTPManager *httpManager = [[ALHTTPManager alloc] init];
            httpManager.attachmentProgressDelegate = self.attachmentProgressDelegate;
            httpManager.delegate = self.delegate;
            [httpManager processUploadFileForMessage:message uploadURL:url];
        }];
    } else {
        NSString *filePath = [ALUtilityClass getPathFromDirectory:message.imageFilePath];
        UIImage *thumbnailImage = [ALUtilityClass setVideoThumbnail:filePath];
        NSString *imageFilePath = [ALUtilityClass saveImageToDocDirectory:thumbnailImage];

        ALUploadTask *alUploadTask = [[ALUploadTask alloc] init];
        alUploadTask.identifier = message.key;
        alUploadTask.message = message;
        alUploadTask.videoThumbnailName = imageFilePath.lastPathComponent;
        self.uploadTask = alUploadTask;

        [self.clientService sendPhotoForUserInfo:nil withCompletion:^(NSString *uploadURL, NSError *error) {

            if (error) {
                [self handleUploadFailedStateWithMessage:message];
                return;
            }

            NSMutableURLRequest *request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];

            [self.responseHandler authenticateRequest:request WithCompletion:^(NSMutableURLRequest *urlRequest, NSError *error)  {

                if (error) {
                    [self handleUploadFailedStateWithMessage:message];
                    return;
                }

                if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {

                    NSURLSession *session = [self configureSessionWithMessage:message];

                    NSData *bodyData = [self requestUploadBodyDataWithFilePath:imageFilePath withRequest:urlRequest withName:self.uploadTask.videoThumbnailName withContentType:@"image/jpeg"];

                    // setting the body of the post to the request
                    [urlRequest setHTTPBody:bodyData];
                    // set URL
                    [urlRequest setURL:[NSURL URLWithString:uploadURL]];

                    [self startSession:session withRequest:urlRequest];
                }
            }];
        }];
    }
}

-(NSURLSession *)configureSessionWithMessage:(ALMessage *)message {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"VIDEO_THUMBNAIL,%@",message.key]];

    if (ALApplozicSettings.getShareExtentionGroup) {
        config.sharedContainerIdentifier = ALApplozicSettings.getShareExtentionGroup;
    }

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:NSOperationQueue.mainQueue];

    return session;
}

- (void)handleUploadFailedStateWithMessage:(ALMessage *)message {
    ALMessage *failedMessage = [[ALMessageService sharedInstance] handleMessageFailedStatus:message];
    if (self.attachmentProgressDelegate) {
        [self.attachmentProgressDelegate onUploadFailed:[[ALMessageService sharedInstance] handleMessageFailedStatus:failedMessage]];
    }
}

- (NSData *)requestUploadBodyDataWithFilePath:(NSString *)filePath
                                  withRequest:(NSMutableURLRequest *)urlRequest
                                     withName:(NSString *)name
                              withContentType:(NSString *)type {

    //Create boundary, it can be anything
    NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // post body
    NSMutableData *body = [NSMutableData data];

    NSString* fileParamConstant;
    if (ALApplozicSettings.isS3StorageServiceEnabled) {
        fileParamConstant = @"file";
    } else {
        fileParamConstant = @"files[]";
    }
    NSData *imageData = [[NSData alloc]initWithContentsOfFile:filePath];
    ALSLog(ALLoggerSeverityInfo, @"Attachment data length: %f",imageData.length/1024.0);
    //Assuming data is not nil we add this to the multipart form
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant, name] dataUsingEncoding:NSUTF8StringEncoding]];

        [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return body;
}

@end
