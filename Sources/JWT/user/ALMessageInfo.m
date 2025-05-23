//
//  KMCoreMessageInfo.m
//  Kommunicate
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreMessageInfo.h"

@implementation KMCoreMessageInfo

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (void)parseMessage:(id)messageJson {
    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
    self.status = [self getShortFromJsonValue:messageJson[@"status"]];
}

@end
