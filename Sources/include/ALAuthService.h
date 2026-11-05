//
//  ALAuthService.h
//  Kommunicate
//
//  Created by Sunil on 11/06/20.
//  Copyright © 2020 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreUserDefaultsHandler.h"
#import "ALAuthClientService.h"

FOUNDATION_EXPORT NSString *const KMCoreAuthTokenRefreshErrorDomain;

typedef NS_ENUM(NSInteger, KMCoreAuthTokenRefreshError) {
    /// The login or application changed while the refresh was in flight; the result was discarded.
    KMCoreAuthTokenRefreshErrorStaleSession = 1
};

@interface ALAuthService : NSObject

@property (nonatomic, strong) ALAuthClientService *authClientService;

- (NSError *)decodeAndSaveToken:(NSString *)authToken;

- (void)validateAuthTokenAndRefreshWithCompletion:(void (^)(NSError * error))completion;

- (void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;

@end
