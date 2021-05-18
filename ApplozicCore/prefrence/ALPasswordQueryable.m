//
//  ALPasswordQueryable.m
//  ApplozicCore
//
//  Created by Sunil on 11/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALPasswordQueryable.h"
#import "ALApplozicSettings.h"

NSString * const AL_KEYCHAIN_GROUPS_ACCESS_KEY = @"ALKeychainGroupsKey";

@implementation ALPasswordQueryable

- (instancetype)initWithService:(NSString *)service {
    self.serviceString = service;
    self.appKeychainAcessGroup = [self getKeychainAcessGroupsName];
    return self;
}

- (NSMutableDictionary<NSString *,id> *)query {
    NSMutableDictionary<NSString *, id> *query =  [[NSMutableDictionary alloc] init];
    query[(__bridge NSString *)kSecClass] = (__bridge NSString *)kSecClassGenericPassword;
    if (self.appKeychainAcessGroup
        && self.appKeychainAcessGroup.length > 0) {
        query[(__bridge NSString *)kSecAttrAccessGroup] = self.appKeychainAcessGroup;
    }
    query[(__bridge NSString *)kSecAttrService] = self.serviceString;
    return query;
}

-(NSString *)getKeychainAcessGroupsName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:AL_KEYCHAIN_GROUPS_ACCESS_KEY];
}
@end
