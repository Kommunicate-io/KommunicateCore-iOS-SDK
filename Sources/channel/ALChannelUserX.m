//
//  ALChannelUserX.m
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "ALChannelUserX.h"

@implementation ALChannelUserX

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    [self parseMessage:messageDictonary];
    return self;
}

- (void)parseMessage:(id) messageJson {
}


- (BOOL)isAdminUser {
    return  self.role.intValue == ADMIN;
}

@end
