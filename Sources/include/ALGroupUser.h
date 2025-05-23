//
//  ALGroupUser.h
//  Kommunicate
//
//  Created by Sunil on 14/02/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//
#import "KMCoreJson.h"
#import <Foundation/Foundation.h>

@interface ALGroupUser : KMCoreJson

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *groupRole;
    
- (id)initWithDictonary:(NSDictionary *)messageDictonary;

@end
