//
//  ALAuthService.m
//  Kommunicate
//
//  Created by Sunil on 11/06/20.
//  Copyright © 2020 kommunicate. All rights reserved.
//

#import "ALAuthService.h"
#import "ALAuthClientService.h"
#import "ALJWT.h"

@implementation ALAuthService

static NSString *const CREATED_TIME = @"createdAtTime";
static NSString *const VALID_UPTO = @"validUpto";

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupService];
    }
    return self;
}

-(void)setupService {
    self.authClientService = [[ALAuthClientService alloc] init];
}

- (NSError *)decodeAndSaveToken:(NSString *)authToken {
    NSError *jwtError;
    if (!authToken) {
        NSError *error = [NSError errorWithDomain:@"KMCore"
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey : @"AuthToken is nil"}];
        return error;
    }

    [KMCoreUserDefaultsHandler setAuthToken:authToken];

    ALJWT *jwt = [ALJWT decodeWithJwt:authToken error:&jwtError];

    if (!jwtError && jwt.body) {
        NSDictionary *jwtBody = jwt.body;
        NSNumber *createdAtTime = [jwtBody objectForKey:CREATED_TIME];
        NSNumber *validUptoInMins = [jwtBody objectForKey:VALID_UPTO];

        if (createdAtTime != nil) {
            [KMCoreUserDefaultsHandler setAuthTokenCreatedAtTime:createdAtTime];
        }

        if (validUptoInMins != nil) {
            [KMCoreUserDefaultsHandler setAuthTokenValidUptoInMins:validUptoInMins];
        }
    }
    return jwtError;
}

- (BOOL)isAuthTokenValid {

    NSNumber *authTokenCreatedAtTime = [KMCoreUserDefaultsHandler getAuthTokenCreatedAtTime];
    NSNumber *authTokenValidUptoMins = [KMCoreUserDefaultsHandler getAuthTokenValidUptoMins];

    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970] * 1000;

    BOOL hasValidAuthTokenTime = authTokenCreatedAtTime != nil && authTokenCreatedAtTime.integerValue > 0;

    BOOL hasValidUptoTokenTime = authTokenValidUptoMins != nil && authTokenValidUptoMins.integerValue > 0;

    return hasValidAuthTokenTime && hasValidUptoTokenTime && (timeInSeconds - authTokenCreatedAtTime.doubleValue) / 60000 < authTokenValidUptoMins.doubleValue;
}

- (void)validateAuthTokenAndRefreshWithCompletion:(void (^)(NSError * error))completion {
    if([self isAuthTokenValid]) {
        completion(nil);
        return;
    } else {
        [self refreshAuthTokenForLoginUserWithCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
            if (error) {
                completion(error);
                return;
            }
            completion(nil);
            return;
        }];
    }
}

- (void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {
    NSString *requestedUserId = [KMCoreUserDefaultsHandler getUserId];
    NSString *requestedApplicationKey = [KMCoreUserDefaultsHandler getApplicationKey];
    [self.authClientService refreshAuthTokenForLoginUserWithCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
        // The login or application changed while the request was in flight; that result, success or
        // failure, belongs to a previous session and must not be saved or reported as current.
        if (![KMCoreUserDefaultsHandler isLoggedIn] ||
            ![[KMCoreUserDefaultsHandler getUserId] isEqualToString:requestedUserId] ||
            ![[KMCoreUserDefaultsHandler getApplicationKey] isEqualToString:requestedApplicationKey]) {
            completion(nil, [NSError errorWithDomain:@"KMCore"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey : @"Auth token refresh result is for a different session"}]);
            return;
        }
        if (error) {
            completion(nil, error);
            return;
        }
        NSError *authTokenError = nil;
        if ([apiResponse.response isKindOfClass:[NSString class]]) {
            authTokenError = [self decodeAndSaveToken:(NSString *)apiResponse.response];
        }
        completion(apiResponse, authTokenError);
    }];
}

@end
