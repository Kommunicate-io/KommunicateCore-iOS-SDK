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
#import "SearchResultCache.h"
#import "ALChannelService.h"

@interface ALChannelDBService ()

@end

@implementation ALChannelDBService

static int const CHANNEL_MEMBER_FETCH_LMIT = 5;

-(void)addMemberToChannel:(NSString *)userId
            andChannelKey:(NSNumber *)channelKey {
    ALChannelUserX *newUserX = [[ALChannelUserX alloc] init];
    newUserX.key = channelKey;
    newUserX.userKey = userId;
    
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL_USER_X * channelUserX =  [self createChannelUserXEntity: newUserX];
    NSError *error = nil;
    if (channelUserX) {
        error = [theDBHandler saveContext];
    }

    if(error) {
        ALSLog(ALLoggerSeverityError, @"ERROR IN Add member to channel  %@",error);
    }
}

-(void)insertChannel:(NSMutableArray *)channelList {
    NSMutableArray *channelArray = [[NSMutableArray alloc] init];
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALChannel *channel in channelList)
    {
        [self createChannelEntity:channel];
        NSError *error = [theDBHandler saveContext];
        if(error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannel METHOD %@",error);
        }
        [channelArray addObject:channel];
    }
}

-(DB_CHANNEL *)createChannelEntity:(ALChannel *)channel {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL * theChannelEntity = [self getChannelByKey:channel.key];
    
    if (!theChannelEntity) {
        theChannelEntity = (DB_CHANNEL *)[theDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL"];
    }

    if (theChannelEntity) {
        theChannelEntity.channelDisplayName = channel.name;
        theChannelEntity.channelKey = channel.key;
        theChannelEntity.clientChannelKey = channel.clientChannelKey;
        if (channel.userCount) {
            theChannelEntity.userCount = channel.userCount;
        }
        theChannelEntity.notificationAfterTime = channel.notificationAfterTime;
        theChannelEntity.deletedAtTime = channel.deletedAtTime;
        theChannelEntity.parentGroupKey = channel.parentKey;
        theChannelEntity.parentClientGroupKey = channel.parentClientKey;
        theChannelEntity.channelImageURL = channel.channelImageURL;
        theChannelEntity.type = channel.type;
        theChannelEntity.adminId = channel.adminKey;
        if (channel.unreadCount != nil &&
            [channel.unreadCount compare:[NSNumber numberWithInt:0]] != NSOrderedSame){
            theChannelEntity.unreadCount = channel.unreadCount;
        }
        theChannelEntity.metadata = channel.metadata.description;
        theChannelEntity.category = channel.category;
    }

    return theChannelEntity;
}

-(void)deleteMembers:(NSNumber *)key {
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", key];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [theDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            for(NSManagedObject *manageOBJ in result) {
                [theDBHandler deleteObject:manageOBJ];
            }
            [theDBHandler saveContext];
        }
    }
}

-(void)insertChannelUserX:(NSMutableArray *)channelUserXList {
    NSMutableArray *channelUserXArray = [[NSMutableArray alloc] init];
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    if (channelUserXList.count) {
        ALChannelUserX *channelUserTemp = [channelUserXList objectAtIndex:0];
        [self deleteMembers:channelUserTemp.key];
    }
    
    for (ALChannelUserX *channelUserX in channelUserXList) {
        [self createChannelUserXEntity:channelUserX];
        NSError *error = [theDBHandler saveContext];
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR IN insertChannelUserX METHOD %@",error);
        }
        [channelUserXArray addObject:channelUserX];
    }
}

-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserX  withContext:(NSManagedObjectContext *)context {

    ALDBHandler * helper = [ALDBHandler sharedInstance];

    DB_CHANNEL_USER_X * theChannelUserXEntity = (DB_CHANNEL_USER_X *)[helper insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X" withManagedObjectContext:context];

    if (channelUserX && theChannelUserXEntity) {
        theChannelUserXEntity.channelKey = channelUserX.key;
        theChannelUserXEntity.userId = channelUserX.userKey;
        if(channelUserX.parentKey != nil){
            theChannelUserXEntity.parentGroupKey = channelUserX.parentKey;
        }
        
        if (channelUserX.role != nil) {
            theChannelUserXEntity.role = channelUserX.role;
        }
    }
    
    return theChannelUserXEntity;
}

-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserX {
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    DB_CHANNEL_USER_X * theChannelUserXEntity = (DB_CHANNEL_USER_X *)[theDBHandler insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (channelUserX && theChannelUserXEntity) {
        theChannelUserXEntity.channelKey = channelUserX.key;
        theChannelUserXEntity.userId = channelUserX.userKey;
        theChannelUserXEntity.parentGroupKey = channelUserX.parentKey;
    }
    
    return theChannelUserXEntity;
}

-(NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey {
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        [fetchRequest setEntity:entity];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"userId"]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [theDBHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            NSMutableArray* users = [NSMutableArray arrayWithArray:result];
            
            for (NSDictionary * theDictionary in users) {
                [memberList addObject:[theDictionary valueForKey:@"userId"]];
            }
        }
    }
    return memberList;
}

-(ALChannel *)loadChannelByKey:(NSNumber *)key {
    ALChannel *cachedChannel = [[SearchResultCache shared] getChannelWithId: key];
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

-(DB_CHANNEL *)getChannelByKey:(NSNumber *)key {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    return nil;
}


//------------------------------------------
#pragma mark CONTACTS GROUP TYPE and NAME GET CHANNEL
//------------------------------------------


-(DB_CHANNEL *)getContactsGroupChannelByName:(NSString *)channelName {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelDisplayName = %@",channelName];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"type = %i", CONTACT_GROUP];
        NSPredicate* combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate: combinePredicate];
        
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:nil];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    return nil;
}

-(ALChannelUserX *)loadChannelUserX:(NSNumber *)channelKey {
    
    DB_CHANNEL_USER_X *dbChannelUserX = [self getChannelUserX:channelKey];
    ALChannelUserX *alChannelUserX = [[ALChannelUserX alloc] init];
    
    if (!dbChannelUserX) {
        return nil;
    }
    
    alChannelUserX.key =dbChannelUserX.channelKey;
    alChannelUserX.parentKey =dbChannelUserX.parentGroupKey;
    alChannelUserX.userKey =dbChannelUserX.userId;
    alChannelUserX.status = dbChannelUserX.status;
    alChannelUserX.unreadCount =dbChannelUserX.unreadCount;
    alChannelUserX.role = dbChannelUserX.role;
    return alChannelUserX;
}

-(DB_CHANNEL_USER_X *)getChannelUserXByUserId:(NSNumber *)channelKey
                                    andUserId:(NSString *) userId {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey == %@ AND userId == %@", channelKey, userId];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count > 0 ) {
            DB_CHANNEL_USER_X *dbChannelUserX = [result objectAtIndex:0];
            return dbChannelUserX;
        }
    }
    return nil;
}

-(DB_CHANNEL_USER_X *)getChannelUserX:channelKey{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL_USER_X *dbChannelUserX = [result objectAtIndex:0];
            return dbChannelUserX;
        }
    }
    return nil;
}


-(ALChannelUserX *)loadChannelUserXByUserId:(NSNumber *)channelKey
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

-(void)updateParentKeyInChannelUserX:(NSNumber *)channelKey
                    andWithParentKey:(NSNumber *)parentKey
                          addUserId :(NSString *) userId {
    
    DB_CHANNEL_USER_X *channelUserX =  [self getChannelUserXByUserId:channelKey andUserId:userId];
    if (channelUserX) {
        ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
        channelUserX.parentGroupKey = parentKey;
        [dbHandler saveContext];
    }
}

-(void)updateRoleInChannelUserX:(NSNumber *)channelKey
                      andUserId:(NSString *)userId withRoleType:(NSNumber*)role {
    
    DB_CHANNEL_USER_X *channelUserX = [self getChannelUserXByUserId:channelKey andUserId:userId];

    if (channelUserX) {
        ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
        channelUserX.role = role;
        [dbHandler saveContext];
    }
}

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key {
    return [self getListOfAllUsersInChannel:key withLimit:0];
}

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key
                                    withLimit:(NSUInteger) fetchLimit {
    
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if (fetchLimit > 0) {
        fetchRequest.fetchLimit = fetchLimit;
    }
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSArray *resultArray = [dbHandler executeFetchRequest:fetchRequest withError:nil];
        
        if (resultArray.count) {
            for (DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                NSString * memberUserId = dbChannelUserX.userId;
                if (memberUserId != nil) {
                    [memberList addObject:memberUserId];
                }
            }
            return memberList;
        }
    }
    return nil;
}

-(NSUInteger)getCountOfNumberOfUsers:(NSNumber *)channelKey {
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CHANNEL_USER_X"];
    [theRequest setIncludesPropertyValues:NO];
    [theRequest setIncludesSubentities:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [theRequest setPredicate:predicate];
    NSUInteger count = [theDbHandler countForFetchRequest:theRequest];
    return count;
}

//------------------------------------------
#pragma mark GET ALL USERS OF CONTACT GROUP BY CHANNEL NAME
//------------------------------------------


-(NSMutableArray *)getListOfAllUsersInChannelByNameForContactsGroup:(NSString *)channelName {
    
    if (channelName == nil) {
        return nil;
    }
    
    DB_CHANNEL *dbChannel = [self getContactsGroupChannelByName:channelName];
    
    if(dbChannel != nil){
        return [self getListOfAllUsersInChannel:dbChannel.channelKey];
    }
    return nil;
}

-(NSString *)stringFromChannelUserList:(NSNumber *)key
{
    NSString *listString = @"";
    NSString *str = @"";
    NSMutableArray *listOfUsersinChannel = [self getListOfAllUsersInChannel:key withLimit:CHANNEL_MEMBER_FETCH_LMIT];

    if (listOfUsersinChannel.count) {
        NSMutableArray * tempArray = [NSMutableArray arrayWithArray:listOfUsersinChannel];

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

-(ALChannel *)checkChannelEntity:(NSNumber *)channelKey {
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

-(void)removeMemberFromChannel:(NSString *)userId
                 andChannelKey:(NSNumber *)channelKey {
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        [fetchRequest setEntity:entity];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"userId = %@", userId];
        NSPredicate* combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        [fetchRequest setPredicate: combinePredicate];
        
        NSError *error = nil;
        NSArray *memberArray = [theDBHandler executeFetchRequest:fetchRequest withError:&error];
        if (memberArray.count) {
            NSManagedObject *manageOBJ = [memberArray objectAtIndex:0];
            [theDBHandler deleteObject:manageOBJ];
            [theDBHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityWarn, @"NO MEMBER FOUND");
        }
    }
}

-(void)deleteChannel:(NSNumber *)channelKey {
    //Delete channel
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
        [fetchRequest setPredicate: predicate];
        
        NSError *error = nil;
        NSArray *array = [theDBHandler executeFetchRequest:fetchRequest withError:&error];
        if(array.count) {
            NSManagedObject *manageOBJ = [array objectAtIndex:0];
            [theDBHandler deleteObject:manageOBJ];
            [theDBHandler saveContext];
            
            // Delete all members
            [self deleteMembers:channelKey];
        } else {
            ALSLog(ALLoggerSeverityWarn, @"NO ENTRY FOUND");
        }
    }
}

#pragma mark- Fetch All Channels
//==============================

-(NSMutableArray*)getAllChannelKeyAndName {
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [theDBHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    NSMutableArray * alChannels = [[NSMutableArray alloc] init];
    
    if (entity) {
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type != %i",CONTACT_GROUP];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSArray *resultArray = [theDBHandler executeFetchRequest:fetchRequest withError:nil];
        if (resultArray.count) {
            for (DB_CHANNEL * dbChannel in resultArray) {
                ALChannel* channel = [[ALChannel alloc] init];
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
            ALSLog(ALLoggerSeverityWarn, @"NO ENTRY FOUND");
        }
    }
    return alChannels;
}

-(NSNumber *)getOverallUnreadCountForChannelFromDB {
    NSNumber * unreadCount;
    int count = 0;
    NSMutableArray * channelArray = [NSMutableArray arrayWithArray:[self getAllChannelKeyAndName]];
    if (channelArray.count) {
        for(ALChannel *alChannel in channelArray) {
            count = count + [alChannel.unreadCount intValue];
        }
        unreadCount = [NSNumber numberWithInt:count];
    }
    return unreadCount;
}

-(void)updateChannel:(NSNumber *)channelKey
          andNewName:(NSString *)newName
          orImageURL:(NSString *)imageURL
         orChildKeys:(NSMutableArray *)childKeysList
  isUpdatingMetaData:(BOOL)flag
      orChannelUsers:(NSMutableArray *)channelUsers {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            if (newName.length) {
                dbChannel.channelDisplayName = newName;
            }
            
            if (!flag) {
                dbChannel.channelImageURL = imageURL;
            }
            
            if (childKeysList.count) {
                for(NSNumber * childKey in childKeysList) {
                    [self updateChannelParentKey:childKey andWithParentKey:channelKey isAdding:YES];
                }
            }
            for(NSDictionary * chUserDict in channelUsers) {
                ALChannelUser * channelUser = [[ALChannelUser alloc] initWithDictonary:chUserDict];
                if (channelUser.parentGroupKey) {
                    [self updateParentKeyInChannelUserX:channelKey andWithParentKey:channelUser.parentGroupKey addUserId:channelUser.userId];
                }
                
                if (channelUser.role) {
                    [self updateRoleInChannelUserX:channelKey andUserId:channelUser.userId withRoleType:channelUser.role];
                }
            }
            [dbHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"UPDATE_CHANNEL_DB : NO CHANNEL FOUND");
        }
    }
}

-(void)updateChannelMetaData:(NSNumber *)channelKey
                    metaData:(NSMutableDictionary *)newMetaData {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            if (newMetaData!=nil) {
                dbChannel.metadata = newMetaData.description;
                
                // Update conversation status from metadata
                dbChannel.category = [ALChannel getConversationCategory:newMetaData];
            }
            
            [dbHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"UPDATE_CHANNEL_DB : NO CHANNEL FOUND");
        }
    }
}

-(void) updateChannelParentKey:(NSNumber *)channelKey
              andWithParentKey:(NSNumber *)channelParentKey
                      isAdding:(BOOL)flag {
    DB_CHANNEL *parentChannel = [self getChannelByKey:channelParentKey];
    DB_CHANNEL *childChannel = [self getChannelByKey:channelKey];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    if (childChannel && childChannel) {
        if (flag) {
            childChannel.parentGroupKey = parentChannel.channelKey;
            childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
        } else {
            childChannel.parentGroupKey = nil;
            childChannel.parentClientGroupKey = nil;
        }
        [dbHandler saveContext];
    }
}

-(void)updateClientChannelParentKey:(NSString *)clientChildKey
             andWithClientParentKey:(NSString *)clientParentKey
                           isAdding:(BOOL)flag {
    DB_CHANNEL *parentChannel = [self getChannelByClientChannelKey:clientParentKey];
    DB_CHANNEL *childChannel = [self getChannelByClientChannelKey:clientChildKey];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    if (parentChannel &&  childChannel) {
        if (flag) {
            childChannel.parentGroupKey = parentChannel.channelKey;
            childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
        } else {
            childChannel.parentGroupKey = nil;
            childChannel.parentClientGroupKey = nil;
        }
        
        [dbHandler saveContext];
    }
}

-(void)updateUnreadCountChannel:(NSNumber *)channelKey
                    unreadCount:(NSNumber *)unreadCount {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count && unreadCount != nil) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            dbChannel.unreadCount = unreadCount;
            [dbHandler saveContext];
        } else {
            ALSLog(ALLoggerSeverityError, @"NO CHANNEL FOUND");
        }
    }
}

-(void)setLeaveFlag:(BOOL)flag
         forChannel:(NSNumber *)groupId {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    
    if(dbChannel) {
        dbChannel.isLeft = flag;
        [dbHandler saveContext];
    } else {
        ALSLog(ALLoggerSeverityError, @"NO CHANNEL : %@ FOUND",groupId);
    }
}

-(BOOL)isChannelLeft:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    return dbChannel.isLeft;
}

-(BOOL)isChannelDeleted:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    return (dbChannel.deletedAtTime != nil);
}

-(BOOL)isConversaionClosed:(NSNumber *)groupId {
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    ALChannel *channel = [ALChannel new];
    NSMutableDictionary *metadata =   [channel getMetaDataDictionary:dbChannel.metadata];
    
    if (metadata &&
        [metadata  valueForKey:AL_CHANNEL_CONVERSATION_STATUS]){
        return ([[metadata  valueForKey:AL_CHANNEL_CONVERSATION_STATUS] isEqualToString:@"CLOSE"]);
    }
    return NO;
}

-(BOOL)isAdminBroadcastChannel:(NSNumber *)groupId
{
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    ALChannel *channel = [ALChannel new];
    NSMutableDictionary *metadata = [channel getMetaDataDictionary:dbChannel.metadata];
    
    return (metadata &&
            [[metadata valueForKey:@"AL_ADMIN_BROADCAST"] isEqualToString:@"true"]);
}

//------------------------------------------
#pragma mark AFTER LEAVE LOGOUT and LOGIN
//------------------------------------------

-(void)removedMembersArray:(NSMutableArray *)memberArray
             andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[ALUserDefaultsHandler getUserId]]) {
        [self setLeaveFlag:YES forChannel:channelKey];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:channelKey forKey:@"CHANNEL_KEY"];
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:dict];
    }
}

-(void)addedMembersArray:(NSMutableArray *)memberArray
           andChannelKey:(NSNumber *)channelKey {
    if ([memberArray containsObject:[ALUserDefaultsHandler getUserId]]) {
        [self setLeaveFlag:NO forChannel:channelKey];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:channelKey forKey:@"CHANNEL_KEY"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:dict];
    }
}

//-----------------------------
#pragma mark Marking Group Read
//-----------------------------

-(NSUInteger)markConversationAsRead:(NSNumber*)channelKey {
    NSArray *messages;
    
    if (channelKey) {
        messages =  [self getUnreadMessagesForGroup:channelKey];
    } else {
        ALSLog(ALLoggerSeverityError, @"channelKey null for marking unread");
    }
    
    if (messages.count > 0) {
        NSBatchUpdateRequest *req= [[NSBatchUpdateRequest alloc] initWithEntityName:@"DB_Message"];
        req.predicate = [NSPredicate predicateWithFormat:@"groupId=%d",[channelKey intValue]];
        req.propertiesToUpdate = @{
            @"status" : @(DELIVERED_AND_READ)
        };
        req.resultType = NSUpdatedObjectsCountResultType;
        ALDBHandler * dbHandler = [ALDBHandler sharedInstance];

        NSError * fetchError = nil;

        NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[dbHandler executeRequestForNSBatchUpdateResult:req withError:&fetchError];

        if (batchUpdateResult) {
            ALSLog(ALLoggerSeverityInfo, @"%@ markConversationAsRead updated rows", batchUpdateResult.result);
        }
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForGroup:(NSNumber*)groupId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSArray *result = nil;
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_Message"];
    
    if (entity) {
        NSPredicate *predicate;
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];
        
        if (groupId) {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%d",@"groupId",groupId.intValue];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
        } else {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
        }
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
    }
    
    return result;
}

-(DB_CHANNEL *)getChannelByClientChannelKey:(NSString *)clientChannelKey {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientChannelKey = %@",clientChannelKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (result.count) {
            DB_CHANNEL *dbChannel = [result objectAtIndex:0];
            return dbChannel;
        }
    }
    ALSLog(ALLoggerSeverityError, @"CHANNEL_NOT_FOUND :: %@",clientChannelKey);
    return nil;
}

-(ALChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey {
    DB_CHANNEL * dbChannel = [self getChannelByClientChannelKey:clientChannelKey];
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


-(NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey {
    NSMutableArray *childArray = [[NSMutableArray alloc] init];
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL"];
    if (entity) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentGroupKey = %@",parentGroupKey];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
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

-(void)updateMuteAfterTime:(NSNumber*)notificationAfterTime
              andChnnelKey:(NSNumber*)channelKey {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    DB_CHANNEL *dbChannel = [self getChannelByKey:channelKey];
    if (dbChannel) {
        dbChannel.notificationAfterTime = notificationAfterTime;
        [dbHandler saveContext];
    }
}

-(NSMutableArray *) getGroupUsersInChannel:(NSNumber *)key {
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_CHANNEL_USER_X"];
    
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        
        NSError *fetchError = nil;
        
        NSArray *resultArray = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        
        if (resultArray.count) {
            for(DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                [memberList addObject:dbChannelUserX];
            }
            return memberList;
        }
    }
    return memberList;
}


-(void)fetchChannelMembersAsyncWithChannelKey:(NSNumber*)channelKey
                                witCompletion:(void(^)(NSMutableArray *membersArray))completion {
    
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DB_CHANNEL_USER_X"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [fetchRequest setPredicate:predicate];
    
    NSAsynchronousFetchRequest *asynchronousFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
        
        NSArray *resultArray =   result.finalResult;
        
        if (resultArray && resultArray.count) {
            for(DB_CHANNEL_USER_X *dbChannelUserX in resultArray) {
                if (dbChannelUserX.userId) {
                    [memberList addObject:dbChannelUserX.userId];
                }
            }
        } else{
            ALSLog(ALLoggerSeverityWarn, @"NO MEMBER FOUND");
        }
        completion(memberList);
    }];
    
    ALDBHandler *handler = [ALDBHandler sharedInstance];
    NSManagedObjectContext *context = handler.persistentContainer.viewContext;
    if (context) {
        [context performBlock:^{
            [context executeRequest:asynchronousFetchRequest error:nil];
        }];
    } else {
        completion(nil);
    }
}

-(void) getUserInSupportGroup:(NSNumber *) channelKey
               withCompletion:(void(^)(NSString *userId)) completion {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DB_CHANNEL_USER_X"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@ AND role = %@", channelKey, @3];
    [fetchRequest setPredicate:predicate];
    
    NSAsynchronousFetchRequest *asynchronousFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult *result) {
        NSArray *resultArray =   result.finalResult;
        if (resultArray && resultArray.count) {
            DB_CHANNEL_USER_X *user = resultArray[0];
            completion(user.userId);
        } else {
            ALSLog(ALLoggerSeverityWarn, @"NO MEMBER FOUND");
            completion(nil);
        }
    }];
    
    ALDBHandler *handler = [ALDBHandler sharedInstance];
    NSManagedObjectContext *context = handler.persistentContainer.viewContext;
    if (context) {
        [context performBlock:^{
            [context executeRequest:asynchronousFetchRequest error:nil];
        }];
    } else {
        completion(nil);
    }
}

@end
