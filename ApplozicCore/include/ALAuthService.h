//
//  ALAuthService.h
//  Applozic
//
//  Created by Sunil on 11/06/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALUserDefaultsHandler.h"
#import "ALAuthClientService.h"

@interface ALAuthService : NSObject

@property (nonatomic, strong) ALAuthClientService *authClientService;

- (NSError *)decodeAndSaveToken:(NSString *)authToken;

- (void)validateAuthTokenAndRefreshWithCompletion:(void (^)(NSError * error))completion;

- (void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;

@end
