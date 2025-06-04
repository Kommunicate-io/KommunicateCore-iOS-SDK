//
//  KMCoreMessageArrayWrapper.h
//  Kommunicate
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreMessage.h"
#import "KMCoreSettings.h"

@interface KMCoreMessageArrayWrapper : NSObject

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSString *dateCellText;

- (BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer;

- (NSMutableArray *)getUpdatedMessageArray;

- (void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray;

- (void)addKMCoreMessageToMessageArray:(KMCoreMessage *)alMessage;

- (void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray;

- (void)removeKMCoreMessageFromMessageArray:(KMCoreMessage *)alMessage;

- (void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray;

- (KMCoreMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(KMCoreMessage *)almessage;

- (NSString *)msgAtTop:(KMCoreMessage *)almessage;

@end
