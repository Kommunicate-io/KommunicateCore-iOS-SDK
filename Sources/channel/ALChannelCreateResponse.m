//
//  ALChannelResponse.m
//  Applozic
//
//  Created by devashish on 12/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALChannelCreateResponse.h"
#import "ALUserDetail.h"
#import "ALContactDBService.h"

@implementation ALChannelCreateResponse  

- (instancetype)initWithJSONString:(NSString *)JSONString {
   self = [super initWithJSONString:JSONString];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
        self.alChannel = [[ALChannel alloc] initWithDictonary:JSONDictionary];
        [self pasreUserDetails:[[NSMutableArray alloc] initWithArray:[JSONDictionary objectForKey:@"users"]]];

        return self;
    } else {
        self.response = JSONString;
        return self;
    }
    
}

- (void)pasreUserDetails:(NSMutableArray * ) userDetailJsonArray {
    
    for (NSDictionary *JSONDictionaryObject in userDetailJsonArray) {
        ALUserDetail *userDetail = [[ALUserDetail alloc] initWithDictonary:JSONDictionaryObject];
        ALContactDBService *contactDBService = [ALContactDBService new];
        userDetail.unreadCount = 0;
        [contactDBService updateUserDetail: userDetail];
    }
}

@end
