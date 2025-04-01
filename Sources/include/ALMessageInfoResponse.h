//
//  ALMessageInfoResponse.h
//  Kommunicate
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALMessageInfo.h"
#import "ALAPIResponse.h"

@interface ALMessageInfoResponse : ALAPIResponse

@property(nonatomic, strong) NSMutableArray <ALMessageInfo *> *msgInfoList;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end
