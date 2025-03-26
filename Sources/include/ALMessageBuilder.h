//
//  ALMessageBuilder.h
//  Kommunicate
//
//  Created by apple on 04/07/18.
//  Copyright © 2018 kommunicate. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ALMessageBuilder : NSObject

@property (nonatomic, copy) NSString *to;

@property (nonatomic, copy) NSString *message;

@property(nonatomic) short contentType;

@property (nonatomic, copy) NSNumber *groupId;

@property(nonatomic,copy) NSNumber *conversationId;

@property (nonatomic,retain) NSMutableDictionary *metadata;

@property (nonatomic, copy) NSString *imageFilePath;

@end
