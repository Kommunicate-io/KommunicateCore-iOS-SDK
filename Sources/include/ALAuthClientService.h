//
//  ALAuthClientService.h
//  Kommunicate
//
//  Created by Sunil on 15/06/20.
//  Copyright © 2020 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"

FOUNDATION_EXPORT NSString *const KMCoreAuthTokenRefreshErrorDomain;

typedef NS_ENUM(NSInteger, KMCoreAuthTokenRefreshError) {
    /// The server rejected the refresh with HTTP 401.
    KMCoreAuthTokenRefreshErrorUnauthorized = 1,
    /// The login or application changed while the refresh was in flight; the result was discarded.
    KMCoreAuthTokenRefreshErrorStaleSession
};

@interface ALAuthClientService : NSObject
- (void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;
@end
