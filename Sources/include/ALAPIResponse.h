//
//  ALAPIResponse.h
//  Kommunicate
//
//  Created by devashish on 19/01/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

extern NSString *const AL_RESPONSE_SUCCESS;
extern NSString *const AL_RESPONSE_ERROR;

@interface ALAPIResponse : ALJson

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *generatedAt;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSString *actualresponse;

@end
