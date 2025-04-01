//
//  ALChannelFeed.h
//  Kommunicate
//
//  Created by devashish on 28/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"
#import "ALChannel.h"

@interface ALChannelFeed : ALJson

@property (nonatomic) NSMutableArray <ALChannel *> *channelFeedsList;

@property (nonatomic) NSMutableArray <ALChannel *> *conversationProxyList;

@end
