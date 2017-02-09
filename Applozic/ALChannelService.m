//
//  ALChannelService.m
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChannelService.h"
#import "ALMessageClientService.h"
#import "ALConversationService.h"
#import "ALChannelUser.h"
#import "ALMuteRequest.h"
#import "ALAPIResponse.h"

@implementation ALChannelService

-(void)callForChannelServiceForDBInsertion:(NSString *)theJson
{
    ALChannelFeed *alChannelFeed = [[ALChannelFeed alloc] initWithJSONString:theJson];
    
    ALChannelDBService *alChannelDBService = [[ALChannelDBService alloc] init];
    [alChannelDBService insertChannel:alChannelFeed.channelFeedsList];
    
    NSMutableArray * memberArray = [NSMutableArray new];
    
    for(ALChannel *channel in alChannelFeed.channelFeedsList)
    {

        for(NSString *memberName in channel.membersName)
        {
            ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
            newChannelUserX.key = channel.key;
            newChannelUserX.userKey = memberName;
            newChannelUserX.parentKey = [channel getChannelMemberParentKey:memberName];
            [memberArray addObject:newChannelUserX];
        }
        
        [alChannelDBService insertChannelUserX:memberArray];
        [alChannelDBService removedMembersArray:channel.removeMembers andChannelKey:channel.key];
        [memberArray removeAllObjects];
        [self processChildGroups:channel];
    }
    
    //callForChannelProxy inserting in DB...
    ALConversationService *alConversationService = [[ALConversationService alloc] init];
    [alConversationService addConversations:alChannelFeed.conversationProxyList];
    
}

-(void)processChildGroups:(ALChannel *)alChannel {
    //Get INFO of Child
    for(NSNumber *channelKey in alChannel.childKeys){
        [self getChannelInformation:channelKey orClientChannelKey:nil withCompletion:^(ALChannel *alChannel3) {
            
        }];
    }
    
}

-(void)getChannelInformation:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *alChannel1 = [channelDBService loadChannelByKey:channelKey];
    
    if(alChannel1)
    {
        completion (alChannel1);
    }
    else
    {
        [ALChannelClientService getChannelInfo:channelKey orClientChannelKey:clientChannelKey withCompletion:^(NSError *error, ALChannel *alChannel2) {
            
            if(!error)
            {
                ALChannelDBService *dbService = [[ALChannelDBService alloc] init];
                [dbService createChannel:alChannel2];
            }
            completion (alChannel2);
        }];
    }
}

+(BOOL)isChannelDeleted:(NSNumber *)groupId
{
    ALChannelDBService *dbSerivce = [[ALChannelDBService alloc] init];
    BOOL flag = [dbSerivce isChannelDeleted:groupId];
    return flag;
}

+(BOOL)isChannelMuted:(NSNumber *)groupId
{
    ALChannelService * channelService = [[ALChannelService alloc] init];
    ALChannel *channel = [channelService getChannelByKey:groupId];
    return [channel isNotificationMuted];
}

-(BOOL)isChannelLeft:(NSNumber *)groupID
{
    ALChannelDBService *dbSerivce = [[ALChannelDBService alloc] init];
    BOOL flag = [dbSerivce isChannelLeft:groupID];
    return flag;
}

-(ALChannel *)getChannelByKey:(NSNumber *)channelKey
{
    ALChannelDBService * dbSerivce = [[ALChannelDBService alloc] init];
    ALChannel *channel = [dbSerivce loadChannelByKey:channelKey];
    return channel;
}

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)channelKey
{
    ALChannelDBService *ob = [[ALChannelDBService alloc] init];
    return [ob getListOfAllUsersInChannel:channelKey];
}

-(NSString *)stringFromChannelUserList:(NSNumber *)key
{
    ALChannelDBService *ob = [[ALChannelDBService alloc] init];
    return [ob stringFromChannelUserList: key];
}

-(NSNumber *)getOverallUnreadCountForChannel
{
    ALChannelDBService *ob = [[ALChannelDBService alloc] init];
    return [ob getOverallUnreadCountForChannelFromDB];
}

-(ALChannel *)fetchChannelWithClientChannelKey:(NSString *)clientChannelKey
{
    ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
    ALChannel * channel = [channelDB loadChannelByClientChannelKey:clientChannelKey];
    return channel;
}

-(BOOL)isLoginUserInChannel:(NSNumber *)channelKey
{
    NSMutableArray * memberList = [NSMutableArray arrayWithArray:[self getListOfAllUsersInChannel:channelKey]];
    return ([memberList containsObject:[ALUserDefaultsHandler getUserId]]);
}

-(NSMutableArray *)getAllChannelList
{
    ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
    return [channelDB getAllChannelKeyAndName];
}

//==========================================================================================================================================
#pragma mark PARENT AND SUB GROUPS METHODS
//==========================================================================================================================================

-(NSMutableArray *)fetchChildChannelsWithParentKey:(NSNumber *)parentGroupKey
{
    ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
    return [channelDB fetchChildChannels:parentGroupKey];
}

-(void)addChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey withCompletion:(void(^)(id json, NSError *error))completion
{
    NSLog(@"ADD_CHILD :: PARENT_KEY : %@ && CHILD_KEYs : %@",parentKey,childKeyList.description);
    if(parentKey)
    {
         [ALChannelClientService addChildKeyList:childKeyList andParentKey:parentKey withCompletion:^(id json, NSError *error) {
             
             if(!error)
             {
                 ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
                 for(NSNumber *childKey in childKeyList)
                 {
                     [channelDB updateChannelParentKey:childKey andWithParentKey:parentKey isAdding:YES];
                 }
             }
             completion(json, error);
             
         }];
    }
}

-(void)removeChildKeyList:(NSMutableArray *)childKeyList andParentKey:(NSNumber *)parentKey withCompletion:(void(^)(id json, NSError *error))completion
{
    NSLog(@"REMOVE_CHILD :: PARENT_KEY : %@ && CHILD_KEYs : %@",parentKey,childKeyList.description);
    if(parentKey)
    {
        [ALChannelClientService removeChildKeyList:childKeyList andParentKey:parentKey withCompletion:^(id json, NSError *error) {
            
            if(!error)
            {
                ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
                for(NSNumber *childKey in childKeyList)
                {
                    [channelDB updateChannelParentKey:childKey andWithParentKey:parentKey isAdding:NO];
                }
            }
            completion(json, error);
            
        }];
    }
}

//=================================================
#pragma mark ADD/REMOVING VIA CLIENT KEYS
//=================================================

-(void)addClientChildKeyList:(NSMutableArray *)clientChildKeyList andParentKey:(NSString *)clientParentKey
              withCompletion:(void(^)(id json, NSError *error))completion
{
    NSLog(@"ADD_CHILD :: PARENT_KEY : %@ && CHILD_KEYs (VIA_CLIENT) : %@",clientParentKey,clientChildKeyList.description);
    if(clientParentKey)
    {
        [ALChannelClientService addClientChildKeyList:clientChildKeyList andClientParentKey:clientParentKey withCompletion:^(id json, NSError *error) {
            
            if(!error)
            {
                ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
                for(NSString *childKey in clientChildKeyList)
                {
                    [channelDB updateClientChannelParentKey:childKey andWithClientParentKey:clientParentKey isAdding:YES];
                }
            }
            completion(json, error);
            
        }];
    }
}

-(void)removeClientChildKeyList:(NSMutableArray *)clientChildKeyList andParentKey:(NSString *)clientParentKey
           withCompletion:(void(^)(id json, NSError *error))completion
{
    NSLog(@"REMOVE_CHILD :: PARENT_KEY : %@ && CHILD_KEYs (VIA_CLIENT) : %@",clientParentKey,clientChildKeyList.description);
    if(clientParentKey)
    {
        [ALChannelClientService removeClientChildKeyList:clientChildKeyList andClientParentKey:clientParentKey withCompletion:^(id json, NSError *error) {
            
            if(!error)
            {
                ALChannelDBService * channelDB = [[ALChannelDBService alloc] init];
                for(NSString *childKey in clientChildKeyList)
                {
                    [channelDB updateClientChannelParentKey:childKey andWithClientParentKey:clientParentKey isAdding:NO];
                }
            }
            completion(json, error);
            
        }];
    }
}


//==========================================================================================================================================
#pragma mark CHANNEL API
//==========================================================================================================================================

//===========================================================================================================================
#pragma mark CREATE CHANNEL
//===========================================================================================================================

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink
      withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion
{
    
    /* GROUP META DATA DICTIONARY
     
     NSMutableDictionary *metaData = [self getChannelMetaData];
     
     NOTE : IF GROUP META DATA REQUIRE THEN REPLACE nil BY metaData
     */
    
    [self createChannel:channelName orClientChannelKey:clientChannelKey andMembersList:memberArray andImageLink:imageLink channelType:PUBLIC
            andMetaData:nil withCompletion:^(ALChannel *alChannel, NSError *error) {
       
        completion(alChannel, error);
    }];
}

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion
{
    if(channelName != nil)
    {
        [ALChannelClientService createChannel:channelName andParentChannelKey:nil orClientChannelKey:(NSString *)clientChannelKey
                               andMembersList:memberArray andImageLink:imageLink channelType:(short)type
                                  andMetaData:metaData withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
                                   
           if(!error)
           {
               response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
               ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
               [channelDBService createChannel:response.alChannel];
               completion(response.alChannel, error);
           }
           else
           {
               NSLog(@"ERROR_IN_CHANNEL_CREATING :: %@",error);
               completion(nil, error);
           }
       }];
    }
    else
    {
        NSLog(@"ERROR : CHANNEL NAME MISSING");
        return;
    }
}

-(NSMutableDictionary *)getChannelMetaData
{
    NSMutableDictionary *grpMetaData = [NSMutableDictionary new];

    [grpMetaData setObject:@":adminName created group" forKey:AL_CREATE_GROUP_MESSAGE];
    [grpMetaData setObject:@":userName removed" forKey:AL_REMOVE_MEMBER_MESSAGE];
    [grpMetaData setObject:@":userName added" forKey:AL_ADD_MEMBER_MESSAGE];
    [grpMetaData setObject:@":userName joined" forKey:AL_JOIN_MEMBER_MESSAGE];
    [grpMetaData setObject:@"Group renamed to :groupName" forKey:AL_GROUP_NAME_CHANGE_MESSAGE];
    [grpMetaData setObject:@":groupName icon changed" forKey:AL_GROUP_ICON_CHANGE_MESSAGE];
    [grpMetaData setObject:@":userName left" forKey:AL_GROUP_LEFT_MESSAGE];
    [grpMetaData setObject:@":groupName deleted" forKey:AL_DELETED_GROUP_MESSAGE];
    [grpMetaData setObject:@(NO) forKey:@"HIDE"];
    
    return grpMetaData;
}

/************************************
#pragma mark : SUB GROUP CREATION
*************************************/

-(void)createChannel:(NSString *)channelName andParentChannelKey:(NSNumber *)parentChannelKey orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink channelType:(short)type
         andMetaData:(NSMutableDictionary *)metaData withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion
{
    if(channelName != nil)
    {
        [ALChannelClientService createChannel:channelName andParentChannelKey:parentChannelKey orClientChannelKey:clientChannelKey
                               andMembersList:memberArray andImageLink:imageLink channelType:(short)type
                                  andMetaData:metaData withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
                                      
          if(!error)
          {
              response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
              ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
              [channelDBService createChannel:response.alChannel];
              completion(response.alChannel, error);
          }
          else
          {
              NSLog(@"ERROR_IN_CHANNEL_CREATING :: %@",error);
              completion(nil, error);
          }
      }];
    }
    else
    {
        NSLog(@"ERROR : CHANNEL NAME MISSING");
        return;
    }
}

//===========================================================================================================================
#pragma mark ADD NEW MEMBER TO CHANNEL
//===========================================================================================================================

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
            withCompletion:(void(^)(NSError *error,ALAPIResponse *response))completion
{
    if((channelKey != nil || clientChannelKey != nil) && userId != nil)
    {
        [ALChannelClientService addMemberToChannel:userId orClientChannelKey:clientChannelKey
                                     andChannelKey:channelKey withCompletion:^(NSError *error, ALAPIResponse *response) {
    
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                if(clientChannelKey != nil)
                {
                    ALChannel *alChannel = [channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [channelDBService addMemberToChannel:userId andChannelKey:alChannel.key];
                }
                else
                {
                    [channelDBService addMemberToChannel:userId andChannelKey:channelKey];
                }
            }
            completion(error,response);
        }];
    }
}

//===========================================================================================================================
#pragma mark REMOVE MEMBER FROM CHANNEL
//===========================================================================================================================

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
                 withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    if((channelKey != nil || clientChannelKey != nil) && userId != nil)
    {
        [ALChannelClientService removeMemberFromChannel:userId orClientChannelKey:clientChannelKey
                                          andChannelKey:channelKey withCompletion:^(NSError *error, ALAPIResponse *response) {
                                              
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                if(clientChannelKey != nil)
                {
                    ALChannel *alChannel = [channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [channelDBService removeMemberFromChannel:userId andChannelKey:alChannel.key];
                }
                else
                {
                    [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                }
            }
            completion(error,response);
        }];
    }
}

//===========================================================================================================================
#pragma mark DELETE CHANNEL
//===========================================================================================================================

-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion
{
    if(channelKey != nil || clientChannelKey != nil)
    {
        [ALChannelClientService deleteChannel:channelKey orClientChannelKey:clientChannelKey
                                withCompletion:^(NSError *error, ALAPIResponse *response) {
                                    
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                if(clientChannelKey != nil)
                {
                    ALChannel *alChannel = [channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [channelDBService deleteChannel:alChannel.key];
                }
                else
                {
                    [channelDBService deleteChannel:channelKey];
                }
            }
            completion(error, response);
        }];
    }
}

-(BOOL)checkAdmin:(NSNumber *)channelKey
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *channel = [channelDBService loadChannelByKey:channelKey];
    
    return [channel.adminKey isEqualToString:[ALUserDefaultsHandler getUserId]];
}

//===========================================================================================================================
#pragma mark LEAVE CHANNEL
//===========================================================================================================================

-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey
     withCompletion:(void(^)(NSError *error))completion
{
    if((channelKey != nil || clientChannelKey != nil) && userId != nil)
    {
        [ALChannelClientService leaveChannel:channelKey orClientChannelKey:clientChannelKey
                                  withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                if(clientChannelKey != nil)
                {
                    ALChannel *alChannel = [channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [channelDBService removeMemberFromChannel:userId andChannelKey:alChannel.key];
                    [channelDBService setLeaveFlag:YES forChannel:alChannel.key];
                }
                else
                {
                    [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                    [channelDBService setLeaveFlag:YES forChannel:channelKey];
                }

            }
            completion(error);
        }];
    }
}

//===========================================================================================================================
#pragma mark RENAME CHANNEL (FROM DEVICE SIDE)
//===========================================================================================================================

-(void)updateChannel:(NSNumber *)channelKey andNewName:(NSString *)newName andImageURL:(NSString *)imageURL
  orClientChannelKey:(NSString *)clientChannelKey orChildKeys:(NSMutableArray *)childKeysList
      withCompletion:(void(^)(NSError *error))completion
{
    if(channelKey != nil || clientChannelKey != nil)
    {
        [ALChannelClientService updateChannel:channelKey orClientChannelKey:clientChannelKey
                                   andNewName:newName andImageURL:imageURL orChildKeys:childKeysList andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                if(clientChannelKey != nil)
                {
                    ALChannel *alChannel = [channelDBService loadChannelByClientChannelKey:clientChannelKey];
                    [channelDBService updateChannel:alChannel.key andNewName:newName orImageURL:imageURL orChildKeys:childKeysList];
                }
                else
                {
                    [channelDBService updateChannel:channelKey andNewName:newName orImageURL:imageURL orChildKeys:childKeysList];
                }
            }
            completion(error);
        }];
    }
}

//===========================================================================================================================
#pragma mark CHANNEL SYNCHRONIZATION
//===========================================================================================================================

-(void)syncCallForChannel
{
    NSNumber *updateAt = [ALUserDefaultsHandler getLastSyncChannelTime];
    
    [ALChannelClientService syncCallForChannel:updateAt andCompletion:^(NSError *error, ALChannelSyncResponse *response) {
        
        if([response.status isEqualToString:@"success"])
        {
            ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
            [channelDBService processArrayAfterSyncCall:response.alChannelArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GroupDetailTableReload" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_CHANNEL_NAME" object:nil];
        }
    }];
}

//===========================================================================================================================
#pragma mark MARK READ FOR GROUP
//===========================================================================================================================

+(void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion
{
    [ALChannelService setUnreadCountZeroForGroupID:channelKey];
    
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    NSUInteger count = [channelDBService markConversationAsRead:channelKey];
    NSLog(@"Found %ld messages for marking as read.", (unsigned long)count);
    
    if(count == 0){
        return;
    }
    
    ALChannelClientService * clientService = [[ALChannelClientService alloc] init];
    [clientService markConversationAsRead:channelKey withCompletion:^(NSString *response, NSError * error) {
        completion(response,error);
    }];

}

+(void)setUnreadCountZeroForGroupID:(NSNumber *)channelKey
{
    ALChannelDBService *channelDBService = [ALChannelDBService new];
    [channelDBService  updateUnreadCountChannel:channelKey unreadCount:[NSNumber numberWithInt:0]];
    
    ALChannel * channel = [channelDBService loadChannelByKey:channelKey];
    channel.unreadCount = [NSNumber numberWithInt:0];
}
    
-(void)muteChannel:(ALMuteRequest *)muteRequest withCompletion:(void(^)(ALAPIResponse * response, NSError *error))completion
{
    ALChannelClientService * clientService = [[ALChannelClientService alloc] init];
    [clientService muteChannel:muteRequest withCompletion:^(ALAPIResponse *response, NSError *error) {
        ALChannelDBService * dbService = [ALChannelDBService new];
        [dbService updateMuteAfterTime:muteRequest.notificationAfterTime andChnnelKey:muteRequest.id];
        completion(response,error);
        
    }];
}
    
@end
