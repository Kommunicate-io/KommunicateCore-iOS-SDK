//
//  ALConversationCreateResponse.h
//  Kommunicate
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"
#import "ALConversationProxy.h"

@interface ALConversationCreateResponse : ALAPIResponse

@property (nonatomic, strong) ALConversationProxy *alConversationProxy;
- (instancetype)initWithJSONString:(NSString *)JSONString;
@end
