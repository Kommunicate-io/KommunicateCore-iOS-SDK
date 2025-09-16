//
//  ALSearchResultCache.h
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 02/07/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreChannel.h"
#import "ALContact.h"
#import "KMCoreUserDetail.h"

@interface ALSearchResultCache : NSObject

+ (ALSearchResultCache *)shared;

- (void)saveChannels:(NSMutableArray<KMCoreChannel *> *)channels;
- (void)saveUserDetails:(NSMutableArray<KMCoreUserDetail *> *)userDetails;

- (KMCoreChannel *)getChannelWithId:(NSNumber *)key;
- (ALContact *)getContactWithId:(NSString *)key;

@end
