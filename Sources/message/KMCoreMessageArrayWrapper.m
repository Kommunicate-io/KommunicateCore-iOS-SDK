//
//  KMCoreMessageArrayWrapper.m
//  Kommunicate
//
//  Created by devashish on 17/12/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "KMCoreMessageArrayWrapper.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALLogger.h"

@interface KMCoreMessageArrayWrapper ()

@end

@implementation KMCoreMessageArrayWrapper

- (id)init {
    self = [super init];
    
    if (self) {
        self.messageArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableArray *)getUpdatedMessageArray {
    return self.messageArray;
}

- (void)addKMCoreMessageToMessageArray:(KMCoreMessage *)alMessage {
    if ([self getUpdatedMessageArray].count == 0) {
        KMCoreMessage *dateLabel = [self getDatePrototype:
                                NSLocalizedStringWithDefaultValue(@"today", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"")
                                   andAlMessageObject:alMessage];
        [self.messageArray addObject:dateLabel];
    } else {
        KMCoreMessage *message = [self.messageArray lastObject];
        
        if ([self checkDateOlder:message.createdAtTime andNewer:alMessage.createdAtTime]) {
            KMCoreMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:alMessage];
            [self.messageArray addObject:dateLabel];
        }
    }
    
    [self.messageArray addObject:alMessage];
}

- (void)removeKMCoreMessageFromMessageArray:(KMCoreMessage *)alMessage {
    
    KMCoreMessage *lastMessage = [self.messageArray lastObject];
    if ([lastMessage isEqual:alMessage]) {
        [self.messageArray removeObject:alMessage];
        KMCoreMessage *msg = [self.messageArray lastObject];
        if ([msg.type isEqualToString:@"100"]) {
            [self.messageArray removeObject:msg];
        }
    } else {
        int x = (int)[self.messageArray indexOfObject:alMessage];
        int length = (int)self.messageArray.count;
        if (x >= 1 && x <= length - 2) {
            KMCoreMessage *prev = [self.messageArray objectAtIndex:x - 1];
            KMCoreMessage *next = [self.messageArray objectAtIndex:x + 1];
            if ([prev.type isEqualToString:@"100"] && [next.type isEqualToString:@"100"]) {
                [self.messageArray removeObject:prev];
            }
        }
        [self.messageArray removeObject:alMessage];
    }
}

- (void)addObjectToMessageArray:(NSMutableArray *)paramMessageArray {
    
    //remove first object if it a date ..
    if ([self.messageArray firstObject]) {
        KMCoreMessage *messgae = [self.messageArray firstObject ];
        if ([messgae.type isEqualToString:@"100"]) {
            [self.messageArray removeObjectAtIndex:0];
        }
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    int countX = ((int)self.messageArray.count);
    for (int i = (int)(tempArray.count-1); i >= countX; i--) {
        //Adding last message as comparision last message is missing
        if (i == 0) {
            [self.messageArray insertObject:tempArray[i] atIndex:0];
        } else {
            KMCoreMessage * msg1 = tempArray[i - 1];
            KMCoreMessage * msg2 = tempArray[i];
            
            [self.messageArray insertObject:tempArray[i] atIndex:0];
            
            if ([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime]) {
                KMCoreMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
                [self.messageArray insertObject:dateLabel atIndex:0];
            }
        }
    }
    //final addintion of date at top ....
    KMCoreMessage *message = [self.messageArray firstObject];
    if (message) {
        NSString *dateString = [self msgAtTop:message];
        KMCoreMessage *dateLabel = [self getDatePrototype:dateString andAlMessageObject:message];
        [self.messageArray insertObject:dateLabel atIndex:0];
    }
    
    [tempArray removeAllObjects];
}

- (void)addLatestObjectToArray:(NSMutableArray *)paramMessageArray {
    
    paramMessageArray = [self filterOutDuplicateMessage:paramMessageArray];
    if (!paramMessageArray.count) {
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.messageArray];
    [tempArray addObjectsFromArray:paramMessageArray];
    
    
    if (tempArray.count == 1) {
        
        self.dateCellText = NSLocalizedStringWithDefaultValue(@"today", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
        
        KMCoreMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[0]];
        
        [self.messageArray addObject:dateLabel];
        [self.messageArray addObject:tempArray[0]];
        [tempArray removeAllObjects];
        return;
    }
    
    int countX  =((int)self.messageArray.count==0)?1:((int)self.messageArray.count);
    for (int i = countX-1 ; i  < (tempArray.count-1) ; i++) {
        
        if (i == 0) {
            [self.messageArray addObject:tempArray[0]];
        } else {
            KMCoreMessage * msg1 = tempArray[i];
            KMCoreMessage * msg2 = tempArray[i+1];
            if ([self checkDateOlder:msg1.createdAtTime andNewer:msg2.createdAtTime]) {
                KMCoreMessage *dateLabel = [self getDatePrototype:self.dateCellText andAlMessageObject:tempArray[i]];
                [self.messageArray addObject:dateLabel];
            }
            [self.messageArray addObject:tempArray[i+1]];
        }
    }
    
    [tempArray removeAllObjects];
}

- (KMCoreMessage *)getDatePrototype:(NSString *)messageText andAlMessageObject:(KMCoreMessage *)almessage {
    KMCoreMessage *dateLabel = [[KMCoreMessage alloc] init];
    dateLabel.createdAtTime = almessage.createdAtTime;
    dateLabel.message = messageText;
    dateLabel.type = @"100";
    dateLabel.contactIds = almessage.contactIds;
    dateLabel.fileMeta.thumbnailUrl = nil;
    dateLabel.groupId = almessage.groupId;
    return dateLabel;
}

- (void)removeObjectFromMessageArray:(NSMutableArray *)paramMessageArray {
    [self.messageArray removeObject:paramMessageArray];
}

- (BOOL)checkDateOlder:(NSNumber *)older andNewer:(NSNumber *)newer {
    double old = [older doubleValue];
    double new = [newer doubleValue];
    
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDate *newerDate = [[NSDate alloc] initWithTimeIntervalSince1970:(new/1000)];
    
    NSDate *current = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *todayDate = [format stringFromDate:current];
    NSString *newerDateString = [format stringFromDate:newerDate];
    NSString *olderDateString = [format stringFromDate:olderDate];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdayDate = [format stringFromDate:yesterday];
    
    if ([newerDateString isEqualToString:olderDateString]) {
        return NO;
    } else {
        if ([newerDateString isEqualToString:todayDate]) {
            self.dateCellText = NSLocalizedStringWithDefaultValue(@"today", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
            
        } else if([newerDateString isEqualToString:yesterdayDate]) {
            self.dateCellText = NSLocalizedStringWithDefaultValue(@"yesterday", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Yesterday", @"");
        } else {
            [format setDateFormat:@"EEEE MMM dd,yyyy"];
            self.dateCellText = [format stringFromDate:newerDate];
        }
        return YES;
    }
}

- (NSString *)msgAtTop:(KMCoreMessage *)almessage {
    double old = [almessage.createdAtTime doubleValue];
    NSDate *olderDate = [[NSDate alloc] initWithTimeIntervalSince1970:(old/1000)];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *string = [format stringFromDate:olderDate];
    
    NSDate *current = [[NSDate alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *todaydate = [format stringFromDate:current];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    NSString *yesterdayDate = [format stringFromDate:yesterday];
    NSString *actualDate = @"";
    
    if ([string isEqualToString:todaydate]) {
        actualDate = NSLocalizedStringWithDefaultValue(@"today", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Today", @"");
    } else if ([string isEqualToString:yesterdayDate]) {
        actualDate = NSLocalizedStringWithDefaultValue(@"yesterday", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Yesterday", @"");
    } else {
        [format setDateFormat:@"EEEE MMM dd,yyyy"];
        actualDate = [format stringFromDate:olderDate];
    }
    
    return actualDate;
}

- (NSMutableArray*)filterOutDuplicateMessage:(NSMutableArray*)newMessageArray {
    
    KMCoreMessage *firstInNewMessage = [newMessageArray objectAtIndex:0];
    
    if (self.messageArray.count <=0) {
        return newMessageArray;
    }
    if (firstInNewMessage.createdAtTime > [KMCoreUserDefaultsHandler getLastSyncTime]) {
        return newMessageArray;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:newMessageArray];
    
    int count = (int)self.messageArray.count;
    for (KMCoreMessage *message in tempArray) {
        
        for (int i = count-1 ; i  > 0 ; i--) {
            KMCoreMessage * oldMessage = [self.messageArray objectAtIndex:i];
            if ([oldMessage.key isEqualToString:message.key]) {
                ALSLog(ALLoggerSeverityInfo, @"removing duplicate object found....");
                [newMessageArray removeObject:message];
            } else if (message.createdAtTime  > oldMessage.createdAtTime) {
                return newMessageArray;
            }
        }
    }
    return newMessageArray;
}

@end
