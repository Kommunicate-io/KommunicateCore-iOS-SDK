//
//  ALUserBlockResponse.m
//  Applozic
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALUserBlockResponse.h"

@implementation ALUserBlockResponse

- (instancetype)initWithJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    self.blockedUserList = [NSMutableArray new];
    NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
    self.blockedToUserList = [[NSMutableArray alloc] initWithArray:[JSONDictionary valueForKey:@"blockedToUserList"]];
    
    for (NSDictionary *dict in self.blockedToUserList) {
        ALUserBlocked *userBlocked = [[ALUserBlocked alloc] init];
        userBlocked.blockedTo = [dict valueForKey:@"blockedTo"];
        userBlocked.applicationKey = [dict valueForKey:@"applicationKey"];
        userBlocked.createdAtTime = [dict valueForKey:@"createdAtTime"];
        userBlocked.updatedAtTime = [dict valueForKey:@"updatedAtTime"];
        userBlocked.userBlocked = [[dict valueForKey:@"userBlocked"] boolValue];
        
        [self.blockedUserList addObject:userBlocked];
    }
    
    self.blockByUserList = [NSMutableArray new];
    self.blockedByList = [[NSMutableArray alloc] initWithArray:[JSONDictionary valueForKey:@"blockedByUserList"]];
    
    for (NSDictionary *dict in self.blockedByList) {
        ALUserBlocked *userBlockedBy = [[ALUserBlocked alloc] init];
        userBlockedBy.blockedBy = [dict valueForKey:@"blockedBy"];
        userBlockedBy.userblockedBy = [[dict valueForKey:@"userBlocked"] boolValue];
        
        [self.blockByUserList addObject: userBlockedBy];
    }
    
    return self;
}

@end
