//
//  KMCoreSettings.h
//  Kommunicate
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const KM_CORE_USER_PROFILE_PROPERTY = @"io.kommunicate.core.userdefault.USER_PROFILE_PROPERTY";
static NSString *const KM_CORE_SEND_MSG_COLOUR = @"io.kommunicate.core.userdefault.SEND_MSG_COLOUR";
static NSString *const KM_CORE_RECEIVE_MSG_COLOUR = @"io.kommunicate.core.userdefault.RECEIVE_MSG_COLOUR";
static NSString *const KM_CORE_NAVIGATION_BAR_COLOUR = @"io.kommunicate.core.userdefault.NAVIGATION_BAR_COLOUR";
static NSString *const KM_CORE_NAVIGATION_BAR_ITEM_COLOUR = @"io.kommunicate.core.userdefault.NAVIGATION_BAR_ITEM_COLOUR";
static NSString *const KM_CORE_REFRESH_BUTTON_VISIBILITY = @"io.kommunicate.core.userdefault.REFRESH_BUTTON_VISIBILITY";
static NSString *const KM_CORE_CONVERSATION_TITLE = @"io.kommunicate.core.userdefault.CONVERSATION_TITLE";
static NSString *const KM_CORE_BACK_BUTTON_TITLE = @"io.kommunicate.core.userdefault.BACK_BUTTON_TITLE";
static NSString *const KM_CORE_FONT_FACE = @"io.kommunicate.core.userdefault.FONT_FACE";
static NSString *const KM_CORE_CHAT_CELL_FONT_TEXT_STYLE = @"io.kommunicate.core.userdefault.CHAT_CELL_FONT_TEXT_STYLE";
static NSString *const KM_CORE_CHAT_CHANNEL_CELL_FONT_TEXT_STYLE = @"io.kommunicate.core.userdefault.CHAT_CHANNEL_CELL_FONT_TEXT_STYLE";
static NSString *const KM_CORE_NOTIFICATION_TITLE = @"io.kommunicate.core.userdefault.NOTIFICATION_TITLE";
static NSString *const KM_CORE_IMAGE_COMPRESSION_FACTOR = @"io.kommunicate.core.userdefault.IMAGE_COMPRESSION_FACTOR";
static NSString *const KM_CORE_IMAGE_UPLOAD_MAX_SIZE = @"io.kommunicate.core.userdefault.IMAGE_UPLOAD_MAX_SIZE";
static NSString *const KM_CORE_GROUP_ENABLE = @"io.kommunicate.core.userdefault.GROUP_ENABLE";
static NSString *const KM_CORE_GROUP_INFO_DISABLED = @"io.kommunicate.core.userdefault.GROUP_INFO_DISABLED";
static NSString *const KM_CORE_GROUP_INFO_EDIT_DISABLED = @"io.kommunicate.core.userdefault.GROUP_INFO_EDIT_DISABLED";
static NSString *const KM_CORE_MAX_SEND_ATTACHMENT = @"io.kommunicate.core.userdefault.MAX_SEND_ATTACHMENT";
static NSString *const KM_CORE_FILTER_CONTACT = @"io.kommunicate.core.userdefault.FILTER_CONTACT";
static NSString *const KM_CORE_FILTER_CONTACT_START_TIME = @"io.kommunicate.core.userdefault.FILTER_CONTACT_START_TIME";
static NSString *const KM_CORE_WALLPAPER_IMAGE = @"io.kommunicate.core.userdefault.WALLPAPER_IMAGE";
static NSString *const KM_CORE_CUSTOM_MSG_BACKGROUND_COLOR = @"io.kommunicate.core.userdefault.CUSTOM_MSG_BACKGROUND_COLOR";
static NSString *const KM_CORE_CUSTOM_MSG_TEXT_COLOR = @"io.kommunicate.core.userdefault.CUSTOM_MSG_TEXT_COLOR";
static NSString *const KM_CORE_ONLINE_CONTACT_LIMIT = @"io.kommunicate.core.userdefault.ONLINE_CONTACT_LIMIT";
static NSString *const KM_CORE_GROUP_EXIT_BUTTON = @"io.kommunicate.core.userdefault.GROUP_EXIT_BUTTON";
static NSString *const KM_CORE_GROUP_MEMBER_ADD_OPTION = @"io.kommunicate.core.userdefault.GROUP_MEMBER_ADD_OPTION";
static NSString *const KM_CORE_GROUP_MEMBER_REMOVE_OPTION = @"io.kommunicate.core.userdefault.GROUP_MEMBER_REMOVE_OPTION";
static NSString *const KM_CORE_THIRD_PARTY_VC_NAME = @"io.kommunicate.core.userdefault.THIRD_PARTY_VC_NAME";
static NSString *const KM_CORE_THIRD_PARTY_DETAIL_VC_NOTIFICATION = @"io.kommunicate.core.userdefault.THIRD_PARTY_DETAIL_VC_NOTIFICATION";
static NSString *const KM_CORE_CONTEXTUAL_CHAT_OPTION = @"io.kommunicate.core.userdefault.CONTEXTUAL_CHAT_OPTION";
static NSString *const KM_CORE_USER_CALL_OPTION = @"io.kommunicate.core.userdefault.USER_CALL_OPTION";
static NSString *const KM_CORE_SEND_BUTTON_BG_COLOR = @"io.kommunicate.core.userdefault.SEND_BUTTON_BG_COLOR";
static NSString *const KM_CORE_TYPE_MSG_BG_COLOR = @"io.kommunicate.core.userdefault.TYPE_MSG_BG_COLOR";
static NSString *const KM_CORE_TYPING_LABEL_BG_COLOR = @"io.kommunicate.core.userdefault.TYPING_LABEL_BG_COLOR";
static NSString *const KM_CORE_TYPING_LABEL_TEXT_COLOR = @"io.kommunicate.core.userdefault.TYPING_LABEL_TEXT_COLOR";
static NSString *const KM_CORE_EMPTY_CONVERSATION_TEXT = @"io.kommunicate.core.userdefault.EMPTY_CONVERSATION_TEXT";
static NSString *const KM_CORE_NO_CONVERSATION_FLAG_CHAT_VC = @"io.kommunicate.core.userdefault.NO_CONVERSATION_FLAG_CHAT_VC";
static NSString *const KM_CORE_ONLINE_INDICATOR_VISIBILITY = @"io.kommunicate.core.userdefault.ONLINE_INDICATOR_VISIBILITY";
static NSString *const KM_CORE_BACK_BUTTON_TITLE_CHATVC = @"io.kommunicate.core.userdefault.BACK_BUTTON_TITLE_CHATVC";
static NSString *const KM_CORE_NO_MORE_CONVERSATION_VISIBILITY = @"io.kommunicate.core.userdefault.NO_MORE_CONVERSATION_VISIBILITY";
static NSString *const KM_CORE_CUSTOM_NAV_RIGHT_BUTTON_MSGVC = @"io.kommunicate.core.userdefault.CUSTOM_NAV_RIGHT_BUTTON_MSGVC";
static NSString *const KM_CORE_TOAST_BG_COLOUR = @"io.kommunicate.core.userdefault.TOAST_BG_COLOUR";
static NSString *const KM_CORE_TOAST_TEXT_COLOUR = @"io.kommunicate.core.userdefault.TOAST_TEXT_COLOUR";
static NSString *const KM_CORE_SEND_MSG_TEXT_COLOUR = @"io.kommunicate.core.userdefault.SEND_MSG_TEXT_COLOUR";
static NSString *const KM_CORE_RECEIVE_MSG_TEXT_COLOUR = @"io.kommunicate.core.userdefault.RECEIVE_MSG_TEXT_COLOUR";
static NSString *const KM_CORE_MSG_TEXT_BG_COLOUR = @"io.kommunicate.core.userdefault.MSG_TEXT_BG_COLOUR";
static NSString *const KM_CORE_PLACE_HOLDER_COLOUR = @"io.kommunicate.core.userdefault.PLACE_HOLDER_COLOUR";
static NSString *const KM_CORE_UNREAD_COUNT_LABEL_BG_COLOUR = @"io.kommunicate.core.userdefault.UNREAD_COUNT_LABEL_BG_COLOUR";
static NSString *const KM_CORE_STATUS_BAR_BG_COLOUR = @"io.kommunicate.core.userdefault.STATUS_BAR_BG_COLOUR";
static NSString *const KM_CORE_STATUS_BAR_STYLE = @"io.kommunicate.core.userdefault.STATUS_BAR_STYLE";
static NSString *const KM_CORE_MAX_TEXT_VIEW_LINES = @"io.kommunicate.core.userdefault.MAX_TEXT_VIEW_LINES";
static NSString *const KM_CORE_ABUSE_WORDS_WARNING_TEXT = @"io.kommunicate.core.userdefault.ABUSE_WORDS_WARNING_TEXT";
static NSString *const KM_CORE_ENABLE_MSGTEXT_ABUSE_CHECK = @"io.kommunicate.core.userdefault.ENABLE_MSGTEXT_ABUSE_CHECK";
static NSString *const KM_CORE_MSG_DATE_COLOR = @"io.kommunicate.core.userdefault.MSG_DATE_COLOR";
static NSString *const KM_CORE_MSG_SEPERATE_DATE_COLOR = @"io.kommunicate.core.userdefault.MSG_SEPERATE_DATE_COLOR";
static NSString *const KM_CORE_ENABLE_RECEIVER_USER_PROFILE = @"io.kommunicate.core.userdefault.ENABLE_RECEIVER_USER_PROFILE";
static NSString *const KM_CORE_CUSTOM_MSG_FONT_SIZE = @"io.kommunicate.core.userdefault.CUSTOM_MSG_FONT_SIZE";
static NSString *const KM_CORE_CUSTOM_MSG_FONT = @"io.kommunicate.core.userdefault.CUSTOM_MSG_FONT";
static NSString *const KM_CORE_FILTER_ONLY_CONTACT_TYPE_ID = @"io.kommunicate.core.userdefault.FILTER_ONLY_CONTACT_TYPE_ID";
static NSString *const KM_CORE_CUSTOM_NAVIGATION_CLASS_NAME = @"io.kommunicate.core.userdefault.NAVIGATION_CONTROLLER_CLASS_NAME";
static NSString *const KM_CORE_SUB_GROUP_LAUNCH = @"io.kommunicate.core.userdefault.SUB_GROUP_LAUNCH";
static NSString *const KM_CORE_GROUP_OF_TWO_FLAG = @"io.kommunicate.core.userdefault.GROUP_OF_TWO_FLAG";
static NSString *const KM_CORE_BROADCAST_GROUP_ENABLE = @"io.kommunicate.core.userdefault.BROADCAST_GROUP_ENABLE";
static NSString *const KM_CORE_VIEW_CONTROLLER_ARRAY = @"io.kommunicate.core.userdefault.VIEW_CONTROLLER_ARRAY";
static NSString *const KM_CORE_MSG_CONTAINER_VC = @"io.kommunicate.core.userdefault.MSG_CONTAINER_VC";
static NSString *const KM_CORE_AUDIO_VIDEO_CLASS = @"io.kommunicate.core.userdefault.AUDIO_VIDEO_CLASS";
static NSString *const KM_CORE_CLIENT_STORYBOARD = @"io.kommunicate.core.userdefault.CLIENT_STORYBOARD";
static NSString *const KM_CORE_GROUP_DELETED_TITLE = @"io.kommunicate.core.userdefault.GROUP_DELETED_TITLE";
static NSString *const KM_CORE_USER_DELETED_TEXT = @"io.kommunicate.core.userdefault.USER_DELETED_TEXT";
static NSString *const KM_CORE_CHAT_LIST_TAB_ICON = @"io.kommunicate.core.userdefault.CHAT_LIST_TAB_ICON";
static NSString *const KM_CORE_USER_PROFILE_TAB_ICON = @"io.kommunicate.core.userdefault.USER_PROFILE_TAB_ICON";
static NSString *const KM_CORE_CHAT_LIST_TAB_TITLE = @"io.kommunicate.core.userdefault.CHAT_LIST_TAB_TITLE";
static NSString *const KM_CORE_USER_PROFILE_TAB_TITLE = @"io.kommunicate.core.userdefault.USER_PROFILE_TAB_TITLE";
static NSString *const KM_CORE_OPEN_CHAT_ON_USER_PROFILE_TAP = @"io.kommunicate.core.userdefault.OPEN_CHAT_ON_USER_PROFILE_TAP";
static NSString *const KM_CORE_MESSAGE_REPLY_ENABLED = @"io.kommunicate.core.userdefault.MESSAGE_REPLY_MESSAGE";
static NSString *const KM_CORE_AV_ENABLED = @"io.kommunicate.core.userfefault.AV_ENABLED";
static NSString *const KM_CORE_CONTACTS_GROUP = @"io.kommunicate.core.userdefault.CONTACTS_GROUP";
static NSString *const KM_CORE_CONTACTS_GROUP_ID = @"io.kommunicate.core.userdefault.CONTACTS_GROUP_ID";
static NSString *const KM_CORE_FORWARD_OPTION = @"io.kommunicate.core.userdefault.FORWARD_OPTION";
static NSString *const KM_CORE_SWIFT_FRAMEWORK = @"io.kommunicate.core.userfefault.SWIFT_FRAMEWORK";
static NSString *const KM_CORE_DEDICATED_SERVER = @"io.kommunicate.core.userfefault.DEDICATED_SERVER";
static NSString *const KM_CORE_HIDE_ATTACHMENT_OPTION = @"io.kommunicate.core.HIDE_ATTACHMENT_OPTIONS";
static NSString *const KM_CORE_S3_STORAGE_SERVICE = @"io.kommunicate.core.userdefault.S3_STORAGE_SERVICE";
static NSString *const KM_CORE_DEFAULT_GROUP_TYPE = @"io.kommunicate.core.DEFAULT_GROUP_TYPE";
static NSString *const KM_CORE_CONTACTS_GROUP_ID_LIST = @"io.kommunicate.core.userdefault.CONTACTS_GROUP_ID_LIST";
static NSString *const KM_CORE_SAVE_VIDEOS_TO_GALLERY = @"io.kommunicate.core.userdefault.SAVE_VIDEOS_TO_GALLERY";
static NSString *const KM_CORE_ENABLE_QUICK_AUDIO_RECORDING = @"io.kommunicate.core.userdefault.ENABLE_QUICK_AUDIO_RECORDING";
static NSString *const KM_CORE_USER_ROLE_NAME = @"io.kommunicate.core.userdefault.AL_USER_ROLE_NAME";
static NSString *const KM_CORE_GROUP_CONVEERSATION_CLOSE = @"io.kommunicate.core.userdefault.AL_GROUP_CONVEERSATION_CLOSE";
static NSString *const KM_CORE_DROP_IN_SHADOW_IN_NAVIGATION_BAR = @"io.kommunicate.core.userdefault.DROP_IN_SHADOW_IN_NAVIGATION_BAR";
static NSString *const KM_CORE_APPLOZIC_LOCALIZABLE = @"io.kommunicate.core.userdefault.APPLOZIC_LOCALIZABLE";
static NSString *const KM_CORE_CATEGORY_NAME = @"io.kommunicate.core.userdefault.AL_CATEGORY_NAME";
static NSString *const KM_CORE_DELETE_CONVERSATION_OPTION = @"io.kommunicate.core.userdefault.DELETE_CONVERSATION_OPTION";
static NSString *const KM_CORE_GOOGLE_CLOUD_SERVICE_ENABLE = @"io.kommunicate.core.userdefault.GOOGLE_CLOUD_SERVICE_ENABLE";
static NSString *const KM_CORE_TEMPLATE_MESSAGES = @"io.kommunicate.core.TEMPLATE_MESSAGES";
static NSString *const KM_CORE_TEMPLATE_MESSAGE_VIEW = @"io.kommunicate.core.TEMPLATE_MESSAGE_VIEW";
static NSString *const KM_CORE_CONTACT_SEARCH = @"io.kommunicate.core.AL_CONTACT_SEARCH";
static NSString *const KM_CORE_CHANNEL_MEMBER_INFO_IN_SUBTITLE = @"io.kommunicate.core.CHANNEL_MEMBER_INFO_IN_SUBTITLE";
static NSString *const KM_CORE_TABBAR_BACKGROUND_COLOUR = @"io.kommunicate.core.TABBAR_BACKGROUND_COLOUR";
static NSString *const KM_CORE_TABBAR_SELECTED_ITEM_COLOUR = @"io.kommunicate.core.TABBAR_SELECTED_ITEM_COLOUR";
static NSString *const KM_CORE_TABBAR_UNSELECTED_ITEM_COLOUR = @"io.kommunicate.core.TABBAR_UNSELECTED_ITEM_COLOUR";
static NSString *const KM_CORE_ATTACHMENT_ITEM_COLOUR = @"io.kommunicate.core.ATTACHMENT_ITEM_COLOUR";
static NSString *const KM_CORE_SEND_ITEM_COLOUR = @"io.kommunicate.core.SEND_ITEM_COLOUR";
static NSString *const KM_CORE_MESSAGE_SUBTEXT_COLOUR = @"io.kommunicate.core.MESSAGE_SUBTEXT_COLOUR";
static NSString *const KM_CORE_MESSAGE_TEXT_COLOUR = @"io.kommunicate.core.MESSAGE_TEXT_COLOUR";
static NSString *const KM_CORE_PROFILE_MAIN_COLOUR = @"io.kommunicate.core.PROFILE_MAIN_COLOUR";
static NSString *const KM_CORE_PROFILE_SUB_COLOUR = @"io.kommunicate.core.PROFILE_SUB_COLOUR";
static NSString *const KM_CORE_NEW_CONTACT_SUB_COLOUR = @"io.kommunicate.core.NEW_CONTACT_SUB_COLOUR";
static NSString *const KM_CORE_NEW_CONTACT_MAIN_COLOUR = @"io.kommunicate.core.NEW_CONTACT_MAIN_COLOUR";
static NSString *const KM_CORE_NEW_CONTACT_TEXT_COLOUR = @"io.kommunicate.core.NEW_CONTACT_TEXT_COLOUR";
static NSString *const KM_CORE_MESSAGES_VIEW_BG_COLOUR = @"io.kommunicate.core.MESSAGES_VIEW_BG_COLOUR";
static NSString *const KM_CORE_CHAT_VIEW_BG_COLOUR = @"io.kommunicate.core.CHAT_VIEW_BG_COLOUR";
static NSString *const KM_CORE_SEARCHBAR_TINT_COLOUR = @"io.kommunicate.core.SEARCHBAR_TINT_COLOUR";
static NSString *const KM_CORE_HIDE_MESSAGES_WITH_METADATA_KEYS = @"io.kommunicate.core.HIDE_MESSAGES_WITH_METADATA_KEYS";
static NSString *const ALDisableMultiSelectGalleryView = @"ALDisableMultiSelectGalleryView";
static NSString *const KM_CORE_5MIN_VIDEO_LIMIT_IN_GALLERY= @"io.kommunicate.core.AL_5MIN_VIDEO_LIMIT_IN_GALLERY";
static NSString *const KM_CORE_BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON =  @"io.kommunicate.core.BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON";
static NSString *const KM_CORE_TEXT_STYLE_FOR_CELL= @"io.kommunicate.core.AL_TEXT_STYLE_FOR_CELL";
static NSString *const KM_CORE_CHAT_CELL_FONT_SIZE= @"io.kommunicate.core.AL_CHAT_CELL_FONT_SIZE";
static NSString *const KM_CORE_CHANNEL_CELL_FONT_SIZE= @"io.kommunicate.core.AL_CHANNEL_CELL_FONT_SIZE";
static NSString *const KM_CORE_BACKGROUND_COLOR_FOR_REPLY_VIEW= @"io.kommunicate.core.AL_BACKGROUND_COLOR_FOR_REPLY_VIEW";
static NSString *const KM_CORE_MESSAGE_TEXT_VIEW_COLOR = @"io.kommunicate.core.MESSAGE_TEXT_VIEW_COLOR";

//Audio Recording View
static NSString *const KM_CORE_ENABLE_NEW_AUDIO_DESIGN = @"io.kommunicate.core.ENABLE_NEW_AUDIO_DESIGN";
static NSString *const KM_CORE_AUDIO_RECORDING_VIEW_BACKGROUND_COLOR = @"io.kommunicate.core.AUDIO_RECORDING_VIEW_BACKGROUND_COLOR";
static NSString *const KM_CORE_SLIDE_TO_CANCEL_TEXT_COLOR = @"io.kommunicate.core.SLIDE_TO_CANCEL_TEXT_COLOR";
static NSString *const KM_CORE_AUDIO_RECORDING_TEXT_COLOR = @"io.kommunicate.core.AUDIO_RECORDING_TEXT_COLOR";
static NSString *const KM_CORE_AUDIO_RECORD_VIEW_FONT = @"io.kommunicate.core.AUDIO_VIEW_FONT";
static NSString *const KM_CORE_MEDIA_SELECT_OPTIONS = @"io.kommunicate.core.MEDIA_SELECT_OPTIONS";
static NSString *const KM_CORE_CHANNEL_ACTION_MESSAGE_BG_COLOR = @"io.kommunicate.core.AL_CHANNEL_ACTION_MESSAGE_BG_COLOR";
static NSString *const KM_CORE_CHANNEL_ACTION_MESSAGE_TEXT_COLOR = @"io.kommunicate.core.AL_CHANNEL_ACTION_MESSAGE_TEXT_COLOR";
static NSString *const KM_CORE_ALPHABETIC_COLOR_CODES = @"io.kommunicate.core.AL_ALPHABETIC_COLOR_CODES";
static NSString *const KM_CORE_DISABLE_UNBLOCK_FROM_CHAT = @"io.kommunicate.core.DISABLE_UNBLOCK_FROM_CHAT";
static NSString *const KM_CORE_USER_DEFAULTS_GROUP_MIGRATION = @"io.kommunicate.core.AL_USER_DEFAULTS_GROUP_MIGRATION";
static NSString *const KM_CORE_USER_DEFAULTS_MIGRATION = @"io.kommunicate.core.AL_USER_DEFAULTS_MIGRATION";
static NSString *const KM_CORE_DOCUMENT_OPTION = @"io.kommunicate.core.AL_DOCUMENT_OPTION";
static NSString *const KM_CORE_SENT_MESSAGE_CONTACT_BUTTON = @"io.kommunicate.core.AL_SENT_MESSAGE_CONTACT_BUTTON";
static NSString *const KM_CORE_SENT_CONTACT_MSG_LABEL_COLOR = @"io.kommunicate.core.AL_SENT_CONTACT_MSG_LABEL_COLOR";
static NSString *const KM_CORE_RECEIVED_CONTACT_MSG_LABEL_COLOR = @"io.kommunicate.core.AL_RECEIVED_CONTACT_MSG_LABEL_COLOR";
static NSString *const KM_CORE_IMAGE_PREVIEW_BACKGROUND_COLOR = @"io.kommunicate.core.AL_IMAGE_PREVIEW_BACKGROUND_COLOR";
static NSString *const KM_CORE_RESTRICTED_MESSAGE_PATTERN  = @"io.kommunicate.core.AL_RESTRICTED_MESSAGE_PATTERN";
static NSString *const KM_CORE_DISABLE_NOTIFICATION_TAP = @"io.kommunicate.core.AL_DISABLE_NOTIFICATION_TAP";
static NSString *const KM_CORE_GROUPS_LIST_TAB = @"io.kommunicate.core.AL_GROUPS_LIST_TAB";
static NSString *const KM_CORE_MESSAGE_SEARCH = @"io.kommunicate.core.AL_MESSAGE_SEARCH";
static NSString *const KM_CORE_MESSAGE_DELETE_FOR_ALL_ENABLED = @"io.kommunicate.core.userdefault.AL_MESSAGE_DELETE_FOR_ALL_ENABLED";
static NSString *const KM_CORE_PHOTO_PICKER_SELECTION_LIMIT = @"io.kommunicate.core.userdefault.AL_PHOTO_PICKER_SELECTION_LIMIT";
static NSString *const KM_CORE_MESSAGE_META_DATA_KEY = @"io.kommunicate.core.userdefault.AL_MESSAGE_META_DATA_KEY";
static NSString *const KM_CORE_SUPPORT_CONTACT_USER_ID = @"io.kommunicate.core.userdefault.AL_SUPPORT_CONTACT_USER_ID";
static NSString *const KM_CORE_AGENTAPP_CONFIGURATION = @"io.kommunicate.core.userdefault.AL_AGENTAPP_CONFIGURATION";
static NSString *const KM_CORE_CUSTOM_BOT_NAME = @"io.kommunicate.core.userdefault.AL_CUSTOM_BOT_NAME";
static NSString *const KM_CORE_CUSTOM_BOT_ID = @"io.kommunicate.core.userdefault.AL_CUSTOM_BOT_ID";
static NSString *const KM_ZENDESK_ACCOUNT_KEY = @"io.kommunicate.core.userdefault.KM_ZENDESK_ACCOUNT_KEY";
static NSString *const KM_ZENDESK_LAST_CONVERSATION_ID = @"io.kommunicate.core.userdefault.KM_ZENDESK_LAST_CONVERSATION_ID";
static NSString *const KM_ZENDESK_LAST_SYNC_TIME = @"io.kommunicate.core.userdefault.KM_ZENDESK_LAST_SYNC_TIME";
static NSString *const KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT = @"KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT";
static NSString *const KM_DEFAULT_UPLOAD_URL = @"KM_DEFAULT_UPLOAD_URL";
static NSString *const KM_DEFAULT_UPLOAD_HEADERS = @"KM_DEFAULT_UPLOAD_HEADERS";
static NSString *const KM_IS_SINGLE_THREADED =  @"KM_IS_SINGLE_THREADED";

@interface KMCoreSettings : NSObject

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
