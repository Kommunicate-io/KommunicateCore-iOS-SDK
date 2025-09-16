//
//  KMCoreMessageInfoResponse.h
//  Kommunicate
//
//  Created by devashish on 17/03/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "KMCoreMessageInfo.h"
#import "ALAPIResponse.h"

@interface KMCoreMessageInfoResponse : ALAPIResponse

@property(nonatomic, strong) NSMutableArray <KMCoreMessageInfo *> *msgInfoList;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end
