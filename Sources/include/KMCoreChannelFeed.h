//
//  KMCoreChannelFeed.h
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"
#import "KMCoreChannel.h"

@interface KMCoreChannelFeed : KMCoreJson

@property (nonatomic) NSMutableArray <KMCoreChannel *> *channelFeedsList;

@property (nonatomic) NSMutableArray <KMCoreChannel *> *conversationProxyList;

@end
