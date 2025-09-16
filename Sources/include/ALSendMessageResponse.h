//
//  ALSendMessageResponse.h
//  Kommunicate
//
//  Created by Devashish on 06/11/15.
//  Copyright © 2015 kommunicate. All rights reserved.
//

/*
 
 {"messageKey":"28c47e68-e6a3-4a6d-b0db-4658d6e0aa18","createdAt":1446820801594}
 */
#import <Foundation/Foundation.h>
#import "KMCoreJson.h"

@interface ALSendMessageResponse : KMCoreJson

@property (nonatomic, copy) NSString *messageKey;

@property (nonatomic, copy) NSNumber *createdAt;

@property (nonatomic, copy) NSNumber *conversationId;

- (BOOL)isSuccess;

@end
