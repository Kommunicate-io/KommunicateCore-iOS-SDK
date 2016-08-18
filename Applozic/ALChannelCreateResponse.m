//
//  ALChannelResponse.m
//  Applozic
//
//  Created by devashish on 12/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALChannelCreateResponse.h"

@implementation ALChannelCreateResponse  

-(instancetype)initWithJSONString:(NSString *)JSONString
{
   self = [super initWithJSONString:JSONString];
    
    if([super.status isEqualToString: RESPONSE_SUCCESS])
    {
        NSDictionary *JSONDictionary = [JSONString valueForKey:@"response"];
        self.alChannel = [[ALChannel alloc] initWithDictonary:JSONDictionary];
        
        return self;
    }
    else
    {
        return nil;
    }
    
}

@end
