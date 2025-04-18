//
//  ALAuthClientService.h
//  Kommunicate
//
//  Created by Sunil on 15/06/20.
//  Copyright © 2020 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAPIResponse.h"

@interface ALAuthClientService : NSObject
- (void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion;
@end
