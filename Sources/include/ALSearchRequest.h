//
//  ALSearchRequest.h
//  Kommunicate
//
//  Created by apple on 05/09/19.
//  Copyright © 2019 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ALSearchRequest : NSObject

@property(nonatomic,retain) NSNumber *channelKey;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSNumber *groupType;
@property(nonatomic,retain) NSString *searchText;

- (NSString*)getParamString;

@end
