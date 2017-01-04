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

@interface ALChannelDBService ()

@end

@implementation ALChannelDBService

-(void)createChannel:(ALChannel *)channel
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    [self createChannelEntity:channel];
    [theDBHandler.managedObjectContext save:nil];
    
    NSMutableArray * memberArray = [NSMutableArray new];
    
    for(NSString *member in channel.membersName)
    {
        ALChannelUserX *newChannelUserX = [[ALChannelUserX alloc] init];
        newChannelUserX.key = channel.key;
        newChannelUserX.userKey = member;
        newChannelUserX.parentKey = channel.parentKey;
        [memberArray addObject:newChannelUserX];
    }
    
    [self insertChannelUserX:memberArray];
    
    [self addedMembersArray:channel.membersName andChannelKey:channel.key];
    [self removedMembersArray:channel.removeMembers andChannelKey:channel.key];
}

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey
{
    ALChannelUserX *newUserX = [[ALChannelUserX alloc] init];
    newUserX.key = channelKey;
    newUserX.userKey = userId;
    
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
//    DB_CHANNEL_USER_X *dbChannelUserX = [self createChannelUserXEntity: newUserX];
    [self createChannelUserXEntity: newUserX];
    
    [theDBHandler.managedObjectContext save:nil];
    //channelUserX.channelDBObjectId = dbChannelUserX.objectID;
    
}

-(void)insertChannel:(NSMutableArray *)channelList
{
    NSMutableArray *channelArray = [[NSMutableArray alloc] init];
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALChannel *channel in channelList)
    {
//        DB_CHANNEL *dbChannel = [self createChannelEntity:channel];
         [self createChannelEntity:channel];
        // IT MIGHT BE USED IN FUTURE
        [theDBHandler.managedObjectContext save:nil];
        //channel.channelDBObjectId = dbChannel.objectID;
        [channelArray addObject:channel];
    }
    
    NSError *error = nil;
    [theDBHandler.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"ERROR IN insertChannel METHOD %@",error);
    }
}

-(DB_CHANNEL *)createChannelEntity:(ALChannel *)channel
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL * theChannelEntity = [self getChannelByKey:channel.key];
    
    if(!theChannelEntity)
    {
        theChannelEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CHANNEL" inManagedObjectContext:theDBHandler.managedObjectContext];
    }
    theChannelEntity.channelDisplayName = channel.name;
    theChannelEntity.channelKey = channel.key;
    theChannelEntity.clientChannelKey = channel.clientChannelKey;
    if(channel.userCount)
    {
        theChannelEntity.userCount = channel.userCount;
    }
    theChannelEntity.parentGroupKey = channel.parentKey;
    theChannelEntity.parentClientGroupKey = channel.parentClientKey;
    theChannelEntity.channelImageURL = channel.channelImageURL;
    theChannelEntity.type = channel.type;
    theChannelEntity.adminId = channel.adminKey;
    theChannelEntity.unreadCount = channel.unreadCount;
    
    return theChannelEntity;
}

-(void)deleteMembers:(NSNumber *)key
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X" inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", key];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(array.count)
    {
        for(NSManagedObject *manageOBJ in array)
        {
            [theDBHandler.managedObjectContext deleteObject:manageOBJ];
        }
    }
    [theDBHandler.managedObjectContext save:nil];
}

-(void)insertChannelUserX:(NSMutableArray *)channelUserXList
{
    NSMutableArray *channelUserXArray = [[NSMutableArray alloc] init];
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    if(channelUserXList.count)
    {
        ALChannelUserX *channelUserTemp = [channelUserXList objectAtIndex:0];
        [self deleteMembers:channelUserTemp.key];
    }
    
    for(ALChannelUserX *channelUserX in channelUserXList)
    {
//        DB_CHANNEL_USER_X *dbChannelUserX = [self createChannelUserXEntity:channelUserX];
         [self createChannelUserXEntity:channelUserX];
        // IT MIGHT BE USED IN FUTURE
        [theDBHandler.managedObjectContext save:nil];
        //channelUserX.channelDBObjectId = dbChannelUserX.objectID;
        [channelUserXArray addObject:channelUserX];
    }

    NSError *error = nil;
    [theDBHandler.managedObjectContext save:&error];
    if(error)
    {
        NSLog(@"ERROR IN insertChannelUserX METHOD %@",error);
    }
    
}

-(DB_CHANNEL_USER_X *)createChannelUserXEntity:(ALChannelUserX *)channelUserX
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL_USER_X * theChannelUserXEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DB_CHANNEL_USER_X" inManagedObjectContext:theDBHandler.managedObjectContext];
    
    if(channelUserX)
    {
        theChannelUserXEntity.channelKey = channelUserX.key;
        theChannelUserXEntity.userId = channelUserX.userKey;
        theChannelUserXEntity.parentGroupKey = channelUserX.parentKey;        
        //        theChannelUserXEntity.status = channelUserX.status;
    }
    
    return theChannelUserXEntity;
}

-(NSMutableArray *)getChannelMembersList:(NSNumber *)channelKey
{
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X" inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"userId"]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"ERROR IN FETCH MEMBER LIST");
    }
    else
    {
        memberList = [NSMutableArray arrayWithArray:fetchedObjects];
    }
    
    return memberList;
}

-(ALChannel *)loadChannelByKey:(NSNumber *)key
{
    DB_CHANNEL *dbChannel = [self getChannelByKey:key];
    ALChannel *alChannel = [[ALChannel alloc] init];
    
    if (!dbChannel)
    {
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
    
    return alChannel;
}

-(DB_CHANNEL *)getChannelByKey:(NSNumber *)key
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count)
    {
        DB_CHANNEL *dbChannel = [result objectAtIndex:0];
        return dbChannel;
    }
    else
    {
        return nil;
    }
}

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)key
{
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                              inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",key];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *resultArray = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (resultArray.count)
    {
        for(DB_CHANNEL_USER_X *dbChannelUserX in resultArray)
        {
            [memberList addObject:dbChannelUserX.userId];
        }
        
        return memberList;
    }
    else
    {
        return nil;
    }
    
}

-(NSString *)stringFromChannelUserList:(NSNumber *)key
{
    NSString *listString = @"";
    NSString *str = @"";
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:[self getListOfAllUsersInChannel:key]];
    
    if(tempArray.count == 0)
    {
        return @"";
    }
    NSMutableArray * listArray = [NSMutableArray new];
    ALContactDBService *contactDB = [ALContactDBService new];
    for(NSString *userID in tempArray)
    {
        ALContact *contact = [contactDB loadContactByKey:@"userId" value:userID];
        [listArray addObject: [contact getDisplayName]];
    }
    if(listArray.count == 1)
    {
        listString = listArray[0];
    }
    else if(listArray.count == 2)
    {
        listString = [NSString stringWithFormat:@"%@, %@", listArray[0], listArray[1]];
    }
    else if(listArray.count > 2)
    {
        int counter = (int)listArray.count - 2;
        str = [NSString stringWithFormat:@"+%d more", counter];
        listString = [NSString stringWithFormat:@"%@, %@, %@", listArray[0], listArray[1], str];
    }
    
    return listString;
}

-(ALChannel *)checkChannelEntity:(NSNumber *)channelKey
{
    DB_CHANNEL *dbChannel = [self getChannelByKey:channelKey];
    ALChannel *channel  = [[ALChannel alloc] init];
    
    if(dbChannel)
    {
        channel.parentKey = dbChannel.parentGroupKey;
        channel.parentClientKey = dbChannel.parentClientGroupKey;
        channel.key = dbChannel.channelKey;
        channel.clientChannelKey = dbChannel.clientChannelKey;
        channel.name = dbChannel.channelDisplayName;
        channel.adminKey = dbChannel.adminId;
        channel.type = dbChannel.type;
        channel.unreadCount = dbChannel.unreadCount;
        channel.channelImageURL = dbChannel.channelImageURL;
        
        return channel;
    }
    else
    {
        return nil;
    }
}

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL_USER_X"
                                              inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    NSPredicate* combinePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    [fetchRequest setPredicate: combinePredicate];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(array.count)
    {
        NSManagedObject *manageOBJ = [array objectAtIndex:0];
        [theDBHandler.managedObjectContext deleteObject:manageOBJ];
        [theDBHandler.managedObjectContext save:nil];
    }
    else
    {
        NSLog(@"NO MEMBER FOUND");
    }
}

-(void)deleteChannel:(NSNumber *)channelKey
{
    //Delete channel
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                              inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@", channelKey];
    [fetchRequest setPredicate: predicate];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //    NSLog(@"CHANEL KEY = %@", channelKey);
    //    NSLog(@"ARRAY COUNT = %lu", (unsigned long)array.count);
    if(array.count)
    {
        NSManagedObject *manageOBJ = [array objectAtIndex:0];
        [theDBHandler.managedObjectContext deleteObject:manageOBJ];
        [theDBHandler.managedObjectContext save:nil];
        
        // Delete all members
        [self deleteMembers:channelKey];
        
    }
    else
    {
        NSLog(@"NO ENTRY FOUND");
    }
}

#pragma mark- Fetch All Channels
//==============================

-(NSMutableArray*)getAllChannelKeyAndName
{
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL"
                                              inManagedObjectContext:theDBHandler.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [theDBHandler.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray * alChannels = [[NSMutableArray alloc] init];
    if(array.count)
    {
        for(DB_CHANNEL * dbChannel in array)
        {
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
            
            [alChannels addObject:channel];
        }
    }
    else
    {
        NSLog(@"NO ENTRY FOUND");
    }
    return alChannels;
}

-(NSNumber *)getOverallUnreadCountForChannelFromDB
{
    NSNumber * unreadCount;
    int count = 0;
    NSMutableArray * channelArray = [NSMutableArray arrayWithArray:[self getAllChannelKeyAndName]];
    for(ALChannel *alChannel in channelArray)
    {
        count = count + [alChannel.unreadCount intValue];
    }
    unreadCount = [NSNumber numberWithInt:count];
    return unreadCount;
}

-(void)updateChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orImageURL:(NSString *)imageURL orChildKeys:(NSMutableArray *)childKeysList
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count)
    {
        DB_CHANNEL *dbChannel = [result objectAtIndex:0];
        if(newName.length) {
            dbChannel.channelDisplayName = newName;
        }

        dbChannel.channelImageURL = imageURL;

        if(childKeysList.count) {
            for(NSNumber * childKey in childKeysList) {
                [self updateChannelParentKey:childKey andWithParentKey:channelKey isAdding:YES];
            }
        }
        [dbHandler.managedObjectContext save:nil];
    }
    else
    {
        NSLog(@"UPDATE_CHANNEL_DB : NO CHANNEL FOUND");
    }
}

-(void) updateChannelParentKey:(NSNumber *)channelKey andWithParentKey:(NSNumber *)channelParentKey isAdding:(BOOL)flag
{
    DB_CHANNEL *parentChannel = [self getChannelByKey:channelParentKey];
    DB_CHANNEL *childChannel = [self getChannelByKey:channelKey];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    if(flag)
    {
        childChannel.parentGroupKey = parentChannel.channelKey;
        childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
    }
    else
    {
        childChannel.parentGroupKey = nil;
        childChannel.parentClientGroupKey = nil;
    }
    
    [dbHandler.managedObjectContext save:nil];
}

-(void)updateClientChannelParentKey:(NSString *)clientChildKey andWithClientParentKey:(NSString *)clientParentKey isAdding:(BOOL)flag
{
    DB_CHANNEL *parentChannel = [self getChannelByClientChannelKey:clientParentKey];
    DB_CHANNEL *childChannel = [self getChannelByClientChannelKey:clientChildKey];
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    
    if(flag)
    {
        childChannel.parentGroupKey = parentChannel.channelKey;
        childChannel.parentClientGroupKey = parentChannel.clientChannelKey;
    }
    else
    {
        childChannel.parentGroupKey = nil;
        childChannel.parentClientGroupKey = nil;
    }
    
    [dbHandler.managedObjectContext save:nil];
}

-(void)updateUnreadCountChannel:(NSNumber *)channelKey unreadCount:(NSNumber *)unreadCount
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channelKey = %@",channelKey];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count && unreadCount!=nil)
    {
        DB_CHANNEL *dbChannel = [result objectAtIndex:0];
        dbChannel.unreadCount = unreadCount;
        [dbHandler.managedObjectContext save:nil];
    }
    else
    {
        NSLog(@"NO CHANNEL FOUND");
    }
}

-(void)setLeaveFlag:(BOOL)flag forChannel:(NSNumber *)groupId
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    
    if(dbChannel)
    {
        dbChannel.isLeft = flag;
        [dbHandler.managedObjectContext save:nil];
    }
    else
    {
        NSLog(@"NO CHANNEL : %@ FOUND",groupId);
    }
}

-(BOOL)isChannelLeft:(NSNumber *)groupId
{
    DB_CHANNEL *dbChannel = [self getChannelByKey:groupId];
    return dbChannel.isLeft;
}

-(void)processArrayAfterSyncCall:(NSMutableArray *)channelArray
{
    for(ALChannel *channelObject in channelArray)
    {
        [self createChannel:channelObject];
    }
}

//------------------------------------------
#pragma mark AFTER LEAVE LOGOUT and LOGIN
//------------------------------------------

-(void)removedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey
{
    if([memberArray containsObject:[ALUserDefaultsHandler getUserId]])
    {
        [self setLeaveFlag:YES forChannel:channelKey];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:channelKey forKey:@"CHANNEL_KEY"];
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"FLAG_VALUE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_USER_FREEZE_CHANNEL_ADD_REMOVING" object:nil userInfo:dict];
    }
}

-(void)addedMembersArray:(NSMutableArray *)memberArray andChannelKey:(NSNumber *)channelKey
{
    if([memberArray containsObject:[ALUserDefaultsHandler getUserId]])
    {
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

-(NSUInteger)markConversationAsRead:(NSNumber*)channelKey
{
    NSArray *messages;
    
    if(channelKey){
        messages =  [self getUnreadMessagesForGroup:channelKey];
    }
    else{
        NSLog(@"channelKey null for marking unread");
    }
    
    if(messages.count > 0)
    {
        NSBatchUpdateRequest *req= [[NSBatchUpdateRequest alloc] initWithEntityName:@"DB_Message"];
        req.predicate = [NSPredicate predicateWithFormat:@"groupId=%d",[channelKey intValue]];
        req.propertiesToUpdate = @{
                                   @"status" : @(DELIVERED_AND_READ)
                                   };
        req.resultType = NSUpdatedObjectsCountResultType;
        ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
        NSBatchUpdateResult *res = (NSBatchUpdateResult *)[dbHandler.managedObjectContext executeRequest:req error:nil];
        NSLog(@"%@ objects updated", res.result);
    }
    return messages.count;
}

- (NSArray *)getUnreadMessagesForGroup:(NSNumber*)groupId {
    
    //Runs at Opening AND Leaving ChatVC AND Opening MessageList..
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_Message" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate;
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status != %i AND type==%@ ",DELIVERED_AND_READ,@"4"];
    
    if (groupId) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K=%d",@"groupId",groupId.intValue];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1,predicate2]];
    }
    else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2]];
    }
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    return result;
}

-(DB_CHANNEL *)getChannelByClientChannelKey:(NSString *)clientChannelKey
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL" inManagedObjectContext:dbHandler.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientChannelKey = %@",clientChannelKey];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (result.count)
    {
        DB_CHANNEL *dbChannel = [result objectAtIndex:0];
        return dbChannel;
    }
    else
    {
        NSLog(@"CHANNEL_NOT_FOUND :: %@",clientChannelKey);
        return nil;
    }
}

-(ALChannel *)loadChannelByClientChannelKey:(NSString *)clientChannelKey
{
    DB_CHANNEL * dbChannel = [self getChannelByClientChannelKey:clientChannelKey];
    ALChannel *alChannel = [[ALChannel alloc] init];
    
    if (!dbChannel)
    {
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
    
    return alChannel;
}

-(NSMutableArray *)fetchChildChannels:(NSNumber *)parentGroupKey
{
    NSMutableArray *childArray = [[NSMutableArray alloc] init];
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DB_CHANNEL" inManagedObjectContext:dbHandler.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentGroupKey = %@",parentGroupKey];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [dbHandler.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    NSLog(@"CHILD CHANNEL FOUND : %lu WITH PARENT KEY : %@",result.count, parentGroupKey);
    NSLog(@"ERROR (IF-ANY) : %@",fetchError.description);
    
    for(DB_CHANNEL *dbChannel in result)
    {
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
        
        [childArray addObject:alChannel];
    }
    
    return childArray;
}

@end
