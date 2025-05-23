//
//  KMCoreChannelSyncResponse.m
//  Kommunicate
//
//  Created by devashish on 16/02/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreChannelSyncResponse.h"

@implementation KMCoreChannelSyncResponse

- (instancetype)initWithJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    
    self.alChannelArray = [[NSMutableArray alloc] init];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSObject *response = [JSONString valueForKey:@"response"];
        NSMutableArray *responseArray = [response valueForKey:@"groupPxys"];

        for (NSDictionary *JSONDictionaryObject in responseArray) {
            KMCoreChannel *alChannel = [[KMCoreChannel alloc] initWithDictonary:JSONDictionaryObject];
            [self.alChannelArray addObject:alChannel];
        }
        
        return self;
    } else {
        return nil;
    }
    
}

- (instancetype)initWithSingleChannelJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    self.alChannel = [[KMCoreChannel alloc] init];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSDictionary *response = [JSONString valueForKey:@"response"];
        KMCoreChannel *alChannel = [[KMCoreChannel alloc] initWithDictonary:response];
        self.alChannel = alChannel;
        return self;
    } else {
        return nil;
    }
}

@end
