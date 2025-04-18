//
//  ALDownloadTask.h
//  Kommunicate
//
//  Created by apple on 25/03/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"

@interface ALDownloadTask : NSObject

@property (nonatomic) BOOL isThumbnail;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, strong) ALMessage *message;

@end
