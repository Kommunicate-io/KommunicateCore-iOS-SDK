//
//  ALUserBlockResponse.h
//  Kommunicate
//
//  Created by devashish on 07/03/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALAPIResponse.h"
#import "ALUserBlocked.h"

@interface ALUserBlockResponse : ALAPIResponse

@property(nonatomic, strong) NSMutableArray *blockedToUserList;
@property(nonatomic, strong) NSMutableArray *blockedByList;

@property(nonatomic, strong) NSMutableArray <ALUserBlocked *> *blockedUserList;
@property(nonatomic, strong) NSMutableArray <ALUserBlocked *> *blockByUserList;

- (instancetype)initWithJSONString:(NSString *)JSONString;

@end
