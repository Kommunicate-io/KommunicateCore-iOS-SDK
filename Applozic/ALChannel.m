//
//  ALChannel.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannel.h"
#import "ALChannelUser.h"


@interface ALChannel ()

@end

@implementation ALChannel

-(id)initWithDictonary:(NSDictionary *)messageDictonary
{
    [self parseMessage:messageDictonary];
    return self;
}

-(void)parseMessage:(id) messageJson
{
    self.key = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.clientChannelKey = [self getStringFromJsonValue:messageJson[@"clientGroupId"]];
    self.name = [self getStringFromJsonValue:messageJson[@"name"]];
    self.channelImageURL = [self getStringFromJsonValue:messageJson[@"imageUrl"]];
    self.adminKey = [self getStringFromJsonValue:messageJson[@"adminId"]];
    self.unreadCount = [self getNSNumberFromJsonValue:messageJson[@"unreadCount"]];
    //self.userCount = [self getNSNumberFromJsonValue:messageJson[@""]];
    self.membersName = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersName"]];
    self.removeMembers = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"removedMembersId"]];
    self.type = [self getShortFromJsonValue:messageJson[@"type"]];
    self.childKeys = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"childKeys"]];

    self.parentKey = [self getNSNumberFromJsonValue:messageJson[@"parentKey"]];
    self.parentClientKey = [self getStringFromJsonValue:messageJson[@"parentClientGroupId"]];
    
    NSDictionary * channelDetailGroup = [messageJson objectForKey:@"groupUsers"];
    NSMutableArray * userArray = [NSMutableArray new];

    for(NSDictionary* dict in channelDetailGroup){
        ALChannelUser * channelUser = [[ALChannelUser alloc] initWithDictonary:dict];
        [userArray addObject:channelUser];
    }
    self.groupUsers = userArray;
}

-(NSNumber *)getChannelMemberParentKey:(NSString *)userId
{
    for(ALChannelUser * channelUser in self.groupUsers)
    {
        if(userId && [userId isEqualToString:channelUser.userId])
        {
            return channelUser.parentGroupKey;
        }
    }
    
    return nil;
}

@end
