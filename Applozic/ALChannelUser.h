//
//  ALChannelUser.h
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 12/8/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALJson.h"

@interface ALChannelUser : ALJson

@property NSNumber * role;
@property NSString * userId;
@property NSNumber * parentGroupKey;

-(id)initWithDictonary:(NSDictionary *)messageDictonary;
-(void)parseMessage:(id) messageJson;

@end
