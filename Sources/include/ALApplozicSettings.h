//
//  ALApplozicSettings.h
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const AL_USER_PROFILE_PROPERTY = @"com.applozic.userdefault.USER_PROFILE_PROPERTY";
static NSString *const AL_SEND_MSG_COLOUR = @"com.applozic.userdefault.SEND_MSG_COLOUR";
static NSString *const AL_RECEIVE_MSG_COLOUR = @"com.applozic.userdefault.RECEIVE_MSG_COLOUR";
static NSString *const AL_NAVIGATION_BAR_COLOUR = @"com.applozic.userdefault.NAVIGATION_BAR_COLOUR";
static NSString *const AL_NAVIGATION_BAR_ITEM_COLOUR = @"com.applozic.userdefault.NAVIGATION_BAR_ITEM_COLOUR";
static NSString *const AL_REFRESH_BUTTON_VISIBILITY = @"com.applozic.userdefault.REFRESH_BUTTON_VISIBILITY";
static NSString *const AL_CONVERSATION_TITLE = @"com.applozic.userdefault.CONVERSATION_TITLE";
static NSString *const AL_BACK_BUTTON_TITLE = @"com.applozic.userdefault.BACK_BUTTON_TITLE";
static NSString *const AL_FONT_FACE = @"com.applozic.userdefault.FONT_FACE";
static NSString *const AL_CHAT_CELL_FONT_TEXT_STYLE = @"com.applozic.userdefault.CHAT_CELL_FONT_TEXT_STYLE";
static NSString *const AL_CHAT_CHANNEL_CELL_FONT_TEXT_STYLE = @"com.applozic.userdefault.CHAT_CHANNEL_CELL_FONT_TEXT_STYLE";
static NSString *const AL_NOTIFICATION_TITLE = @"com.applozic.userdefault.NOTIFICATION_TITLE";
static NSString *const AL_IMAGE_COMPRESSION_FACTOR = @"com.applozic.userdefault.IMAGE_COMPRESSION_FACTOR";
static NSString *const AL_IMAGE_UPLOAD_MAX_SIZE = @"com.applozic.userdefault.IMAGE_UPLOAD_MAX_SIZE";
static NSString *const AL_GROUP_ENABLE = @"com.applozic.userdefault.GROUP_ENABLE";
static NSString *const AL_GROUP_INFO_DISABLED = @"com.applozic.userdefault.GROUP_INFO_DISABLED";
static NSString *const AL_GROUP_INFO_EDIT_DISABLED = @"com.applozic.userdefault.GROUP_INFO_EDIT_DISABLED";
static NSString *const AL_MAX_SEND_ATTACHMENT = @"com.applozic.userdefault.MAX_SEND_ATTACHMENT";
static NSString *const AL_FILTER_CONTACT = @"com.applozic.userdefault.FILTER_CONTACT";
static NSString *const AL_FILTER_CONTACT_START_TIME = @"com.applozic.userdefault.FILTER_CONTACT_START_TIME";
static NSString *const AL_WALLPAPER_IMAGE = @"com.applozic.userdefault.WALLPAPER_IMAGE";
static NSString *const AL_CUSTOM_MSG_BACKGROUND_COLOR = @"com.applozic.userdefault.CUSTOM_MSG_BACKGROUND_COLOR";
static NSString *const AL_CUSTOM_MSG_TEXT_COLOR = @"com.applozic.userdefault.CUSTOM_MSG_TEXT_COLOR";
static NSString *const AL_ONLINE_CONTACT_LIMIT = @"com.applozic.userdefault.ONLINE_CONTACT_LIMIT";
static NSString *const AL_GROUP_EXIT_BUTTON = @"com.applozic.userdefault.GROUP_EXIT_BUTTON";
static NSString *const AL_GROUP_MEMBER_ADD_OPTION = @"com.applozic.userdefault.GROUP_MEMBER_ADD_OPTION";
static NSString *const AL_GROUP_MEMBER_REMOVE_OPTION = @"com.applozic.userdefault.GROUP_MEMBER_REMOVE_OPTION";
static NSString *const AL_THIRD_PARTY_VC_NAME = @"com.applozic.userdefault.THIRD_PARTY_VC_NAME";
static NSString *const AL_THIRD_PARTY_DETAIL_VC_NOTIFICATION = @"com.applozic.userdefault.THIRD_PARTY_DETAIL_VC_NOTIFICATION";
static NSString *const AL_CONTEXTUAL_CHAT_OPTION = @"com.applozic.userdefault.CONTEXTUAL_CHAT_OPTION";
static NSString *const AL_USER_CALL_OPTION = @"com.applozic.userdefault.USER_CALL_OPTION";
static NSString *const AL_SEND_BUTTON_BG_COLOR = @"com.applozic.userdefault.SEND_BUTTON_BG_COLOR";
static NSString *const AL_TYPE_MSG_BG_COLOR = @"com.applozic.userdefault.TYPE_MSG_BG_COLOR";
static NSString *const AL_TYPING_LABEL_BG_COLOR = @"com.applozic.userdefault.TYPING_LABEL_BG_COLOR";
static NSString *const AL_TYPING_LABEL_TEXT_COLOR = @"com.applozic.userdefault.TYPING_LABEL_TEXT_COLOR";
static NSString *const AL_EMPTY_CONVERSATION_TEXT = @"com.applozic.userdefault.EMPTY_CONVERSATION_TEXT";
static NSString *const AL_NO_CONVERSATION_FLAG_CHAT_VC = @"com.applozic.userdefault.NO_CONVERSATION_FLAG_CHAT_VC";
static NSString *const AL_ONLINE_INDICATOR_VISIBILITY = @"com.applozic.userdefault.ONLINE_INDICATOR_VISIBILITY";
static NSString *const AL_BACK_BUTTON_TITLE_CHATVC = @"com.applozic.userdefault.BACK_BUTTON_TITLE_CHATVC";
static NSString *const AL_NO_MORE_CONVERSATION_VISIBILITY = @"com.applozic.userdefault.NO_MORE_CONVERSATION_VISIBILITY";
static NSString *const AL_CUSTOM_NAV_RIGHT_BUTTON_MSGVC = @"com.applozic.userdefault.CUSTOM_NAV_RIGHT_BUTTON_MSGVC";
static NSString *const AL_TOAST_BG_COLOUR = @"com.applozic.userdefault.TOAST_BG_COLOUR";
static NSString *const AL_TOAST_TEXT_COLOUR = @"com.applozic.userdefault.TOAST_TEXT_COLOUR";
static NSString *const AL_SEND_MSG_TEXT_COLOUR = @"com.applozic.userdefault.SEND_MSG_TEXT_COLOUR";
static NSString *const AL_RECEIVE_MSG_TEXT_COLOUR = @"com.applozic.userdefault.RECEIVE_MSG_TEXT_COLOUR";
static NSString *const AL_MSG_TEXT_BG_COLOUR = @"com.applozic.userdefault.MSG_TEXT_BG_COLOUR";
static NSString *const AL_PLACE_HOLDER_COLOUR = @"com.applozic.userdefault.PLACE_HOLDER_COLOUR";
static NSString *const AL_UNREAD_COUNT_LABEL_BG_COLOUR = @"com.applozic.userdefault.UNREAD_COUNT_LABEL_BG_COLOUR";
static NSString *const AL_STATUS_BAR_BG_COLOUR = @"com.applozic.userdefault.STATUS_BAR_BG_COLOUR";
static NSString *const AL_STATUS_BAR_STYLE = @"com.applozic.userdefault.STATUS_BAR_STYLE";
static NSString *const AL_MAX_TEXT_VIEW_LINES = @"com.applozic.userdefault.MAX_TEXT_VIEW_LINES";
static NSString *const AL_ABUSE_WORDS_WARNING_TEXT = @"com.applozic.userdefault.ABUSE_WORDS_WARNING_TEXT";
static NSString *const AL_ENABLE_MSGTEXT_ABUSE_CHECK = @"com.applozic.userdefault.ENABLE_MSGTEXT_ABUSE_CHECK";
static NSString *const AL_MSG_DATE_COLOR = @"com.applozic.userdefault.MSG_DATE_COLOR";
static NSString *const AL_MSG_SEPERATE_DATE_COLOR = @"com.applozic.userdefault.MSG_SEPERATE_DATE_COLOR";
static NSString *const AL_ENABLE_RECEIVER_USER_PROFILE = @"com.applozic.userdefault.ENABLE_RECEIVER_USER_PROFILE";
static NSString *const AL_CUSTOM_MSG_FONT_SIZE = @"com.applozic.userdefault.CUSTOM_MSG_FONT_SIZE";
static NSString *const AL_CUSTOM_MSG_FONT = @"com.applozic.userdefault.CUSTOM_MSG_FONT";
static NSString *const AL_FILTER_ONLY_CONTACT_TYPE_ID = @"com.applozic.userdefault.FILTER_ONLY_CONTACT_TYPE_ID";
static NSString *const AL_CUSTOM_NAVIGATION_CLASS_NAME = @"com.applozic.userdefault.NAVIGATION_CONTROLLER_CLASS_NAME";
static NSString *const AL_SUB_GROUP_LAUNCH = @"com.applozic.userdefault.SUB_GROUP_LAUNCH";
static NSString *const AL_GROUP_OF_TWO_FLAG = @"com.applozic.userdefault.GROUP_OF_TWO_FLAG";
static NSString *const AL_BROADCAST_GROUP_ENABLE = @"com.applozic.userdefault.BROADCAST_GROUP_ENABLE";
static NSString *const AL_VIEW_CONTROLLER_ARRAY = @"com.applozic.userdefault.VIEW_CONTROLLER_ARRAY";
static NSString *const AL_MSG_CONTAINER_VC = @"com.applozic.userdefault.MSG_CONTAINER_VC";
static NSString *const AL_AUDIO_VIDEO_CLASS = @"com.applozic.userdefault.AUDIO_VIDEO_CLASS";
static NSString *const AL_CLIENT_STORYBOARD = @"com.applozic.userdefault.CLIENT_STORYBOARD";
static NSString *const AL_GROUP_DELETED_TITLE = @"com.applozic.userdefault.GROUP_DELETED_TITLE";
static NSString *const AL_USER_DELETED_TEXT = @"com.applozic.userdefault.USER_DELETED_TEXT";
static NSString *const AL_CHAT_LIST_TAB_ICON = @"com.applozic.userdefault.CHAT_LIST_TAB_ICON";
static NSString *const AL_USER_PROFILE_TAB_ICON = @"com.applozic.userdefault.USER_PROFILE_TAB_ICON";
static NSString *const AL_CHAT_LIST_TAB_TITLE = @"com.applozic.userdefault.CHAT_LIST_TAB_TITLE";
static NSString *const AL_USER_PROFILE_TAB_TITLE = @"com.applozic.userdefault.USER_PROFILE_TAB_TITLE";
static NSString *const AL_OPEN_CHAT_ON_USER_PROFILE_TAP = @"com.applozic.userdefault.OPEN_CHAT_ON_USER_PROFILE_TAP";
static NSString *const AL_MESSAGE_REPLY_ENABLED = @"com.applozic.userdefault.MESSAGE_REPLY_MESSAGE";
static NSString *const AL_AV_ENABLED = @"com.applozic.userfefault.AV_ENABLED";
static NSString *const AL_CONTACTS_GROUP = @"com.applozic.userdefault.CONTACTS_GROUP";
static NSString *const AL_CONTACTS_GROUP_ID = @"com.applozic.userdefault.CONTACTS_GROUP_ID";
static NSString *const AL_FORWARD_OPTION = @"com.applozic.userdefault.FORWARD_OPTION";
static NSString *const AL_SWIFT_FRAMEWORK = @"com.applozic.userfefault.SWIFT_FRAMEWORK";
static NSString *const AL_DEDICATED_SERVER = @"com.applozic.userfefault.DEDICATED_SERVER";
static NSString *const AL_HIDE_ATTACHMENT_OPTION = @"com.applozic.HIDE_ATTACHMENT_OPTIONS";
static NSString *const AL_S3_STORAGE_SERVICE = @"com.applozic.userdefault.S3_STORAGE_SERVICE";
static NSString *const AL_DEFAULT_GROUP_TYPE = @"com.applozic.DEFAULT_GROUP_TYPE";
static NSString *const AL_CONTACTS_GROUP_ID_LIST = @"com.applozic.userdefault.CONTACTS_GROUP_ID_LIST";
static NSString *const AL_SAVE_VIDEOS_TO_GALLERY = @"com.applozic.userdefault.SAVE_VIDEOS_TO_GALLERY";
static NSString *const AL_ENABLE_QUICK_AUDIO_RECORDING = @"com.applozic.userdefault.ENABLE_QUICK_AUDIO_RECORDING";
static NSString *const AL_USER_ROLE_NAME = @"com.applozic.userdefault.AL_USER_ROLE_NAME";
static NSString *const AL_GROUP_CONVEERSATION_CLOSE = @"com.applozic.userdefault.AL_GROUP_CONVEERSATION_CLOSE";
static NSString *const AL_DROP_IN_SHADOW_IN_NAVIGATION_BAR = @"com.applozic.userdefault.DROP_IN_SHADOW_IN_NAVIGATION_BAR";
static NSString *const AL_APPLOZIC_LOCALIZABLE = @"com.applozic.userdefault.APPLOZIC_LOCALIZABLE";
static NSString *const AL_CATEGORY_NAME = @"com.applozic.userdefault.AL_CATEGORY_NAME";
static NSString *const AL_DELETE_CONVERSATION_OPTION = @"com.applozic.userdefault.DELETE_CONVERSATION_OPTION";
static NSString *const AL_GOOGLE_CLOUD_SERVICE_ENABLE = @"com.applozic.userdefault.GOOGLE_CLOUD_SERVICE_ENABLE";
static NSString *const AL_TEMPLATE_MESSAGES = @"com.applozic.TEMPLATE_MESSAGES";
static NSString *const AL_TEMPLATE_MESSAGE_VIEW = @"com.applozic.TEMPLATE_MESSAGE_VIEW";
static NSString *const AL_CONTACT_SEARCH = @"com.applozic.AL_CONTACT_SEARCH";
static NSString *const AL_CHANNEL_MEMBER_INFO_IN_SUBTITLE = @"com.applozic.CHANNEL_MEMBER_INFO_IN_SUBTITLE";
static NSString *const AL_TABBAR_BACKGROUND_COLOUR = @"com.applozic.TABBAR_BACKGROUND_COLOUR";
static NSString *const AL_TABBAR_SELECTED_ITEM_COLOUR = @"com.applozic.TABBAR_SELECTED_ITEM_COLOUR";
static NSString *const AL_TABBAR_UNSELECTED_ITEM_COLOUR = @"com.applozic.TABBAR_UNSELECTED_ITEM_COLOUR";
static NSString *const AL_ATTACHMENT_ITEM_COLOUR = @"com.applozic.ATTACHMENT_ITEM_COLOUR";
static NSString *const AL_SEND_ITEM_COLOUR = @"com.applozic.SEND_ITEM_COLOUR";
static NSString *const AL_MESSAGE_SUBTEXT_COLOUR = @"com.applozic.MESSAGE_SUBTEXT_COLOUR";
static NSString *const AL_MESSAGE_TEXT_COLOUR = @"com.applozic.MESSAGE_TEXT_COLOUR";
static NSString *const AL_PROFILE_MAIN_COLOUR = @"com.applozic.PROFILE_MAIN_COLOUR";
static NSString *const AL_PROFILE_SUB_COLOUR = @"com.applozic.PROFILE_SUB_COLOUR";
static NSString *const AL_NEW_CONTACT_SUB_COLOUR = @"com.applozic.NEW_CONTACT_SUB_COLOUR";
static NSString *const AL_NEW_CONTACT_MAIN_COLOUR = @"com.applozic.NEW_CONTACT_MAIN_COLOUR";
static NSString *const AL_NEW_CONTACT_TEXT_COLOUR = @"com.applozic.NEW_CONTACT_TEXT_COLOUR";
static NSString *const AL_MESSAGES_VIEW_BG_COLOUR = @"com.applozic.MESSAGES_VIEW_BG_COLOUR";
static NSString *const AL_CHAT_VIEW_BG_COLOUR = @"com.applozic.CHAT_VIEW_BG_COLOUR";
static NSString *const AL_SEARCHBAR_TINT_COLOUR = @"com.applozic.SEARCHBAR_TINT_COLOUR";
static NSString *const AL_HIDE_MESSAGES_WITH_METADATA_KEYS = @"com.applozic.HIDE_MESSAGES_WITH_METADATA_KEYS";
static NSString *const ALDisableMultiSelectGalleryView = @"ALDisableMultiSelectGalleryView";
static NSString *const AL_5MIN_VIDEO_LIMIT_IN_GALLERY= @"com.applozic.AL_5MIN_VIDEO_LIMIT_IN_GALLERY";
static NSString *const AL_BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON =  @"com.applozic.BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON";
static NSString *const AL_TEXT_STYLE_FOR_CELL= @"com.applozic.AL_TEXT_STYLE_FOR_CELL";
static NSString *const AL_CHAT_CELL_FONT_SIZE= @"com.applozic.AL_CHAT_CELL_FONT_SIZE";
static NSString *const AL_CHANNEL_CELL_FONT_SIZE= @"com.applozic.AL_CHANNEL_CELL_FONT_SIZE";
static NSString *const AL_BACKGROUND_COLOR_FOR_REPLY_VIEW= @"com.applozic.AL_BACKGROUND_COLOR_FOR_REPLY_VIEW";
static NSString *const AL_MESSAGE_TEXT_VIEW_COLOR = @"com.applozic.MESSAGE_TEXT_VIEW_COLOR";

//Audio Recording View
static NSString *const AL_ENABLE_NEW_AUDIO_DESIGN = @"com.applozic.ENABLE_NEW_AUDIO_DESIGN";
static NSString *const AL_AUDIO_RECORDING_VIEW_BACKGROUND_COLOR = @"com.applozic.AUDIO_RECORDING_VIEW_BACKGROUND_COLOR";
static NSString *const AL_SLIDE_TO_CANCEL_TEXT_COLOR = @"com.applozic.SLIDE_TO_CANCEL_TEXT_COLOR";
static NSString *const AL_AUDIO_RECORDING_TEXT_COLOR = @"com.applozic.AUDIO_RECORDING_TEXT_COLOR";
static NSString *const AL_AUDIO_RECORD_VIEW_FONT = @"com.applozic.AUDIO_VIEW_FONT";
static NSString *const AL_MEDIA_SELECT_OPTIONS = @"com.applozic.MEDIA_SELECT_OPTIONS";
static NSString *const AL_CHANNEL_ACTION_MESSAGE_BG_COLOR = @"com.applozic.AL_CHANNEL_ACTION_MESSAGE_BG_COLOR";
static NSString *const AL_CHANNEL_ACTION_MESSAGE_TEXT_COLOR = @"com.applozic.AL_CHANNEL_ACTION_MESSAGE_TEXT_COLOR";
static NSString *const AL_ALPHABETIC_COLOR_CODES = @"com.applozic.AL_ALPHABETIC_COLOR_CODES";
static NSString *const AL_DISABLE_UNBLOCK_FROM_CHAT = @"com.applozic.DISABLE_UNBLOCK_FROM_CHAT";
static NSString *const AL_USER_DEFAULTS_GROUP_MIGRATION = @"com.applozic.AL_USER_DEFAULTS_GROUP_MIGRATION";
static NSString *const AL_USER_DEFAULTS_MIGRATION = @"com.applozic.AL_USER_DEFAULTS_MIGRATION";
static NSString *const AL_DOCUMENT_OPTION = @"com.applozic.AL_DOCUMENT_OPTION";
static NSString *const AL_SENT_MESSAGE_CONTACT_BUTTON = @"com.applozic.AL_SENT_MESSAGE_CONTACT_BUTTON";
static NSString *const AL_SENT_CONTACT_MSG_LABEL_COLOR = @"com.applozic.AL_SENT_CONTACT_MSG_LABEL_COLOR";
static NSString *const AL_RECEIVED_CONTACT_MSG_LABEL_COLOR = @"com.applozic.AL_RECEIVED_CONTACT_MSG_LABEL_COLOR";
static NSString *const AL_IMAGE_PREVIEW_BACKGROUND_COLOR = @"com.applozic.AL_IMAGE_PREVIEW_BACKGROUND_COLOR";
static NSString *const AL_RESTRICTED_MESSAGE_PATTERN  = @"com.applozic.AL_RESTRICTED_MESSAGE_PATTERN";
static NSString *const AL_DISABLE_NOTIFICATION_TAP = @"com.applozic.AL_DISABLE_NOTIFICATION_TAP";
static NSString *const AL_GROUPS_LIST_TAB = @"com.applozic.AL_GROUPS_LIST_TAB";
static NSString *const AL_MESSAGE_SEARCH = @"com.applozic.AL_MESSAGE_SEARCH";
static NSString *const AL_MESSAGE_DELETE_FOR_ALL_ENABLED = @"com.applozic.userdefault.AL_MESSAGE_DELETE_FOR_ALL_ENABLED";
static NSString *const AL_PHOTO_PICKER_SELECTION_LIMIT = @"com.applozic.userdefault.AL_PHOTO_PICKER_SELECTION_LIMIT";
static NSString *const AL_MESSAGE_META_DATA_KEY = @"com.applozic.userdefault.AL_MESSAGE_META_DATA_KEY";
static NSString *const AL_SUPPORT_CONTACT_USER_ID = @"com.applozic.userdefault.AL_SUPPORT_CONTACT_USER_ID";
static NSString *const AL_AGENTAPP_CONFIGURATION = @"com.applozic.userdefault.AL_AGENTAPP_CONFIGURATION";
static NSString *const AL_CUSTOM_BOT_NAME = @"com.applozic.userdefault.AL_CUSTOM_BOT_NAME";
static NSString *const AL_CUSTOM_BOT_ID = @"com.applozic.userdefault.AL_CUSTOM_BOT_ID";
static NSString *const KM_ZENDESK_ACCOUNT_KEY = @"com.applozic.userdefault.KM_ZENDESK_ACCOUNT_KEY";
static NSString *const KM_ZENDESK_LAST_CONVERSATION_ID = @"com.applozic.userdefault.KM_ZENDESK_LAST_CONVERSATION_ID";
static NSString *const KM_ZENDESK_LAST_SYNC_TIME = @"com.applozic.userdefault.KM_ZENDESK_LAST_SYNC_TIME";
static NSString *const KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT = @"KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT";
static NSString *const KM_DEFAULT_UPLOAD_URL = @"KM_DEFAULT_UPLOAD_URL";
static NSString *const KM_DEFAULT_UPLOAD_HEADERS = @"KM_DEFAULT_UPLOAD_HEADERS";
static NSString *const KM_IS_SINGLE_THREADED =  @"KM_IS_SINGLE_THREADED";

@interface ALApplozicSettings : NSObject

@property (strong, nonatomic) NSUserDefaults *userDefaults;


+ (void)setFontFace:(NSString *)fontFace;
+ (NSString *)getFontFace;

// works with font face for iOS 11, uses system font face for iOS 10, being ignored for versions below
+ (void)setChatCellFontTextStyle:(NSString *)fontTextStyle;
+ (NSString *)getChatCellFontTextStyle;

// works with font face for iOS 11, uses system font face for iOS 10, being ignored for versions below
+ (void)setChatChannelCellFontTextStyle:(NSString *)fontTextStyle;
+ (NSString *)getChatChannelCellFontTextStyle;

+ (void)setUserProfileHidden:(BOOL)flag;

+ (BOOL)isUserProfileHidden;

+ (void)setColorForSendMessages:(UIColor *)sendMsgColor;

+ (void)setColorForReceiveMessages:(UIColor *)receiveMsgColor;

+ (UIColor *)getSendMsgColor;

+ (UIColor *)getReceiveMsgColor;

+ (void)setColorForNavigation:(UIColor *)barColor;

+ (UIColor *)getColorForNavigation;

+ (void)setColorForNavigationItem:(UIColor *)barItemColor;

+ (UIColor *)getColorForNavigationItem;

+ (void)hideRefreshButton:(BOOL)state;

+ (BOOL)isRefreshButtonHidden;

+ (void)setTitleForConversationScreen:(NSString *)titleText;

+ (NSString *)getTitleForConversationScreen;

+ (void)setTitleForBackButtonMsgVC:(NSString *)backButtonTitle;
+ (NSString *)getTitleForBackButtonMsgVC;

+ (NSString *)getTitleForBackButtonChatVC;
+ (void)setTitleForBackButtonChatVC:(NSString *)backButtonTitle;

+ (void)setNotificationTitle:(NSString *)notificationTitle;

+ (NSString *)getNotificationTitle;

+ (void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize;

+ (NSInteger)getMaxImageSizeForUploadInMB;

+ (void)setMaxCompressionFactor:(double)maxCompressionRatio;

+ (double)getMaxCompressionFactor;

+ (void)setGroupOption:(BOOL)option;

+ (BOOL)getGroupOption;

+ (void)setMultipleAttachmentMaxLimit:(NSInteger)limit;

+ (NSInteger)getMultipleAttachmentMaxLimit;

+ (void)setFilterContactsStatus:(BOOL)flag;

+ (BOOL)getFilterContactsStatus;

+ (void)setStartTime:(NSNumber *)startTime;

+ (NSNumber *)getStartTime;

+ (void)setChatWallpaperImageName:(NSString *)imageName;

+ (NSString *)getChatWallpaperImageName;

+ (void)setCustomMessageBackgroundColor:(UIColor *)color;

+ (UIColor *)getCustomMessageBackgroundColor;

+ (void)setCustomMessageTextColor:(UIColor *)color;
+ (UIColor *)getCustomMessageTextColor;

+ (void)setGroupExitOption:(BOOL)option;
+ (BOOL)getGroupExitOption;

+ (void)setGroupMemberAddOption:(BOOL)option;
+ (BOOL)getGroupMemberAddOption;

+ (void)setGroupMemberRemoveOption:(BOOL)option;
+ (BOOL)getGroupMemberRemoveOption;

+ (void)setOnlineContactLimit:(NSInteger)limit;
+ (NSInteger)getOnlineContactLimit;

+ (NSString *)getCustomClassName;
+ (void)setCustomClassName:(NSString *)className;

// When a user taps on title view in ALChatViewController  with this option you can receive notification with name thirdPartyDetailVCNotification with options to show custom group detail VC
// might be blocked by "setGroupInfoDisabled" and "setReceiverUserProfileOption"
+ (BOOL)getOptionToPushNotificationToShowCustomGroupDetalVC;
+ (void)setOptionToPushNotificationToShowCustomGroupDetalVC:(BOOL)option;

+ (void)setContextualChat:(BOOL)option;
+ (BOOL)getContextualChatOption;

+ (void)setCallOption:(BOOL)flag;
+ (BOOL)getCallOption;

// Enable/Diable Notification Sound
+ (void)enableNotificationSound;
+ (void)disableNotificationSound;
// Enable/Diable Notification Complete
+ (void)enableNotification;
+ (void)disableNotification;

+ (UIColor *)getColorForSendButton;
+ (void)setColorForSendButton:(UIColor *)color;

+ (UIColor *)getColorForTypeMsgBackground;
+ (void)setColorForTypeMsgBackground:(UIColor *)viewColor;

+ (UIColor *)getBGColorForTypingLabel;
+ (void)setBGColorForTypingLabel:(UIColor *)bgColor;

+ (UIColor *)getTextColorForTypingLabel;
+ (void)setTextColorForTypingLabel:(UIColor *)txtColor;

+ (NSString *)getEmptyConversationText;
+ (void)setEmptyConversationText:(NSString *)text;

+ (BOOL)getVisibilityNoConversationLabelChatVC;
+ (void)setVisibilityNoConversationLabelChatVC:(BOOL)flag;

+ (BOOL)getVisibilityForOnlineIndicator;
+ (void)setVisibilityForOnlineIndicator:(BOOL)flag;

+ (BOOL)getVisibilityForNoMoreConversationMsgVC;
+ (void)setVisibilityForNoMoreConversationMsgVC:(BOOL)flag;

+ (BOOL)isRefreshChatButtonEnabledInMsgVc;
+ (void)enableRefreshChatButtonInMsgVc:(BOOL)flag;

+ (UIColor *)getColorForToastText;
+ (void)setColorForToastText:(UIColor *)toastTextColor;

+ (UIColor *)getColorForToastBackground;
+ (void)setColorForToastBackground:(UIColor *)toastBGColor;

+ (UIColor *)getSendMsgTextColor;
+ (void)setSendMsgTextColor:(UIColor *)sendMsgColor;

+ (UIColor *)getReceiveMsgTextColor;
+ (void)setReceiveMsgTextColor:(UIColor *)receiveMsgColor;

+ (UIColor *)getMsgTextViewBGColor;
+ (void)setMsgTextViewBGColor:(UIColor *)color;

+ (UIColor *)getPlaceHolderColor;
+ (void)setPlaceHolderColor:(UIColor *)color;

+ (UIColor *)getUnreadCountLabelBGColor;
+ (void)setUnreadCountLabelBGColor:(UIColor *)color;

+ (UIColor *)getStatusBarBGColor;
+ (void)setStatusBarBGColor:(UIColor *)color;

+ (UIStatusBarStyle)getStatusBarStyle;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style;

+ (void)setMaxTextViewLines:(int)numberOfLines;
+ (int)getMaxTextViewLines;

+ (void)setAbuseWarningText:(NSString *)warningText;
+ (NSString *)getAbuseWarningText;

+ (BOOL)getMessageAbuseMode;
+ (void)setMessageAbuseMode:(BOOL)flag;

+ (UIColor *)getDateColor;
+ (void)setDateColor:(UIColor *)dateColor;

+ (UIColor *)getMsgDateColor;
+ (void)setMsgDateColor:(UIColor *)dateColor;

+ (BOOL)getReceiverUserProfileOption;
+ (void)setReceiverUserProfileOption:(BOOL)flag;

+ (float)getCustomMessageFontSize;
+ (void)setCustomMessageFontSize:(float)fontSize;

+ (NSString *)getCustomMessageFont;
+ (void)setCustomMessageFont:(NSString *)font;

+ (void) setGroupInfoDisabled:(BOOL)flag;
+ (BOOL) isGroupInfoDisabled;

+ (void) setGroupInfoEditDisabled:(BOOL)flag;
+ (BOOL) isGroupInfoEditDisabled;

+ (void)setGroupOfTwoFlag:(BOOL)flag;
+ (BOOL)getGroupOfTwoFlag;

+ (void)setBroadcastGroupEnable:(BOOL)flag;
+ (BOOL)isBroadcastGroupEnable;

+ (void) setContactTypeToFilter:(NSMutableArray *)arrayWithIds;
+ (NSMutableArray*) getContactTypeToFilter;

+ (NSString *)getCustomNavigationControllerClassName;
+ (void)setNavigationControllerClassName:(NSString *)className;

+ (BOOL)getSubGroupLaunchFlag;
+ (void)setSubGroupLaunchFlag:(BOOL)flag;

+ (NSArray *)getListOfViewControllers;
+ (void)setListOfViewControllers:(NSArray *)viewList;

+ (void)setMsgContainerVC:(NSString *)className;
+ (NSString *)getMsgContainerVC;

+ (NSString *)getAudioVideoClassName;
+ (void)setAudioVideoClassName:(NSString *)className;

+ (NSString *)getClientStoryBoard;
+ (void)setClientStoryBoard:(NSString *)storyboard;
+ (NSString *)getGroupDeletedTitle;
+ (void)setGroupDeletedTitle:(NSString *)title;

+ (NSString *)getUserDeletedText;
+ (void)setUserDeletedText:(NSString *)text;

+ (UIImage *)getChatListTabIcon;
+ (void)setChatListTabIcon:(NSString *)imageName;

+ (NSString *)getChatListTabTitle;
+ (void)setChatListTabTitle:(NSString *)title;

+ (UIImage *)getProfileTabIcon;
+ (void)setProfileTabIcon:(NSString *)imageName;

+ (NSString *)getProfileTabTitle;
+ (void)setProfileTabTitle:(NSString *)title;

+ (BOOL)isChatOnTapUserProfile;
+ (void)openChatOnTapUserProfile:(BOOL)flag;

+ (BOOL)isReplyOptionEnabled;
+ (void)replyOptionEnabled:(BOOL)flag;

+ (BOOL)isAudioVideoEnabled;
+ (void)setAudioVideoEnabled:(BOOL)flag;

+ (void)enableOrDisableContactsGroup:(BOOL)flag;

+ (BOOL)isContactsGroupEnabled;

+ (void)setContactsGroupId:(NSString *)contactsGroupId;

+ (NSString *)getContactsGroupId;

+ (void)setContactGroupIdList:(NSArray *)contactIdList;

+ (NSArray*)getContactGroupIdList;

+ (void)forwardOptionEnableOrDisable:(BOOL)flag;

+ (BOOL)isForwardOptionEnabled;

+ (BOOL)isSwiftFramework;
+ (void)setSwiftFramework:(BOOL)flag;

+ (BOOL)isStorageServiceEnabled;
+ (void)enableStorageService:(BOOL)flag;

+ (BOOL)isGoogleCloudServiceEnabled;
+ (void)enableGoogleCloudService:(BOOL)flag;

+ (BOOL)isConversationCloseButtonEnabled;
+ (void)setConversationCloseButton:(BOOL)flag;

+ (void)setHideAttachmentsOption:(NSArray *)array;

+ (NSArray*)getHideAttachmentsOption;

+ (BOOL)isCameraOptionHidden;
+ (BOOL)isPhotoGalleryOptionHidden;
+ (BOOL)isSendAudioOptionHidden;
+ (BOOL)isSendVideoOptionHidden;
+ (BOOL)isLocationOptionHidden;
+ (BOOL)isBlockUserOptionHidden;
+ (BOOL)isShareContactOptionHidden;
+ (BOOL)isAttachmentButtonHidden;
+ (BOOL)isDocumentOptionHidden;
+ (BOOL)isS3StorageServiceEnabled;
+ (void)enableS3StorageService:(BOOL)flag;
+ (void) setDefaultGroupType:(NSInteger)type;
+ (NSInteger) getDefaultGroupType;
+ (void) enableSaveVideosToGallery:(BOOL)flag;
+ (BOOL) isSaveVideoToGalleryEnabled;
+ (void) enableQuickAudioRecording:(BOOL)flag;
+ (BOOL) isQuickAudioRecordingEnabled;

+ (void)setUserRoleName:(NSString*)roleName;
+ (NSString*)getUserRoleName;

+ (void)setDropShadowInNavigationBar:(BOOL)flag;
+ (BOOL)isDropShadowInNavigationBarEnabled;

+ (void)setDeleteConversationOption:(BOOL)flag;
+ (BOOL)isDeleteConversationOptionEnabled;

+ (NSString *)getLocalizableName;
+ (void)setLocalizableName:(NSString *)localizableName;
+ (void)setTemplateMessages:(NSMutableDictionary *)dictionary;
+ (NSMutableDictionary*) getTemplateMessages;

+ (BOOL)isTemplateMessageEnabled;
+ (void)enableTeamplateMessage:(BOOL)flag;

+ (void)setCategoryName:(NSString*)categoryName;
+ (NSString*)getCategoryName;

+ (BOOL)isContactSearchEnabled;
+ (void)enableContactSearch:(BOOL)flag;

+ (BOOL)isChannelMembersInfoInNavigationBarEnabled;
+ (void)showChannelMembersInfoInNavigationBar:(BOOL)flag;

+ (UIColor *)getTabBarBackgroundColour;
+ (void) setTabBarBackgroundColour:(UIColor *)color;
+ (UIColor *)getTabBarSelectedItemColour;
+ (void) setTabBarSelectedItemColour:(UIColor *)color;
+ (UIColor *)getTabBarUnSelectedItemColour;
+ (void) setTabBarUnSelectedItemColour:(UIColor *)color;
+ (UIColor *)getAttachmentIconColour;
+ (void)setAttachmentIconColour:(UIColor *)color;
+ (UIColor *)getSendIconColour;
+ (void) setSendIconColour:(UIColor *)color;
+ (UIColor *)getMessageSubtextColour;
+ (void)setMessageSubtextColour:(UIColor *)color;
+ (UIColor *)getProfileMainColour;
+ (void) setProfileMainColour:(UIColor *)color;
+ (UIColor *)getProfileSubColour;
+ (void) setProfileSubColour:(UIColor *)color;
+ (UIColor *)getNewContactMainColour;
+ (void) setNewContactMainColour:(UIColor *)color;
+ (UIColor *)getNewContactSubColour;
+ (void)setNewContactSubColour:(UIColor *)color;
+ (UIColor *)getNewContactTextColour;
+ (void) setNewContactTextColour:(UIColor *)color;
+ (UIColor *)getMessageListTextColor;
+ (void) setMessageListTextColor:(UIColor *)color;
+ (UIColor *)getMessagesViewBackgroundColour;
+ (void)setMessagesViewBackgroundColour:(UIColor *)color;
+ (UIColor *)getChatViewControllerBackgroundColor;
+ (void) setChatViewControllerBackgroundColor:(UIColor *)color;
+ (UIColor *)getSearchBarTintColour;
+ (void)setSearchBarTintColour:(UIColor *)color;

+ (NSArray *)metadataKeysToHideMessages;
+ (void)hideMessagesWithMetadataKeys:(NSArray *)keys;

+ (BOOL)isMultiSelectGalleryViewDisabled;
+ (void)disableMultiSelectGalleryView:(BOOL)enabled;

+ (BOOL)is5MinVideoLimitInGalleryEnabled;
+ (void)enable5MinVideoLimitInGallery:(BOOL)enabled;

+ (void)setBackgroundColorForAttachmentPlusIcon:(UIColor *)backgroundColor;
+ (UIColor *)getBackgroundColorForAttachmentPlusIcon;
+ (void)clearAll;

+ (BOOL)isTextStyleInCellEnabled;
+ (void)enableTextStyleCell:(BOOL)enabled;

+ (void)setChatCellTextFontSize:(float)fontSize;
+ (float)getChatCellTextFontSize;

+ (void)setChannelCellTextFontSize:(float)fontSize;
+ (float)getChannelCellTextFontSize;

+ (void)setBackgroundColorForAudioRecordingView:(UIColor *)backgroundColor;
+ (UIColor *)getBackgroundColorForAudioRecordingView;

+ (void)setColorForSlideToCancelText:(UIColor *)color;
+ (UIColor *)getColorForSlideToCancelText;

+ (void)setColorForAudioRecordingText:(UIColor *)color;
+ (UIColor *)getColorForAudioRecordingText;

+ (void)setFontForAudioView:(NSString *)font;
+ (NSString *)getFontForAudioView;

+ (void)enableNewAudioDesign:(BOOL)enable;
+ (BOOL)isNewAudioDesignEnabled;

+ (void)setBackgroundColorForReplyView:(UIColor *)backgroudColor;
+ (UIColor *)getBackgroundColorForReplyView;

+ (void)setHideMediaSelectOption:(NSMutableArray *)array;
+ (NSArray *)getHideMediaSelectOption;

+ (BOOL)imagesHiddenInGallery;
+ (BOOL)videosHiddenInGallery;

+ (void)setTextColorForMessageTextView:(UIColor *)txtColor;
+ (UIColor *)getTextColorForMessageTextView;

+ (void)setChannelActionMessageBgColor:(UIColor *)txtColor;
+ (UIColor *)getChannelActionMessageBgColor;

+ (void)setChannelActionMessageTextColor:(UIColor *)txtColor;
+ (UIColor *)getChannelActionMessageTextColor;

+ (void)setUserIconFirstNameColorCodes:(NSMutableDictionary *)nsMutableDictionary;
+ (NSMutableDictionary*) getUserIconFirstNameColorCodes;

// Enable/Disable unblock users from sendMessageTextView
+ (void)setIsUnblockInChatDisabled:(BOOL)flag;
+ (BOOL)isUnblockInChatDisabled;

+ (void)setupSuiteAndMigrate;
+ (NSString *)getShareExtentionGroup;

+ (BOOL)isDocumentOptionEnabled;
+ (void)enableDocumentOption:(BOOL)flag;

+ (BOOL)isAddContactButtonForSenderDisabled;
+ (void)disableAddContactButtonForSender;

+ (void)setColorForSentContactMsgLabel:(UIColor *)sentContactLabelMsgColor;
+ (void)setColorForReceivedContactMsgLabel:(UIColor *)receivedMsgColor;

+ (UIColor *)getSentContactMsgLabelColor;
+ (UIColor *)getReceivedContactMsgLabelColor;

+ (void)setImagePreviewBackgroundColor:(UIColor *)color;
+ (UIColor *)getImagePreviewBackgroundColor;

+ (void)restrictedMessageRegexPattern:(NSString *)pattern;
+ (NSString *)getRestrictedMessageRegexPattern;

+ (void)disableInAppNotificationTap:(BOOL)flag;
+ (BOOL)isInAppNotificationTapDisabled;

+ (void)disableGroupListingTab:(BOOL)flag;
+ (BOOL)isGroupListingTabDisabled;

+ (void)enableMessageSearch:(BOOL)flag;

+ (BOOL)isMessageSearchEnabled;

+ (void)enableMessageDeleteForAllOption:(BOOL)flag;
+ (BOOL)isMessageDeleteForAllEnabled;

+ (void)setPhotosSelectionLimit:(NSInteger)selectionLimit;
+ (NSInteger)getPhotosSelectionLimit;

+ (void)setMessageMetadata:(NSMutableDictionary *)messageMetadata;
+ (NSMutableDictionary *)getMessageMetadata;

/// Support contact userId can be set for  showing the support contact at top in contact screen.
+ (void)setSupportContactUserId:(NSString *)userId;
+ (NSString *)getSupportContactUserId;

+ (void) enableAgentApConfiguration:(BOOL) flag;
+ (BOOL) isAgentAppConfigurationEnabled;

+ (void)setCustomBotName:(NSString *)customBotName;
+ (NSString *)getCustomBotName;

+(void)setCustomizedBotId:(NSString *)customizedBotId;
+ (NSString *)getCustomizedBotId;

+ (void)clearCustomBotConfiguration;

+ (void) setZendeskSdkAccountKey:(NSString *) accountKey;
+ (NSString *) getZendeskSdkAccountKey;

+ (void) setLastZendeskConversationId: (NSNumber *) conversationId;
+ (NSNumber *) getLastZendeskConversationId;

+ (void) saveZendeskLastSyncTime: (NSNumber *) lastSyncTime;
+ (NSNumber *) getZendeskLastSyncTime;

+ (void) setSelectedLanguageForSpeechToText: (NSString *) language;
+ (NSString *) getSelectedLanguageForSpeechToText;

+ (void) setDefaultOverrideuploadUrl: (NSString *) url;
+ (NSString *) getDefaultOverrideuploadUrl;

+ (void) setDefaultOverrideuploadHeaders: (NSMutableDictionary *) headers;
+ (NSMutableDictionary *) getDefaultOverrideuploadHeaders;

+ (void) setIsSingleThreadedEnabled: (BOOL) flag;
+ (BOOL) getIsSingleThreadedEnabled;

+ (void) setIsChatTranscriptSent:(NSString*)groupId;
+ (BOOL) isChatTranscriptSent:(NSString*)groupId;

@end
