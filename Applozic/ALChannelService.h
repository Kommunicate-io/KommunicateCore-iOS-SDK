//
//  ALChannelService.h
//  Applozic
//
//  Created by devashish on 04/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALChannelFeed.h"
#import "ALChannelDBService.h"
#import "ALChannelClientService.h"
#import "ALUserDefaultsHandler.h"
#import "ALChannelSyncResponse.h"

@interface ALChannelService : NSObject

-(void)callForChannelServiceForDBInsertion:(id)theJson;

-(void)getChannelInformation:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void (^)(ALChannel *alChannel3)) completion;

-(ALChannel *)getChannelByKey:(NSNumber *)channelKey;

-(NSMutableArray *)getListOfAllUsersInChannel:(NSNumber *)channelKey;

-(NSString *)stringFromChannelUserList:(NSNumber *)key;

-(void)createChannel:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey andMembersList:(NSMutableArray *)memberArray andImageLink:(NSString *)imageLink withCompletion:(void(^)(ALChannel *alChannel))completion;

-(void)addMemberToChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion;

-(void)removeMemberFromChannel:(NSString *)userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withComletion:(void(^)(NSError *error, NSString *response))completion;

-(void)deleteChannel:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error))completion;

-(BOOL)checkAdmin:(NSNumber *)channelKey;

-(void)leaveChannel:(NSNumber *)channelKey andUserId:(NSString *)userId orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error))completion;

-(void)syncCallForChannel;

-(void)renameChannel:(NSNumber *)channelKey andNewName:(NSString *)newName orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error))completion;

+(void)markConversationAsRead:(NSNumber *)channelKey withCompletion:(void (^)(NSString *, NSError *))completion;

-(BOOL)isChannelLeft:(NSNumber*)groupID;

+(void)setUnreadCountZeroForGroupID:(NSNumber*)channelKey;

-(NSNumber *)getOverallUnreadCountForChannel;

-(ALChannel *)fetchChannelWithClientChannelKey:(NSString *)clientChannelKey;

@end
