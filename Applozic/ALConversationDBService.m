//
//  ALConversationDBService.m
//  Applozic
//
//  Created by Devashish on 27/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALConversationDBService.h"
#import "ALDBHandler.h"

@implementation ALConversationDBService

-(void)insertConversationProxy:(NSMutableArray *)proxyArray
{
    if(proxyArray == nil || !proxyArray.count ){
        return;
    }

    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALConversationProxy *proxy in proxyArray){
        
        [self createConversationProxy:proxy];
    }

    NSError *error = [theDBHandler saveContext];
    if (error) {
        ALSLog(ALLoggerSeverityError, @"ERROR: InsertConversationProxy METHOD %@",error);
    }
    
}

-(void)insertConversationProxyTopicDetails:(NSMutableArray*)proxyArray{
    

    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    
    for(ALConversationProxy *proxy in proxyArray)
    {
        DB_ConversationProxy *dbConversationProxy = [self getConversationProxyByKey:proxy.Id];
        if(!dbConversationProxy){
            dbConversationProxy.topicDetailJson = proxy.topicDetailJson;
        }
    }
    
    NSError *error = [theDBHandler saveContext];
    if (error) {
        ALSLog(ALLoggerSeverityError, @"ERROR: TopicDetails Insert METHOD %@",error);
    } else {
        ALSLog(ALLoggerSeverityInfo, @"SUCCESS: TopicDetails Insertion in DB ");
    }

}

-(DB_ConversationProxy *)createConversationProxy:(ALConversationProxy *)conversationProxy
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    DB_ConversationProxy *dbConversationProxy = [self getConversationProxyByKey:conversationProxy.Id];
    if(!dbConversationProxy)
    {
        dbConversationProxy = (DB_ConversationProxy*)[theDBHandler insertNewObjectForEntityForName:@"DB_ConversationProxy"];
    }
    if (dbConversationProxy) {
        dbConversationProxy.iD=conversationProxy.Id;
        dbConversationProxy.topicId = conversationProxy.topicId;
        dbConversationProxy.groupId = conversationProxy.groupId;
        dbConversationProxy.created = [NSNumber numberWithBool:conversationProxy.created];
        dbConversationProxy.closed = [NSNumber numberWithBool:conversationProxy.closed];
        dbConversationProxy.userId = conversationProxy.userId;
        dbConversationProxy.topicDetailJson = conversationProxy.topicDetailJson;
    }

    return dbConversationProxy;
}


-(DB_ConversationProxy *)getConversationProxyByKey:(NSNumber *)Id
{
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_ConversationProxy"];
    if (entity) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iD = %@",Id];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count) {
            DB_ConversationProxy *proxy = [result objectAtIndex:0];
            return proxy;
        }
    }
    return nil;
}

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId {
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_ConversationProxy"];

    if (entity) {
        NSPredicate *predicate;
        if (userId) {
            predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
        } else {
            ALSLog(ALLoggerSeverityError, @"Error");
        }

        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count) {
            return result;
        }
    }
    return nil;
}

-(NSArray*)getConversationProxyListFromDBForUserID:(NSString*)userId
                                        andTopicId:(NSString*)topicId {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_ConversationProxy"];

    if (entity) {
        NSPredicate *predicate;
        if (userId) {
            predicate = [NSPredicate predicateWithFormat:@"userId == %@ && topicId == %@",userId,topicId];
        }

        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
        NSError *fetchError = nil;

        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count) {
            return result;
        }
    }
    return nil;
}

-(NSArray*)getConversationProxyListFromDBWithChannelKey:(NSNumber *)channelKey {
    
    ALDBHandler * dbHandler = [ALDBHandler sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [dbHandler entityDescriptionWithEntityForName:@"DB_ConversationProxy"];

    if (entity) {
        NSPredicate *predicate;
        if (channelKey) {
            predicate = [NSPredicate predicateWithFormat:@"groupId = %@",channelKey];
        }
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate]]];
        NSError *fetchError = nil;
        NSArray *result = [dbHandler executeFetchRequest:fetchRequest withError:&fetchError];
        if (result.count) {
            return result;
        }
    }
    return nil;
}

@end
