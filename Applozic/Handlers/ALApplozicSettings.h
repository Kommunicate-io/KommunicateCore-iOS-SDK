//
//  ALApplozicSettings.h
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#define USER_PROFILE_PROPERTY @"com.applozic.userdefault.USER_PROFILE_PROPERTY"
#define SEND_MSG_COLOUR @"com.applozic.userdefault.SEND_MSG_COLOUR"
#define RECEIVE_MSG_COLOUR @"com.applozic.userdefault.RECEIVE_MSG_COLOUR"
#define NAVIGATION_BAR_COLOUR @"com.applozic.userdefault.NAVIGATION_BAR_COLOUR"
#define NAVIGATION_BAR_ITEM_COLOUR @"com.applozic.userdefault.NAVIGATION_BAR_ITEM_COLOUR"
#define REFRESH_BUTTON_VISIBILITY @"com.applozic.userdefault.REFRESH_BUTTON_VISIBILITY"
#define CONVERSATION_TITLE @"com.applozic.userdefault.CONVERSATION_TITLE"
#define BACK_BUTTON_TITLE @"com.applozic.userdefault.BACK_BUTTON_TITLE"
#define FONT_FACE @"com.applozic.userdefault.FONT_FACE"
#define NOTIFICATION_TITLE @"com.applozic.userdefault.NOTIFICATION_TITLE"
#define IMAGE_COMPRESSION_FACTOR @"com.applozic.userdefault.IMAGE_COMPRESSION_FACTOR"
#define IMAGE_UPLOAD_MAX_SIZE @"com.applozic.userdefault.IMAGE_UPLOAD_MAX_SIZE"
#define GROUP_ENABLE @"com.applozic.userdefault.GROUP_ENABLE"
#define MAX_SEND_ATTACHMENT @"com.applozic.userdefault.MAX_SEND_ATTACHMENT"
#define FILTER_CONTACT @"com.applozic.userdefault.FILTER_CONTACT"
#define FILTER_CONTACT_START_TIME @"com.applozic.userdefault.FILTER_CONTACT_START_TIME"
#define WALLPAPER_IMAGE @"com.applozic.userdefault.WALLPAPER_IMAGE"
#define CUSTOM_MSG_BACKGROUND_COLOR @"com.applozic.userdefault.CUSTOM_MSG_BACKGROUND_COLOR"
#define ONLINE_CONTACT_LIMIT @"com.applozic.userdefault.ONLINE_CONTACT_LIMIT"
#define GROUP_EXIT_BUTTON @"com.applozic.userdefault.GROUP_EXIT_BUTTON"
#define GROUP_MEMBER_ADD_OPTION @"com.applozic.userdefault.GROUP_MEMBER_ADD_OPTION"
#define GROUP_MEMBER_REMOVE_OPTION @"com.applozic.userdefault.GROUP_MEMBER_REMOVE_OPTION"
#define THIRD_PARTY_VC_NAME @"com.applozic.userdefault.THIRD_PARTY_VC_NAME"
#define CONTEXTUAL_CHAT_OPTION @"com.applozic.userdefault.CONTEXTUAL_CHAT_OPTION"
#define USER_CALL_OPTION @"com.applozic.userdefault.USER_CALL_OPTION"
#define SEND_BUTTON_BG_COLOR @"com.applozic.userdefault.SEND_BUTTON_BG_COLOR"
#define TYPE_MSG_BG_COLOR @"com.applozic.userdefault.TYPE_MSG_BG_COLOR"
#define TYPING_LABEL_BG_COLOR @"com.applozic.userdefault.TYPING_LABEL_BG_COLOR"
#define TYPING_LABEL_TEXT_COLOR @"com.applozic.userdefault.TYPING_LABEL_TEXT_COLOR"
#define EMPTY_CONVERSATION_TEXT @"com.applozic.userdefault.EMPTY_CONVERSATION_TEXT"
#define NO_CONVERSATION_FLAG_CHAT_VC @"com.applozic.userdefault.NO_CONVERSATION_FLAG_CHAT_VC"
#define ONLINE_INDICATOR_VISIBILITY @"com.applozic.userdefault.ONLINE_INDICATOR_VISIBILITY"
#define BACK_BUTTON_TITLE_CHATVC @"com.applozic.userdefault.BACK_BUTTON_TITLE_CHATVC"
#define NO_MORE_CONVERSATION_VISIBILITY @"com.applozic.userdefault.NO_MORE_CONVERSATION_VISIBILITY"
#define CUSTOM_NAV_RIGHT_BUTTON_MSGVC @"com.applozic.userdefault.CUSTOM_NAV_RIGHT_BUTTON_MSGVC"
#define TOAST_BG_COLOUR @"com.applozic.userdefault.TOAST_BG_COLOUR"
#define TOAST_TEXT_COLOUR @"com.applozic.userdefault.TOAST_TEXT_COLOUR"
#define SEND_MSG_TEXT_COLOUR @"com.applozic.userdefault.SEND_MSG_TEXT_COLOUR"
#define RECEIVE_MSG_TEXT_COLOUR @"com.applozic.userdefault.RECEIVE_MSG_TEXT_COLOUR"
#define MSG_TEXT_BG_COLOUR @"com.applozic.userdefault.MSG_TEXT_BG_COLOUR"
#define PLACE_HOLDER_COLOUR @"com.applozic.userdefault.PLACE_HOLDER_COLOUR"
#define UNREAD_COUNT_LABEL_BG_COLOUR @"com.applozic.userdefault.UNREAD_COUNT_LABEL_BG_COLOUR"
#define STATUS_BAR_BG_COLOUR @"com.applozic.userdefault.STATUS_BAR_BG_COLOUR"
#define STATUS_BAR_STYLE @"com.applozic.userdefault.STATUS_BAR_STYLE"
#define MAX_TEXT_VIEW_LINES @"com.applozic.userdefault.MAX_TEXT_VIEW_LINES"


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALApplozicSettings : NSObject

+(void)setFontFace:(NSString *)fontFace;

+(NSString *)getFontFace;

+(void)setUserProfileHidden: (BOOL)flag;

+(BOOL)isUserProfileHidden;

+(void)setColorForSendMessages:(UIColor *)sendMsgColor ;

+(void)setColorForReceiveMessages:(UIColor *)receiveMsgColor;

+(UIColor *)getSendMsgColor;

+(UIColor *)getReceiveMsgColor;

+(void)setColorForNavigation:(UIColor *)barColor;

+(UIColor *)getColorForNavigation;

+(void)setColorForNavigationItem:(UIColor *)barItemColor;

+(UIColor *)getColorForNavigationItem;

+(void)hideRefreshButton:(BOOL)state;

+(BOOL)isRefreshButtonHidden;

+(void)setTitleForConversationScreen:(NSString *)titleText;

+(NSString *)getTitleForConversationScreen;

+(void)setTitleForBackButtonMsgVC:(NSString *)backButtonTitle;
+(NSString *)getTitleForBackButtonMsgVC;

+(NSString *)getTitleForBackButtonChatVC;
+(void)setTitleForBackButtonChatVC:(NSString *)backButtonTitle;

+(void)setNotificationTitle:(NSString *)notificationTitle;

+(NSString *)getNotificationTitle;

+(void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize;

+(NSInteger)getMaxImageSizeForUploadInMB;

+(void) setMaxCompressionFactor:(double)maxCompressionRatio;

+(double) getMaxCompressionFactor;

+(void)setGroupOption:(BOOL)option;

+(BOOL)getGroupOption;

+(void)setMultipleAttachmentMaxLimit:(NSInteger)limit;

+(NSInteger)getMultipleAttachmentMaxLimit;

+(void)setFilterContactsStatus:(BOOL)flag;

+(BOOL)getFilterContactsStatus;

+(void)setStartTime:(NSNumber *)startTime;

+(NSNumber *)getStartTime;

+(void)setChatWallpaperImageName:(NSString*)imageName;

+(NSString *)getChatWallpaperImageName;

+(void)setCustomMessageBackgroundColor:(UIColor *)color;

+(UIColor *)getCustomMessageBackgroundColor;

+(void)setGroupExitOption:(BOOL)option;
+(BOOL)getGroupExitOption;

+(void)setGroupMemberAddOption:(BOOL)option;
+(BOOL)getGroupMemberAddOption;

+(void)setGroupMemberRemoveOption:(BOOL)option;
+(BOOL)getGroupMemberRemoveOption;

+(void)setOnlineContactLimit:(NSInteger)limit;
+(NSInteger)getOnlineContactLimit;

+(NSString *)getCustomClassName;
+(void)setCustomClassName:(NSString *)className;

+(void)setContextualChat:(BOOL)option;
+(BOOL)getContextualChatOption;

+(void)setCallOption:(BOOL)flag;
+(BOOL)getCallOption;

// Enable/Diable Notification Sound
+(void)enableNotificationSound;
+(void)disableNotificationSound;
// Enable/Diable Notification Complete
+(void)enableNotification;
+(void)disableNotification;

+(UIColor *)getColorForSendButton;
+(void)setColorForSendButton:(UIColor *)color;

+(UIColor *)getColorForTypeMsgBackground;
+(void)setColorForTypeMsgBackground:(UIColor *)viewColor;

+(UIColor *)getBGColorForTypingLabel;
+(void)setBGColorForTypingLabel:(UIColor *)bgColor;

+(UIColor *)getTextColorForTypingLabel;
+(void)setTextColorForTypingLabel:(UIColor *)txtColor;

+(NSString *)getEmptyConversationText;
+(void)setEmptyConversationText:(NSString *)text;

+(BOOL)getVisibilityNoConversationLabelChatVC;
+(void)setVisibilityNoConversationLabelChatVC:(BOOL)flag;

+(BOOL)getVisibilityForOnlineIndicator;
+(void)setVisibilityForOnlineIndicator:(BOOL)flag;

+(BOOL)getVisibilityForNoMoreConversationMsgVC;
+(void)setVisibilityForNoMoreConversationMsgVC:(BOOL)flag;

+(BOOL)getCustomNavRightButtonMsgVC;
+(void)setCustomNavRightButtonMsgVC:(BOOL)flag;

+(UIColor *)getColorForToastText;
+(void)setColorForToastText:(UIColor *)toastTextColor;

+(UIColor *)getColorForToastBackground;
+(void)setColorForToastBackground:(UIColor *)toastBGColor;

+(UIColor *)getSendMsgTextColor;
+(void)setSendMsgTextColor:(UIColor *)sendMsgColor;

+(UIColor *)getReceiveMsgTextColor;
+(void)setReceiveMsgTextColor:(UIColor *)receiveMsgColor;

+(UIColor *)getMsgTextViewBGColor;
+(void)setMsgTextViewBGColor:(UIColor *)color;

+(UIColor *)getPlaceHolderColor;
+(void)setPlaceHolderColor:(UIColor *)color;

+(UIColor *)getUnreadCountLabelBGColor;
+(void)setUnreadCountLabelBGColor:(UIColor *)color;

+(UIColor *)getStatusBarBGColor;
+(void)setStatusBarBGColor:(UIColor *)color;

+(UIStatusBarStyle)getStatusBarStyle;            
+(void)setStatusBarStyle:(UIStatusBarStyle)style;


+(void)setMaxTextViewLines:(int)numberOfLines;
+(int)getMaxTextViewLines;
@end
