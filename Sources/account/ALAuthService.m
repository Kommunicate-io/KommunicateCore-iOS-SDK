//
//  ALAuthService.m
//  Applozic
//
//  Created by Sunil on 11/06/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
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
        NSError *error = [NSError errorWithDomain:@"Applozic"
                                              code:1
                                          userInfo:@{NSLocalizedDescriptionKey : @"AuthToken is nil"}];
        return error;
    }

    [ALUserDefaultsHandler setAuthToken:authToken];

    ALJWT *jwt = [ALJWT decodeWithJwt:authToken error:&jwtError];

    if (!jwtError && jwt.body) {
        NSDictionary *jwtBody = jwt.body;
        NSNumber *createdAtTime = [jwtBody objectForKey:CREATED_TIME];
        NSNumber *validUptoInMins = [jwtBody objectForKey:VALID_UPTO];

        if (createdAtTime != nil) {
            [ALUserDefaultsHandler setAuthTokenCreatedAtTime:createdAtTime];
        }

        if (validUptoInMins != nil) {
            [ALUserDefaultsHandler setAuthTokenValidUptoInMins:validUptoInMins];
        }
    }
    return jwtError;
}

- (BOOL)isAuthTokenValid {

    NSNumber *authTokenCreatedAtTime = [ALUserDefaultsHandler getAuthTokenCreatedAtTime];
    NSNumber *authTokenValidUptoMins = [ALUserDefaultsHandler getAuthTokenValidUptoMins];

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
    [self.authClientService refreshAuthTokenForLoginUserWithCompletion:^(ALAPIResponse *apiResponse, NSError *error) {
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
