//
//  ALConversationClientService.h
//  Kommunicate
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "ALConversationCreateResponse.h"
#import "ALConversationProxy.h"
#import "ALResponseHandler.h"

@interface ALConversationClientService : NSObject
@property (nonatomic, strong) ALResponseHandler *responseHandler;

- (void)createConversation:(ALConversationProxy *)alConversationProxy
           withCompletion:(void(^)(NSError *error, ALConversationCreateResponse *response))completion;

- (void)fetchTopicDetails:(NSNumber *)alConversationProxyID andCompletion:(void (^)(NSError *, ALAPIResponse *))completion;
@end
