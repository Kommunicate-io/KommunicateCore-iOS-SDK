//
//  ALChannelDBService.m
//  Applozic
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChannelDBService.h"
#import "ALConstant.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "ALChannelUser.h"
#import "ALSearchResultCache.h"
#import "ALChannelService.h"
#import "ALLogger.h"

@interface ALChannelDBService ()

@end

@implementation ALChannelDBService

static int const CHANNEL_MEMBER_FETCH_LMIT = 5;

#pragma mark - Add member in Channel

- (void)addMemberToChannel:(NSString *)userId
             andChannelKey:(NSNumber *)channelKey {
    ALChannelUserX *channelUser = [[ALChannelUserX alloc] init];
    channelUser.key = channelKey;
    channelUser.userKey = userId;
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL_USER_X *dbChannelUser =  [self createChannelUserXEntity: channelUser];
    NSError *error = nil;
    if (dbChannelUser) {
        error = [alDBHandler saveContext];
    }

    if (error) {
        ALSLog(ALLoggerSeverityError, @"ERROR IN Add member to channel  %@",error);
    }
}

#pragma mark - Insert Channel in Database

- (void)insertChannel:(NSMutableArray *)channelList {
    NSMutableArray *channelArray = [[NSMutableArray alloc] init];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    for (ALChannel *channel in channelList) {
        [self createChannelEntity:channel];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannel METHOD %@",error);
        }
        [channelArray addObject:channel];
    }
}

- (DB_CHANNEL *)createChannelEntity:(ALChannel *)channel {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL *dbChannelEntity = [self getChannelByKey:channel.key];
    
    if (!dbChannelEntity) {
        dbChannelEntity = (DB_CHANNEL *)[alDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL"];
    }

    if (dbChannelEntity) {
        dbChannelEntity.channelDisplayName = channel.name;
        dbChannelEntity.channelKey = channel.key;
        dbChannelEntity.clientChannelKey = channel.clientChannelKey;
        if (channel.userCount != nil) {
            dbChannelEntity.userCount = channel.userCount;
        }
        dbChannelEntity.notificationAfterTime = channel.notificationAfterTime;
        dbChannelEntity.deletedAtTime = channel.deletedAtTime;
        dbChannelEntity.parentGroupKey = channel.parentKey;
        dbChannelEntity.parentClientGroupKey = channel.parentClientKey;
        dbChannelEntity.channelImageURL = channel.channelImageURL;
        dbChannelEntity.type = channel.type;
        dbChannelEntity.adminId = channel.adminKey;
        if (channel.unreadCount != nil &&
            [channel.unreadCount compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
            dbChannelEntity.unreadCount = channel.unreadCount;
        }
        dbChannelEntity.metadata = channel.metadata.description;
        dbChannelEntity.category = channel.category;
    }

    return dbChannelEntity;
}

#pragma mark - Delete member from channel

- (void)deleteMembers:(NSNumber *)key {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *channelUserFetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelUserEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserEntity) {
        [channelUserFetchRequest setEntity:channelUserEntity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", key];
        [channelUserFetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:channelUserFetchRequest withError:&fetchError];
        
        if (result.count) {
            for (NSManagedObject *managedObject in result) {
                [alDBHandler deleteObject:managedObject];
            }
            [alDBHandler saveContext];
        }
    }
}

- (void)insertChannelUserX:(NSMutableArray *)channelUserXList {
    NSMutableArray *channelUserXArray = [[NSMutableArray alloc] init];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    if (channelUserXList.count) {
        ALChannelUserX *channelUserTemp = [channelUserXList objectAtIndex:0];
        [self deleteMembers:channelUserTemp.key];
    }
    
    for (ALChannelUserX *channelUserX in channelUserXList) {
        [self createChannelUserXEntity:channelUserX];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannelUserX METHOD %@",error);
        }
        [channelUserXArray addObject:channelUserX];
    }
}

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserX withContext:(NSManagedObjectContext *)context {

    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

    DB_CHANNEL_USER_X *dbChannelUser = (DB_CHANNEL_USER_X *)[alDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X" withManagedObjectContext:context];

    if (channelUserX && dbChannelUser) {
        dbChannelUser.channelKey = channelUserX.key;
        dbChannelUser.userId = channelUserX.userKey;
        if(channelUserX.parentKey != nil) {
            dbChannelUser.parentGroupKey = channelUserX.parentKey;
        }
        
        if (channelUserX.role != nil) {
            dbChannelUser.role = channelUserX.role;
        }
    }
    
    return dbChannelUser;
}

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserX {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    DB_CHANNEL_USER_X *dbChannelUser = (DB_CHANNEL_USER_X *)[alDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserX && dbChannelUser) {
        dbChannelUser.channelKey = channelUserX.key;
        dbChannelUser.userId = channelUserX.userKey;
        dbChannelUser.parentGroupKey = channelUserX.parentKey;
    }
    
    return dbChannelUser;
}

- (NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey {
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelUserEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserEntity) {
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"userId"]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            NSMutableArray *users = [NSMutableArray arrayWithArray:result];
            
            for (NSDictionary *theDictionary in users) {
                [memberList addObject:[theDictionary valueForKey:@"userId"]];
            }
        }
    }
    return memberList;
}

#pragma mark - Load channel by channelKey

- (ALChannel *)loadChannelByKey:(NSNumber *)key {
    ALChannel *cachedChannel = [[ALSearchResultCache shared] getChannelWithId: key];
    if (cachedChannel != nil) {
        return cachedChannel;
    }
    DB_CHANNEL *dbChannel = [self getChannelByKey:key];
    ALChannel *alChannel = [[ALChannel alloc] init];
    
    if (!dbChannel) {
        return nil;
    }
    
    alChannel.parentKey = dbChannel.parentGroupKey;
    alChannel.parentClientKey = dbChannel.parentClientGroupKey;
    alChannel.key = dbChannel.channelKey;
    alChannel.clientChannelKey = dbChannel.clientChannelKey;
    alChannel.name = dbChannel.channelDisplayName;
    alChannel.channelImageURL = dbChannel.channelImageURL;
    alChannel.unreadCount = dbChannel.unreadCount;
    alChannel.adminKey = dbChannel.adminId;
    alChannel.type = dbChannel.type;
    if (alChannel.type == GROUP_OF_TWO) {
        alChannel.membersName = [self getChannelMembersList:key];
        alChannel.membersId = [self getChannelMembersList:key];
    }
    alChannel.notificationAfterTime = dbChannel.notificationAfterTime;
    alChannel.deletedAtTime = dbChannel.deletedAtTime;
    alChannel.metadata = [alChannel getMetaDataDictionary:dbChannel.metadata];
    alChannel.userCount = dbChannel.userCount;
    alChannel.category = dbChannel.category;
    return alChannel;
}

- (DB_CHANNEL *)getChannelByKey:(NSNumber *)key {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    return nil;
}

#pragma mark - Contacts group type

- (DB_CHANNEL *)getContactsGroupChannelByName:(NSString *)channelName {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelDisplayName = %@",channelName];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %i", CONTACT_GROUP];
        NSPredicate* combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate: combinePredicate];
        
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:nil];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    return nil;
}

- (ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey {
    
    DB_CHANNEL_USER_X *dbChannelUserX = [self getChannelUserX:channelKey];
    ALChannelUserX *alChannelUserX = [[ALChannelUserX alloc] init];
    
    if (!dbChannelUserX) {
        return nil;
    }
    
    alChannelUserX.key = dbChannelUserX.channelKey;
    alChannelUserX.parentKey = dbChannelUserX.parentGroupKey;
    alChannelUserX.userKey = dbChannelUserX.userId;
    alChannelUserX.status = dbChannelUserX.status;
    alChannelUserX.unreadCount = dbChannelUserX.unreadCount;
    alChannelUserX.role = dbChannelUserX.role;
    return alChannelUserX;
}

- (DB_CHANNEL_USER_X *)getChannelUserXByUserId:(NSNumber *)channelKey
                                     andUserId:(NSString *)userId {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelUserEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey == %@ AND userId == %@", channelKey, userId];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count > 0 ) {
            DB_CHANNEL_USER_X *dbChannelUserX = [result objectAtIndex:0];
            return dbChannelUserX;
        }
    }
    return nil;
}

- (DB_CHANNEL_USER_X *)getChannelUserX:channelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL_USER_X *dbChannelUserX = [result objectAtIndex:0];
            return dbChannelUserX;
        }
    }
    return nil;
}


- (ALChannelUserX *)loadChannelUserXByUserId:(NSNumber *)channelKey
                                   andUserId:(NSString *)userId {
    
    DB_CHANNEL_USER_X *dbChannelUserX = [self getChannelUserXByUserId:channelKey andUserId:userId];
    ALChannelUserX *alChannelUserX = [[ALChannelUserX alloc] init];
    
    if (!dbChannelUserX) {
        return nil;
    }
    
    alChannelUserX.key = dbChannelUserX.channelKey;
    alChannelUserX.parentKey =dbChannelUserX.parentGroupKey;
    alChannelUserX.userKey = dbChannelUserX.userId;
    alChannelUserX.status = dbChannelUserX.status;
    alChannelUserX.unreadCount = dbChannelUserX.unreadCount;
    alChannelUserX.role = dbChannelUserX.role;
    
    return alChannelUserX;
}

- (void)updateParentKeyInChannelUserX:(NSNumber *)channelKey
                     andWithParentKey:(NSNumber *)parentKey
                           addUserId :(NSString *) userId {
    
    DB_CHANNEL_USER_X *channelUserX =  [self getChannelUserXByUserId:channelKey andUserId:userId];
    if (channelUserX) {
        ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
        channelUserX.parentGroupKey = parentKey;
        [alDBHandler saveContext];
    }
}

- (void)updateRoleInChannelUserX:(NSNumber *)channelKey
                       andUserId:(NSString *)userId
                    withRoleType:(NSNumber*)role {
    
    DB_CHANNEL_USER_X *channelUserX = [self getChannelUserXByUserId:channelKey andUserId:userId];

    if (channelUserX) {
        ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
        channelUserX.role = role;
        [alDBHandler saveContext];
    }
}

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key {
    return [self getListOfAllUsersInChannel:key withLimit:0];
}

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key
                                     withLimit:(NSUInteger) fetchLimit {
    
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if (fetchLimit > 0) {
        fetchRequest.fetchLimit = fetchLimit;
    }
    
    NSEntityDescription *channelUserEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:predicate];
        NSArray *resultArray = [alDBHandler executeFetchRequest:fetchRequest withError:nil];
        
        if (resultArray.count) {
            for (DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                NSString *memberUserId = dbChannelUserX.userId;
                if (memberUserId != nil) {
                    [memberList addObject:memberUserId];
                }
            }
            return memberList;
        }
    }
    return nil;
}

- (NSUInteger)getCountOfNumberOfUsers:(NSNumber *)channelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *channelUserRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL_USER_X"];
    [channelUserRequest setIncludesPropertyValues:NO];
    [channelUserRequest setIncludesSubentities:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [channelUserRequest setPredicate:predicate];
    NSUInteger count = [alDBHandler countForFetchRequest:channelUserRequest];
    return count;
}

- (NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName {
    
    if (channelName == nil) {
        return nil;
    }
    
    DB_CHANNEL *dbChannel = [self getContactsGroupChannelByName:channelName];
    
    if (dbChannel != nil) {
        return [self getListOfAllUsersInChannel:dbChannel.channelKey];
    }
    return nil;
}

#pragma mark - User names Comma Separated

- (NSString *)userNamesWithCommaSeparatedForChannelkey:(NSNumber *)key {
    NSString *listString = @"";
    NSString *str = @"";
    NSMutableArray *listOfUsersinChannel = [self getListOfAllUsersInChannel:key withLimit:CHANNEL_MEMBER_FETCH_LMIT];

    if (listOfUsersinChannel.count) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:listOfUsersinChannel];

        if (!tempArray || tempArray.count == 0) {
            return @"";
        }
        NSMutableArray * listArray = [NSMutableArray new];
        ALContactDBService *contactDB = [ALContactDBService new];
        for (NSString *userID in tempArray) {
            ALContact *contact = [contactDB loadContactByKey:@"userId" value:userID];
            [listArray addObject: [contact getDisplayName]];
        }
        if (listArray.count == 1) {
            listString = listArray[0];
        } else if(listArray.count == 2) {
            listString = [NSString stringWithFormat:@"%@, %@", listArray[0], listArray[1]];
        } else if(listArray.count > 2) {
            NSInteger countOfUsers = [self getCountOfNumberOfUsers:key];

            if (countOfUsers > 2) {
                int counter = (int)countOfUsers - 2;
                str = [NSString stringWithFormat:@"+%d %@",counter, NSLocalizedStringWithDefaultValue(@"moreMember", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"more", @"")];
                listString = [NSString stringWithFormat:@"%@, %@, %@", listArray[0], listArray[1], str];
            }
        }
    }

    return listString;
}

- (ALChannel *)checkChannelEntity:(NSNumber *)channelKey {
    DB_CHANNEL *dbChannel = [self getChannelByKey:channelKey];
    ALChannel *channel  = [[ALChannel alloc] init];
    
    if (dbChannel) {
        channel.parentKey = dbChannel.parentGroupKey;
        channel.parentClientKey = dbChannel.parentClientGroupKey;
        channel.key = dbChannel.channelKey;
        channel.clientChannelKey = dbChannel.clientChannelKey;
        channel.name = dbChannel.channelDisplayName;
        channel.adminKey = dbChannel.adminId;
        channel.type = dbChannel.type;
        channel.unreadCount = dbChannel.unreadCount;
        channel.channelImageURL = dbChannel.channelImageURL;
        channel.deletedAtTime = dbChannel.deletedAtTime;
        channel.metadata = [channel getMetaDataDictionary:dbChannel.metadata];
        channel.userCount = dbChannel.userCount;
        channel.category = dbChannel.category;
        return channel;
    } else {
        return nil;
    }
}

#pragma mark - Remove member from channel in Database

- (void)removeMemberFromChannel:(NSString *)userId
                  andChannelKey:(NSNumber *)channelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (userEntity) {
        [fetchRequest setEntity:userEntity];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"userId = %@", userId];
        NSPredicate* combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        [fetchRequest setPredicate: combinePredicate];
        
        NSError *error = nil;
        NSArray *memberArray = [alDBHandler executeFetchRequest:fetchRequest withError:&error];
        if (memberArray.count) {
            NSManagedObject *managedObject = [memberArray objectAtIndex:0];
            [alDBHandler deleteObject:managedObject];
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityWarn, @"Channel not found in database skipping removing member from channel for channelKey :%@", channelKey);
        }
    }
}

#pragma mark - Delete Channel

- (void)deleteChannel:(NSNumber *)channelKey {
    //Delete channel
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        [fetchRequest setEntity:channelEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        [fetchRequest setPredicate: predicate];
        
        NSError *error = nil;
        NSArray *array = [alDBHandler executeFetchRequest:fetchRequest withError:&error];
        if(array.count) {
            NSManagedObject *managedObject = [array objectAtIndex:0];
            [alDBHandler deleteObject:managedObject];
            [alDBHandler saveContext];
            
            // Delete all members
            [self deleteMembers:channelKey];
        } else {
            ALSLog(ALLoggerSeverityWarn, @"Channel not found in database skipping delete channel for channelKey :%@", channelKey);
        }
    }
}

#pragma mark- Fetch All Channels

- (NSMutableArray *)getAllChannelKeyAndName {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    NSMutableArray *alChannels = [[NSMutableArray alloc] init];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type != %i",CONTACT_GROUP];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSArray *resultArray = [alDBHandler executeFetchRequest:fetchRequest withError:nil];
        if (resultArray.count) {
            for (DB_CHANNEL *dbChannel in resultArray) {
                ALChannel *channel = [[ALChannel alloc] init];
                channel.parentKey = dbChannel.parentGroupKey;
                channel.parentClientKey = dbChannel.parentClientGroupKey;
                channel.key = dbChannel.channelKey;
                channel.clientChannelKey = dbChannel.clientChannelKey;
                channel.name = dbChannel.channelDisplayName;
                channel.adminKey = dbChannel.adminId;
                channel.type = dbChannel.type;
                channel.unreadCount = dbChannel.unreadCount;
                channel.channelImageURL = dbChannel.channelImageURL;
                channel.deletedAtTime = dbChannel.deletedAtTime;
                channel.metadata = [channel getMetaDataDictionary:dbChannel.metadata];
                channel.userCount = dbChannel.userCount;
                channel.category = dbChannel.category;
                [alChannels addObject:channel];
            }
        } else {
            ALSLog(ALLoggerSeverityWarn, @"Channels not found in database count of channels is zero");
        }
    }
    return alChannels;
}

- (NSNumber *)getOverallUnreadCountForChannelFromDB {
    NSNumber *unreadCount;
    int count = 0;
    NSMutableArray *channelArray = [NSMutableArray arrayWithArray:[self getAllChannelKeyAndName]];
    if (channelArray.count) {
        for (ALChannel *alChannel in channelArray) {
            count = count + [alChannel.unreadCount intValue];
        }
        unreadCount = [NSNumber numberWithInt:count];
    }
    return unreadCount;
}

#pragma mark - Update Channel

- (void)updateChannel:(NSNumber *)channelKey
           andNewName:(NSString *)newName
           orImageURL:(NSString *)imageURL
          orChildKeys:(NSMutableArray *)childKeysList
   isUpdatingMetaData:(BOOL)flag
       orChannelUsers:(NSMutableArray *)channelUsers {
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            if (newName.length) {
                dbChannel.channelDisplayName = newName;
            }
            
            if (!flag) {
                dbChannel.channelImageURL = imageURL;
            }
            
            if (childKeysList.count) {
                for (NSNumber *childKey in childKeysList) {
                    [self updateChannelParentKey:childKey andWithParentKey:channelKey isAdding:YES];
                }
            }
            for (NSDictionary *chUserDict in channelUsers) {
                ALChannelUser *channelUser = [[ALChannelUser alloc] initWithDictonary:chUserDict];
                if (channelUser.parentGroupKey != nil) {
                    [self updateParentKeyInChannelUserX:channelKey andWithParentKey:channelUser.parentGroupKey addUserId:channelUser.userId];
                }
                
                if (channelUser.role != nil) {
                    [self updateRoleInChannelUserX:channelKey andUserId:channelUser.userId withRoleType:channelUser.role];
                }
            }
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in database to update channel with chnnelKey : %@", channelKey);
        }
    }
}

- (void)updateChannelMetaData:(NSNumber *)channelKey
                     metaData:(NSMutableDictionary *)newMetaData {
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            if (newMetaData != nil) {
                dbChannel.metadata = newMetaData.description;
                
                // Update conversation status from metadata
                dbChannel.category = [ALChannel getConversationCategory:newMetaData];
            }
            
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in database to update metadata with channelKey : %@", channelKey);
        }
    }
}

- (void)updateChannelParentKey:(NSNumber *)channelKey
              andWithParentKey:(NSNumber *)channelParentKey
                      isAdding:(BOOL)flag {
    DB_CHANNEL *parentChannel = [self getChannelByKey:channelParentKey];
    DB_CHANNEL *childChannel = [self getChannelByKey:channelKey];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    if (childChannel && childChannel) {
        if (flag) {
            childChannel.parentGroupKey = parentChannel.channelKey;
            childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
        } else {
            childChannel.parentGroupKey = nil;
            childChannel.parentClientGroupKey = nil;
        }
        [alDBHandler saveContext];
    }
}

- (void)updateClientChannelParentKey:(NSString *)clientChildKey
              andWithClientParentKey:(NSString *)clientParentKey
                            isAdding:(BOOL)flag {
    DB_CHANNEL *parentChannel = [self getChannelByClientChannelKey:clientParentKey];
    DB_CHANNEL *childChannel = [self getChannelByClientChannelKey:clientChildKey];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    if (parentChannel && childChannel) {
        if (flag) {
            childChannel.parentGroupKey = parentChannel.channelKey;
            childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
        } else {
            childChannel.parentGroupKey = nil;
            childChannel.parentClientGroupKey = nil;
        }
        
        [alDBHandler saveContext];
    }
}

- (void)updateUnreadCountChannel:(NSNumber *)channelKey
                     unreadCount:(NSNumber *)unreadCount {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count && unreadCount != nil) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            dbChannel.unreadCount = unreadCount;
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in database to update unread count with channelKey : %@", channelKey);
        }
    }
}

- (void)setLeaveFlag:(BOOL)flag
          forChannel:(NSNumber *)groupId {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    
    if(dbChannel) {
        dbChannel.isLeft = flag;
        [alDBHandler saveContext];
    } else {
        ALSLog(ALLoggerSeverityError, @"Channel not found in database to set the leave flag with channelKey : %@", groupId);
    }
}

#pragma mark - Channel left

- (BOOL)isChannelLeft:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    return dbChannel.isLeft;
}

#pragma mark - Channel Deleted

- (BOOL)isChannelDeleted:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    return (dbChannel.deletedAtTime != nil);
}

#pragma mark - Conversaion Closed

- (BOOL)isConversaionClosed:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    ALChannel *channel = [ALChannel new];
    NSMutableDictionary *metadata = [channel getMetaDataDictionary:dbChannel.metadata];
    
    if (metadata &&
        [metadata valueForKey:AL_CHANNEL_CONVERSATION_STATUS]){
        return ([[metadata  valueForKey:AL_CHANNEL_CONVERSATION_STATUS] isEqualToString:@"CLOSE"]);
    }
    return NO;
}

- (BOOL)isAdminBroadcastChannel:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    ALChannel *channel = [ALChannel new];
    NSMutableDictionary *metadata = [channel getMetaDataDictionary:dbChannel.metadata];
    
    return (metadata &&
            [[metadata valueForKey:@"AL_ADMIN_BROADCAST"] isEqualToString:@"true"]);
}

- (void)removedMembersArray:(NSMutableArray *)memberArray
              andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[ALUserDefaultsHandler getUserId]]) {
        [self setLeaveFlag:YES forChannel:channelKey];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:channelKey forKey:@"CHANNEL_KEY"];
        [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:userInfo];
    }
}

- (void)addedMembersArray:(NSMutableArray *)memberArray
            andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[ALUserDefaultsHandler getUserId]]) {
        [self setLeaveFlag:NO forChannel:channelKey];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:channelKey forKey:@"CHANNEL_KEY"];
        [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:userInfo];
    }
}

#pragma mark - Marking Group Read

- (NSUInteger)markConversationAsRead:(NSNumber *)channelKey {
    NSArray *messages;
    
    if (channelKey != nil) {
        messages = [self getUnreadMessagesForGroup:channelKey];
    } else {
        ALSLog(ALLoggerSeverityError, @"channelKey null for marking unread");
    }
    
    if (messages.count > 0) {
        NSBatchUpdateRequest *messageUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:@"DB_Message"];
        messageUpdateRequest.predicate = [NSPredicate predicateWithFormat:@"groupId=%d",[channelKey intValue]];
        messageUpdateRequest.propertiesToUpdate = @{
            @"status" : @(DELIVERED_AND_READ)
        };
        messageUpdateRequest.resultType = NSUpdatedObjectsCountResultType;
        ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];

        NSError *fetchError = nil;

        NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[alDBHandler executeRequestForNSBatchUpdateResult:messageUpdateRequest withError:&fetchError];

        if (batchUpdateResult) {
            ALSLog(ALLoggerSeverityInfo, @"%@ markConversationAsRead updated rows", batchUpdateResult.result);
        }
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForGroup:(NSNumber *)groupId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSArray *result = nil;
    NSEntityDescription *messageEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_Message"];
    
    if (messageEntity) {
        NSPredicate *predicate;
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];
        
        if (groupId != nil) {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%d",@"groupId",groupId.intValue];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        } else {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
        }
        [fetchRequest setEntity:messageEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
    }
    
    return result;
}

#pragma mark - Get Channel by client key

- (DB_CHANNEL *)getChannelByClientChannelKey:(NSString *)clientChannelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (channelEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientChannelKey = %@",clientChannelKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    ALSLog(ALLoggerSeverityError, @"CHANNEL_NOT_FOUND :: %@",clientChannelKey);
    return nil;
}

- (ALChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey {
    DB_CHANNEL *dbChannel = [self getChannelByClientChannelKey:clientChannelKey];
    ALChannel *alChannel = [[ALChannel alloc] init];
    
    if (!dbChannel) {
        return nil;
    }
    
    alChannel.parentKey = dbChannel.parentGroupKey;
    alChannel.parentClientKey = dbChannel.parentClientGroupKey;
    alChannel.key = dbChannel.channelKey;
    alChannel.clientChannelKey = dbChannel.clientChannelKey;
    alChannel.name = dbChannel.channelDisplayName;
    alChannel.unreadCount = dbChannel.unreadCount;
    alChannel.adminKey = dbChannel.adminId;
    alChannel.type = dbChannel.type;
    alChannel.channelImageURL = dbChannel.channelImageURL;
    alChannel.deletedAtTime = dbChannel.deletedAtTime;
    alChannel.metadata = [alChannel getMetaDataDictionary:dbChannel.metadata];
    alChannel.userCount = dbChannel.userCount;
    alChannel.category = dbChannel.category;
    return alChannel;
}


- (NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey {
    NSMutableArray *childArray = [[NSMutableArray alloc] init];
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *channelEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    if (channelEntity) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentGroupKey = %@",parentGroupKey];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count > 0) {
            ALSLog(ALLoggerSeverityInfo, @"CHILD CHANNEL FOUND : %lu WITH PARENT KEY : %@",(unsigned long)result.count, parentGroupKey);
            ALSLog(ALLoggerSeverityError, @"ERROR (IF-ANY) : %@",fetchError.description);
            
            for (DB_CHANNEL *dbChannel in result) {
                ALChannel *alChannel = [[ALChannel alloc] init];
                alChannel.parentKey = dbChannel.parentGroupKey;
                alChannel.parentClientKey = dbChannel.parentClientGroupKey;
                alChannel.key = dbChannel.channelKey;
                alChannel.clientChannelKey = dbChannel.clientChannelKey;
                alChannel.name = dbChannel.channelDisplayName;
                alChannel.unreadCount = dbChannel.unreadCount;
                alChannel.adminKey = dbChannel.adminId;
                alChannel.type = dbChannel.type;
                alChannel.channelImageURL = dbChannel.channelImageURL;
                alChannel.deletedAtTime = dbChannel.deletedAtTime;
                alChannel.metadata = [alChannel getMetaDataDictionary:dbChannel.metadata];
                alChannel.userCount = dbChannel.userCount;
                alChannel.category = dbChannel.category;
                [childArray addObject:alChannel];
            }
        }
    }
    
    return childArray;
}

- (void)updateMuteAfterTime:(NSNumber *)notificationAfterTime
               andChnnelKey:(NSNumber *)channelKey {
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    
    DB_CHANNEL *dbChannel = [self getChannelByKey:channelKey];
    if (dbChannel) {
        dbChannel.notificationAfterTime = notificationAfterTime;
        [alDBHandler saveContext];
    }
}

- (NSMutableArray *)getGroupUsersInChannel:(NSNumber *)key {
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *channelUserEntity = [alDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserEntity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        
        NSArray *resultArray = [alDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (resultArray.count) {
            for(DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                [memberList addObject:dbChannelUserX];
            }
            return memberList;
        }
    }
    return memberList;
}

#pragma mark - Get Channel members async

- (void)fetchChannelMembersAsyncWithChannelKey:(NSNumber *)channelKey
                                 witCompletion:(void(^)(NSMutableArray *membersArray))completion {
    
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DB_CHANNEL_USER_X"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [fetchRequest setPredicate:predicate];
    
    NSAsynchronousFetchRequest *asynchronousFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
        
        NSArray *resultArray = result.finalResult;
        
        if (resultArray && resultArray.count) {
            for(DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                if (dbChannelUserX.userId) {
                    [memberList addObject:dbChannelUserX.userId];
                }
            }
        } else{
            ALSLog(ALLoggerSeverityWarn, @"No member found in channel");
        }
        completion(memberList);
    }];
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSManagedObjectContext *context = alDBHandler.persistentContainer.viewContext;
    if (context) {
        [context performBlock:^{
            [context executeRequest:asynchronousFetchRequest error:nil];
        }];
    } else {
        completion(nil);
    }
}

#pragma mark - Get users in support group

- (void)getUserInSupportGroup:(NSNumber *)channelKey
               withCompletion:(void(^)(NSString *userId)) completion {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DB_CHANNEL_USER_X"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@ AND role = %@", channelKey, @3];
    [fetchRequest setPredicate:predicate];
    
    NSAsynchronousFetchRequest *asynchronousFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
        NSArray *resultArray = result.finalResult;
        if (resultArray && resultArray.count) {
            DB_CHANNEL_USER_X *user = resultArray[0];
            completion(user.userId);
        } else {
            ALSLog(ALLoggerSeverityWarn, @"No member found in support group");
            completion(nil);
        }
    }];
    
    ALDBHandler *alDBHandler = [ALDBHandler sharedInstance];
    NSManagedObjectContext *context = alDBHandler.persistentContainer.viewContext;
    if (context) {
        [context performBlock:^{
            [context executeRequest:asynchronousFetchRequest error:nil];
        }];
    } else {
        completion(nil);
    }
}

@end
