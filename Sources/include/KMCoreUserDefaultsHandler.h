//
//  KMCoreUserDefaultsHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMCoreSettings.h"

static NSString *const KM_CORE_APPLICATION_KEY = @"com.kommunicate.core.userdefault.APPLICATION_KEY";
static NSString *const KM_CORE_EMAIL_VERIFIED = @"com.kommunicate.core.userdefault.EMAIL_VERIFIED";
static NSString *const KM_CORE_DISPLAY_NAME = @"com.kommunicate.core.userdefault.DISPLAY_NAME";
static NSString *const KM_CORE_DEVICE_KEY_STRING = @"com.kommunicate.core.userdefault.DEVICE_KEY_STRING";
static NSString *const KM_CORE_USER_KEY_STRING = @"com.kommunicate.core.userdefault.USER_KEY_STRING";
static NSString *const KM_CORE_EMAIL_ID = @"com.kommunicate.core.userdefault.EMAIL_ID";
static NSString *const KM_CORE_USER_ID = @"com.kommunicate.core.userdefault.USER_ID";
static NSString *const KM_CORE_USER_IMAGE_URL = @"com.kommunicate.core.userdefault.AL_USER_IMAGE_URL";
static NSString *const KM_CORE_USER_CONTACT_NUMBER = @"com.kommunicate.core.userdefault.AL_USER_PHONE_NUMBER";
static NSString *const KM_CORE_USER_ROLE_IN_ORGANIZATION = @"com.kommunicate.core.userdefault.AL_USER_ROLE_IN_ORGANIZATION";
static NSString *const KM_CORE_APN_DEVICE_TOKEN = @"com.kommunicate.core.userdefault.APN_DEVICE_TOKEN";
static NSString *const KM_CORE_GOOGLE_MAP_API_KEY = @"com.kommunicate.core.userdefault.GOOGLE_MAP_API_KEY";
static NSString *const KM_CORE_LAST_SYNC_TIME = @"com.kommunicate.core.userdefault.LAST_SYNC_TIME";
static NSString *const KM_CORE_CONVERSATION_DB_SYNCED = @"com.kommunicate.core.userdefault.CONVERSATION_DB_SYNCED";
static NSString *const KM_CORE_LOGOUT_BUTTON_VISIBLITY = @"com.kommunicate.core.userdefault.LOGOUT_BUTTON_VISIBLITY";
static NSString *const KM_CORE_BOTTOM_TAB_BAR_VISIBLITY = @"com.kommunicate.core.userdefault.BOTTOM_TAB_BAR_VISIBLITY";
static NSString *const KM_CORE_DEVICE_DEFAULT_LANGUAGE = @"com.kommunicate.core.userdefault.AL_DEVICE_DEFAULT_LANGUAGE";
static NSString *const KM_CORE_BACK_BTN_VISIBILITY_ON_CON_LIST = @"com.kommunicate.core.userdefault.BACK_BTN_VISIBILITY_ON_CON_LIST";
static NSString *const KM_CORE_CONVERSATION_CONTACT_IMAGE_VISIBILITY = @"com.kommunicate.core.userdefault.CONVERSATION_CONTACT_IMAGE_VISIBILITY";
static NSString *const KM_CORE_MSG_LIST_CALL_SUFIX = @"com.kommunicate.core.userdefault.MSG_CALL_MADE:";
static NSString *const KM_CORE_PROCESSED_NOTIFICATION_IDS  = @"com.kommunicate.core.userdefault.PROCESSED_NOTIFICATION_IDS";
static NSString *const KM_CORE_TEAM_MODE_ENABLED  = @"com.kommunicate.core.userdefault.TEAM_MODE_ENABLED";
static NSString *const KM_CORE_KM_SSL_PINNING_ENABLED = @"com.kommunicate.core.userdefault.KM_SSL_PINNING_ENABLED";
static NSString *const KM_CORE_ASSIGNED_TEAM_IDS  = @"com.kommunicate.core.userdefault.ASSIGNED_TEAM_IDS";
static NSString *const KM_CORE_LAST_SEEN_SYNC_TIME = @"com.kommunicate.core.userdefault.LAST_SEEN_SYNC_TIME";
static NSString *const KM_CORE_SHOW_LOAD_ERLIER_MESSAGE = @"com.kommunicate.core.userdefault.SHOW_LOAD_ERLIER_MESSAGE:";
static NSString *const KM_CORE_LAST_SYNC_CHANNEL_TIME = @"com.kommunicate.core.userdefault.LAST_SYNC_CHANNEL_TIME";
static NSString *const KM_CORE_USER_BLOCK_LAST_TIMESTAMP = @"com.kommunicate.core.userdefault.USER_BLOCK_LAST_TIMESTAMP";
static NSString *const KM_CORE_APP_MODULE_NAME_ID = @"com.kommunicate.core.userdefault.APP_MODULE_NAME_ID";
static NSString *const KM_CORE_CONTACT_VIEW_LOADED = @"com.kommunicate.core.userdefault.CONTACT_VIEW_LOADED";
static NSString *const KM_CORE_USER_INFO_API_CALLED_SUFFIX = @"com.kommunicate.core.userdefault.USER_INFO_API_CALLED:";
static NSString *const APPLOZIC_BASE_URL = @"APPLOZIC_BASE_URL";
static NSString *const CHAT_BASE_URL = @"CHAT_BASE_URL";
static NSString *const APPLOZIC_MQTT_URL = @"APPLOZIC_MQTT_URL";
static NSString *const APPLOZIC_FILE_URL = @"APPLOZIC_FILE_URL";
static NSString *const APPLOZIC_MQTT_PORT = @"APPLOZIC_MQTT_PORT";
static NSString *const KM_CORE_USER_TYPE_ID = @"com.kommunicate.core.userdefault.USER_TYPE_ID";
static NSString *const KM_CORE_MESSSAGE_LIST_LAST_TIME = @"com.kommunicate.core.userdefault.MESSSAGE_LIST_LAST_TIME";
static NSString *const KM_CORE_ALL_CONVERSATION_FETCHED = @"com.kommunicate.core.userdefault.ALL_CONVERSATION_FETCHED";
static NSString *const KM_CORE_CONVERSATION_FETCH_PAGE_SIZE = @"com.kommunicate.core.userdefault.CONVERSATION_FETCH_PAGE_SIZE";
static NSString *const KM_CORE_NOTIFICATION_MODE = @"com.kommunicate.core.userdefault.NOTIFICATION_MODE";
static NSString *const KM_CORE_USER_PASSWORD = @"com.kommunicate.core.userdefault.USER_PASSWORD";
static NSString *const KM_CORE_USER_AUTHENTICATION_TYPE_ID = @"com.kommunicate.core.userdefault.USER_AUTHENTICATION_TYPE_ID";
static NSString *const KM_CORE_UNREAD_COUNT_TYPE = @"com.kommunicate.core.userdefault.UNREAD_COUNT_TYPE";
static NSString *const KM_CORE_MSG_SYN_CALL = @"com.kommunicate.core.userdefault.MSG_SYN_CALL";
static NSString *const KM_CORE_DEBUG_LOG_FLAG = @"com.kommunicate.core.userdefault.DEBUG_LOG_FLAG";
static NSString *const KM_CORE_LOGIN_USER_CONTACT = @"com.kommunicate.core.userdefault.LOGIN_USER_CONTACT";
static NSString *const KM_CORE_LOGGEDIN_USER_STATUS = @"com.kommunicate.core.userdefault.LOGGEDIN_USER_STATUS";
static NSString *const KM_CORE_LOGIN_USER_SUBSCRIBED_MQTT = @"com.kommunicate.core.userdefault.LOGIN_USER_SUBSCRIBED_MQTT";
static NSString *const KM_CORE_USER_ENCRYPTION_KEY = @"com.kommunicate.core.userdefault.USER_ENCRYPTION_KEY";
static NSString *const KM_CORE_USER_PRICING_PACKAGE = @"com.kommunicate.core.userdefault.USER_PRICING_PACKAGE";
static NSString *const KM_CORE_DEVICE_ENCRYPTION_ENABLE = @"com.kommunicate.core.userdefault.DEVICE_ENCRYPTION_ENABLE";
static NSString *const KM_CORE_NOTIFICATION_SOUND_FILE_NAME = @"com.kommunicate.core.userdefault.NOTIFICATION_SOUND_FILE_NAME";
static NSString *const KM_CORE_CONTACT_SERVER_CALL_IS_DONE = @"com.kommunicate.core.userdefault.AL_CONTACT_SERVER_CALL_IS_DONE";
static NSString *const KM_CORE_CONTACT_SCROLLING_DONE = @"com.kommunicate.core.userdefault.AL_CONTACT_SCROLLING_DONE";
static NSString *const KM_CORE_KEY_PREFIX = @"com.kommunicate.core.userdefault";
static NSString *const KM_CORE_GROUP_FILTER_LAST_SYNC_TIME = @"com.kommunicate.core.GROUP_FILTER_LAST_SYNC_TIME";
static NSString *const KM_CORE_USER_ROLE_TYPE = @"com.kommunicate.core.userdefault.AL_USER_ROLE_TYPE";
static NSString *const KM_CORE_USER_PUSH_NOTIFICATION_FORMATE = @"com.kommunicate.core.userdefault.AL_USER_PUSH_NOTIFICATION_FORMATE";
static NSString *const KM_CORE_USER_MQTT_ENCRYPTION_KEY = @"com.kommunicate.core.userdefault.USER_MQTT_ENCRYPTION_KEY";
static NSString *const KM_CORE_LAST_SYNC_TIME_FOR_META_DATA = @"com.kommunicate.core.userdefault.LAST_SYNC_TIME_FOR_META_DATA";
static NSString *const KM_CORE_NOTIFICATION_TITLE_KEY = @"NOTIFICATION_TITLE";
static NSString *const KM_CORE_DISABLE_USER_CHAT = @"DISABLE_CHAT_WITH_USER";
static NSString *const KM_CORE_USER_DISPLAY_NAME_API_CALLED_SUFFIX = @"com.kommunicate.core.userdefault.AL_USER_DISPLAY_NAME_API_CALLED:";
static NSString *const KM_CORE_STORE = @"AL_STORE";
static NSString *const KM_CORE_STORE_USER_PASSWORD = @"AL_USER_PASSW";
static NSString *const KM_CORE_AUTHENTICATION_TOKEN = @"AL_AUTHENTICATION_TOKEN";
static NSString *const KM_CORE_AUTHENTICATION_TOKEN_CREATED_TIME = @"com.kommunicate.core.userdefault.AUTHENTICATION_TOKEN_CREATED_TIME";
static NSString *const KM_CORE_AUTHENTICATION_TOKEN_VALID_UPTO_MINS = @"com.kommunicate.core.userdefault.AUTHENTICATION_TOKEN_VALID_UPTO_MINS";
static NSString *const KM_CORE_INITIAL_MESSAGE_LIST_CALL = @"com.kommunicate.core.userdefault.AL_INITIAL_MESSAGE_LIST_CALL";
static NSString *const KM_CORE_LOGGED_IN_USER_DEACTIVATED = @"com.kommunicate.core.userdefault.AL_LOGGED_IN_USER_DEACTIVATED";
static NSString *const KM_CORE_CHANNEL_LIST_LAST_GENERATED_TIME = @"com.kommunicate.core.userdefault.AL_CHANNEL_LIST_LAST_GENERATED_TIME";
static NSString *const KM_CORE_VOIP_DEVICE_TOKEN = @"com.kommunicate.core.userdefault.VOIP_DEVICE_TOKEN";

@interface KMCoreUserDefaultsHandler : NSObject

+ (void)setConversationContactImageVisibility:(BOOL)visibility;

+ (BOOL)isConversationContactImageVisible;

+ (void)setBottomTabBarHidden:(BOOL)visibleStatus;

+ (BOOL)isBottomTabBarHidden;

+ (void) setDeviceDefaultLanguage : (NSString *) languageCode;
+ (NSString *) getDeviceDefaultLanguage;

+ (void)setNavigationRightButtonHidden:(BOOL)flagValue;
+ (BOOL)isNavigationRightButtonHidden;

+ (void)setBackButtonHidden:(BOOL)flagValue;

+ (BOOL)isBackButtonHidden;

+ (BOOL)isLoggedIn;

+ (void)clearAll;

+ (NSString *)getApplicationKey;

+ (void)setApplicationKey:(NSString *)applicationKey;

+ (void)setEmailVerified:(BOOL)value;

+ (void)setApnDeviceToken:(NSString *)apnDeviceToken;

+ (NSString *)getApnDeviceToken;

+ (void)setBoolForKey_isConversationDbSynced:(BOOL)value;

+ (BOOL)getBoolForKey_isConversationDbSynced;

+ (void)setDeviceKeyString:(NSString *)deviceKeyString;

+ (void)setUserKeyString:(NSString *)userKeyString;

+ (void)setDisplayName:(NSString *)displayName;

+ (void)setUserContactNumber:(NSString *)userContactNumber;

+ (void)setUserImageURL:(NSString *)userImageURL;

+ (void)setUserRoleInOrganization:(NSString *)designation;

+ (void)setEmailId:(NSString *)emailId;

+ (void)setTeamModeEnabled:(BOOL)flagValue;

+ (BOOL)isTeamModeEnabled;

+ (void)setAssignedTeamIds:(NSMutableArray *)assignedTeamIDs;

+ (NSMutableArray*)getAssignedTeamIds;

+ (NSString *)getEmailId;

+ (NSString *)getDeviceKeyString;

+ (void)setUserId:(NSString *)userId;

+ (NSString*)getUserId;

+ (void)setLastSyncTime:(NSNumber *)lastSyncTime;

+ (void)setServerCallDoneForMSGList:(BOOL)value forContactId:(NSString *)constactId;

+ (BOOL)isServerCallDoneForMSGList:(NSString *)contactId;

+ (void)setProcessedNotificationIds:(NSMutableArray *)arrayWithIds;

+ (NSMutableArray*)getProcessedNotificationIds;

+ (BOOL)isNotificationProcessd:(NSString *)withNotificationId;

+ (NSNumber *)getLastSeenSyncTime;

+ (void)setLastSeenSyncTime:(NSNumber *)lastSeenTime;

+ (void)setShowLoadEarlierOption:(BOOL)value forContactId:(NSString *)constactId;

+ (BOOL)isShowLoadEarlierOption:(NSString *)constactId;

+ (void)setLastSyncChannelTime:(NSNumber *)lastSyncChannelTime;

+ (NSNumber *)getLastSyncChannelTime;

+ (NSNumber *)getLastSyncTime;

+ (NSString *)getUserKeyString;

+ (NSString *)getDisplayName;

+ (NSString *)getUserImageURL;

+ (NSString *)getUserContactNumber;

+ (NSString *)getUserRoleInOrganization;

+ (void)setUserBlockLastTimeStamp:(NSNumber *)lastTimeStamp;

+ (NSNumber *)getUserBlockLastTimeStamp;

+ (NSString *)getPassword;
+ (void)setPassword:(NSString *)password;

+ (void)setAppModuleName:(NSString *)appModuleName;
+ (NSString *)getAppModuleName;

+ (BOOL)getContactViewLoaded;
+ (void)setContactViewLoadStatus:(BOOL)status;

+ (void)setServerCallDoneForUserInfo:(BOOL)value ForContact:(NSString *)contactId;
+ (BOOL)isServerCallDoneForUserInfoForContact:(NSString *)contactId;

+ (void)setBASEURL:(NSString *)baseURL;
+ (NSString *)getBASEURL;

+ (void)setChatBaseURL: (NSString *)chatBaseURL;
+ (NSString *)getChatBaseURL;

+ (void)setMQTTURL:(NSString *)mqttURL;
+ (NSString *)getMQTTURL;

+ (void)setFILEURL:(NSString *)fileURL;
+ (NSString *)getFILEURL;

+ (void)setMQTTPort:(NSString *)portNumber;
+ (NSString *)getMQTTPort;

+ (void)setUserTypeId:(short)type;
+ (short)getUserTypeId;

+ (NSNumber *)getLastMessageListTime;
+ (void)setLastMessageListTime:(NSNumber *)lastTime;

+ (BOOL)getFlagForAllConversationFetched;
+ (void)setFlagForAllConversationFetched:(BOOL)flag;

+ (NSInteger)getFetchConversationPageSize;
+ (void)setFetchConversationPageSize:(NSInteger)limit;

+ (short)getNotificationMode;
+ (void)setNotificationMode:(short)mode;

+ (short)getUserAuthenticationTypeId;
+ (void)setUserAuthenticationTypeId:(short)type;

+ (short)getUnreadCountType;
+ (void)setUnreadCountType:(short)mode;

+ (BOOL)isMsgSyncRequired;
+ (void)setMsgSyncRequired:(BOOL)flag;

+ (BOOL)isDebugLogsRequire;
+ (void)setDebugLogsRequire:(BOOL)flag;

+ (BOOL)getLoginUserConatactVisibility;
+ (void)setLoginUserConatactVisibility:(BOOL)flag;

+ (NSString *)getLoggedInUserStatus;
+ (void)setLoggedInUserStatus:(NSString *)status;

+ (BOOL)isUserLoggedInUserSubscribedMQTT;
+ (void)setLoggedInUserSubscribedMQTT:(BOOL)flag;

+ (NSString *)getEncryptionKey;
+ (void)setEncryptionKey:(NSString *)encrptionKey;

+ (short)getUserPricingPackage;
+ (void)setUserPricingPackage:(short)pricingPackage;

+ (BOOL)getEnableEncryption;
+ (void)setEnableEncryption:(BOOL)flag;

+ (void)setGoogleMapAPIKey:(NSString *)googleMapAPIKey;
+ (NSString *)getGoogleMapAPIKey;

+ (NSString *)getNotificationSoundFileName;
+ (void)setNotificationSoundFileName:(NSString *)notificationSoundFileName;

+ (BOOL)isContactServerCallIsDone;
+ (void)setContactServerCallIsDone:(BOOL)flag;

+ (BOOL)isContactScrollingIsInProgress;
+ (void)setContactScrollingIsInProgress:(BOOL)flag;

+ (void)setLastGroupFilterSyncTime:(NSNumber *)lastSyncTime;
+ (NSNumber *)getLastGroupFilterSyncTIme;

+ (void)setUserRoleType:(short)type;
+ (short)getUserRoleType;

+ (void)setPushNotificationFormat:(short)type;
+ (short)getPushNotificationFormat;
+ (void)setUserEncryption:(NSString *)encryptionKey;
+ (NSString *)getUserEncryptionKey;

+ (void)setLastSyncTimeForMetaData:(NSNumber *)metaDataLastSyncTime;
+ (NSNumber *)getLastSyncTimeForMetaData;

+ (void)disableChat:(BOOL)disable;
+ (BOOL)isChatDisabled;

+ (void)setAuthToken:(NSString *)authToken;
+ (NSString *)getAuthToken;

+ (void)setAuthTokenCreatedAtTime:(NSNumber *)createdAtTime;
+ (NSNumber *)getAuthTokenCreatedAtTime;
+ (void)setAuthTokenValidUptoInMins:(NSNumber *)validUptoInMins;
+ (NSNumber *)getAuthTokenValidUptoMins;

+ (void)setInitialMessageListCallDone:(BOOL)flag;
+ (BOOL)isInitialMessageListCallDone;

+ (void)deactivateLoggedInUser:(BOOL)deactivate;
+ (BOOL)isLoggedInUserDeactivated;

+ (void)setKMSSLPinningEnabled:(BOOL)flag;
+ (BOOL)isKMSSLPinningEnabled;

+ (void)setChannelListLastSyncGeneratedTime:(NSNumber *)lastSyncGeneratedTime;
+ (NSNumber *)getChannelListLastSyncGeneratedTime;

+ (void)setVOIPDeviceToken:(NSString *)VOIPDeviceToken;
+ (NSString *)getVOIPDeviceToken;
@end
