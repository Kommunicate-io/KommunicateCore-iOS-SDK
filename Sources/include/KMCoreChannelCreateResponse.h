//
//  KMCoreChannelCreateResponse.h
//  Kommunicate
//
//  Created by devashish on 12/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "KMCoreChannel.h"

@interface KMCoreChannelCreateResponse : ALAPIResponse

@property (nonatomic, strong) KMCoreChannel *alChannel;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end
