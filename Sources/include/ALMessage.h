//
//  ALMessage.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>
#import "ALJson.h"
#import "ALFileMetaInfo.h"
#import "KMCoreSettings.h"
#import "ALMessageBuilder.h"
#import "ALConstant.h"

static int const ALMESSAGE_CONTENT_DEFAULT = 0;
static int const ALMESSAGE_CONTENT_ATTACHMENT = 1;
static int const ALMESSAGE_CONTENT_LOCATION = 2;
static int const ALMESSAGE_CONTENT_TEXT_HTML = 3;
static int const ALMESSAGE_CONTENT_PRICE = 4;
static int const ALMESSAGE_CONTENT_TEXT_URL = 5;
static int const ALMESSAGE_CONTENT_VCARD = 7;
static int const ALMESSAGE_CONTENT_AUDIO = 8;
static int const ALMESSAGE_CONTENT_CAMERA_RECORDING = 9;
static int const ALMESSAGE_CHANNEL_NOTIFICATION = 10;
static int const ALMESSAGE_CONTENT_CUSTOM = 101;
static int const ALMESSAGE_CONTENT_HIDDEN = 11;
static int const ALMESSAGE_CONTENT_INITIAL_STATIC_MESSAGE = 102;
static int const ALMESSAGE_CONTENT_TYPING_INDICATOR = 111;

static NSString *const AL_CATEGORY_PUSHNNOTIFICATION = @"PUSHNOTIFICATION";
static NSString *const AL_CATEGORY_HIDDEN = @"HIDDEN";
static NSString *const AL_MESSAGE_REPLY_KEY = @"AL_REPLY";
static NSString *const AL_OUT_BOX = @"5";
static NSString *const AL_IN_BOX = @"4";
static NSString * const AL_RESET_UNREAD_COUNT = @"AL_RESET_UNREAD_COUNT";
static NSString *const AUTO_SUGGESTION_TYPE_MESSAGE = @"KM_AUTO_SUGGESTION";

typedef enum {
    AL_NOT_A_REPLY,
    AL_A_REPLY,
    AL_REPLY_BUT_HIDDEN,
}ALReplyType;


@interface ALMessage : ALJson

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *deviceKey;

@property (nonatomic, copy) NSString *userKey;

@property (nonatomic, copy) NSString *to;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) BOOL sendToDevice;

@property (nonatomic, assign) BOOL shared;

@property (nonatomic, copy) NSNumber *createdAtTime;

@property (nonatomic, copy) NSString *type;

@property (nonatomic) short source;

@property (nonatomic, copy) NSString *contactIds;

@property (nonatomic, assign) BOOL storeOnDevice;

@property (nonatomic,retain) ALFileMetaInfo *fileMeta;

@property (nonatomic,retain) NSString *imageFilePath;

@property (nonatomic,assign) BOOL inProgress;

@property (nonatomic, strong) NSString *fileMetaKey;

@property (nonatomic, assign) BOOL isUploadFailed;

@property (nonatomic,assign) BOOL delivered;

@property(nonatomic,assign)BOOL sentToServer;

@property(nonatomic,copy) NSManagedObjectID *msgDBObjectId;

@property(nonatomic,copy) NSString *pairedMessageKey;

@property(nonatomic,assign) long messageId;

@property(nonatomic,retain)NSString *applicationId;

@property(nonatomic) short contentType;

@property (nonatomic, copy) NSNumber *groupId;

@property(nonatomic,copy) NSNumber *conversationId;

@property (nonatomic, copy) NSNumber *status;

@property (nonatomic,retain) NSMutableDictionary *metadata;

@property (nonatomic,copy) NSNumber *messageReplyType;

@property (nonatomic,assign) BOOL deleted;

@property (nonatomic, assign) BOOL msgHidden;

@property (nonatomic, copy) NSString *autoSuggestionData;

- (NSString *)getCreatedAtTime:(BOOL)today;
- (id)initWithDictonary:(NSDictionary *)messageDictonary;
- (BOOL)isDownloadRequired;
- (BOOL)isUploadRequire;
- (BOOL)isHiddenMessage;
- (BOOL)isVOIPNotificationMessage;
- (NSString *)getCreatedAtTimeChat:(BOOL)today;
- (NSNumber *)getGroupId;
- (NSString *)getLastMessage;
- (NSMutableDictionary *)getMetaDataDictionary:(NSString *)string;
- (NSString *)getVOIPMessageText;
- (BOOL)isMsgHidden;
- (BOOL)isPushNotificationMessage;
- (BOOL)isMessageCategoryHidden;
- (ALReplyType)getReplyType;
- (BOOL)isToIgnoreUnreadCountIncrement;
- (BOOL)isAReplyMessage;
- (BOOL)isSentMessage;
- (BOOL)isReceivedMessage;
- (BOOL)isLocationMessage;
- (BOOL)isContactMessage;
- (BOOL)isChannelContentTypeMessage;
- (BOOL)isDocumentMessage;
- (BOOL)isSilentNotification;
- (BOOL)isDeletedForAll;
- (BOOL)isMessageSentToServer;
- (BOOL)isConversationDeleted;

- (instancetype)initWithBuilder:(ALMessageBuilder *)builder;
+ (instancetype)build:(void (^)(ALMessageBuilder *))builder;
- (BOOL)isNotificationDisabled;
- (BOOL)isLinkMessage;
- (BOOL)isResetUnreadCountMessage;
- (BOOL)hasAttachment;
- (void)setAsDeletedForAll;
- (NSMutableDictionary *)combineMetadata:(NSMutableDictionary *)messageMetadata;
- (BOOL) isAssignmentMessage;
- (BOOL) isAutoSuggestion;
@end
