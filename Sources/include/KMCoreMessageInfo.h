//
//  KMCoreMessageInfo.h
//  Kommunicate
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"

@interface KMCoreMessageInfo : KMCoreJson

@property (nonatomic, strong) NSString *userId;
@property (nonatomic) short status;

- (id)initWithDictonary:(NSDictionary *)messageDictonary;
- (void)parseMessage:(id)messageJson;

@end
