//
//  ALSecureStore.m
//  ApplozicCore
//
//  Created by Sunil on 11/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALSecureStore.h"
#import <Security/Security.h>

@implementation ALSecureStore

- (nonnull instancetype)initWithSecureStoreQueryable:(id <ALSecureStoreQueryable> _Nonnull)secureStoreQueryable {
    self.secureStoreQueryable = secureStoreQueryable;
    return self;
}

- (BOOL)setValue:(NSString * _Nonnull)value
  forUserAccount:(NSString * _Nonnull)userAccount
           error:(NSError * _Nullable * _Nullable)error {

    NSData *encodedData = [value dataUsingEncoding:NSUTF8StringEncoding];

    if (!encodedData) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"Applozic"
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey : @"String to Data conversion error"}];
        }
        return NO;
    }

    NSMutableDictionary<NSString *, id> *query =  self.secureStoreQueryable.query;
    query[(__bridge NSString *)kSecAttrAccount] = userAccount;

    OSStatus status =
    SecItemCopyMatching((__bridge CFDictionaryRef)query, nil);

    if (status == errSecSuccess) {
        NSMutableDictionary <NSString *, id> *attributesToUpdate = [[NSMutableDictionary alloc] init];
        attributesToUpdate[(__bridge NSString *)kSecValueData] = encodedData;
        status =
        SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
        if (status !=  errSecSuccess) {
            [self setErrorMessage:status withError:error];
            return NO;
        }
        return YES;
    } else if (status == errSecItemNotFound) {
        [query setValue:encodedData
                 forKey:(__bridge NSString *)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)query, nil);

        if (status !=  errSecSuccess) {
            [self setErrorMessage:status withError:error];
            return NO;
        }
        return YES;
    }
    [self setErrorMessage:status withError:error];
    return NO;
}

- (NSString * _Nullable)getValueFor:(NSString * _Nonnull)userAccount
                              error:(NSError * _Nullable * _Nullable)error {

    NSMutableDictionary <NSString *, id> *query =  self.secureStoreQueryable.query;
    query[(__bridge NSString *)kSecMatchLimit] = (__bridge NSString *)kSecMatchLimitOne;
    query[(__bridge NSString *)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    query[(__bridge NSString *)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge NSString *)kSecAttrAccount] = userAccount;

    CFDictionaryRef cfDictionary = nil;

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&cfDictionary);

    if (status == errSecSuccess) {
        NSDictionary<NSString *, id> *queriedItem = (__bridge NSDictionary *)cfDictionary;

        NSData * encodedData = [queriedItem objectForKey:(__bridge NSString *)kSecValueData];

        NSString* decodedPassword = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
        return decodedPassword;
    }
    [self setErrorMessage:status withError:error];
    return nil;
}

- (BOOL)removeValueFor:(NSString * _Nonnull)userAccount error:(NSError * _Nullable * _Nullable)error {

    NSMutableDictionary<NSString *, id> *query =  self.secureStoreQueryable.query;
    query[(__bridge NSString *)kSecAttrAccount] = userAccount;
    OSStatus status =
    SecItemDelete((__bridge CFDictionaryRef)query);

    if (status == errSecSuccess || status == errSecItemNotFound) {
        return YES;
    }

    [self setErrorMessage:status withError:error];
    return NO;
}

- (BOOL)removeAllValuesAndReturnError:(NSError * _Nullable * _Nullable)error {

    NSMutableDictionary<NSString *, id> *query =  self.secureStoreQueryable.query;
    OSStatus status =
    SecItemDelete((__bridge CFDictionaryRef)query);

    if (status == errSecSuccess || status == errSecItemNotFound) {
        return YES;
    }
    [self setErrorMessage:status withError:error];
    return NO;
}


-(BOOL)setErrorMessage:(OSStatus)status
             withError:(NSError **)error {
    BOOL success = NO;
    NSString *errorMessage = nil;
    if (@available(iOS 11.3, *)) {
        CFStringRef errorMessageRef = SecCopyErrorMessageString(status, nil);
        if (errorMessageRef != NULL) {
            errorMessage = (__bridge_transfer NSString *)errorMessageRef;
        } else {
            errorMessage  = [[NSString alloc] initWithFormat:@"Unhandled Error with status %d" ,(int)status];
        }
    } else {
        errorMessage  = [[NSString alloc] initWithFormat:@"Unhandled Error with status %d" ,(int)status];
    }

    if (errorMessage) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"Applozic"
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        }
    }
    return success;
}

@end
