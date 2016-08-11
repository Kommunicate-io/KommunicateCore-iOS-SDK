//
//  ALChannelClientService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define CHANNEL_INFO_URL @"/rest/ws/group/info"
#define CHANNEL_SYNC_URL @"/rest/ws/group/list"
#define CREATE_CHANNEL_URL @"/rest/ws/group/create"
#define DELETE_CHANNEL_URL @"/rest/ws/group/delete"
#define LEFT_CHANNEL_URL @"/rest/ws/group/left"
#define ADD_MEMBER_TO_CHANNEL_URL @"/rest/ws/group/add/member"
#define REMOVE_MEMBER_FROM_CHANNEL_URL @"/rest/ws/group/remove/member"
#define RENAME_CHANNEL_URL @"/rest/ws/group/change/name"

#import "ALChannelClientService.h"
#import "NSString+Encode.h"

@interface ALChannelClientService ()

@end

@implementation ALChannelClientService

+(void)getChannelInfo:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error, ALChannel *channel)) completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/group/info", KBASE_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@", channelKey];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@", clientChannelKey];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_INFORMATION" WithCompletionHandler:^(id theJson, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR IN CHANNEL_INFORMATION SERVER CALL REQUEST %@", error);
        }
        else
        {
            NSLog(@"JSON ALCHANNEL CLIENT SERVICE CLASS :: %@", theJson);
            ALChannelCreateResponse *response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
            completion(error, response.alChannel);
        }
        
    }];
}

+(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink withCompletion:(void(^)(NSError *error, ALChannelCreateResponse *response))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CREATE_CHANNEL_URL];
    NSMutableDictionary *channelDictionary = [NSMutableDictionary new];
    
    [channelDictionary setObject:channelName forKey:@"groupName"];
    [channelDictionary setObject:memberArray forKey:@"groupMemberList"];
  
    if(imageLink){
        [channelDictionary setObject:imageLink forKey:@"imageUrl"];
    }
    
    if(clientChannelKey)
    {
        [channelDictionary setObject:clientChannelKey forKey:@"clientGroupId"];
    }
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:channelDictionary options:0 error:&error];
    NSString *theParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    NSLog(@"PARAM_STRING :: %@", theParamString);

    [ALResponseHandler processRequest:theRequest andTag:@"CREATE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *theError) {

        ALChannelCreateResponse *response = nil;
        
        if (theError)
        {
            NSLog(@"ERROR IN CREATE_CHANNEL %@", theError);
        }
        else
        {
            NSLog(@"SEVER RESPONSE FROM JSON CREATE_CHANNEL : %@", (NSString *)theJson);
            response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
        }
        
        completion(theError, response);
        
    }];
    
}

+(void)addMemberToChannel:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, ADD_MEMBER_TO_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@",channelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@&userId=%@",clientChannelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    }
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"ADD_NEW_MEMBER_TO_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN ADD_NEW_MEMBER_TO_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"Response ADD_NEW_MEMBER_TO_CHANNEL :%@",response);
        completion(error, response);
    }];
}

+(void)removeMemberFromChannel:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey andChannelKey:(NSNumber *)channelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, REMOVE_MEMBER_FROM_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@&userId=%@",clientChannelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"REMOVE_MEMBER_FROM_CHANNEL_URL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN REMOVE_MEMBER_FROM_CHANNEL_URL SERVER CALL REQUEST %@", error);
        }
        else
        {
            NSLog(@"Response REMOVE_MEMBER_FROM_CHANNEL %@",theJson);
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, DELETE_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@", channelKey];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@",clientChannelKey];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"DELETE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN DELETE_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)leaveChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withUserId:(NSString *)userId andCompletion:(void (^)(NSError *, ALAPIResponse *))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, LEFT_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@",channelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@&userId=%@",clientChannelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"LEAVE_FROM_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN LEAVE_FROM_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"Response: LEAVE_FROM_CHANNEL %@",response.status);
        completion(error, response);
    }];
}

+(void)renameChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
          andNewName:(NSString *)newName andCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, RENAME_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&newName=%@", channelKey, newName];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@&newName=%@", clientChannelKey, newName];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"RENAME_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN RENAME_CHANNEL SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];
}

+(void)syncCallForChannel:(NSNumber *)updatedAt andCompletion:(void(^)(NSError *error, ALChannelSyncResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CHANNEL_SYNC_URL];
    NSMutableURLRequest * theRequest;
    
    if(updatedAt != nil || updatedAt != NULL)  // IF NEED DATA AFTER A PARTICULAR TIME
    {
        NSString * theParamString = [NSString stringWithFormat:@"updatedAt=%@", updatedAt];
        theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    }
    else  // IF CALLING FIRST TIME
    {
        theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:nil];
    }
    
    [ALResponseHandler processRequest:theRequest andTag:@"CHANNEL_SYNCHRONIZATION" WithCompletionHandler:^(id theJson, NSError *error) {
        ALChannelSyncResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN CHANNEL_SYNCHRONIZATION SERVER CALL REQUEST %@", error);
        }
        else
        {
            response = [[ALChannelSyncResponse alloc] initWithJSONString:theJson];
        }
        
        completion(error, response);
    }];

}

-(void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@/rest/ws/message/read/conversation",KBASE_URL];
    NSString * theParamString;
    if(channelKey)
    {
        theParamString = [NSString stringWithFormat:@"groupId=%@",channelKey];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"MARK_CONVERSATION_AS_READ" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            completion(nil,theError);
            NSLog(@"theError");
            return ;
        }else{
            //read sucessfull
            NSLog(@"sucessfully marked read !");
        }
        NSLog(@"Response: %@", (NSString *)theJson);
        completion((NSString *)theJson,nil);
    }];
}


@end
