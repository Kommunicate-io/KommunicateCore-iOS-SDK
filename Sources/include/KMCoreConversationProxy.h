//
//  KMCoreConversationProxy.h
//  Kommunicate
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreJson.h"
#import "ALTopicDetail.h"
#import "DB_ConversationProxy.h"

@interface KMCoreConversationProxy : KMCoreJson

@property (nonatomic, strong) NSNumber *Id;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *topicDetailJson;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSArray *supportIds;
@property (nonatomic, strong) NSMutableArray *fallBackTemplatesListArray;
@property (nonatomic, strong) NSMutableDictionary *fallBackTemplateForSENDER;
@property (nonatomic, strong) NSMutableDictionary *fallBackTemplateForRECEIVER;
@property (nonatomic) BOOL created;
@property (nonatomic) BOOL closed;

- (void)parseMessage:(id)messageJson;
- (id)initWithDictonary:(NSDictionary *)messageDictonary;
- (ALTopicDetail *)getTopicDetail;
+ (NSMutableDictionary *)getDictionaryForCreate:(KMCoreConversationProxy *)conversationProxy;
- (void)setSenderSMSFormat:(NSString *)senderFormatString;
- (void)setReceiverSMSFormat:(NSString *)recieverFormatString;

@end
