//
//  KMCoreConversationClientService.h
//  Kommunicate
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConstant.h"
#import "KMCoreConversationCreateResponse.h"
#import "KMCoreConversationProxy.h"
#import "ALResponseHandler.h"

@interface KMCoreConversationClientService : NSObject
@property (nonatomic, strong) ALResponseHandler *responseHandler;

- (void)createConversation:(KMCoreConversationProxy *)alConversationProxy
           withCompletion:(void(^)(NSError *error, KMCoreConversationCreateResponse *response))completion;

- (void)fetchTopicDetails:(NSNumber *)alConversationProxyID andCompletion:(void (^)(NSError *, ALAPIResponse *))completion;
@end
