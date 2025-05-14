//
//  ALChannelSyncResponse.h
//  Kommunicate
//
//  Created by devashish on 16/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "ALChannel.h"

@interface ALChannelSyncResponse : ALAPIResponse

@property (nonatomic, strong) NSMutableArray *alChannelArray;

@property (nonatomic, strong) ALChannel *alChannel;

- (instancetype)initWithJSONString:(NSString *)JSONString;

// Initializer for a single channel
- (instancetype)initWithSingleChannelJSONString:(NSString *)JSONString;

@end
