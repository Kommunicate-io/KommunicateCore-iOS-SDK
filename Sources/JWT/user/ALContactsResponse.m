//
//  ALContactsResponse.m
//  Kommunicate
//
//  Created by devashish on 25/04/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALContactsResponse.h"
#import "KMCoreUserDetail.h"
#import "KMCoreSettings.h"

@implementation ALContactsResponse

- (id)initWithJSONString:(NSString *)JSONString {
    [self parseJsonString:JSONString];
    return self;
}

- (void)parseJsonString:(NSString *)JSONString {
    if ((JSONString && [JSONString isKindOfClass:[NSString class]] && JSONString.length) ||
        (JSONString && [JSONString isKindOfClass:[NSDictionary class]] && ((NSDictionary*)JSONString).count)) {
        NSMutableArray *userDetailArray = [[NSMutableArray alloc] initWithArray:[JSONString valueForKey:@"users"]];
        self.userDetailList = [NSMutableArray new];

        for (NSDictionary *userDictionary in userDetailArray) {
            KMCoreUserDetail *userDetail = [[KMCoreUserDetail alloc] initWithDictonary:userDictionary];
            [self.userDetailList addObject:userDetail];
        }

        self.lastFetchTime =  [JSONString valueForKey:@"lastFetchTime"];
        [KMCoreSettings setStartTime:self.lastFetchTime];
        
        self.totalUnreadCount = [JSONString valueForKey:@"totalUnreadCount"];
    }
}

@end
