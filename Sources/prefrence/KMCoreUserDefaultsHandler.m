//
//  KMCoreUserDefaultsHandler.m
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import "KMCoreUserDefaultsHandler.h"
#import "ALLogger.h"
#import "ALPasswordQueryable.h"
#import "ALUtilityClass.h"

@implementation KMCoreUserDefaultsHandler

+ (void)setConversationContactImageVisibility:(BOOL)visibility {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:visibility forKey:KM_CORE_CONVERSATION_CONTACT_IMAGE_VISIBILITY];
    [userDefaults synchronize];
}

+ (BOOL)isConversationContactImageVisible {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONVERSATION_CONTACT_IMAGE_VISIBILITY];
}

+ (void)setBottomTabBarHidden:(BOOL)visibleStatus {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:visibleStatus forKey:KM_CORE_BOTTOM_TAB_BAR_VISIBLITY];
    [userDefaults synchronize];
}

+ (BOOL)isBottomTabBarHidden {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    BOOL flag = [userDefaults boolForKey:KM_CORE_BOTTOM_TAB_BAR_VISIBLITY];
    if (flag) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)setDeviceDefaultLanguage:(NSString *)languageCode {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setObject: languageCode forKey:KM_CORE_DEVICE_DEFAULT_LANGUAGE];
    [userDefaults synchronize];
}

+ (NSString *)getDeviceDefaultLanguage {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *languageCode = [userDefaults objectForKey:KM_CORE_DEVICE_DEFAULT_LANGUAGE];
    return languageCode;
}

+ (void)setNavigationRightButtonHidden:(BOOL)flagValue {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flagValue forKey:KM_CORE_LOGOUT_BUTTON_VISIBLITY];
    [userDefaults synchronize];
}

+ (BOOL)isNavigationRightButtonHidden {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_LOGOUT_BUTTON_VISIBLITY];
}

+ (void)setBackButtonHidden:(BOOL)flagValue {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flagValue forKey:KM_CORE_BACK_BTN_VISIBILITY_ON_CON_LIST];
    [userDefaults synchronize];
}

+ (BOOL)isBackButtonHidden {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_BACK_BTN_VISIBILITY_ON_CON_LIST];
}

+ (void)setApplicationKey:(NSString *)applicationKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:applicationKey forKey:KM_CORE_APPLICATION_KEY];
    [userDefaults synchronize];
}

+ (NSString *)getApplicationKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_APPLICATION_KEY];
}

+ (BOOL)isLoggedIn {
    return [KMCoreUserDefaultsHandler getDeviceKeyString] != nil;
}

+ (void)clearAll {
    ALSLog(ALLoggerSeverityInfo, @"CLEARING_USER_DEFAULTS");
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    NSArray *keyArray = [dictionary allKeys];
    for (NSString *defaultKeyString in keyArray) {
        if ([defaultKeyString hasPrefix:KM_CORE_KEY_PREFIX] &&
            ![defaultKeyString isEqualToString:KM_CORE_APN_DEVICE_TOKEN] &&
            ![defaultKeyString isEqualToString:KM_CORE_VOIP_DEVICE_TOKEN]) {
            [userDefaults removeObjectForKey:defaultKeyString];
            [userDefaults synchronize];
        }
    }

    ALSecureStore *store = [KMCoreUserDefaultsHandler getSecureStore];
    NSError *passError;
    [store removeValueFor:KM_CORE_STORE_USER_PASSWORD error:&passError];
    if (passError != nil) {
        ALSLog(ALLoggerSeverityError, @"Failed to remove password from the store : %@",
               [passError description]);
    }
    NSError *authTokenError;
    [store removeValueFor:KM_CORE_AUTHENTICATION_TOKEN error:&authTokenError];
    if (authTokenError != nil) {
        ALSLog(ALLoggerSeverityError, @"Failed to remove auth token from the store : %@",
               [authTokenError description]);
    }
}

+ (void)setApnDeviceToken:(NSString *)apnDeviceToken {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:apnDeviceToken forKey:KM_CORE_APN_DEVICE_TOKEN];
    [userDefaults synchronize];
}

+ (NSString *)getApnDeviceToken {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_APN_DEVICE_TOKEN];
}

+ (void)setEmailVerified:(BOOL)value {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:value forKey:KM_CORE_EMAIL_VERIFIED];
    [userDefaults synchronize];
}

+ (void)getEmailVerified {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults boolForKey: KM_CORE_EMAIL_VERIFIED];
}

// isConversationDbSynced

+ (void)setBoolForKey_isConversationDbSynced:(BOOL)value {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:value forKey:KM_CORE_CONVERSATION_DB_SYNCED];
    [userDefaults synchronize];
}

+ (BOOL)getBoolForKey_isConversationDbSynced {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONVERSATION_DB_SYNCED];
}

+ (void)setEmailId:(NSString *)emailId {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:emailId forKey:KM_CORE_EMAIL_ID];
    [userDefaults synchronize];
}

+ (NSString *)getEmailId {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_EMAIL_ID];
}

+ (void)setUserImageURL:(NSString *)userImageURL{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:userImageURL forKey:KM_CORE_USER_IMAGE_URL];
    [userDefaults synchronize];
}

+ (NSString *)getUserImageURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_IMAGE_URL];
}


+ (void)setUserContactNumber:(NSString *)userContactNumber{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:userContactNumber forKey:KM_CORE_USER_CONTACT_NUMBER];
    [userDefaults synchronize];
}

+ (NSString *)getUserContactNumber {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_CONTACT_NUMBER];
}

+ (void)setUserRoleInOrganization:(NSString *)designation{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:designation forKey:KM_CORE_USER_ROLE_IN_ORGANIZATION];
    [userDefaults synchronize];
}

+ (NSString *)getUserRoleInOrganization {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_ROLE_IN_ORGANIZATION];
}

+ (void)setDisplayName:(NSString *)displayName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:displayName forKey:KM_CORE_DISPLAY_NAME];
    [userDefaults synchronize];
}

+ (NSString *)getDisplayName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_DISPLAY_NAME];
}

//deviceKey String
+ (void)setDeviceKeyString:(NSString *)deviceKeyString {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:deviceKeyString forKey:KM_CORE_DEVICE_KEY_STRING];
    [userDefaults synchronize];
}

+ (NSString *)getDeviceKeyString{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_DEVICE_KEY_STRING];
}

+ (void)setUserKeyString:(NSString *)suUserKeyString {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:suUserKeyString forKey:KM_CORE_USER_KEY_STRING];
    [userDefaults synchronize];
}

+ (NSString *)getUserKeyString {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_KEY_STRING];
}

//LOGIN USER ID
+ (void)setUserId:(NSString *)userId {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:userId forKey:KM_CORE_USER_ID];
    [userDefaults synchronize];
}

+ (NSString *)getUserId {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_ID];
}

//LOGIN USER PASSWORD
+ (void)setPassword:(NSString *)password {
    ALSecureStore *store = [KMCoreUserDefaultsHandler getSecureStore];
    NSError *passError;
    [store setValue:password forUserAccount:KM_CORE_STORE_USER_PASSWORD error:&passError];
    if (passError != nil) {
        ALSLog(ALLoggerSeverityError, @"Failed to save password in the store : %@",
               [passError description]);
    }
}

+ (NSString *)getPassword {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *passwordInDefaults = [userDefaults valueForKey:KM_CORE_USER_PASSWORD];
    // For apps migrating from an old version
    if (passwordInDefaults != nil) {
        return passwordInDefaults;
    } else {
        ALSecureStore *store = [KMCoreUserDefaultsHandler getSecureStore];
        NSError *passError;
        NSString *passwordInStore = [store getValueFor:KM_CORE_STORE_USER_PASSWORD error:&passError];
        if (passError != nil) {
            ALSLog(ALLoggerSeverityError, @"Failed to get password from the store : %@",
                   [passError description]);
            return nil;
        }
        return passwordInStore;
    }
}

//last sync time
+ (void)setLastSyncTime:(NSNumber *)lstSyncTime {

    lstSyncTime = @([lstSyncTime doubleValue] + 1);
    ALSLog(ALLoggerSeverityInfo, @"saving last Sync time in the preference ...%@" ,lstSyncTime);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lstSyncTime doubleValue] forKey:KM_CORE_LAST_SYNC_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastSyncTime {
    // NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_LAST_SYNC_TIME];
}


+ (void)setServerCallDoneForMSGList:(BOOL)value forContactId:(NSString *)contactId {
    if (!contactId) {
        return;
    }
    
    NSString *key = [KM_CORE_MSG_LIST_CALL_SUFIX stringByAppendingString: contactId];
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:true forKey:key];
    [userDefaults synchronize];
}

+ (BOOL)isServerCallDoneForMSGList:(NSString *)contactId {
    if (!contactId) {
        return true;
    }
    NSString *key = [KM_CORE_MSG_LIST_CALL_SUFIX stringByAppendingString: contactId];
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:key];
}

+ (void)setProcessedNotificationIds:(NSMutableArray *)arrayWithIds {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setObject:arrayWithIds forKey:KM_CORE_PROCESSED_NOTIFICATION_IDS];
}

+ (NSMutableArray *)getProcessedNotificationIds {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [[userDefaults objectForKey:KM_CORE_PROCESSED_NOTIFICATION_IDS] mutableCopy];
}

+ (void)setTeamModeEnabled:(BOOL)flagValue {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flagValue forKey:KM_CORE_TEAM_MODE_ENABLED];
    [userDefaults synchronize];
}

+ (BOOL)isTeamModeEnabled {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_TEAM_MODE_ENABLED];
}

+ (void)setKMSSLPinningEnabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_KM_SSL_PINNING_ENABLED];
    [userDefaults synchronize];
}

+ (BOOL)isKMSSLPinningEnabled {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    // Check if the key exists and return false if the value is null or does not exist
    if (![userDefaults objectForKey:KM_CORE_KM_SSL_PINNING_ENABLED]) {
        return NO;
    }
    return [userDefaults boolForKey:KM_CORE_KM_SSL_PINNING_ENABLED];
}

+ (void)setAssignedTeamIds:(NSMutableArray *)assignedTeamIDs {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setObject:assignedTeamIDs forKey:KM_CORE_ASSIGNED_TEAM_IDS];
}

+ (NSMutableArray *)getAssignedTeamIds {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [[userDefaults objectForKey:KM_CORE_ASSIGNED_TEAM_IDS] mutableCopy];
}

+ (BOOL)isNotificationProcessd:(NSString *)withNotificationId {
    NSMutableArray *mutableArray = [self getProcessedNotificationIds];
    
    if (mutableArray == nil) {
        mutableArray = [[NSMutableArray alloc]init];
    }
    
    BOOL isTheObjectThere = [mutableArray containsObject:withNotificationId];
    
    if (!isTheObjectThere) {
        [mutableArray addObject:withNotificationId];
    }
    //WE will just store 20 notificationIds for processing...
    if (mutableArray.count > 20) {
        [mutableArray removeObjectAtIndex:0];
    }
    [self setProcessedNotificationIds:mutableArray];
    return isTheObjectThere;
    
}

+ (void)setLastSeenSyncTime:(NSNumber *)lastSeenTime {
    ALSLog(ALLoggerSeverityInfo, @"saving last seen time in the preference ...%@" ,lastSeenTime);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastSeenTime doubleValue] forKey:KM_CORE_LAST_SEEN_SYNC_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastSeenSyncTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSNumber *timeStamp = [userDefaults objectForKey:KM_CORE_LAST_SEEN_SYNC_TIME];
    return timeStamp != nil ? timeStamp : [NSNumber numberWithInt:0];
}

+ (void)setShowLoadEarlierOption:(BOOL)value forContactId:(NSString *)contactId {
    if (!contactId) {
        return;
    }
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *key = [KM_CORE_SHOW_LOAD_ERLIER_MESSAGE stringByAppendingString:contactId];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

+ (BOOL)isShowLoadEarlierOption:(NSString *)contactId {
    if (!contactId) {
        return NO;
    }
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *key = [KM_CORE_SHOW_LOAD_ERLIER_MESSAGE stringByAppendingString:contactId];
    if ([userDefaults valueForKey:key]) {
        return [userDefaults boolForKey:key];
    } else {
        return YES;
    }
    
}

+ (void)setLastSyncChannelTime:(NSNumber *)lastSyncChannelTime {
    lastSyncChannelTime = @([lastSyncChannelTime doubleValue] + 1);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastSyncChannelTime doubleValue] forKey:KM_CORE_LAST_SYNC_CHANNEL_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastSyncChannelTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_LAST_SYNC_CHANNEL_TIME];
}

+ (void)setUserBlockLastTimeStamp:(NSNumber *)lastTimeStamp {
    lastTimeStamp = @([lastTimeStamp doubleValue] + 1);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastTimeStamp doubleValue] forKey:KM_CORE_USER_BLOCK_LAST_TIMESTAMP];
    [userDefaults synchronize];
}

+ (NSNumber *)getUserBlockLastTimeStamp {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSNumber *lastSyncTimeStamp = [userDefaults valueForKey:KM_CORE_USER_BLOCK_LAST_TIMESTAMP];
    if (lastSyncTimeStamp == nil) {
        lastSyncTimeStamp = [NSNumber numberWithInt:1000];
    }
    
    return lastSyncTimeStamp;
}

//App Module Name
+ (void )setAppModuleName:(NSString *)appModuleName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:appModuleName forKey:KM_CORE_APP_MODULE_NAME_ID];
    [userDefaults synchronize];
}

+ (NSString *)getAppModuleName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_APP_MODULE_NAME_ID];
}

+ (void)setContactViewLoadStatus:(BOOL)status {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:status forKey:KM_CORE_CONTACT_VIEW_LOADED];
    [userDefaults synchronize];
}

+ (BOOL)getContactViewLoaded {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTACT_VIEW_LOADED];
}

+ (void)setServerCallDoneForUserInfo:(BOOL)value ForContact:(NSString *)contactId {
    if (!contactId) {
        return;
    }
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *key = [KM_CORE_USER_INFO_API_CALLED_SUFFIX stringByAppendingString:contactId];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

+ (BOOL)isServerCallDoneForUserInfoForContact:(NSString *)contactId {
    if (!contactId) {
        return true;
    }

    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *key = [KM_CORE_USER_INFO_API_CALLED_SUFFIX stringByAppendingString:contactId];
    return [userDefaults boolForKey:key];
}


+ (void)setBASEURL:(NSString *)baseURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:baseURL forKey:APPLOZIC_BASE_URL];
    [userDefaults synchronize];
}

+ (NSString *)getBASEURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *kBaseUrl = [userDefaults valueForKey:APPLOZIC_BASE_URL];
    return (kBaseUrl && ![kBaseUrl isEqualToString:@""]) ? kBaseUrl : @"https://apps.applozic.com";
}


+ (void)setChatBaseURL:(NSString *)baseURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:baseURL forKey:CHAT_BASE_URL];
    [userDefaults synchronize];
}

+ (NSString *)getChatBaseURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *kBaseUrl = [userDefaults valueForKey:CHAT_BASE_URL];
    return (kBaseUrl && ![kBaseUrl isEqualToString:@""]) ? kBaseUrl : @"https://apps.applozic.com";
}

+ (void)setMQTTURL:(NSString *)mqttURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:mqttURL forKey:APPLOZIC_MQTT_URL];
    [userDefaults synchronize];
}

+ (NSString *)getMQTTURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *kMqttUrl = [userDefaults valueForKey:APPLOZIC_MQTT_URL];
    return (kMqttUrl && ![kMqttUrl isEqualToString:@""]) ? kMqttUrl : @"apps.applozic.com";
}

+ (void)setFILEURL:(NSString *)fileURL {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:fileURL forKey:APPLOZIC_FILE_URL];
    [userDefaults synchronize];
}

+ (NSString *)getFILEURL {
    if ([KMCoreSettings isS3StorageServiceEnabled]) {
        return [self getBASEURL];
    }

    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *kFileUrl = [userDefaults valueForKey:APPLOZIC_FILE_URL];
    return (kFileUrl && ![kFileUrl isEqualToString:@""]) ? kFileUrl : @"https://applozic.appspot.com";
}

+ (void)setMQTTPort:(NSString *)portNumber {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:portNumber forKey:APPLOZIC_MQTT_PORT];
    [userDefaults synchronize];
}

+ (NSString *)getMQTTPort {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSString *kPortNumber = [userDefaults valueForKey:APPLOZIC_MQTT_PORT];
    return (kPortNumber && ![kPortNumber isEqualToString:@""]) ? kPortNumber : @"1883";
}

+ (void)setUserTypeId:(short)type {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:type forKey:KM_CORE_USER_TYPE_ID];
    [userDefaults synchronize];
}

+ (short)getUserTypeId{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults integerForKey:KM_CORE_USER_TYPE_ID];
}

+ (void)setLastMessageListTime:(NSNumber *)lastTime {
    lastTime = @([lastTime doubleValue] + 1);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastTime doubleValue] forKey:KM_CORE_MESSSAGE_LIST_LAST_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastMessageListTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_MESSSAGE_LIST_LAST_TIME];
}

+ (void)setFlagForAllConversationFetched:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_ALL_CONVERSATION_FETCHED];
    [userDefaults synchronize];
}

+ (BOOL)getFlagForAllConversationFetched {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ALL_CONVERSATION_FETCHED];
}

+ (void)setFetchConversationPageSize:(NSInteger)limit {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:limit forKey:KM_CORE_CONVERSATION_FETCH_PAGE_SIZE];
    [userDefaults synchronize];
}

+ (NSInteger)getFetchConversationPageSize {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSInteger maxLimit = [userDefaults integerForKey:KM_CORE_CONVERSATION_FETCH_PAGE_SIZE];
    return maxLimit ? maxLimit : 60;
}

+ (void)setNotificationMode:(short)mode {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:mode forKey:KM_CORE_NOTIFICATION_MODE];
    [userDefaults synchronize];
}

+ (short)getNotificationMode {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults integerForKey:KM_CORE_NOTIFICATION_MODE];
}

+ (void)setUserAuthenticationTypeId:(short)type {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:type forKey:KM_CORE_USER_AUTHENTICATION_TYPE_ID];
    [userDefaults synchronize];
}

+ (short)getUserAuthenticationTypeId {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    short type = [userDefaults integerForKey:KM_CORE_USER_AUTHENTICATION_TYPE_ID];
    return type ? type : 1;
}

+ (void)setUnreadCountType:(short)mode {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:mode forKey:KM_CORE_UNREAD_COUNT_TYPE];
    [userDefaults synchronize];
}

+ (short)getUnreadCountType {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    short type = [userDefaults integerForKey:KM_CORE_UNREAD_COUNT_TYPE];
    return type ? type : 0;
}

+ (void)setMsgSyncRequired:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_MSG_SYN_CALL];
    [userDefaults synchronize];
}

+ (BOOL)isMsgSyncRequired {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_MSG_SYN_CALL];
}

+ (void)setDebugLogsRequire:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_DEBUG_LOG_FLAG];
    [userDefaults synchronize];
}

+ (BOOL)isDebugLogsRequire {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DEBUG_LOG_FLAG];
}

+ (void)setLoginUserConatactVisibility:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_LOGIN_USER_CONTACT];
    [userDefaults synchronize];
}

+ (BOOL)getLoginUserConatactVisibility {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_LOGIN_USER_CONTACT];
}

+ (void)setLoggedInUserStatus:(NSString *)status {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:status forKey:KM_CORE_LOGGEDIN_USER_STATUS];
    [userDefaults synchronize];
}

+ (NSString *)getLoggedInUserStatus {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_LOGGEDIN_USER_STATUS];
}

+ (BOOL)isUserLoggedInUserSubscribedMQTT {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_LOGIN_USER_SUBSCRIBED_MQTT];
}

+ (void)setLoggedInUserSubscribedMQTT:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_LOGIN_USER_SUBSCRIBED_MQTT];
    [userDefaults synchronize];
}

+ (NSString *)getEncryptionKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_ENCRYPTION_KEY];
}

+ (void)setEncryptionKey:(NSString *)encrptionKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:encrptionKey forKey:KM_CORE_USER_ENCRYPTION_KEY];
    [userDefaults synchronize];
}

+ (void)setUserPricingPackage:(short)pricingPackage {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:pricingPackage forKey:KM_CORE_USER_PRICING_PACKAGE];
    [userDefaults synchronize];
}

+ (short)getUserPricingPackage {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults integerForKey:KM_CORE_USER_PRICING_PACKAGE];
}

+ (void)setEnableEncryption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_DEVICE_ENCRYPTION_ENABLE];
    [userDefaults synchronize];
}

+ (BOOL)getEnableEncryption {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DEVICE_ENCRYPTION_ENABLE];
}

+ (void)setGoogleMapAPIKey:(NSString *)googleMapAPIKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:googleMapAPIKey forKey:KM_CORE_GOOGLE_MAP_API_KEY];
    [userDefaults synchronize];
}

+ (NSString *)getGoogleMapAPIKey {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_GOOGLE_MAP_API_KEY];
}

+ (NSString *)getNotificationSoundFileName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_NOTIFICATION_SOUND_FILE_NAME];
}


+ (void)setNotificationSoundFileName:(NSString *)notificationSoundFileName {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:notificationSoundFileName forKey:KM_CORE_NOTIFICATION_SOUND_FILE_NAME];
    [userDefaults synchronize];
}

+ (void)setContactServerCallIsDone:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_CONTACT_SERVER_CALL_IS_DONE];
    [userDefaults synchronize];
}

+ (BOOL)isContactServerCallIsDone {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTACT_SERVER_CALL_IS_DONE];
}

+ (void)setContactScrollingIsInProgress:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_CONTACT_SCROLLING_DONE];
    [userDefaults synchronize];
}

+ (BOOL)isContactScrollingIsInProgress {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTACT_SCROLLING_DONE];
}

+ (void)setLastGroupFilterSyncTime: (NSNumber *)lastSyncTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastSyncTime doubleValue] forKey:KM_CORE_GROUP_FILTER_LAST_SYNC_TIME];
    [userDefaults synchronize];
}
+ (NSNumber *)getLastGroupFilterSyncTIme {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_GROUP_FILTER_LAST_SYNC_TIME];

}

+ (void)setUserRoleType:(short)type{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:type forKey:KM_CORE_USER_ROLE_TYPE];
    [userDefaults synchronize];
}

+ (short)getUserRoleType{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    short roleType = [userDefaults integerForKey:KM_CORE_USER_ROLE_TYPE];
    return roleType ? roleType : 3;
    
}

+ (void)setPushNotificationFormat:(short)format{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setInteger:format forKey:KM_CORE_USER_PUSH_NOTIFICATION_FORMATE];
    [userDefaults synchronize];
}

+ (short)getPushNotificationFormat{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    short pushNotificationFormat = [userDefaults integerForKey:KM_CORE_USER_PUSH_NOTIFICATION_FORMATE];
    return pushNotificationFormat ? pushNotificationFormat : 0;
}

+ (void)setUserEncryption:(NSString *)encryptionKey{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:encryptionKey forKey:KM_CORE_USER_MQTT_ENCRYPTION_KEY];
    [userDefaults synchronize];
}

+ (NSString *)getUserEncryptionKey{
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_USER_MQTT_ENCRYPTION_KEY];
}

+ (void)setLastSyncTimeForMetaData:(NSNumber *)metaDataLastSyncTime {
    metaDataLastSyncTime = @([metaDataLastSyncTime doubleValue] + 1);
    NSLog(@"saving last Sync time for meta data in the preference ...%@" ,metaDataLastSyncTime);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[metaDataLastSyncTime doubleValue] forKey:KM_CORE_LAST_SYNC_TIME_FOR_META_DATA];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastSyncTimeForMetaData {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_LAST_SYNC_TIME_FOR_META_DATA];
}

+ (void)disableChat:(BOOL)disable {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool: disable forKey:KM_CORE_DISABLE_USER_CHAT];
    [userDefaults synchronize];
}

+ (BOOL)isChatDisabled {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DISABLE_USER_CHAT];
}

+ (void)setAuthToken:(NSString *)authToken {
    ALSecureStore *store = [KMCoreUserDefaultsHandler getSecureStore];
    NSError *authTokenError;
    [store setValue:authToken forUserAccount:KM_CORE_AUTHENTICATION_TOKEN error:&authTokenError];
    if (authTokenError != nil) {
        ALSLog(ALLoggerSeverityError, @"Failed to save auth token in the store : %@",
               [authTokenError description]);
    }
}

+ (NSString *)getAuthToken {
    ALSecureStore *store = [KMCoreUserDefaultsHandler getSecureStore];
    NSError *authTokenError;
    NSString *authTokenInStore = [store getValueFor:KM_CORE_AUTHENTICATION_TOKEN error:&authTokenError];
    if (authTokenError != nil) {
        ALSLog(ALLoggerSeverityError, @"Failed to get auth token from the store : %@",
               [authTokenError description]);
        return nil;
    }
    return authTokenInStore;
}

+ (void)setAuthTokenCreatedAtTime:(NSNumber *)createdAtTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[createdAtTime doubleValue] forKey:KM_CORE_AUTHENTICATION_TOKEN_CREATED_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getAuthTokenCreatedAtTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_AUTHENTICATION_TOKEN_CREATED_TIME];
}

+ (void)setAuthTokenValidUptoInMins:(NSNumber *)validUptoInMins {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[validUptoInMins doubleValue] forKey:KM_CORE_AUTHENTICATION_TOKEN_VALID_UPTO_MINS];
    [userDefaults synchronize];
}

+ (NSNumber *)getAuthTokenValidUptoMins {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_AUTHENTICATION_TOKEN_VALID_UPTO_MINS];
}

+ (void)setInitialMessageListCallDone:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool:flag forKey:KM_CORE_INITIAL_MESSAGE_LIST_CALL];
    [userDefaults synchronize];
}

+ (BOOL)isInitialMessageListCallDone {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_INITIAL_MESSAGE_LIST_CALL];
}

+ (NSUserDefaults *)getUserDefaults {
    NSString *appSuiteName = [ALUtilityClass getAppGroupsName];
    return [[NSUserDefaults alloc] initWithSuiteName:appSuiteName];
}

+ (void)deactivateLoggedInUser:(BOOL)deactivate {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setBool: deactivate forKey:KM_CORE_LOGGED_IN_USER_DEACTIVATED];
    [userDefaults synchronize];
}

+ (BOOL)isLoggedInUserDeactivated {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_LOGGED_IN_USER_DEACTIVATED];
}

+ (void)setChannelListLastSyncGeneratedTime:(NSNumber *)lastSyncGeneratedTime {
    lastSyncGeneratedTime = @([lastSyncGeneratedTime doubleValue] + 1);
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setDouble:[lastSyncGeneratedTime doubleValue] forKey:KM_CORE_CHANNEL_LIST_LAST_GENERATED_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getChannelListLastSyncGeneratedTime {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    NSNumber *lastSyncGeneratedTime = [userDefaults valueForKey:KM_CORE_CHANNEL_LIST_LAST_GENERATED_TIME];
    if (lastSyncGeneratedTime == nil) {
        lastSyncGeneratedTime = [NSNumber numberWithInt:10000];
    }
    return lastSyncGeneratedTime;
}

+ (void)setVOIPDeviceToken:(NSString *)VOIPDeviceToken {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    [userDefaults setValue:VOIPDeviceToken forKey:KM_CORE_VOIP_DEVICE_TOKEN];
    [userDefaults synchronize];
}

+ (NSString *)getVOIPDeviceToken {
    NSUserDefaults *userDefaults = [KMCoreUserDefaultsHandler getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_VOIP_DEVICE_TOKEN];
}

+ (ALSecureStore *)getSecureStore {
    ALPasswordQueryable *passQuery = [[ALPasswordQueryable alloc] initWithService:KM_CORE_STORE];
    ALSecureStore *store = [[ALSecureStore alloc] initWithSecureStoreQueryable:(passQuery)];
    return store;
}
@end
