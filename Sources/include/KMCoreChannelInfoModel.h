//
//  KMCoreChannelInfoModel.h
//  Kommunicate
//
//  Created by Nitin on 21/10/17.
//  Copyright © 2017 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"
#import "KMCoreChannelResponse.h"

@interface KMCoreChannelInfoModel : KMCoreJson

@property (nonatomic, strong)  NSDictionary *channel;

@property (nonatomic, strong) NSMutableArray *groupMemberList;


@end
