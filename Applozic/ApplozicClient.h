//
//  ApplozicClient.h
//  Applozic
//
//  Created by Sunil on 12/03/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import "Applozic.h"
#import <Foundation/Foundation.h>


@protocol ApplozicAttachmentDelegate <NSObject>

-(void)onUpdateBytesDownloaded:(NSUInteger) bytesReceived;
-(void)onUpdateBytesUploaded:(NSUInteger) bytesSent;
-(void)onUploadFailed:(ALMessage*)alMessage;
-(void)onDownloadFailed:(ALMessage*)alMessage;
-(void)onUploadCompleted:(ALMessage *) alMessage;
-(void)onDownloadCompleted:(ALMessage *) alMessage;

@optional

@end

@interface ApplozicClient : NSObject  <NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<ApplozicAttachmentDelegate>attachmentProgressDelegate;

-(instancetype)initWithApplicationKey:(NSString *)applicationKey;

-(instancetype)initWithApplicationKey:(NSString *)applicationKey withDelegate:(id<ApplozicUpdatesDelegate>) delegate;

-(void)loginUser:(ALUser *)alUser withCompletion:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion;

-(void)updateApnDeviceTokenWithCompletion:(NSString *)apnDeviceToken withCompletion:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion;

-(void)sendMessageWithAttachment:(ALMessage*) attachmentMessage;

-(void)sendTextMessage:(ALMessage*) alMessage withCompletion:(void(^)(ALMessage *message, NSError *error))completion;

-(void) getLatestMessages:(BOOL)isNextPage withCompletionHandler: (void(^)(NSMutableArray * messageList, NSError *error)) completion;

-(void) getMessages:(MessageListRequest *)messageListRequest withCompletionHandler: (void(^)(NSMutableArray * messageList, NSError *error)) completion;

-(void) downloadMessageAttachment:(ALMessage*)alMessage;

-(void) creataChannelWithName:(NSString *)channelName orClientChannelKey:(NSString *)clientChannelKey
         andMembersUserIdList:(NSMutableArray *)memberUserIdArray andImageLink:(NSString *)imageLink channelType:(short)type
                  andMetaData:(NSMutableDictionary *)metaData adminUser:(NSString *)adminUserId withGroupUsers : (NSMutableArray*) groupRoleUsers withCompletion:(void(^)(ALChannel *alChannel, NSError *error))completion;

-(void) removeMemberFromChannelWithUserId:userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;


-(void) leaveMemberFromChannelWithUserId:userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void) addMemberToChannelWithUserId:userId andChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *)clientChannelKey withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void)updateChannelWithChannelKey:(NSNumber *)channelKey andNewName:(NSString *)newName andImageURL:(NSString *)imageURL orClientChannelKey:(NSString *)clientChannelKey
                isUpdatingMetaData:(BOOL)flag metadata:(NSMutableDictionary *)metaData orChannelUsers:(NSMutableArray *)channelUsers withCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void)getChannelInformationWithChannelKey:(NSNumber *)channelKey orClientChannelKey:(NSString *) clientChannelKey withCompletion:(void(^)(NSError *error, ALChannel *alChannel, AlChannelFeedResponse *channelResponse))completion;

-(void)logoutUserWithCompletion:(void(^)(NSError *error, ALAPIResponse *response))completion;

-(void)muteChannelOrUnMuteWithChannelKey:(NSNumber *)channelKey andTime:(NSNumber *)notificationTime withCompletion:(void(^)(ALAPIResponse *response, NSError *error))completion;

-(void)unBlockUserWithUserId:(NSString *)userId withCompletion:(void(^)(NSError *error, BOOL userUnblock))completion;

-(void)blockUserWithUserId:(NSString *)userId withCompletion:(void(^)(NSError *error, BOOL userBlock))completion;

-(void)markConversationReadForGroup:(NSNumber *) groupId withCompletion:(void(^)(NSString *response, NSError *error)) completion;

-(void)markConversationReadForOnetoOne:(NSString*) userId withCompletion:(void(^)(NSString *response, NSError *error)) completion;

-(void)notificationArrivedToApplication:(UIApplication*)application withDictionary:(NSDictionary *)userInfo;

-(void)subscribeToConversation;

-(void)unsubscribeToConversation;

-(void)unSubscribeToTypingStatusForChannel:(NSNumber *)chanelKey;

-(void)unSubscribeToTypingStatusForOneToOne;

-(void)sendTypingStatusForUserId:(NSString *)userId orForGroupId:(NSNumber*)channelKey withTyping:(BOOL) isTyping;

-(void)subscribeToTypingStatusForOneToOne;

-(void)subscribeToTypingStatusForChannel:(NSNumber *) channelKey;


@end
