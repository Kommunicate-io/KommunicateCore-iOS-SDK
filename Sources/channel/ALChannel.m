//
//  ALChannel.m
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "ALChannel.h"
#import "ALChannelUser.h"
#import "KMCoreUserDefaultsHandler.h"


@interface ALChannel ()

@end

@implementation ALChannel

@synthesize membersName = _membersName;

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (void)parseMessage:(id) messageJson {
    self.key = [self getNSNumberFromJsonValue:messageJson[@"id"]];
    self.clientChannelKey = [self getStringFromJsonValue:messageJson[@"clientGroupId"]];
    self.name = [self getStringFromJsonValue:messageJson[@"name"]];
    self.channelImageURL = [self getStringFromJsonValue:messageJson[@"imageUrl"]];
    self.adminKey = [self getStringFromJsonValue:messageJson[@"adminId"]];
    self.unreadCount = [self getNSNumberFromJsonValue:messageJson[@"unreadCount"]];
    self.userCount = [self getNSNumberFromJsonValue:messageJson[@"userCount"]];
    [self setMembersName: [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersName"]]];
    self.membersId = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"membersId"]];
    
    self.removeMembers = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"removedMembersId"]];
    self.type = [self getShortFromJsonValue:messageJson[@"type"]];
    
    self.metadata = [[NSMutableDictionary alloc] initWithDictionary:[messageJson objectForKey:@"metadata"]];
    
    self.platformSource = [self getStringFromJsonValue:messageJson[@"metadata"][@"source"]];

    self.childKeys = [[NSMutableArray alloc] initWithArray:[messageJson objectForKey:@"childKeys"]];
    
    self.notificationAfterTime = [self getNSNumberFromJsonValue:messageJson[@"notificationAfterTime"]];
    
    self.deletedAtTime = [self getNSNumberFromJsonValue:messageJson[@"deletedAtTime"]];
    
    self.parentKey = [self getNSNumberFromJsonValue:messageJson[@"parentKey"]];
    self.parentClientKey = [self getStringFromJsonValue:messageJson[@"parentClientGroupId"]];
    
    NSDictionary *channelDetailGroup = [messageJson objectForKey:@"groupUsers"];
    NSMutableArray *userArray = [NSMutableArray new];

    for (NSDictionary *dict in channelDetailGroup) {
        ALChannelUser *channelUser = [[ALChannelUser alloc] initWithDictonary:dict];
        [userArray addObject:channelUser];
    }
    self.groupUsers = userArray;
    
    // Channel conversation status
    if (self.metadata) {
        self.category = [ALChannel getConversationCategory:self.metadata];
    } else {
        self.category = ALL_CONVERSATION;
    }
}

- (NSNumber *)getChannelMemberParentKey:(NSString *)userId {
    for (ALChannelUser *channelUser in self.groupUsers) {
        if (userId && [userId isEqualToString:channelUser.userId]) {
            return channelUser.parentGroupKey;
        }
    }
    return nil;
}

- (BOOL)isNotificationMuted {
    long secsUtc1970 = [[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] ] longValue]*1000L;
    if (_notificationAfterTime != nil) {
        return ([_notificationAfterTime longValue]> secsUtc1970);
    } else {
        return ([self isGroupMutedByDefault]);
    }
}

- (void)setMembersName:(NSMutableArray *)membersName {
    _membersName = membersName;
}

- (NSMutableArray *)membersName {
    return self.membersId;
}

- (NSString *)getReceiverIdInGroupOfTwo {
    
    if (self.type!=GROUP_OF_TWO) {
        return nil;
    }
    
    for (NSString *userId in self.membersName) {
        if (!([userId isEqualToString:[KMCoreUserDefaultsHandler getUserId]])) {
            return userId;
        }
    }
    return nil;
}

- (NSMutableDictionary *)getMetaDataDictionary:(NSString *)string {

    if (!string) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSMutableDictionary *metadataDictionary;

    @try {
        NSError *error;
        metadataDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable
                                                                        format:&format
                                                                         error:&error];
    } @catch(NSException *exp) {
    }
    
    return metadataDictionary;
}

- (BOOL)isGroupMutedByDefault {
    
    if (_metadata && [_metadata  valueForKey:AL_CHANNEL_DEFAULT_MUTE]) {
        return ([ [_metadata  valueForKey:AL_CHANNEL_DEFAULT_MUTE] isEqualToString:@"true"]);
    }
    return NO;
}

- (BOOL)isConversationClosed {

    if (_metadata && [_metadata  valueForKey:AL_CHANNEL_CONVERSATION_STATUS]) {
        return ([ [_metadata  valueForKey:AL_CHANNEL_CONVERSATION_STATUS] isEqualToString:@"CLOSE"]);
    }
    return NO;
}

- (BOOL)isBroadcastGroup {
    return  self.type == BROADCAST;
}

- (BOOL)isOpenGroup {
    return self.type == OPEN;
}

- (BOOL)isGroupOfTwo {
    return self.type == GROUP_OF_TWO;
}

- (BOOL)isPartOfCategory:(NSString *)category {
    
    if ( _metadata && [_metadata  valueForKey:AL_CATEGORY]) {
        return ([ [_metadata  valueForKey:AL_CATEGORY] isEqualToString:category]);
    }
    return NO;
}

- (BOOL)isContextBasedChat {
    
    if (_metadata && [_metadata  valueForKey:AL_CONTEXT_BASED_CHAT]) {
        return ([ [_metadata  valueForKey:AL_CONTEXT_BASED_CHAT] isEqualToString:@"true"]);
    }
    return NO;
}

- (BOOL)isDeleted {
    return self.deletedAtTime != nil && self.deletedAtTime.longValue > 0;
}

+ (CONVERSATION_CATEGORY)getConversationCategory:(NSDictionary *)metadata {
    NSString *status = [metadata objectForKey:AL_CHANNEL_CONVERSATION_STATUS];
    NSString *assignee = [metadata valueForKey:AL_CONVERSATION_ASSIGNEE];

    if (status != nil && ([status isEqualToString:@"2"] || [status isEqualToString:@"3"])) {
        return CLOSED_CONVERSATION;
    } else if (assignee != nil && ([assignee isEqualToString:[KMCoreUserDefaultsHandler getUserId]])) {
        return ASSIGNED_CONVERSATION;
    }
    return ALL_CONVERSATION;
}

@end
