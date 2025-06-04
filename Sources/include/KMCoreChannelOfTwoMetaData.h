//
//  KMCoreChannelOfTwoMetaData.h
//  Kommunicate
//
//  Created by Mihir on 02/05/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMCoreChannelOfTwoMetaData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *link;
- (NSMutableDictionary *)toDict:(KMCoreChannelOfTwoMetaData *)metadata;
@end
