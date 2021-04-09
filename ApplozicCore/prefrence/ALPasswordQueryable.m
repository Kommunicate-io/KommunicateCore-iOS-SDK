//
//  ALPasswordQueryable.m
//  ApplozicCore
//
//  Created by Sunil on 11/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALPasswordQueryable.h"

@implementation ALPasswordQueryable

- (instancetype)initWithService:(NSString *)service {
    self.serviceString = service;
    return self;
}

- (NSMutableDictionary<NSString *,id> *)query {
    NSMutableDictionary<NSString *, id> *query =  [[NSMutableDictionary alloc] init];
    query[(__bridge NSString *)kSecClass] = (__bridge NSString *)kSecClassGenericPassword;
    query[(__bridge NSString *)kSecAttrService] = self.serviceString;
    return query;
}

@end
