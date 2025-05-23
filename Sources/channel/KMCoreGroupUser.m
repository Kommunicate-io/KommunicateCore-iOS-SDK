//
//  KMCoreGroupUser.m
//  Kommunicate
//
//  Created by Sunil on 14/02/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import "KMCoreGroupUser.h"

@implementation KMCoreGroupUser

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (void)parseMessage:(id) messageJson {
    self.groupRole = [self getNSNumberFromJsonValue:messageJson[@"groupRole"]];
    self.userId = [self getStringFromJsonValue:messageJson[@"userId"]];
}


@end
