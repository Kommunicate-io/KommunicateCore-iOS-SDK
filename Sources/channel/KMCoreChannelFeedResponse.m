//
//  KMCoreChannelFeedResponse.m
//  Kommunicate
//
//  Created by Nitin on 20/10/17.
//  Copyright © 2017 kommunicate. All rights reserved.
//

#import "KMCoreChannelFeedResponse.h"
#import "KMCoreChannelCreateResponse.h"
#import "KMCoreUserDetail.h"
#import "ALContactDBService.h"

@implementation KMCoreChannelFeedResponse


- (instancetype)initWithJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
        self.kmCoreChannel = [[KMCoreChannel alloc] initWithDictonary:JSONDictionary];
        [self parseUserDetails:[[NSMutableArray alloc] initWithArray:[JSONDictionary objectForKey:@"users"]]];
        return self;
    } else {
        NSArray *errorResponseList = [JSONString valueForKey:@"errorResponse"];
        if (errorResponseList != nil && errorResponseList.count > 0) {
            self.errorResponse = errorResponseList.firstObject;
        }
        return self;
    }
}

- (void)parseUserDetails:(NSMutableArray *)userDetailJsonArray {
    
    for (NSDictionary *JSONDictionaryObject in userDetailJsonArray) {
        KMCoreUserDetail *userDetail = [[KMCoreUserDetail alloc] initWithDictonary:JSONDictionaryObject];
        userDetail.unreadCount = 0;
        ALContactDBService * contactDB = [ALContactDBService new];
        [contactDB updateUserDetail: userDetail];
    }
}


@end
