//
//  KMCoreChannelResponse.m
//  Kommunicate
//
//  Created by devashish on 12/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreChannelCreateResponse.h"
#import "KMCoreUserDetail.h"
#import "ALContactDBService.h"

@implementation KMCoreChannelCreateResponse  

- (instancetype)initWithJSONString:(NSString *)JSONString {
   self = [super initWithJSONString:JSONString];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
        self.alChannel = [[KMCoreChannel alloc] initWithDictonary:JSONDictionary];
        [self pasreUserDetails:[[NSMutableArray alloc] initWithArray:[JSONDictionary objectForKey:@"users"]]];

        return self;
    } else {
        self.response = JSONString;
        return self;
    }
    
}

- (void)pasreUserDetails:(NSMutableArray * ) userDetailJsonArray {
    
    for (NSDictionary *JSONDictionaryObject in userDetailJsonArray) {
        KMCoreUserDetail *userDetail = [[KMCoreUserDetail alloc] initWithDictonary:JSONDictionaryObject];
        ALContactDBService *contactDBService = [ALContactDBService new];
        userDetail.unreadCount = 0;
        [contactDBService updateUserDetail: userDetail];
    }
}

@end
