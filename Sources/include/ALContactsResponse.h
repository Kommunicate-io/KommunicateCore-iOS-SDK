//
//  ALContactsResponse.h
//  Kommunicate
//
//  Created by devashish on 25/04/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreJson.h"

@interface ALContactsResponse : KMCoreJson

@property (nonatomic, strong) NSNumber *lastFetchTime;
@property (nonatomic, strong) NSNumber *totalUnreadCount;

@property (nonatomic, strong) NSMutableArray *userDetailList;

@end
