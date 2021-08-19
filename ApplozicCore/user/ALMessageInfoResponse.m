//
//  ALMessageInfoResponse.m
//  Applozic
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMessageInfoResponse.h"

@implementation ALMessageInfoResponse

- (instancetype)initWithJSONString:(NSString *)JSONString {
    self = [super initWithJSONString:JSONString];
    
    self.msgInfoList = [NSMutableArray new];
    
    if ([super.status isEqualToString: AL_RESPONSE_SUCCESS]) {
        NSMutableArray *responseArray = [JSONString valueForKey:@"response"];
        
        for(NSDictionary *JSONDictionaryObject in responseArray) {
            ALMessageInfo *messageInfoObject = [[ALMessageInfo alloc] initWithDictonary:JSONDictionaryObject];
            [self.msgInfoList addObject:messageInfoObject];
        }
        
        return self;
    } else {
        return nil;
    }

}

@end
