//
//  KMCoreChannelResponse.h
//  Kommunicate
//
//  Created by Nitin on 21/10/17.
//  Copyright © 2017 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "KMCoreJson.h"
#import "KMCoreConversationProxy.h"

@interface KMCoreChannelResponse :  KMCoreJson

@property (nonatomic, strong) NSNumber *key;
@property (nonatomic, strong) NSString *clientGroupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *adminKey;
@property (nonatomic) short type;
@property (nonatomic, strong) NSNumber *userCount;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) KMCoreConversationProxy *conversationProxy;
@property (nonatomic, strong) NSNumber *notificationAfterTime;
@property (nonatomic, strong) NSNumber *deletedAtTime;
@property (nonatomic, strong) NSMutableDictionary *metadata;


@end
