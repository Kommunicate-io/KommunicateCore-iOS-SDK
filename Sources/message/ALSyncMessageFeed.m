//
//  ALSyncMessageFeed.m
//  ChatApp
//
//  Created by Devashish on 20/09/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALSyncMessageFeed.h"

#import "ALMessage.h"


@implementation ALSyncMessageFeed


- (id)initWithJSONString:(NSString *)syncMessageResponse {
    
    self.lastSyncTime = [syncMessageResponse valueForKey:@"lastSyncTime"];
    NSMutableArray *messageList = [syncMessageResponse valueForKey:@"messages"];
    [self parseMessagseArray:messageList];
    self.deliveredMessageKeys = [syncMessageResponse valueForKey:@"deliveredMessageKeys"];
    return self;
}

- (void)parseMessagseArray:(id)theMessageDict {
    NSMutableArray *messagesArray = [NSMutableArray new];
    for (NSDictionary *theDictionary in theMessageDict) {
        ALMessage *message = [[ALMessage alloc] initWithDictonary:theDictionary ];
        [messagesArray addObject:message];
    }
    self.messagesList = messagesArray;
}

@end
