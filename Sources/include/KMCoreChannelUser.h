//
//  KMCoreChannelUser.h
//  Kommunicate
//
//  Created by Adarsh Kumar Mishra on 12/8/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALJson.h"

@interface KMCoreChannelUser : ALJson

@property (nonatomic, strong) NSNumber *role;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *parentGroupKey;

- (id)initWithDictonary:(NSDictionary *)messageDictonary;
- (void)parseMessage:(id)messageJson;

@end
