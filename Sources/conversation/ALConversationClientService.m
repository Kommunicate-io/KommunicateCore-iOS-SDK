//
//  ALConversationClientService.m
//  Kommunicate
//
//  Created by Divjyot Singh on 04/03/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALConversationClientService.h"
#import "ALConversationDBService.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALLogger.h"

static NSString *const CREATE_CONVERSATION_URL = @"/rest/ws/conversation/id";
static NSString *const FETCH_CONVERSATION_DETAILS = @"/rest/ws/conversation/topicId";

@implementation ALConversationClientService

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupServices];
    }
    return self;
}

-(void)setupServices {
   self.responseHandler = [[ALResponseHandler alloc] init];
}

#pragma mark - Create conversation

- (void)createConversation:(ALConversationProxy *)alConversationProxy
            withCompletion:(void(^)(NSError *error, ALConversationCreateResponse *response))completion {
    
    NSString *conversationURLString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CREATE_CONVERSATION_URL];
    
    NSDictionary *dictionaryToSend = [NSDictionary dictionaryWithDictionary:[ALConversationProxy getDictionaryForCreate:alConversationProxy]];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:dictionaryToSend options:0 error:&error];
    NSString *conversationParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];
    NSMutableURLRequest *conversationRequest = [ALRequestHandler createPOSTRequestWithUrlString:conversationURLString paramString:conversationParamString];
    [self.responseHandler authenticateAndProcessRequest:conversationRequest andTag:@"CREATE_CONVERSATION" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        ALConversationCreateResponse *response = nil;
        
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN CREATE_CONVERSATION %@", theError);
        } else {
            response = [[ALConversationCreateResponse alloc] initWithJSONString:theJson];
        }
        ALSLog(ALLoggerSeverityInfo, @"SEVER RESPONSE FROM JSON CREATE_CONVERSATION : %@", theJson);
        completion(theError, response);
    }];
}

- (void)fetchTopicDetails:(NSNumber *)alConversationProxyID
            andCompletion:(void (^)(NSError *, ALAPIResponse *))completion {
    
    NSString *conversationDetailURLString = [NSString stringWithFormat:@"%@%@",KBASE_URL, FETCH_CONVERSATION_DETAILS];
    NSString *conversationDetailParamString = [NSString stringWithFormat:@"id=%@",alConversationProxyID];
    
    NSMutableURLRequest *conversationDetailRequest =  [ALRequestHandler createGETRequestWithUrlString:conversationDetailURLString paramString:conversationDetailParamString];
    
    [self.responseHandler authenticateAndProcessRequest:conversationDetailRequest andTag:@"FETCH_TOPIC_DETAILS" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        ALAPIResponse *response = nil;
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN FETCH_TOPIC_DETAILS SERVER CALL REQUEST %@", theError);
        } else {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        completion(theError, response);
    }];
}

@end
