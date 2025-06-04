//
//  KMCoreMessageList.h
//  ChatApp
//
//  Created by Devashish on 22/09/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"


@interface KMCoreMessageList : KMCoreJson

@property (nonatomic) NSMutableArray *messageList;
@property (nonatomic) NSMutableArray *connectedUserList;
@property (nonatomic) NSMutableArray *userDetailsList;
@property(nonatomic) NSMutableArray *conversationPxyList;
@property(nonatomic) NSString *userId;
@property(nonatomic) NSNumber *groupId;

- (id)initWithJSONString:(NSString *)syncMessageResponse andWithUserId:(NSString *)userId andWithGroup:(NSNumber *)groupId;


@end
