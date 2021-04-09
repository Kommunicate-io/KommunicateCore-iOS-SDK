//
//  ALPasswordQueryable.h
//  ApplozicCore
//
//  Created by apple on 11/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSecureStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALPasswordQueryable : NSObject <ALSecureStoreQueryable>

- (nonnull instancetype)init NS_UNAVAILABLE;

- (nonnull instancetype)initWithService:(NSString * _Nonnull)service;
@property (nonatomic) NSString *serviceString;

@property (nonatomic, readonly, copy) NSMutableDictionary<NSString *, id> * _Nonnull query;

@end

NS_ASSUME_NONNULL_END
