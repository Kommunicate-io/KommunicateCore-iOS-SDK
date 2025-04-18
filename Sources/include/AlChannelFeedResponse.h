//
//  AlChannelFeedResponse.h
//  Kommunicate
//
//  Created by Nitin on 20/10/17.
//  Copyright © 2017 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "ALChannel.h"

@interface AlChannelFeedResponse : ALAPIResponse

@property (nonatomic, strong) ALChannel *alChannel;
@property (nonatomic, strong) NSDictionary *errorResponse;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end
