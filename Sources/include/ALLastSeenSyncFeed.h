//
//  ALLastSeenSyncFeed.h
//  Kommunicate
//
//  Created by Devashish on 19/12/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreUserDetail.h"
#import "ALJson.h"

@interface ALLastSeenSyncFeed : ALJson

@property(nonatomic) NSMutableArray <KMCoreUserDetail *> *lastSeenArray;

- (instancetype)initWithJSONString:(NSString *)lastSeenResponse;

- (void)populateLastSeenDetail:(NSMutableArray *)jsonString;

@end
