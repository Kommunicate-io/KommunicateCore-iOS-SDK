//
//  ALChannelOfTwoMetaData.m
//  Kommunicate
//
//  Created by Mihir on 02/05/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//

#import "ALChannelOfTwoMetaData.h"

@implementation ALChannelOfTwoMetaData

- (NSMutableDictionary *)toDict:(ALChannelOfTwoMetaData *)metadata {
    NSMutableDictionary *metaData = [NSMutableDictionary new];
    [metaData setObject:metadata.title forKey:@"title"];
    [metaData setObject:metadata.price forKey:@"price"];
    [metaData setObject:metadata.link forKey:@"link"];
    return metaData;
}
@end
