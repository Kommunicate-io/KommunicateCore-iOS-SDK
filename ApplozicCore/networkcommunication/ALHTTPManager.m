//
//  ALHTTPManager.m
//  Applozic
//
//  Created by apple on 25/03/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import "ALHTTPManager.h"
#import "ALLogger.h"
#import "ALMessageDBService.h"
#import "ALConnectionQueueHandler.h"
#import "ALUtilityClass.h"
#import "ALMessageClientService.h"

@implementation ALHTTPManager

static dispatch_semaphore_t semaphore;

- (instancetype)init {
    self = [super init];
    if (!semaphore) {
        semaphore = dispatch_semaphore_create(2); //2 tasks
    }
    if (self) {
        self.buffer = [[NSMutableData alloc]init];
        self.responseHandler = [[ALResponseHandler alloc] init];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    ALMessageDBService *messageDatabaseService = [[ALMessageDBService alloc]init];

    if (self->_downloadTask != nil) {
        [self->_buffer appendData:data];
        if (!self->_downloadTask.isThumbnail) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.attachmentProgressDelegate onUpdateBytesDownloaded:self->_buffer.length withMessage:self->_downloadTask.message];
            });
        }

    } else if (self->_uploadTask != nil) {

        DB_Message *dbMessage = (DB_Message *)[messageDatabaseService getMessageByKey:@"key" value:self->_uploadTask.identifier];
        ALMessage *message = [messageDatabaseService createMessageEntity:dbMessage];

        ALFileMetaInfo *existingFileMeta = message.fileMeta;
        NSError *jsonError = nil;
        NSDictionary *fileMetaJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];

        if (jsonError == nil) {
            if (ALApplozicSettings.isS3StorageServiceEnabled) {
                [message.fileMeta populate:fileMetaJSONDictionary];
            } else {
                NSDictionary *fileMetadataDictionary = [fileMetaJSONDictionary objectForKey:@"fileMeta"];
                [message.fileMeta populate:fileMetadataDictionary];
            }

            if ([message.fileMeta.contentType hasPrefix:@"video"]) {
                message.fileMeta.thumbnailUrl = dbMessage.fileMetaInfo.thumbnailUrl;
                message.fileMeta.thumbnailBlobKey = dbMessage.fileMetaInfo.thumbnailBlobKeyString;
            }
            ALMessage *alMessage = [ALMessageService processFileUploadSucess:message];

            if (!alMessage) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (self.attachmentProgressDelegate) {
                        message.fileMeta = existingFileMeta;
                        [self.attachmentProgressDelegate onUploadFailed:[[ALMessageService sharedInstance] handleMessageFailedStatus:message]];
                    }
                });
                return;
            }
            [[ALMessageService sharedInstance] sendMessages:alMessage withCompletion:^(NSString *message, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (error) {
                        ALSLog(ALLoggerSeverityError, @"ERROR IN POSTING Data:: %@", error);
                        if (self.attachmentProgressDelegate) {
                            [self.attachmentProgressDelegate onUploadFailed:[[ALMessageService sharedInstance] handleMessageFailedStatus:alMessage]];
                        }
                    } else {
                        if (self.attachmentProgressDelegate) {
                            [self.attachmentProgressDelegate onUploadCompleted:alMessage withOldMessageKey:self->_uploadTask.identifier];
                        }
                        if (self.delegate) {
                            [self.delegate onMessageSent:alMessage];
                        }
                    }
                });
            }];
        } else {
            ALSLog(ALLoggerSeverityError, @"ERROR In Uploading file:: %@", jsonError);

            if (self.attachmentProgressDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.attachmentProgressDelegate onUploadFailed:message];
                });
            }
        }
        dispatch_semaphore_signal(semaphore);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    ALMessageDBService *messageDatabaseService = [[ALMessageDBService alloc]init];

    if (error == nil && [task.response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)task.response statusCode] == 200) {
        if (self->_downloadTask != nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                ALMessage *alMessage = [messageDatabaseService writeDataAndUpdateMessageInDb:self.buffer withMessage:self->_downloadTask.message withFileFlag:!self->_downloadTask.isThumbnail];

                if (self.attachmentProgressDelegate) {
                    [self.attachmentProgressDelegate onDownloadCompleted:alMessage];
                }
                self.buffer = nil;
                [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:session];
            });
        }
    } else {
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:session];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"Error while downloading  %@", error.localizedDescription);
        } else {
            ALSLog(ALLoggerSeverityError, @"Got some error while downloading");
        }
        self.buffer = nil;
        if (self->_downloadTask != nil && self.attachmentProgressDelegate) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.attachmentProgressDelegate onDownloadFailed:self->_downloadTask.message];
            });
        }
    }
    dispatch_semaphore_signal(semaphore);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    ALMessageDBService *messageDatabaseService = [[ALMessageDBService alloc]init];

    if (self->_uploadTask != nil && self.attachmentProgressDelegate != nil) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.attachmentProgressDelegate onUpdateBytesUploaded:totalBytesSent withMessage:[messageDatabaseService getMessageByKey:self->_uploadTask.identifier]];
        });
    }
}

- (void)processUploadFileForMessage:(ALMessage *)message uploadURL:(NSString *)uploadURL {

    ALUploadTask *alUploadTask = [[ALUploadTask alloc]init];
    alUploadTask.identifier = message.key;
    self.uploadTask = alUploadTask;

    NSURL *documentDirectory =  [ALUtilityClass getApplicationDirectoryWithFilePath:message.imageFilePath];
    NSString *filePath = documentDirectory.path;

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *appsGroupDirectoryURL = [ALUtilityClass getAppsGroupDirectoryWithFilePath:message.imageFilePath];
        if (appsGroupDirectoryURL != nil) {
            filePath = appsGroupDirectoryURL.path;
        }
    }

    ALSLog(ALLoggerSeverityInfo, @"FILE_PATH : %@",filePath);
    NSMutableURLRequest *request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];

    [self.responseHandler authenticateRequest:request WithCompletion:^(NSMutableURLRequest *urlRequest, NSError *error)  {

        if (error) {
            if (self.attachmentProgressDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    message.inProgress = NO;
                    message.isUploadFailed = YES;
                    [self.attachmentProgressDelegate onUploadFailed:message];
                });
            }
            return;
        }

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                //Create boundary, it can be anything
                NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
                // set Content-Type in HTTP header
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
                [urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
                // post body
                NSMutableData *body = [NSMutableData data];
                //Populate a dictionary with all the regular values you would like to send.
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                // add params (all params are strings)
                for (NSString *param in parameters) {
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
                }

                NSString *fileParamConstant;
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
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant,message.fileMeta.name] dataUsingEncoding:NSUTF8StringEncoding]];

                    [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", message.fileMeta.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:imageData];
                    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                }
                //Close off the request with the boundary
                [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                // setting the body of the post to the request
                [urlRequest setHTTPBody:body];
                // set URL
                [urlRequest setURL:[NSURL URLWithString:uploadURL]];

                NSMutableArray *sessionURLArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];

                for (NSURLSession *session in sessionURLArray) {
                    NSURLSessionConfiguration *config = session.configuration;
                    NSArray *sessionIdentifierArray =  [config.identifier componentsSeparatedByString:@","];
                    if (sessionIdentifierArray && sessionIdentifierArray.count>1) {
                        //Check if message key are same and first argumnent is not THUMBNAIL
                        if (![sessionIdentifierArray[0] isEqual: @"VIDEO_THUMBNAIL"]
                            && ![sessionIdentifierArray[0] isEqual: @"THUMBNAIL"]
                            && [sessionIdentifierArray[1] isEqualToString: message.key]) {
                            ALSLog(ALLoggerSeverityInfo, @"Already present in upload file Queue returing for key %@",message.key);
                            return;
                        }
                    }
                }

                NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"FILE,%@",message.key]];

                if (ALApplozicSettings.getShareExtentionGroup) {
                    config.sharedContainerIdentifier = ALApplozicSettings.getShareExtentionGroup;
                }

                NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
                [self startSession: session withRequest: urlRequest];
            });
        } else {
            ALSLog(ALLoggerSeverityError, @"<<< ERROR >>> :: FILE DO NOT EXIT AT GIVEN PATH");
            if (self.attachmentProgressDelegate) {

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    message.inProgress = NO;
                    message.isUploadFailed = YES;
                    [self.attachmentProgressDelegate onUploadFailed:message];
                });
            }
        }
    }];

}

- (void)processDownloadForMessage:(ALMessage *) alMessage
             isAttachmentDownload:(BOOL) attachmentDownloadFlag {

    ALDownloadTask *downloadTask = [[ALDownloadTask alloc]init];
    downloadTask.isThumbnail = !attachmentDownloadFlag;
    downloadTask.message = alMessage;
    self.downloadTask = downloadTask;

    NSMutableArray *sessionArray = [[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue];

    for (NSURLSession *session in sessionArray) {
        NSURLSessionConfiguration *config = session.configuration;
        NSArray *sessionConfigIdentifierArray =  [config.identifier componentsSeparatedByString:@","];
        if (sessionConfigIdentifierArray && sessionConfigIdentifierArray.count>1) {
            //Check if the currently  its called for file download or THUMBNAIL with messageKey
            if (attachmentDownloadFlag && [sessionConfigIdentifierArray[0] isEqualToString:@"FILE"] &&
                [sessionConfigIdentifierArray[1] isEqualToString:alMessage.key]) {
                ALSLog(ALLoggerSeverityInfo, @"Already present in file Download Queue returing for  key %@",alMessage.key);
                return;
            } else if (!attachmentDownloadFlag &&  [sessionConfigIdentifierArray[0] isEqualToString:@"THUMBNAIL"] && [sessionConfigIdentifierArray[1] isEqualToString:alMessage.key]) {
                ALSLog(ALLoggerSeverityInfo, @"Already present in Download Thumbnail download Queue returing for  key %@",alMessage.key);
                return;
            }
        }
    }

    NSString *fileExtension = [ALUtilityClass getFileExtensionWithFileName:alMessage.fileMeta.name];

    NSString *fileName  = [NSString stringWithFormat:attachmentDownloadFlag? @"%@_local.%@": @"%@_thumbnail_local.%@",alMessage.key,fileExtension];

    NSURL *applicationDirectoryURL =  [ALUtilityClass getApplicationDirectoryWithFilePath:fileName];
    NSString *filePath = applicationDirectoryURL.path;

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *appsGroupDirectoryURL = [ALUtilityClass getAppsGroupDirectoryWithFilePath:fileName];
        if (appsGroupDirectoryURL != nil) {
            filePath = appsGroupDirectoryURL.path;
        }
    }

    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    ALMessageClientService *messageClientService = [[ALMessageClientService alloc]init];
    if (data) {
        ALMessageDBService *messageDbService = [[ALMessageDBService alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            DB_Message *messageEntity = [self updateDbMessageWithKey:alMessage.key withFileName:fileName withAttachmentFlag:attachmentDownloadFlag];
            if (messageEntity) {
                self.downloadTask.message = [messageDbService createMessageEntity:messageEntity];
                if (self.attachmentProgressDelegate) {
                    [self.attachmentProgressDelegate onDownloadCompleted:self.downloadTask.message];
                }
            } else {
                if (attachmentDownloadFlag) {
                    alMessage.inProgress = NO;
                    alMessage.isUploadFailed = NO;
                    alMessage.imageFilePath = fileName;
                } else {
                    alMessage.fileMeta.thumbnailFilePath = fileName;
                }
                self.downloadTask.message = alMessage;
                if (self.attachmentProgressDelegate) {
                    [self.attachmentProgressDelegate onDownloadCompleted:alMessage];
                }
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            if (attachmentDownloadFlag) {
                [messageClientService downloadImageUrl:alMessage.fileMeta.blobKey withCompletion:^(NSString *fileURL, NSError *error) {
                    if (error) {
                        ALSLog(ALLoggerSeverityError, @"ERROR GETTING DOWNLOAD URL : %@", error);
                        if (self.attachmentProgressDelegate) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self.attachmentProgressDelegate onDownloadFailed:alMessage];
                            });
                        }
                        return;
                    }
                    ALSLog(ALLoggerSeverityInfo, @"ATTACHMENT DOWNLOAD URL : %@", fileURL);

                    [self createGETRequestForAttachmentDownloadWithUrlString:fileURL withCompletion:^(NSMutableURLRequest *theRequest, NSError *error) {

                        if (error) {
                            if (self.attachmentProgressDelegate) {
                                dispatch_async(dispatch_get_main_queue(), ^(void) {
                                    [self.attachmentProgressDelegate onDownloadFailed:alMessage];
                                });
                            }
                            return;
                        }
                        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"FILE,%@",alMessage.key]];

                        if (ALApplozicSettings.getShareExtentionGroup) {
                            config.sharedContainerIdentifier = ALApplozicSettings.getShareExtentionGroup;
                        }
                        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
                        [self startSession:session withRequest:theRequest];
                    }];
                }];
            } else {

                [messageClientService downloadImageThumbnailUrl:alMessage.fileMeta.thumbnailUrl blobKey:alMessage.fileMeta.thumbnailBlobKey completion:^(NSString *fileURL, NSError *error) {

                    ALSLog(ALLoggerSeverityInfo, @"Thumbnail DOWNLOAD URL : %@", fileURL);
                    if (error == nil) {

                        NSString *downloadURLString = [NSString stringWithFormat:@"%@",fileURL];
                        NSMutableURLRequest *urlRequest =  [ALRequestHandler createGETRequestWithUrlStringWithoutHeader:downloadURLString paramString:nil];

                        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"THUMBNAIL,%@", alMessage.key]];
                        config.HTTPMaximumConnectionsPerHost = 2;

                        if (ALApplozicSettings.getShareExtentionGroup) {
                            config.sharedContainerIdentifier = ALApplozicSettings.getShareExtentionGroup;
                        }

                        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

                        [self startSession:session withRequest:urlRequest];
                    } else {
                        ALSLog(ALLoggerSeverityError, @"ERROR  DOWNLOAD Thumbnail : %@", error.description);
                        if (self.attachmentProgressDelegate) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self.attachmentProgressDelegate onDownloadFailed:alMessage];
                            });
                        }
                    }

                }];
            }
        });
    }
}

- (void)startSession:(NSURLSession *)session
         withRequest:(NSURLRequest *)urlRequest {
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:session];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if ([[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] containsObject:session]) {
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:urlRequest];
        [sessionDataTask resume];
    } else {
        dispatch_semaphore_signal(semaphore);
        return;
    }
}

- (void)uploadProfileImage:(UIImage *)profileImage
              withFilePath:(NSString *)filePath uploadURL:(NSString *)uploadURL withCompletion:(void(^)(NSData *data,NSError *error))completion {

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *fileError = [NSError errorWithDomain:@"Applozic"
                                                 code:errSSLInternal
                                             userInfo:@{NSLocalizedDescriptionKey : @"File does not exist "}];

        completion(nil, fileError);
        return;
    }
    NSMutableURLRequest *uploadImageRequest = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];

    [self.responseHandler authenticateRequest:uploadImageRequest WithCompletion:^(NSMutableURLRequest *urlRequest, NSError *error) {

        if (error) {
            completion(nil, error);
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            //Create boundary, it can be anything
            NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
            // set Content-Type in HTTP header
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
            // post body
            NSMutableData *body = [NSMutableData data];
            NSString *FileParamConstant = @"file";
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
            ALSLog(ALLoggerSeverityInfo, @"IMAGE_DATA :: %f",imageData.length/1024.0);

            //Assuming data is not nil we add this to the multipart form
            if (imageData) {

                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant, @"imge_123_profile"] dataUsingEncoding:NSUTF8StringEncoding]];

                [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", @"image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            //Close off the request with the boundary
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            // setting the body of the post to the request
            [urlRequest setHTTPBody:body];
            // set URL
            [urlRequest setURL:[NSURL URLWithString:uploadURL]];

            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

            NSURLSessionDataTask *sessionURLDataTask  = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    completion(data,error);
                });
            }];
            [sessionURLDataTask resume];
        });
    }];
}

- (DB_Message *)updateDbMessageWithKey:(NSString *)key
                          withFileName:(NSString *)fileName
                    withAttachmentFlag:(BOOL)isAttachmentDownload {
    DB_Message *messageEntity = nil;
    @try {
        ALMessageDBService *messageDatabase = [[ALMessageDBService alloc] init];
        messageEntity = (DB_Message*)[messageDatabase getMessageByKey:@"key" value:key];
        if (isAttachmentDownload) {
            messageEntity.inProgress = [NSNumber numberWithBool:NO];
            messageEntity.isUploadFailed = [NSNumber numberWithBool:NO];
            messageEntity.filePath = fileName;
        } else {
            messageEntity.fileMetaInfo.thumbnailFilePath = fileName;
        }
        [[ALDBHandler sharedInstance] saveContext];
    } @catch (NSException *exception) {
        ALSLog(ALLoggerSeverityError, @"NSException while update db message: %@",exception.reason);
    } @finally {
        return messageEntity;
    }
}

- (void)createGETRequestForAttachmentDownloadWithUrlString:(NSString *)fileURL
                                            withCompletion:(void(^)(NSMutableURLRequest *theRequest, NSError *error))completion {
    if (ALApplozicSettings.isS3StorageServiceEnabled ||
        ALApplozicSettings.isGoogleCloudServiceEnabled) {
        NSMutableURLRequest *downloadRequest = [ALRequestHandler createGETRequestWithUrlStringWithoutHeader:fileURL paramString:nil];
        completion(downloadRequest, nil);
    } else {
        NSMutableURLRequest *downloadRequest = [ALRequestHandler createGETRequestWithUrlString:fileURL paramString:nil];
        [self.responseHandler authenticateRequest:downloadRequest WithCompletion:^(NSMutableURLRequest *urlRequest, NSError *error) {
            if (error) {
                completion(nil, error);
                return;
            }
            completion(urlRequest, nil);
        }];
    }
}
@end
