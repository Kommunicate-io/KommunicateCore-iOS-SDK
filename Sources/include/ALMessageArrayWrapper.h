//
//  ALMessageArrayWrapper.h
//  Kommunicate
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "KMCoreSettings.h"

@interface ALMessageArrayWrapper : NSObject

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSString *dateCellText;

- (BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer;

- (NSMutableArray *)getUpdatedMessageArray;

- (void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray;

- (void)addALMessageToMessageArray:(ALMessage *)alMessage;

- (void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray;

- (void)removeALMessageFromMessageArray:(ALMessage *)alMessage;

- (void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray;

- (ALMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(ALMessage *)almessage;

- (NSString *)msgAtTop:(ALMessage *)almessage;

@end
