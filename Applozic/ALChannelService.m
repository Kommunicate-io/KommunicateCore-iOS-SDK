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

@implementation ALChannelService
{
    BOOL isChannelLeaved;
    BOOL isChannelRenamed;
    BOOL isChannelDeleted;
    BOOL isChannelMemberAdded;
    BOOL isChannelMemberRemoved;
}

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
            [memberArray addObject:newChannelUserX];
        }
        [alChannelDBService insertChannelUserX:memberArray];
        [memberArray removeAllObjects];
    }
    
    //callForChannelProxy inserting in DB...
    ALConversationService *alConversationService = [[ALConversationService alloc] init];
    [alConversationService addConversations:alChannelFeed.conversationProxyList];
    
}

-(void)getChannelInformation:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion
{
    ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *alChannel1 = [channelDBService checkChannelEntity:channelKey];
    
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

-(BOOL)isChannelLeft:(NSNumber*)groupID
{
    ALChannelDBService *dbSerivce = [[ALChannelDBService alloc] init];
    if([dbSerivce isChannelLeft:groupID])
    {
        return YES;
    }
    else
    {
        return NO;
    }
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

//==========================================================================================================================================
#pragma mark CHANNEL API
//==========================================================================================================================================

//===========================================================================================================================
#pragma mark CREATE CHANNEL
//===========================================================================================================================

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
      andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink withCompletion:(void(^)(ALChannel *alChannel))completion
{
    if(channelName != nil)
    {
        [ALChannelClientService createChannel:channelName orClientChannelKey:(NSString *)clientChannelKey
                               andMembersList:memberArray andImageLink:imageLink  withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
            
            if(!error)
            {
                response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService createChannel:response.alChannel];
                completion(response.alChannel);
            }
            else
            {
                NSLog(@"ERROR_IN_CHANNEL_CREATING :: %@",error);
                completion(nil);
            }
        }];
    }
    else
    {
        return;
    }
}

//===========================================================================================================================
#pragma mark ADD NEW MEMBER TO CHANNEL
//===========================================================================================================================

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
            withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion
{
    
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService addMemberToChannel:userId orClientChannelKey:clientChannelKey
                                     andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService addMemberToChannel:userId andChannelKey:channelKey];
            }
            completion(error,response);
        }];
    }
}

//===========================================================================================================================
#pragma mark REMOVE MEMBER FROM CHANNEL
//===========================================================================================================================

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
                 withComletion:(void(^)(NSError *error, NSString *response))completion
{
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService removeMemberFromChannel:userId orClientChannelKey:clientChannelKey
                                          andChannelKey:channelKey withComletion:^(NSError *error, ALAPIResponse *response) {
                                              
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                isChannelMemberRemoved = YES;
            }
            completion(error,response.status);
        }];
    }
}

//===========================================================================================================================
#pragma mark DELETE CHANNEL
//===========================================================================================================================

-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
{
    if(channelKey != nil)
    {
        [ALChannelClientService deleteChannel:channelKey orClientChannelKey:clientChannelKey
                                withComletion:^(NSError *error, ALAPIResponse *response) {
                                    
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService deleteChannel:channelKey];
            }
            completion(error);
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
    if(channelKey != nil && userId != nil)
    {
        [ALChannelClientService leaveChannel:channelKey orClientChannelKey:clientChannelKey
                                  withUserId:(NSString *)userId andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService removeMemberFromChannel:userId andChannelKey:channelKey];
                [channelDBService setLeaveFlagForChannel:channelKey];
            }
            completion(error);
        }];
    }
}

//===========================================================================================================================
#pragma mark RENAME CHANNEL (FROM DEVICE SIDE)
//===========================================================================================================================

-(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orClientChannelKey:(NSString *)clientChannelKey
      withCompletion:(void(^)(NSError *error))completion
{
    if(channelKey != nil && newName != nil)
    {
        [ALChannelClientService renameChannel:channelKey orClientChannelKey:clientChannelKey
                                   andNewName:newName andCompletion:^(NSError *error, ALAPIResponse *response) {
            
            if([response.status isEqualToString:@"success"])
            {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService renameChannel:channelKey andNewName:newName];
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

+(void)setUnreadCountZeroForGroupID:(NSNumber*)channelKey
{
    ALChannelDBService *channelDBService = [ALChannelDBService new];
    [channelDBService  updateUnreadCountChannel:channelKey unreadCount:[NSNumber numberWithInt:0]];
    
    ALChannel * channel = [channelDBService loadChannelByKey:channelKey];
    channel.unreadCount = [NSNumber numberWithInt:0];
}

@end
