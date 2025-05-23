//
//  KMCoreChannelSyncResponse.h
//  Kommunicate
//
//  Created by devashish on 16/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "KMCoreChannel.h"

@interface KMCoreChannelSyncResponse : ALAPIResponse

@property (nonatomic, strong) NSMutableArray *alChannelArray;

@property (nonatomic, strong) KMCoreChannel *alChannel;

- (instancetype)initWithJSONString:(NSString *)JSONString;

// Initializer for a single channel
- (instancetype)initWithSingleChannelJSONString:(NSString *)JSONString;

@end
