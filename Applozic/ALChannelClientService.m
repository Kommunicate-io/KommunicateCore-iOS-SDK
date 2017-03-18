//
//  ALChannelClientService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define CHANNEL_INFO_URL @"/rest/ws/group/info"
//#define CHANNEL_SYNC_URL @"/rest/ws/group/list"
#define CHANNEL_SYNC_URL @"/rest/ws/group/v3/list"
#define CREATE_CHANNEL_URL @"/rest/ws/group/create"
#define DELETE_CHANNEL_URL @"/rest/ws/group/delete"
#define LEFT_CHANNEL_URL @"/rest/ws/group/left"
#define ADD_MEMBER_TO_CHANNEL_URL @"/rest/ws/group/add/member"
#define REMOVE_MEMBER_FROM_CHANNEL_URL @"/rest/ws/group/remove/member"
#define UPDATE_CHANNEL_URL @"/rest/ws/group/update"
#define UPDATE_GROUP_USER @"/rest/ws/group/user/update"


/************************************************
 SUB GROUP URL : ADD A SINGLE CHILD
*************************************************/

#define ADD_SUB_GROUP @"/rest/ws/group/add/subgroup"
#define REMOVE_SUB_GROUP @"/rest/ws/group/remove/subgroup"

/************************************************
 SUB GROUP URL : ADD MULTIPLE CHILD
 *************************************************/

#define ADD_MULTIPLE_SUB_GROUP @"/rest/ws/group/add/subgroups"
#define REMOVE_MULTIPLE_SUB_GROUP @"/rest/ws/group/remove/subgroups"


#import "ALChannelClientService.h"
#import "NSString+Encode.h"
#import "ALContactService.h"
#import "ALUserClientService.h"
#import "ALContactDBService.h"
#import "ALContactDBService.h"
#import "ALUserDetailListFeed.h"
#import "ALUserService.h"
#import "ALMuteRequest.h"


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
            NSLog(@"RESPONSE_CHANNEL_INFORMATION :: %@", theJson);
            ALChannelCreateResponse *response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
            NSMutableArray * members = response.alChannel.removeMembers;
            ALContactService * contactService = [ALContactService new];
            NSMutableArray* userNotPresentIds =[NSMutableArray new];
            for(NSString * userId in members)
            {
                if(![contactService isContactExist:userId])
                {
                    [userNotPresentIds addObject:userId];
                }
            }
            if(userNotPresentIds.count>0)
            {
                NSLog(@"Call userDetails...");
                
                ALUserService *alUserService = [ALUserService new];
                [alUserService fetchAndupdateUserDetails:userNotPresentIds withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
                    NSLog(@"User detail response sucessfull.");
                    completion(error, response.alChannel);
                    
                }];
            }
            else
            {
                
                NSLog(@"No user for userDetails");
                completion(error, response.alChannel);
            }
        }
    }];
}

+(void)createChannel:(NSString *)channelName andParentChannelKey:(NSNumber *)parentChannelKey
  orClientChannelKey:(NSString *)clientChannelKey andMembersList:(NSMutableArray *)memberArray
        andImageLink:(NSString *)imageLink channelType:(short)type andMetaData:(NSMutableDictionary *)metaData
      withCompletion:(void(^)(NSError *error, ALChannelCreateResponse *response))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, CREATE_CHANNEL_URL];
    NSMutableDictionary *channelDictionary = [NSMutableDictionary new];
    
    [channelDictionary setObject:channelName forKey:@"groupName"];
    [channelDictionary setObject:memberArray forKey:@"groupMemberList"];
    [channelDictionary setObject:[NSString stringWithFormat:@"%i", type] forKey:@"type"];
    
    if(metaData)
    {
        [channelDictionary setObject:metaData forKey:@"metadata"];
    }
    
    if(imageLink)
    {
        [channelDictionary setObject:imageLink forKey:@"imageUrl"];
    }
    
    if(clientChannelKey)
    {
        [channelDictionary setObject:clientChannelKey forKey:@"clientGroupId"];
    }
    if(parentChannelKey)
    {
        [channelDictionary setObject:parentChannelKey forKey:@"parentKey"];
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
            NSLog(@"ERROR IN CREATE_CHANNEL :: %@", theError);
        }
        else
        {
            response = [[ALChannelCreateResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_CREATE_CHANNEL :: %@", (NSString *)theJson);
        completion(theError, response);
        
    }];
}

+(void)addMemberToChannel:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey andChannelKey:(NSNumber *)channelKey
           withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
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
            NSLog(@"ERROR IN ADD_NEW_MEMBER_TO_CHANNEL :: %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_ADD_NEW_MEMBER_TO_CHANNEL :: %@", (NSString *)theJson);
        completion(error, response);
    }];
}

+(void)removeMemberFromChannel:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey andChannelKey:(NSNumber *)channelKey
                withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, REMOVE_MEMBER_FROM_CHANNEL_URL];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&userId=%@", channelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    if(clientChannelKey)
    {
        theParamString = [NSString stringWithFormat:@"clientGroupId=%@&userId=%@",clientChannelKey,[userId urlEncodeUsingNSUTF8StringEncoding]];
    }
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"REMOVE_MEMBER_FROM_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN REMOVE_MEMBER_FROM_CHANNEL :: %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_REMOVE_MEMBER_FROM_CHANNEL :: %@", (NSString *)theJson);
        completion(error, response);
    }];
}

+(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
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
            NSLog(@"ERROR IN DELETE_CHANNEL SERVER CALL REQUEST :: %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_DELETE_CHANNEL :: %@", (NSString *)theJson);
        completion(error, response);
    }];
}

+(void)leaveChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withUserId:(NSString *)userId
      andCompletion:(void (^)(NSError *, ALAPIResponse *))completion
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
            NSLog(@"ERROR IN LEAVE_FROM_CHANNEL SERVER CALL REQUEST  :: %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_LEAVE_FROM_CHANNEL :: %@", (NSString *)theJson);
        completion(error, response);
    }];
}

+(void)updateChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
          andNewName:(NSString *)newName andImageURL:(NSString *)imageURL metadata:(NSMutableDictionary *)metaData
         orChildKeys:(NSMutableArray *)childKeysList andCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, UPDATE_CHANNEL_URL];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
        
    if(newName.length)
    {
        [dictionary setObject:newName forKey:@"newName"];
    }
    if(clientChannelKey.length)
    {
        [dictionary setObject:clientChannelKey forKey:@"clientGroupId"];
    }
    else
    {
        [dictionary setObject:channelKey forKey:@"groupId"];
    }

    [dictionary setObject:imageURL forKey:@"imageUrl"];
    
    if (metaData)
    {
        [dictionary setObject:metaData forKey:@"metadata"];
    }
    
    if(childKeysList.count) {
         [dictionary setObject:childKeysList forKey:@"childKeys"];
    }
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString * theParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];
    
    NSLog(@"PARAM_STRING_CHANNEL_UPDATE :: %@", theParamString);
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"UPDATE_CHANNEL" WithCompletionHandler:^(id theJson, NSError *error) {
        
        ALAPIResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN UPDATE_CHANNEL :: %@", error);
        }
        else
        {
            response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        }
        NSLog(@"RESPONSE_UPDATE_CHANNEL :: %@", (NSString *)theJson);
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
        
        NSLog(@"CHANNEL_SYNCHRONIZATION_RESPONSE :: %@", (NSString *)theJson);
        ALChannelSyncResponse *response = nil;
        if(error)
        {
            NSLog(@"ERROR IN CHANNEL_SYNCHRONIZATION SERVER CALL REQUEST %@", error);
        }
        else
        {
            NSMutableArray* userNotPresentIds =[NSMutableArray new];
            response = [[ALChannelSyncResponse alloc] initWithJSONString:theJson];
            ALContactService * contactService = [ALContactService new];
            
            for(ALChannel * channel in response.alChannelArray){
                
                for(NSString * userId in channel.membersName){
                    
                    if(![contactService isContactExist:userId]){
                        [userNotPresentIds addObject:userId];
                    }
                }
            }
            if(userNotPresentIds.count>0)
            {
                NSLog(@"Call userDetails...");
                ALUserService *alUserService = [ALUserService new];
                [alUserService fetchAndupdateUserDetails:userNotPresentIds withCompletion:^(NSMutableArray *userDetailArray, NSError *theError) {
                    NSLog(@"User detail response sucessfull.");
                    completion(error, response);
                }];
            }
            else
            {
            
                completion(error, response);
            }
        }
    }];
    
}

+(void)addChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey withCompletion:(void (^)(id json, NSError * error))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL,ADD_MULTIPLE_SUB_GROUP];
    
    NSString * tempString = @"";
    for(NSNumber *subGroupKey in childKeyList)
    {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"&subGroupIds=%@",subGroupKey]];
    }
    
    tempString = [tempString substringFromIndex:1];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&%@",parentKey,tempString];
    NSLog(@"PARAM_STRING_CHANNEL_UPDATE :: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];

    [ALResponseHandler processRequest:theRequest andTag:@"ADDING_CHILD_TO_PARENT" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"RESPONSE_ADDING_CHILD_TO_PARENT :: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"ERROR ADDING_CHILD_TO_PARENT :: %@", theError);
            completion(nil, theError);
            return;
        }
        completion((NSString *)theJson, nil);
    }];
}

+(void)removeChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey withCompletion:(void (^)(id json, NSError * error))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL,REMOVE_MULTIPLE_SUB_GROUP];
    
    NSString * tempString = @"";
    for(NSNumber *subGroupKey in childKeyList)
    {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"&subGroupIds=%@",subGroupKey]];
    }
    
    tempString = [tempString substringFromIndex:1];
    NSString * theParamString = [NSString stringWithFormat:@"groupId=%@&%@",parentKey,tempString];
    NSLog(@"PARAM_STRING_CHANNEL_UPDATE :: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"REMOVE_CHILD_TO_PARENT" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"RESPONSE_REMOVE_CHILD_TO_PARENT :: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"ERROR REMOVE_CHILD_TO_PARENT :: %@", theError);
            completion(nil, theError);
            return;
        }
        completion((NSString *)theJson, nil);
    }];
}

//=================================================
#pragma mark ADD/REMOVING VIA CLIENT KEYS
//=================================================

+(void)addClientChildKeyList:(NSMutableArray *)clientChildKeyList andClientParentKey:(NSString *)clientParentKey
              withCompletion:(void (^)(id json, NSError * error))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL,ADD_MULTIPLE_SUB_GROUP];
    
    NSString * tempString = @"";
    for(NSString *subGroupKey in clientChildKeyList)
    {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"&clientSubGroupIds=%@",subGroupKey]];
    }
    
    tempString = [tempString substringFromIndex:1];
    NSString * theParamString = [NSString stringWithFormat:@"clientGroupId=%@&%@",clientParentKey,tempString];
    NSLog(@"PARAM_STRING_ADDING_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"ADDING_CHILD_TO_PARENT_VIA_CLIENT_KEY" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"RESPONSE_ADDING_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"ERROR ADDING_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", theError);
            completion(nil, theError);
            return;
        }
        completion((NSString *)theJson, nil);
    }];
}

+(void)removeClientChildKeyList:(NSMutableArray *)clientChildKeyList andClientParentKey:(NSString *)clientParentKey
                withCompletion:(void (^)(id json, NSError * error))completion
{
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL,REMOVE_MULTIPLE_SUB_GROUP];
    
    NSString * tempString = @"";
    for(NSString *subGroupKey in clientChildKeyList)
    {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"&clientSubGroupIds=%@",subGroupKey]];
    }
    
    tempString = [tempString substringFromIndex:1];
    NSString * theParamString = [NSString stringWithFormat:@"clientGroupId=%@&%@",clientParentKey,tempString];
    NSLog(@"PARAM_STRING_ADDING_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", theParamString);
    NSMutableURLRequest * theRequest = [ALRequestHandler createGETRequestWithUrlString:theUrlString paramString:theParamString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"REMOVE_CHILD_TO_PARENT_VIA_CLIENT_KEY" WithCompletionHandler:^(id theJson, NSError *theError) {
        
        NSLog(@"RESPONSE_REMOVE_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", (NSString *)theJson);
        if (theError)
        {
            NSLog(@"ERROR REMOVE_CHILD_TO_PARENT (VIA CLIENT KEY) :: %@", theError);
            completion(nil, theError);
            return;
        }
        completion((NSString *)theJson, nil);
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
        if (theError)
        {
            NSLog(@"ERROR IN MARK_CONVERSATION_AS_READ :: %@", theError);
            completion(nil, theError);
            return;
        }
        else
        {
            NSLog(@"sucessfully marked read !");
        }
        NSLog(@"RESPONSE_MARK_CONVERSATION_AS_READ :: %@", (NSString *)theJson);
        completion((NSString *)theJson, nil);
    }];
}

    
-(void) muteChannel:(ALMuteRequest *)alMuteRequest withCompletion:(void(^)(ALAPIResponse * response, NSError * error))completion
{
    
    NSString * theUrlString = [NSString stringWithFormat:@"%@%@",KBASE_URL,UPDATE_GROUP_USER];
    NSError * error;
   
    NSData * postdata = [NSJSONSerialization dataWithJSONObject:alMuteRequest.dictionary options:0 error:&error];
    NSString *paramString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * theRequest = [ALRequestHandler createPOSTRequestWithUrlString:theUrlString paramString:paramString];
    
    [ALResponseHandler processRequest:theRequest andTag:@"MUTE_GROUP" WithCompletionHandler:^(id theJson, NSError *theError) {
       
        if (theError)
        {
            NSLog(@" muteChannel :: %@", theError);
            completion(nil, theError);
            return;
        }
        ALAPIResponse*  response = [[ALAPIResponse alloc] initWithJSONString:theJson];
        completion(response, nil);
        
    }];

}

@end
