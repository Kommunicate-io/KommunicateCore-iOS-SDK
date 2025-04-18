//
//  ALLastSeenSyncFeed.m
//  Kommunicate
//
//  Created by Devashish on 19/12/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "ALLastSeenSyncFeed.h"

@implementation ALLastSeenSyncFeed

- (instancetype)initWithJSONString:(NSString *)serverResponse {
    NSMutableArray *lastSeenDetailArray = [serverResponse valueForKey:@"response"];
    [self populateLastSeenDetail:lastSeenDetailArray];
    return self;
}

- (void)populateLastSeenDetail:(NSMutableArray *)lastSeenDetailArray {
    NSMutableArray *listArray = [NSMutableArray new];
    for (NSDictionary *userDetailDictionary in lastSeenDetailArray) {
        KMCoreUserDetail *userLastSeenDetail = [[KMCoreUserDetail alloc] initWithDictonary:userDetailDictionary];
        [listArray addObject:userLastSeenDetail];
    }
    self.lastSeenArray = listArray;
}

@end
