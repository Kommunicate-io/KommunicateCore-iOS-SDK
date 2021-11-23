//
//  ALMessage.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALMessage.h"
#import "ALUtilityClass.h"
#import "ALChannel.h"
#import "ALContact.h"
#import "ALChannelService.h"
#import "ALContactDBService.h"
#import "ALUserDefaultsHandler.h"
#import "ALLogger.h"

static NSString * const AL_DELETE_MESSAGE_FOR_KEY = @"AL_DELETE_GROUP_MESSAGE_FOR_ALL";
static NSString * const AL_TRUE = @"true";

@implementation ALMessage

- (NSNumber *)getGroupId {
    if ([self.groupId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        return nil;
    } else {
        return self.groupId;
    }
}

- (id)initWithDictonary:(NSDictionary *)messageDictonary {
    @try {
        [self parseMessage:messageDictonary];
    } @catch (NSException *exception) {
        ALSLog(ALLoggerSeverityError, @"EXCEPTION : MSG_PARSING :: %@",exception.description);
    } @finally {
    }
    return self;
}

- (void)parseMessage:(id)messageJson {

    // key String

    self.key =  [super getStringFromJsonValue:messageJson[@"key"]];

    self.pairedMessageKey = [super getStringFromJsonValue:messageJson[@"pairedMessageKey"]];


    // device keyString

    self.deviceKey = [self getStringFromJsonValue:messageJson[@"deviceKey"]];


    // su user keyString

    self.userKey = [self getStringFromJsonValue:messageJson[@"suUserKeyString"]];


    // to

    self.to = [self getStringFromJsonValue:messageJson[@"to"]];


    // message

    self.message = [self getStringFromJsonValue:messageJson[@"message"]];

    // sendToDevice

    self.sendToDevice = [self getBoolFromJsonValue:messageJson[@"sendToDevice"]];


    // shared

    self.shared = [self getBoolFromJsonValue:messageJson[@"shared"]];


    // createdAtTime

    self.createdAtTime = [self getNSNumberFromJsonValue:messageJson[@"createdAtTime"]];


    // type

    self.type = [self getStringFromJsonValue:messageJson[@"type"]];


    // source

    self.source = [self getShortFromJsonValue:messageJson[@"source"]];


    // contactIds

    self.contactIds = [self getStringFromJsonValue:messageJson[@"contactIds"]];


    // storeOnDevice

    self.storeOnDevice = [self getBoolFromJsonValue:messageJson[@"storeOnDevice"]];


    // read

    //self.read = [self getBoolFromJsonValue:messageJson[@"read"]];

    //develired
    self.delivered = [self getBoolFromJsonValue:messageJson[@"delivered"]];

    //groupId

    self.groupId = [self getNSNumberFromJsonValue:messageJson[@"groupId"]];

    //contentType

    self.contentType = [self getShortFromJsonValue:messageJson[@"contentType"]];

    //conversationID
    self.conversationId = [self getNSNumberFromJsonValue:messageJson[@"conversationId"]];

    //status
    self.status = [self getNSNumberFromJsonValue:messageJson[@"status"]];

    // file meta info

    NSDictionary * fileMetaDictionary = messageJson[@"fileMeta"];

    if ([self validateJsonClass:fileMetaDictionary]) {

        ALFileMetaInfo *fileMetaInfo = [ALFileMetaInfo new];

        fileMetaInfo.blobKey = [self getStringFromJsonValue:fileMetaDictionary[@"blobKey"]];
        fileMetaInfo.thumbnailBlobKey = [self getStringFromJsonValue:fileMetaDictionary[@"thumbnailBlobKey"]];
        fileMetaInfo.contentType = [self getStringFromJsonValue:fileMetaDictionary[@"contentType"]];
        fileMetaInfo.createdAtTime = [self getNSNumberFromJsonValue:fileMetaDictionary[@"createdAtTime"]];
        fileMetaInfo.key = [self getStringFromJsonValue:fileMetaDictionary[@"key"]];
        fileMetaInfo.name = [self getStringFromJsonValue:fileMetaDictionary[@"name"]];
        fileMetaInfo.userKey = [self getStringFromJsonValue:fileMetaDictionary[@"userKey"]];
        fileMetaInfo.size = [self getStringFromJsonValue:fileMetaDictionary[@"size"]];
        fileMetaInfo.thumbnailUrl = [self getStringFromJsonValue:fileMetaDictionary[@"thumbnailUrl"]];
        fileMetaInfo.url = [self getStringFromJsonValue:fileMetaDictionary[@"url"]];

        self.fileMeta = fileMetaInfo;
    }

    self.deleted = NO;

    self.metadata = [[NSMutableDictionary  alloc] initWithDictionary:messageJson[@"metadata"]];

    self.msgHidden = [self isMsgHidden];

}


- (NSString *)getCreatedAtTime:(BOOL)today {

    NSString *formattedString = today ? @"hh:mm a":@"dd MMM";
    NSString *formattedDateString;
    NSDate *currentTime = [[NSDate alloc] init];

    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:self.createdAtTime.doubleValue/1000];
    NSTimeInterval difference = [currentTime timeIntervalSinceDate:messageDate];

    float minutes;
    if (difference <= 3600) {
        if (difference <= 60) {
            formattedDateString = NSLocalizedStringWithDefaultValue(@"justNow", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Just Now", @"");
        } else {
            minutes = difference/60;
            formattedDateString = [NSString stringWithFormat:@"%.0f", minutes];
            formattedDateString = [formattedDateString stringByAppendingString:@" m"];
        }
    } else if(difference <= 7200) {
        minutes = (difference - 3600)/60;
        formattedDateString = [NSString stringWithFormat:@"%.0f", minutes];
        NSString *hour = @"1h ";
        formattedDateString = [hour stringByAppendingString:formattedDateString];
        formattedDateString = [formattedDateString stringByAppendingString:@"m"];
    } else {
        formattedDateString = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue]/1000 toFormat:formattedString];
    }

    return formattedDateString;
}

- (NSString *)getCreatedAtTimeChat:(BOOL)today {

    NSString *formattedString = @"hh:mm a";
    NSString *formattedDateString = [ALUtilityClass formatTimestamp:[self.createdAtTime doubleValue]/1000 toFormat:formattedString];
    return formattedDateString;
}
- (BOOL)isDownloadRequired {

    //TODO:check for SD card
    return (self.fileMeta && !self.imageFilePath);
}

- (BOOL)isUploadRequire {
    //TODO:check for SD card
    return ( (self.imageFilePath && !self.fileMeta && [self.type  isEqualToString:@"5"])
            || self.isUploadFailed==YES );
}


- (BOOL)isHiddenMessage {
    return ((self.contentType == ALMESSAGE_CONTENT_HIDDEN) || [self isVOIPNotificationMessage]
            || [self isPushNotificationMessage] || [self isMessageCategoryHidden]
            || self.getReplyType== AL_REPLY_BUT_HIDDEN || self.isMsgHidden );
}

- (BOOL)isVOIPNotificationMessage {
    return (self.contentType == AV_CALL_HIDDEN_NOTIFICATION);
}

- (BOOL)isToIgnoreUnreadCountIncrement {
    return (self.contentType == AV_CALL_MESSAGE);
}

- (BOOL)isResetUnreadCountMessage {
    return (self.groupId && self.isChannelContentTypeMessage &&
            self.metadata && [self.metadata  valueForKey:AL_RESET_UNREAD_COUNT]
            && [[self.metadata  valueForKey:AL_RESET_UNREAD_COUNT] isEqualToString:ALUserDefaultsHandler.getUserId]);
}

- (NSString*)getLastMessage {

    if (self.contentType == ALMESSAGE_CONTENT_LOCATION) {
        return NSLocalizedStringWithDefaultValue(@"location", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Location", @"");
    }

    if (self.contentType == ALMESSAGE_CONTENT_VCARD) {
        return NSLocalizedStringWithDefaultValue(@"contact", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Contact", @"");
    }

    if (self.contentType == ALMESSAGE_CONTENT_AUDIO) {
        return NSLocalizedStringWithDefaultValue(@"audio", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Audio", @"");
    }

    if (self.contentType == ALMESSAGE_CONTENT_CAMERA_RECORDING) {
        return NSLocalizedStringWithDefaultValue(@"video", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Video", @"");
    }

    if (self.contentType == ALMESSAGE_CONTENT_ATTACHMENT
        || self.fileMeta != nil
        || self.imageFilePath != nil) {
        return NSLocalizedStringWithDefaultValue(@"attachment", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Attachment", @"");
    }
    if (self.message
        && ![self.message isEqualToString:@""]) {
        return self.message;
    }

    return @"Message";
}


- (NSMutableDictionary *)getMetaDataDictionary:(NSString *)string {

    if (string == nil) {
        return nil;
    }

    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSMutableDictionary *metaDataDictionary;

    if (!data) {
        return nil;
    }

    @try {
        NSError *error;
        metaDataDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable
                                                                        format:&format
                                                                         error:&error];
    } @catch(NSException * exp) {
    }

    return metaDataDictionary;
}

- (NSString *)getVOIPMessageText {
    NSString *msgType = (NSString *)[self.metadata objectForKey:@"MSG_TYPE"];
    BOOL flag = [[self.metadata objectForKey:@"CALL_AUDIO_ONLY"] boolValue];

    NSString *text = self.message;

    if ([msgType isEqualToString:@"CALL_MISSED"]) {
        text = flag ? @"Missed Audio Call" : @"Missed Video Call";
    } else if([msgType isEqualToString:@"CALL_END"]) {
        text = flag ? @"Audio Call" : @"Video Call";
    } else if([msgType isEqualToString:@"CALL_REJECTED"]) {
        text = @"Call Busy";
    }

    return text;
}

- (BOOL)isMsgHidden {
    BOOL hide = [[self.metadata objectForKey:@"hide"] boolValue];

    // Check messages that we need to hide
    NSArray *keys = [ALApplozicSettings metadataKeysToHideMessages];
    if (keys != nil) {
        for (NSString *key in keys) {
            // If this key is present then it's a hidden message
            if ([self.metadata objectForKey:key] != nil) {
                return true;
            }
        }
    }
    return hide;
}

- (BOOL)isPushNotificationMessage {
    return (self.metadata && [self.metadata valueForKey:@"category"] &&
            [ [self.metadata valueForKey:@"category"] isEqualToString:AL_CATEGORY_PUSHNNOTIFICATION]);
}

- (BOOL)isMessageCategoryHidden {
    return (self.metadata && [self.metadata valueForKey:@"category"] &&
            [[self.metadata valueForKey:@"category"] isEqualToString:AL_CATEGORY_HIDDEN]);
}

- (BOOL)isAReplyMessage {
    return (self.metadata && [self.metadata valueForKey:AL_MESSAGE_REPLY_KEY] );
}

- (BOOL)isSentMessage {
    return [self.type isEqualToString:AL_OUT_BOX];
}

- (BOOL)isReceivedMessage {
    return [self.type isEqualToString:AL_IN_BOX];
}

- (BOOL)isLocationMessage {
    return (self.contentType ==ALMESSAGE_CONTENT_LOCATION);
}

- (BOOL)isContactMessage {
    return (self.contentType ==ALMESSAGE_CONTENT_VCARD);
}

- (BOOL)isLinkMessage {
    return (_metadata && [_metadata  valueForKey:@"linkMessage"] && [ [_metadata  valueForKey:@"linkMessage"] isEqualToString:@"true"]);
}

- (BOOL)isChannelContentTypeMessage {
    return (self.contentType == ALMESSAGE_CHANNEL_NOTIFICATION);
}

- (BOOL)isDocumentMessage {
    return (self.contentType ==ALMESSAGE_CONTENT_ATTACHMENT) &&
    !([self.fileMeta.contentType hasPrefix:@"video"]|| [self.fileMeta.contentType hasPrefix:@"audio"] || [self.fileMeta.contentType hasPrefix:@"image"] );

}

- (BOOL)hasAttachment {
    return self.fileMeta != nil || self.imageFilePath != nil;
}

- (BOOL)isSilentNotification {

    if (_metadata && [_metadata  valueForKey:@"show"]) {
        return ([ [_metadata  valueForKey:@"show"] isEqualToString:@"false"]);
    }
    return NO;
}

- (ALReplyType)getReplyType {
    switch ([self.messageReplyType intValue])
    {

        case 1:
            return AL_A_REPLY;
            break;

        case 2:
            return AL_REPLY_BUT_HIDDEN;
            break;

        default:
            return AL_NOT_A_REPLY;
    }
}

- (BOOL)isDeletedForAll {
    return self.metadata &&
    [self.metadata valueForKey:AL_DELETE_MESSAGE_FOR_KEY] &&
    [[self.metadata valueForKey:AL_DELETE_MESSAGE_FOR_KEY] isEqualToString:AL_TRUE];
}

- (instancetype)initWithBuilder:(ALMessageBuilder *)builder {
    if (self = [super init]) {
        _contactIds = builder.to;
        _to = builder.to;
        _message = builder.message;
        _contentType = builder.contentType;
        _conversationId = builder.conversationId;
        _deviceKey  =  [ALUserDefaultsHandler getDeviceKeyString];
        _type = @"5";
        _createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
        _deviceKey = [ALUserDefaultsHandler getDeviceKeyString ];
        _sendToDevice = NO;
        _shared = NO;
        _fileMeta = nil;
        _storeOnDevice = NO;
        _key = [[NSUUID UUID] UUIDString];
        _delivered = NO;
        _fileMetaKey = nil;
        _groupId = builder.groupId;
        _source = AL_SOURCE_IOS;
        _metadata = builder.metadata; // EXAMPLE FOR META DATA
        if (builder.imageFilePath) {
            _imageFilePath = builder.imageFilePath.lastPathComponent;
            _fileMeta = [self getFileMetaInfo];
            //File Meta Creation
            _fileMeta.name = [NSString stringWithFormat:@"AUD-5-%@", builder.imageFilePath];
            if (builder.to) {
                _fileMeta.name = [NSString stringWithFormat:@"%@-5-%@",builder.to, builder.imageFilePath];
            }
        }

    }
    return self;
}

- (ALFileMetaInfo *)getFileMetaInfo {
    ALFileMetaInfo *fileMetaInfo = [ALFileMetaInfo new];
    
    fileMetaInfo.blobKey = nil;
    fileMetaInfo.contentType = @"";
    fileMetaInfo.createdAtTime = nil;
    fileMetaInfo.key = nil;
    fileMetaInfo.name = @"";
    fileMetaInfo.size = @"";
    fileMetaInfo.userKey = @"";
    fileMetaInfo.thumbnailUrl = @"";
    fileMetaInfo.progressValue = 0;
    
    return fileMetaInfo;
}

+ (instancetype)build:(void (^)(ALMessageBuilder *))builder {
    ALMessageBuilder *alMessageBuilder = [ALMessageBuilder new];
    builder(alMessageBuilder);
    return [[ALMessage alloc] initWithBuilder:alMessageBuilder];
}

- (BOOL)isNotificationDisabled {
    ALChannel *channel;
    ALContact *contact;
    if (self.groupId != nil) {
        ALChannelService *channelService = [[ALChannelService alloc] init];
        channel = [channelService getChannelByKey:self.groupId];
    } else {
        ALContactDBService *alContactDBService = [[ALContactDBService alloc] init];
        contact = [alContactDBService loadContactByKey:@"userId" value:self.contactIds];
    }
    
    return (([ALUserDefaultsHandler getNotificationMode] == AL_NOTIFICATION_DISABLE)
            || (_metadata && ([self isSilentNotification]
                              || [self isHiddenMessage]))
            || (channel && [channel isNotificationMuted])
            || (contact && [contact isNotificationMuted]));
}

- (void)setAsDeletedForAll {
    if (!self.metadata) {
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    [self.metadata setValue:AL_TRUE forKey:AL_DELETE_MESSAGE_FOR_KEY];
}

- (BOOL)isMessageSentToServer {
    return self.status.intValue != 0;
}

- (NSMutableDictionary *)combineMetadata:(NSMutableDictionary *)messageMetadata {
    if (!self.metadata) {
        return messageMetadata;
    }

    if (messageMetadata) {
        [messageMetadata addEntriesFromDictionary:self.metadata];
        return messageMetadata;
    }
    return self.metadata;
}

@end
