//
//  ALChannelSyncResponse.m
//  Kommunicate
//
//  Created by devashish on 16/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALChannelSyncResponse.h"

@implementation ALChannelSyncResponse

- (instancetype)initWithJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    
    self.alChannelArray = [[NSMutableArray alloc] init];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSObject *response = [JSONString valueForKey:@"response"];
        NSMutableArray *responseArray = [response valueForKey:@"groupPxys"];

        for (NSDictionary *JSONDictionaryObject in responseArray) {
            ALChannel *alChannel = [[ALChannel alloc] initWithDictonary:JSONDictionaryObject];
            [self.alChannelArray addObject:alChannel];
        }
        
        return self;
    } else {
        return nil;
    }
    
}

@end
