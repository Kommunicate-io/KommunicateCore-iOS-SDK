//
//  KMCoreChannelDBService.m
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "KMCoreChannelDBService.h"
#import "ALConstant.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "KMCoreChannelUser.h"
#import "ALSearchResultCache.h"
#import "KMCoreChannelService.h"
#import "ALLogger.h"

@interface KMCoreChannelDBService ()

@end

@implementation KMCoreChannelDBService

static int const CHANNEL_MEMBER_FETCH_LMIT = 5;

#pragma mark - Add member in Channel

- (void)addMemberToChannel:(NSString *)userId
             andChannelKey:(NSNumber *)channelKey {
    KMCoreChannelUserX *channelUser = [[KMCoreChannelUserX alloc] init];
    channelUser.key = channelKey;
    channelUser.userKey = userId;
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    
    for (KMCoreChannel *channel in channelList) {
        [self createChannelEntity:channel];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannel METHOD %@",error);
        }
        [channelArray addObject:channel];
    }
}

- (DB_CHANNEL *)createChannelEntity:(KMCoreChannel *)channel {
    if (!channel || !channel.key) {
        ALSLog(ALLoggerSeverityError, @"Invalid channel input");
        return nil;
    }

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *context = alDBHandler.persistentContainer.viewContext;

    DB_CHANNEL *dbChannelEntity = nil;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channel.key];
    fetchRequest.fetchLimit = 1;

    NSError *fetchError = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];

    if (fetchError) {
        ALSLog(ALLoggerSeverityError, @"Error fetching DB_CHANNEL: %@", fetchError.localizedDescription);
    }

    if (results.count > 0) {
        dbChannelEntity = results.firstObject;
    } else {
        dbChannelEntity = (DB_CHANNEL *)[alDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL"];
    }

    if (dbChannelEntity) {
        dbChannelEntity.channelDisplayName = channel.name;
        dbChannelEntity.channelKey = channel.key;
        dbChannelEntity.clientChannelKey = channel.clientChannelKey;
        dbChannelEntity.userCount = channel.userCount;
        dbChannelEntity.notificationAfterTime = channel.notificationAfterTime;
        dbChannelEntity.deletedAtTime = channel.deletedAtTime;
        dbChannelEntity.parentGroupKey = channel.parentKey;
        dbChannelEntity.parentClientGroupKey = channel.parentClientKey;
        dbChannelEntity.channelImageURL = channel.channelImageURL;
        dbChannelEntity.type = channel.type;
        dbChannelEntity.adminId = channel.adminKey;

        if (channel.unreadCount && [channel.unreadCount intValue] != 0) {
            dbChannelEntity.unreadCount = channel.unreadCount;
        }

        dbChannelEntity.metadata = channel.metadata.description;
        dbChannelEntity.platformSource = channel.platformSource;
        dbChannelEntity.category = channel.category;
    }

    return dbChannelEntity;
}

#pragma mark - Delete member from channel

- (void)deleteMembers:(NSNumber *)key {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    
    if (channelUserXList.count) {
        KMCoreChannelUserX *channelUserTemp = [channelUserXList objectAtIndex:0];
        [self deleteMembers:channelUserTemp.key];
    }
    
    for (KMCoreChannelUserX *channelUserX in channelUserXList) {
        [self createChannelUserXEntity:channelUserX];
        NSError *error = [alDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannelUserX METHOD %@",error);
        }
        [channelUserXArray addObject:channelUserX];
    }
}

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(KMCoreChannelUserX *)channelUserX withContext:(NSManagedObjectContext *)context {

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];

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

- (DB_CHANNEL_USER_X *)createChannelUserXEntity:(KMCoreChannelUserX *)channelUserX {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    
    DB_CHANNEL_USER_X *dbChannelUser = (DB_CHANNEL_USER_X *)[alDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserX && dbChannelUser) {
        dbChannelUser.channelKey = channelUserX.key;
        dbChannelUser.userId = channelUserX.userKey;
        dbChannelUser.parentGroupKey = channelUserX.parentKey;
    }
    
    return dbChannelUser;
}

- (NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey {
    __block NSMutableArray *memberList = [[NSMutableArray alloc] init];
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelUserEntity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                                             inManagedObjectContext:backgroundContext];
        if (!channelUserEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL_USER_X not found");
            return;
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channelKey = %@", channelKey]];
        [fetchRequest setPropertiesToFetch:@[@"userId"]];
        [fetchRequest setResultType:NSDictionaryResultType];  // Fetch only dictionary with "userId"
        
        NSError *fetchError = nil;
        NSArray *result = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];
        
        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch userIds for channelKey %@: %@", channelKey, fetchError.localizedDescription);
            return;
        }
        
        for (NSDictionary *dict in result) {
            NSString *userId = dict[@"userId"];
            if (userId) {
                [memberList addObject:userId];
            }
        }
    }];
    
    return memberList;
}

#pragma mark - Load channel by channelKey

- (KMCoreChannel *)loadChannelByKey:(NSNumber *)key {
    KMCoreChannel *cachedChannel = [[ALSearchResultCache shared] getChannelWithId:key];
    if (cachedChannel) {
        return cachedChannel;
    }

    KMCoreChannel *channel = [self getChannelByKey:key];

    if (!channel) {
        return nil;
    }

    if (channel.type == GROUP_OF_TWO) {
        channel.membersName = [self getChannelMembersList:key];
        channel.membersId = [self getChannelMembersList:key];
    }

    return channel;
}


- (KMCoreChannel *)getChannelByKey:(NSNumber *)key {
    __block KMCoreChannel *safeChannel = nil;

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];

    [backgroundContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", key];
        fetchRequest.fetchLimit = 1;

        NSError *error = nil;
        NSArray *results = [backgroundContext executeFetchRequest:fetchRequest error:&error];
        if (results.count > 0) {
            DB_CHANNEL *dbChannel = results.firstObject;

            KMCoreChannel *channel = [[KMCoreChannel alloc] init];
            channel.parentKey = dbChannel.parentGroupKey;
            channel.parentClientKey = dbChannel.parentClientGroupKey;
            channel.key = dbChannel.channelKey;
            channel.clientChannelKey = dbChannel.clientChannelKey;
            channel.name = dbChannel.channelDisplayName;
            channel.channelImageURL = dbChannel.channelImageURL;
            channel.unreadCount = dbChannel.unreadCount;
            channel.adminKey = dbChannel.adminId;
            channel.type = dbChannel.type;
            channel.notificationAfterTime = dbChannel.notificationAfterTime;
            channel.deletedAtTime = dbChannel.deletedAtTime;
            channel.metadata = [channel getMetaDataDictionary:dbChannel.metadata];
            channel.platformSource = dbChannel.platformSource;
            channel.userCount = dbChannel.userCount;
            channel.category = dbChannel.category;

            safeChannel = channel;
        }
    }];

    return safeChannel;
}

#pragma mark - Contacts group type

- (DB_CHANNEL *)getContactsGroupChannelByName:(NSString *)channelName {
    __block DB_CHANNEL *fetchedChannel = nil;
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelEntity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                                          inManagedObjectContext:backgroundContext];
        if (!channelEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelEntity];

        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelDisplayName = %@", channelName];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %i", CONTACT_GROUP];
        NSPredicate *combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];

        [fetchRequest setPredicate:combinePredicate];
        
        NSError *error = nil;
        NSArray *result = [backgroundContext executeFetchRequest:fetchRequest error:&error];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Fetch error in getContactsGroupChannelByName: %@", error.localizedDescription);
        } else if (result.count > 0) {
            fetchedChannel = result.firstObject;
        }
    }];

    return fetchedChannel;
}


- (KMCoreChannelUserX *)loadChannelUserX:(NSNumber *)channelKey {
    
    DB_CHANNEL_USER_X *dbChannelUserX = [self getChannelUserX:channelKey];
    KMCoreChannelUserX *alChannelUserX = [[KMCoreChannelUserX alloc] init];
    
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
    __block DB_CHANNEL_USER_X *fetchedUserX = nil;
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];

    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                                  inManagedObjectContext:backgroundContext];
        if (!entity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL_USER_X not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channelKey == %@ AND userId == %@", channelKey, userId]];

        NSError *fetchError = nil;
        NSArray *results = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Fetch failed in getChannelUserXByUserId: %@", fetchError.localizedDescription);
        } else if (results.count > 0) {
            fetchedUserX = results.firstObject;
        }
    }];

    return fetchedUserX;
}

- (DB_CHANNEL_USER_X *)getChannelUserX:(NSNumber *)channelKey {
    __block DB_CHANNEL_USER_X *fetchedUserX = nil;

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];

    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                                  inManagedObjectContext:backgroundContext];
        if (!entity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL_USER_X not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channelKey = %@", channelKey]];

        NSError *fetchError = nil;
        NSArray *result = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch DB_CHANNEL_USER_X: %@", fetchError.localizedDescription);
        } else if (result.count > 0) {
            fetchedUserX = result.firstObject;
        }
    }];

    return fetchedUserX;
}


- (KMCoreChannelUserX *)loadChannelUserXByUserId:(NSNumber *)channelKey
                                   andUserId:(NSString *)userId {
    
    DB_CHANNEL_USER_X *dbChannelUserX = [self getChannelUserXByUserId:channelKey andUserId:userId];
    KMCoreChannelUserX *alChannelUserX = [[KMCoreChannelUserX alloc] init];
    
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
        KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
        channelUserX.parentGroupKey = parentKey;
        [alDBHandler saveContext];
    }
}

- (void)updateRoleInChannelUserX:(NSNumber *)channelKey
                       andUserId:(NSString *)userId
                    withRoleType:(NSNumber*)role {
    
    DB_CHANNEL_USER_X *channelUserX = [self getChannelUserXByUserId:channelKey andUserId:userId];

    if (channelUserX) {
        KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
        channelUserX.role = role;
        [alDBHandler saveContext];
    }
}

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key {
    return [self getListOfAllUsersInChannel:key withLimit:0];
}

- (NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key
                                     withLimit:(NSUInteger)fetchLimit {
    
    __block NSMutableArray *memberList = [[NSMutableArray alloc] init];
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelUserEntity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                                             inManagedObjectContext:backgroundContext];
        if (!channelUserEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL_USER_X not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channelKey = %@", key]];
        
        if (fetchLimit > 0) {
            fetchRequest.fetchLimit = fetchLimit;
        }

        NSError *fetchError = nil;
        NSArray *resultArray = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];
        
        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch users: %@", fetchError.localizedDescription);
            return;
        }

        for (DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
            if (dbChannelUserX.userId) {
                [memberList addObject:dbChannelUserX.userId];
            }
        }
    }];
    
    return memberList.count > 0 ? memberList : nil;
}

- (NSUInteger)getCountOfNumberOfUsers:(NSNumber *)channelKey {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
                str = [NSString stringWithFormat:@"+%d %@",counter, NSLocalizedStringWithDefaultValue(@"moreMember", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"more", @"")];
                listString = [NSString stringWithFormat:@"%@, %@, %@", listArray[0], listArray[1], str];
            }
        }
    }

    return listString;
}

- (KMCoreChannel *)checkChannelEntity:(NSNumber *)channelKey {
    KMCoreChannel *channel = [self getChannelByKey:channelKey];
    return channel;
}

#pragma mark - Remove member from channel in Database

- (void)removeMemberFromChannel:(NSString *)userId
                  andChannelKey:(NSNumber *)channelKey {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    __block NSMutableArray *alChannels = [[NSMutableArray alloc] init];
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelEntity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                                         inManagedObjectContext:backgroundContext];
        if (!channelEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL not found");
            return;
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type != %i", CONTACT_GROUP]];

        NSError *error = nil;
        NSArray *resultArray = [backgroundContext executeFetchRequest:fetchRequest error:&error];

        if (error) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch channels: %@", error.localizedDescription);
            return;
        }

        for (DB_CHANNEL *dbChannel in resultArray) {
            KMCoreChannel *channel = [[KMCoreChannel alloc] init];
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
            channel.platformSource = dbChannel.platformSource;
            channel.userCount = dbChannel.userCount;
            channel.category = dbChannel.category;
            
            [alChannels addObject:channel];
        }
    }];
    
    return alChannels;
}

- (NSNumber *)getOverallUnreadCountForChannelFromDB {
    NSNumber *unreadCount;
    int count = 0;
    NSMutableArray *channelArray = [NSMutableArray arrayWithArray:[self getAllChannelKeyAndName]];
    if (channelArray.count) {
        for (KMCoreChannel *alChannel in channelArray) {
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
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
                [self updateParentForChildKeys:childKeysList andWithParentKey:channelKey isAdding:YES];
            }
            for (NSDictionary *chUserDict in channelUsers) {
                KMCoreChannelUser *channelUser = [[KMCoreChannelUser alloc] initWithDictonary:chUserDict];
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
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
                dbChannel.category = [KMCoreChannel getConversationCategory:newMetaData];
            }
            
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in database to update metadata with channelKey : %@", channelKey);
        }
    }
}

- (void)updatePlatformSource:(NSNumber *)channelKey
              platformSource:(NSString *)newPlatformSource {
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
            if (newPlatformSource != nil) {
                dbChannel.platformSource = newPlatformSource;
            }
            
            [alDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in database to update platformSource with channelKey : %@", channelKey);
        }
    }
    
}

- (void)updateParentForChildKeys:(NSArray<NSNumber *> *)childKeys
              andWithParentKey:(NSNumber *)parentKey
                      isAdding:(BOOL)flag {
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

    [backgroundContext performBlock:^{
        NSMutableArray *allKeys = [childKeys mutableCopy];
        if (parentKey) {
            [allKeys addObject:parentKey];
        }

        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey IN %@", allKeys];

        NSError *fetchError = nil;
        NSArray *results = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError || results.count == 0) {
            ALSLog(ALLoggerSeverityError, @"[BatchUpdate] Fetch failed: %@", fetchError.localizedDescription);
            return;
        }

        DB_CHANNEL *parentChannel = nil;
        NSMutableDictionary<NSNumber *, DB_CHANNEL *> *channelMap = [NSMutableDictionary new];

        for (DB_CHANNEL *channel in results) {
            if ([channel.channelKey isEqualToNumber:parentKey]) {
                parentChannel = channel;
            } else {
                channelMap[channel.channelKey] = channel;
            }
        }

        for (NSNumber *childKey in childKeys) {
            DB_CHANNEL *childChannel = channelMap[childKey];
            if (!childChannel) continue;

            if (flag && parentChannel) {
                childChannel.parentGroupKey = parentChannel.channelKey;
                childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
            } else {
                childChannel.parentGroupKey = nil;
                childChannel.parentClientGroupKey = nil;
            }
        }

        if ([backgroundContext hasChanges]) {
            NSError *saveError = nil;
            if (![backgroundContext save:&saveError]) {
                ALSLog(ALLoggerSeverityError, @"[BatchUpdate] Save failed: %@", saveError.localizedDescription);
            }
        }
    }];
}

- (void)updateClientChannelParentKey:(NSString *)clientChildKey
              andWithClientParentKey:(NSString *)clientParentKey
                            isAdding:(BOOL)flag {
    DB_CHANNEL *parentChannel = [self getChannelByClientChannelKey:clientParentKey];
    DB_CHANNEL *childChannel = [self getChannelByClientChannelKey:clientChildKey];
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    
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
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *context = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [context performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", groupId];
        fetchRequest.fetchLimit = 1;
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        if (results.count > 0) {
            DB_CHANNEL *dbChannel = results.firstObject;
            dbChannel.isLeft = flag;
            [context save:&error];
        } else {
            ALSLog(ALLoggerSeverityError, @"Channel not found in DB to set leave flag: %@", groupId);
        }
    }];
}

#pragma mark - Channel left

- (BOOL)isChannelLeft:(NSNumber *)groupId {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *context = [[alDBHandler persistentContainer] viewContext]; // read-safe
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", groupId];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0) {
        DB_CHANNEL *dbChannel = results.firstObject;
        return dbChannel.isLeft;
    }
    return NO;
}

#pragma mark - Channel Deleted

- (BOOL)isChannelDeleted:(NSNumber *)groupId {
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *context = [[alDBHandler persistentContainer] viewContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", groupId];
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (results.count > 0) {
        DB_CHANNEL *dbChannel = results.firstObject;
        return (dbChannel.deletedAtTime != nil);
    }
    return NO;
}

#pragma mark - Conversaion Closed

- (BOOL)isConversaionClosed:(NSNumber *)groupId {
    KMCoreChannel *channel = [self getChannelByKey:groupId];
    if (!channel || !channel.metadata) return NO;
    
    NSString *status = [channel.metadata valueForKey:AL_CHANNEL_CONVERSATION_STATUS];
    return (status && [status isEqualToString:@"CLOSE"]);
}

- (BOOL)isAdminBroadcastChannel:(NSNumber *)groupId {
    KMCoreChannel *channel = [self getChannelByKey:groupId];
    if (!channel || !channel.metadata) return NO;
    
    return [[channel.metadata valueForKey:@"AL_ADMIN_BROADCAST"] isEqualToString:@"true"];
}

- (void)removedMembersArray:(NSMutableArray *)memberArray
              andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[KMCoreUserDefaultsHandler getUserId]]) {
        [self setLeaveFlag:YES forChannel:channelKey];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:channelKey forKey:@"CHANNEL_KEY"];
        [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:userInfo];
    }
}

- (void)addedMembersArray:(NSMutableArray *)memberArray
            andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[KMCoreUserDefaultsHandler getUserId]]) {
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
        KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];

        NSError *fetchError = nil;

        NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[alDBHandler executeRequestForNSBatchUpdateResult:messageUpdateRequest withError:&fetchError];

        if (batchUpdateResult) {
            ALSLog(ALLoggerSeverityInfo, @"%@ markConversationAsRead updated rows", batchUpdateResult.result);
        }
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForGroup:(NSNumber *)groupId {

    __block NSArray *result = nil;
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"DB_Message"
                                                         inManagedObjectContext:backgroundContext];
        if (!messageEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_Message not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:messageEntity];

        NSPredicate *predicateStatusAndType = [NSPredicate predicateWithFormat:@"status != %i AND type == %@", DELIVERED_AND_READ, @"4"];

        if (groupId != nil) {
            NSPredicate *predicateGroup = [NSPredicate predicateWithFormat:@"groupId == %d", groupId.intValue];
            [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicateGroup, predicateStatusAndType]]];
        } else {
            [fetchRequest setPredicate:predicateStatusAndType];
        }

        NSError *fetchError = nil;
        result = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch unread messages: %@", fetchError.localizedDescription);
            result = @[];
        }
    }];
    
    return result;
}

#pragma mark - Get Channel by client key

- (DB_CHANNEL *)getChannelByClientChannelKey:(NSString *)clientChannelKey {
    __block DB_CHANNEL *dbChannel = nil;
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelEntity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                                         inManagedObjectContext:backgroundContext];
        if (!channelEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL not found");
            return;
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"clientChannelKey = %@", clientChannelKey]];
        
        NSError *fetchError = nil;
        NSArray *result = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];
        
        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Error fetching channel by clientChannelKey: %@, %@", clientChannelKey, fetchError.localizedDescription);
            return;
        }

        if (result.count > 0) {
            dbChannel = result.firstObject;
        }
    }];
    
    if (!dbChannel) {
        ALSLog(ALLoggerSeverityError, @"CHANNEL_NOT_FOUND :: %@", clientChannelKey);
    }

    return dbChannel;
}

- (KMCoreChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey {
    DB_CHANNEL *dbChannel = [self getChannelByClientChannelKey:clientChannelKey];
    KMCoreChannel *alChannel = [[KMCoreChannel alloc] init];
    
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
    alChannel.platformSource = dbChannel.platformSource;
    alChannel.userCount = dbChannel.userCount;
    alChannel.category = dbChannel.category;
    return alChannel;
}


- (NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey {
    __block NSMutableArray *childArray = [[NSMutableArray alloc] init];

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];

    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelEntity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                                         inManagedObjectContext:backgroundContext];
        if (!channelEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentGroupKey = %@", parentGroupKey]];

        NSError *fetchError = nil;
        NSArray *result = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Fetch error in fetchChildChannels: %@", fetchError.localizedDescription);
            return;
        }

        if (result.count > 0) {
            ALSLog(ALLoggerSeverityInfo, @"CHILD CHANNEL FOUND : %lu WITH PARENT KEY : %@", (unsigned long)result.count, parentGroupKey);

            for (DB_CHANNEL *dbChannel in result) {
                KMCoreChannel *alChannel = [[KMCoreChannel alloc] init];
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
                alChannel.platformSource = dbChannel.platformSource;
                alChannel.userCount = dbChannel.userCount;
                alChannel.category = dbChannel.category;

                [childArray addObject:alChannel];
            }
        }
    }];

    return childArray;
}

- (void)updateMuteAfterTime:(NSNumber *)notificationAfterTime
               andChnnelKey:(NSNumber *)channelKey {
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *context = [[alDBHandler persistentContainer] newBackgroundContext];
    
    [context performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        fetchRequest.fetchLimit = 1;
        
        NSError *fetchError = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
        
        if (results.count > 0) {
            DB_CHANNEL *dbChannel = results.firstObject;
            dbChannel.notificationAfterTime = notificationAfterTime;
            
            NSError *saveError = nil;
            if (![context save:&saveError]) {
                ALSLog(ALLoggerSeverityError, @"Failed to save updated mute time for channelKey %@: %@", channelKey, saveError.localizedDescription);
            }
        } else {
            ALSLog(ALLoggerSeverityWarn, @"Channel not found in DB to update mute time for channelKey: %@", channelKey);
        }
    }];
}

- (NSMutableArray *)getGroupUsersInChannel:(NSNumber *)key {
    __block NSMutableArray *memberList = [[NSMutableArray alloc] init];

    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
    NSManagedObjectContext *backgroundContext = [[alDBHandler persistentContainer] newBackgroundContext];

    [backgroundContext performBlockAndWait:^{
        NSEntityDescription *channelUserEntity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                                             inManagedObjectContext:backgroundContext];
        if (!channelUserEntity) {
            ALSLog(ALLoggerSeverityError, @"Entity DB_CHANNEL_USER_X not found");
            return;
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:channelUserEntity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channelKey = %@", key]];

        NSError *fetchError = nil;
        NSArray *resultArray = [backgroundContext executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            ALSLog(ALLoggerSeverityError, @"Failed to fetch channel users: %@", fetchError.localizedDescription);
            return;
        }

        if (resultArray.count > 0) {
            for (DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                [memberList addObject:dbChannelUserX];
            }
        }
    }];

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
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
    
    KMCoreDBHandler *alDBHandler = [KMCoreDBHandler sharedInstance];
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
