//
//  ALUserDetailListFeed.h
//  Kommunicate
//
//  Created by Abhishek Thapliyal on 10/13/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "ALJson.h"

@interface ALUserDetailListFeed : ALJson

@property (nonatomic, strong) NSMutableArray *userIdList;

@property (nonatomic) BOOL contactSync;

- (void)setArray:(NSMutableArray *)array;

@end
