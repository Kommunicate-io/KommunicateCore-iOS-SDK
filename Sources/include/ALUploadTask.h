//
//  ALUploadTask.h
//  Kommunicate
//
//  Created by apple on 25/03/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreMessage.h"

@interface ALUploadTask : NSObject

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) KMCoreMessage *message;

@property (nonatomic, strong) NSString *videoThumbnailName;

@end
