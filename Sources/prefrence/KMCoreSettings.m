//
//  KMCoreSettings.m
//  Kommunicate
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 kommunicate. All rights reserved.
//

#import "KMCoreSettings.h"
#import "KMCoreUserDefaultsHandler.h"
#import "ALConstant.h"
#import "ALUtilityClass.h"

@interface KMCoreSettings ()

@end

@implementation KMCoreSettings

+ (void)setFontFace:(NSString *)fontFace {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:fontFace  forKey:KM_CORE_FONT_FACE];
    [userDefaults synchronize];
}

+ (NSString *)getFontFace {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_FONT_FACE];
}

+ (void)setChatCellFontTextStyle:(NSString *)fontTextStyle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:fontTextStyle  forKey:KM_CORE_CHAT_CELL_FONT_TEXT_STYLE];
    [userDefaults synchronize];
}

+ (NSString *)getChatCellFontTextStyle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_CHAT_CELL_FONT_TEXT_STYLE];
}

+ (void)setChatChannelCellFontTextStyle:(NSString *)fontTextStyle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:fontTextStyle  forKey:KM_CORE_CHAT_CHANNEL_CELL_FONT_TEXT_STYLE];
    [userDefaults synchronize];
}

+ (NSString *)getChatChannelCellFontTextStyle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_CHAT_CHANNEL_CELL_FONT_TEXT_STYLE];
}

+ (void)setTitleForConversationScreen:(NSString *)titleText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:titleText  forKey:KM_CORE_CONVERSATION_TITLE];
    [userDefaults synchronize];
}

+ (NSString *)getTitleForConversationScreen {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CONVERSATION_TITLE];
}

+ (void)setUserProfileHidden: (BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_USER_PROFILE_PROPERTY];
    [userDefaults synchronize];
}

+ (BOOL)isUserProfileHidden {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_USER_PROFILE_PROPERTY];
}

+ (void)setColorForSendMessages:(UIColor *)sendMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:sendColorData  forKey:KM_CORE_SEND_MSG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send message color: %@", error);
    }
}

+ (void)setColorForReceiveMessages:(UIColor *)receiveMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:receiveColorData  forKey:KM_CORE_RECEIVE_MSG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send message color: %@", error);
    }
}

+ (UIColor *)getSendMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *sendColorData = [userDefaults objectForKey:KM_CORE_SEND_MSG_COLOUR];
    NSError *error;
    UIColor *sendColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:sendColorData error:&error];
    if (sendColor && !error) { return sendColor; }
    return [UIColor whiteColor];
}

+ (UIColor *)getReceiveMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *receiveColorData = [userDefaults objectForKey:KM_CORE_RECEIVE_MSG_COLOUR];
    NSError *error;
    UIColor *receiveColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:receiveColorData error:&error];
    if (receiveColor && !error) { return receiveColor; }
    return [UIColor whiteColor];
}

+ (void)setColorForNavigation:(UIColor *)barColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *barColorData = [NSKeyedArchiver archivedDataWithRootObject:barColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:barColorData  forKey:KM_CORE_NAVIGATION_BAR_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving naviagtion message color: %@", error);
    }
}

+ (UIColor *)getColorForNavigation {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *barColorData = [userDefaults objectForKey:KM_CORE_NAVIGATION_BAR_COLOUR];
    NSError *error;
    UIColor *barColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:barColorData error:&error];
    if (barColor && !error) { return barColor; }
    return [UIColor whiteColor];
}

+ (void)setColorForNavigationItem:(UIColor *)barItemColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *barItemColorData = [NSKeyedArchiver archivedDataWithRootObject:barItemColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:barItemColorData  forKey:KM_CORE_NAVIGATION_BAR_ITEM_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving navigation bar item color: %@", error);
    }
}

+ (UIColor *)getColorForNavigationItem {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *barItemColourData = [userDefaults objectForKey:KM_CORE_NAVIGATION_BAR_ITEM_COLOUR];
    NSError *error;
    UIColor *barItemColour = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:barItemColourData error:&error];
    if (barItemColour && !error) { return barItemColour; }
    return [UIColor whiteColor];
}

+ (void)hideRefreshButton:(BOOL)state {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:state  forKey:KM_CORE_REFRESH_BUTTON_VISIBILITY];
    [userDefaults synchronize];
}

+ (BOOL)isRefreshButtonHidden {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_REFRESH_BUTTON_VISIBILITY];
}

+ (void)setTitleForBackButtonMsgVC:(NSString *)backButtonTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:backButtonTitle  forKey:KM_CORE_BACK_BUTTON_TITLE];
    [userDefaults synchronize];
}

+ (NSString *)getTitleForBackButtonMsgVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_BACK_BUTTON_TITLE];
}

+ (void)setTitleForBackButtonChatVC:(NSString *)backButtonTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:backButtonTitle  forKey:KM_CORE_BACK_BUTTON_TITLE_CHATVC];
    [userDefaults synchronize];
}

+ (NSString *)getTitleForBackButtonChatVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *text = [userDefaults valueForKey:KM_CORE_BACK_BUTTON_TITLE_CHATVC];
    return text ? text : NSLocalizedStringWithDefaultValue(@"chatViewBack", [KMCoreSettings getLocalizableName],[NSBundle mainBundle], @"Back", @"");
}

+ (void)setNotificationTitle:(NSString *)notificationTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:notificationTitle  forKey:KM_CORE_NOTIFICATION_TITLE];
    [userDefaults synchronize];
}

+ (NSString *)getNotificationTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_NOTIFICATION_TITLE];
}

+ (void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:maxFileSize  forKey:KM_CORE_IMAGE_UPLOAD_MAX_SIZE];
    [userDefaults synchronize];
}

+ (NSInteger)getMaxImageSizeForUploadInMB {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSInteger maxSize = [userDefaults integerForKey:KM_CORE_IMAGE_UPLOAD_MAX_SIZE];
    return maxSize? maxSize : 25;
}

+ (void)setMaxCompressionFactor:(double)maxCompressionRatio {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setDouble:maxCompressionRatio   forKey:KM_CORE_IMAGE_COMPRESSION_FACTOR];
    [userDefaults synchronize];
}

+ (double)getMaxCompressionFactor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults doubleForKey:KM_CORE_IMAGE_COMPRESSION_FACTOR];
}

+ (void)setGroupOption:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_GROUP_ENABLE];
    [userDefaults synchronize];
}

+ (BOOL)getGroupOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_ENABLE];
}

+ (void)setMultipleAttachmentMaxLimit:(NSInteger)limit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:limit  forKey:KM_CORE_MAX_SEND_ATTACHMENT];
    [userDefaults synchronize];
}

+ (NSInteger)getMultipleAttachmentMaxLimit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSInteger maxLimit = [userDefaults integerForKey:KM_CORE_MAX_SEND_ATTACHMENT];
    return maxLimit ? maxLimit : 5;
}

+ (void)setFilterContactsStatus:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_FILTER_CONTACT];
    [userDefaults synchronize];
}

+ (BOOL)getFilterContactsStatus {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_FILTER_CONTACT];
}

+ (void)setStartTime:(NSNumber *)startTime {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    startTime = @([startTime doubleValue] + 1);
    [userDefaults setDouble:[startTime doubleValue]  forKey:KM_CORE_FILTER_CONTACT_START_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getStartTime {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_FILTER_CONTACT_START_TIME];
}

+ (void)setChatWallpaperImageName:(NSString*)imageName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:imageName  forKey:KM_CORE_WALLPAPER_IMAGE];
    [userDefaults synchronize];
}

+ (NSString *)getChatWallpaperImageName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_WALLPAPER_IMAGE];
}

+ (void)setCustomMessageBackgroundColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *recievedCustomBackgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setValue:recievedCustomBackgroundColorData
                         forKey:KM_CORE_CUSTOM_MSG_BACKGROUND_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving custom message background color: %@", error);
    }
}

+ (UIColor *)getCustomMessageBackgroundColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *customMessageBackGroundColorData = [userDefaults
                                                objectForKey:KM_CORE_CUSTOM_MSG_BACKGROUND_COLOR];
    NSError *error;
    UIColor *customMessageBackGroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:customMessageBackGroundColorData error:&error];
    if (customMessageBackGroundColor && !error) { return customMessageBackGroundColor; }
    return [UIColor whiteColor];
}

+ (void)setCustomMessageTextColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *recievedCustomBackgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setValue:recievedCustomBackgroundColorData
                         forKey:KM_CORE_CUSTOM_MSG_TEXT_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving custom message text color: %@", error);
    }
}

+ (UIColor *)getCustomMessageTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *customMessageBackGroundColorData = [userDefaults
                                                objectForKey:KM_CORE_CUSTOM_MSG_TEXT_COLOR];
    NSError *error;
    UIColor *customMessageBackGroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:customMessageBackGroundColorData error:&error];
    if (customMessageBackGroundColor && !error) { return customMessageBackGroundColor; }
    return [UIColor whiteColor];
}

+ (void)setGroupExitOption:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_GROUP_EXIT_BUTTON];
    [userDefaults synchronize];
}

+ (BOOL)getGroupExitOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_EXIT_BUTTON];
}

+ (void)setGroupMemberAddOption:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_GROUP_MEMBER_ADD_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)getGroupMemberAddOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_MEMBER_ADD_OPTION];
}

+ (void)setGroupMemberRemoveOption:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_GROUP_MEMBER_REMOVE_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)getGroupMemberRemoveOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_MEMBER_REMOVE_OPTION];
}

+ (void)setOnlineContactLimit:(NSInteger)limit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:limit  forKey:KM_CORE_ONLINE_CONTACT_LIMIT];
    [userDefaults synchronize];
}

+ (NSInteger)getOnlineContactLimit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSInteger maxLimit = [userDefaults integerForKey:KM_CORE_ONLINE_CONTACT_LIMIT];
    return maxLimit ? maxLimit : 0;
}

+ (void)setContextualChat:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_CONTEXTUAL_CHAT_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)getContextualChatOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTEXTUAL_CHAT_OPTION];
}

+ (NSString *)getCustomClassName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_THIRD_PARTY_VC_NAME];
}

+ (void)setCustomClassName:(NSString *)className {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:className  forKey:KM_CORE_THIRD_PARTY_VC_NAME];
    [userDefaults synchronize];
}

+ (BOOL)getOptionToPushNotificationToShowCustomGroupDetalVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_THIRD_PARTY_DETAIL_VC_NOTIFICATION];
}

+ (void)setOptionToPushNotificationToShowCustomGroupDetalVC:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_THIRD_PARTY_DETAIL_VC_NOTIFICATION];
    [userDefaults synchronize];
}

+ (void)setCallOption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_USER_CALL_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)getCallOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_USER_CALL_OPTION];
}

/*
 NOTIFICATION_ENABLE_SOUND = 0,
 NOTIFICATION_DISABLE_SOUND = 1,
 NOTIFICATION_DISABLE = 2
 */
+ (void)enableNotificationSound {
    [KMCoreUserDefaultsHandler setNotificationMode:AL_NOTIFICATION_ENABLE_SOUND];
}

+ (void)disableNotificationSound {
    [KMCoreUserDefaultsHandler setNotificationMode:AL_NOTIFICATION_DISABLE_SOUND];
}

+ (void)enableNotification {
    [KMCoreUserDefaultsHandler setNotificationMode:KM_CORE_NOTIFICATION_TITLE];
}

+ (void)disableNotification {
    [KMCoreUserDefaultsHandler setNotificationMode:KM_CORE_NOTIFICATION_TITLE];
}

+ (void)setColorForSendButton:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_SEND_BUTTON_BG_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send button color: %@", error);
    }
}

+ (UIColor *)getColorForSendButton {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_SEND_BUTTON_BG_COLOR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor whiteColor];
}

+ (void)setColorForTypeMsgBackground:(UIColor *)viewColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *viewColorData = [NSKeyedArchiver archivedDataWithRootObject:viewColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:viewColorData  forKey:KM_CORE_TYPE_MSG_BG_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving type message background color: %@", error);
    }
}

+ (UIColor *)getColorForTypeMsgBackground {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *viewColorData = [userDefaults objectForKey:KM_CORE_TYPE_MSG_BG_COLOR];
    NSError *error;
    UIColor *viewColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:viewColorData error:&error];
    if (viewColor && !error) { return viewColor; }
    return [UIColor lightGrayColor];
}

+ (void)setBGColorForTypingLabel:(UIColor *)bgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *bgColorData = [NSKeyedArchiver archivedDataWithRootObject:bgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:bgColorData  forKey:KM_CORE_TYPING_LABEL_BG_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving typing label background color: %@", error);
    }
}

+ (UIColor *)getBGColorForTypingLabel {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *bgColorData = [userDefaults objectForKey:KM_CORE_TYPING_LABEL_BG_COLOR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:bgColorData error:&error];
    if (bgColor && !error) { return bgColor; }
    return [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
}

+ (void)setTextColorForTypingLabel:(UIColor *)txtColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *txtColorData = [NSKeyedArchiver archivedDataWithRootObject:txtColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:txtColorData  forKey:KM_CORE_TYPING_LABEL_TEXT_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving typing label text color: %@", error);
    }
}

+ (UIColor *)getTextColorForTypingLabel {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *txtColorData = [userDefaults objectForKey:KM_CORE_TYPING_LABEL_TEXT_COLOR];
    NSError *error;
    UIColor *txtColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:txtColorData error:&error];
    if (txtColor && !error) { return txtColor; }
    return [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5];
}

+ (void)setTextColorForMessageTextView:(UIColor *)txtColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *txtColorData = [NSKeyedArchiver archivedDataWithRootObject:txtColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:txtColorData  forKey:KM_CORE_MESSAGE_TEXT_VIEW_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving message text view color: %@", error);
    }
}

+ (UIColor *)getTextColorForMessageTextView {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *txtColorData = [userDefaults objectForKey:KM_CORE_MESSAGE_TEXT_VIEW_COLOR];
    NSError *error;
    UIColor *txtColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:txtColorData error:&error];
    if (txtColor && !error) { return txtColor; }
    return [UIColor blackColor];
}


+ (void)setEmptyConversationText:(NSString *)text {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:text  forKey:KM_CORE_EMPTY_CONVERSATION_TEXT];
    [userDefaults synchronize];
}

+ (NSString *)getEmptyConversationText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *text = [userDefaults valueForKey:KM_CORE_EMPTY_CONVERSATION_TEXT];
    return text ? text : NSLocalizedStringWithDefaultValue(@"noConversationTitle", [KMCoreSettings getLocalizableName],[NSBundle mainBundle], @"You have no conversations yet", @"");
}

+ (void)setVisibilityNoConversationLabelChatVC:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_NO_CONVERSATION_FLAG_CHAT_VC];
    [userDefaults synchronize];
}

+ (BOOL)getVisibilityNoConversationLabelChatVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_NO_CONVERSATION_FLAG_CHAT_VC];
}

+ (void)setVisibilityForOnlineIndicator:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_ONLINE_INDICATOR_VISIBILITY];
    [userDefaults synchronize];
}

+ (BOOL)getVisibilityForOnlineIndicator {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ONLINE_INDICATOR_VISIBILITY];
}

+ (void)setVisibilityForNoMoreConversationMsgVC:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_NO_MORE_CONVERSATION_VISIBILITY];
    [userDefaults synchronize];
}

+ (BOOL)getVisibilityForNoMoreConversationMsgVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_NO_MORE_CONVERSATION_VISIBILITY];
}

+ (void)enableRefreshChatButtonInMsgVc:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_CUSTOM_NAV_RIGHT_BUTTON_MSGVC];
    [userDefaults synchronize];
}

+ (BOOL)isRefreshChatButtonEnabledInMsgVc {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CUSTOM_NAV_RIGHT_BUTTON_MSGVC];
}

+ (void)setColorForToastBackground:(UIColor *)toastBGColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *toastBGData = [NSKeyedArchiver archivedDataWithRootObject:toastBGColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:toastBGData  forKey:KM_CORE_TOAST_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving toast background color: %@", error);
    }
}

+ (UIColor *)getColorForToastBackground {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *toastBGData = [userDefaults objectForKey:KM_CORE_TOAST_BG_COLOUR];
    NSError *error;
    UIColor *toastBGColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:toastBGData error:&error];
    if (toastBGColor && !error) { return toastBGColor; }
    return [UIColor grayColor];
}

+ (void)setColorForToastText:(UIColor *)toastTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *toastTextData = [NSKeyedArchiver archivedDataWithRootObject:toastTextColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:toastTextData  forKey:KM_CORE_TOAST_TEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving toast text color: %@", error);
    }
}

+ (UIColor *)getColorForToastText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *toastTextData = [userDefaults objectForKey:KM_CORE_TOAST_TEXT_COLOUR];
    NSError *error;
    UIColor *toastTextColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:toastTextData error:&error];
    if (toastTextColor && !error) { return toastTextColor; }
    return [UIColor blackColor];
}

+ (void)setSendMsgTextColor:(UIColor *)sendMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:sendColorData  forKey:KM_CORE_SEND_MSG_TEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send message text color: %@", error);
    }
}

+ (UIColor *)getSendMsgTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *sendColorData = [userDefaults objectForKey:KM_CORE_SEND_MSG_TEXT_COLOUR];
    NSError *error;
    UIColor *sendColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:sendColorData error:&error];
    if (sendColor && !error) { return sendColor; }
    return [UIColor whiteColor];
}

+ (void)setReceiveMsgTextColor:(UIColor *)receiveMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:receiveColorData  forKey:KM_CORE_RECEIVE_MSG_TEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving receive message text color: %@", error);
    }
}

+ (UIColor *)getReceiveMsgTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *receiveColorData = [userDefaults objectForKey:KM_CORE_RECEIVE_MSG_TEXT_COLOUR];
    NSError *error;
    UIColor *receiveColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:receiveColorData error:&error];
    if (receiveColor && !error) { return receiveColor; }
    return [UIColor grayColor];
}

+ (void)setMsgTextViewBGColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MSG_TEXT_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving message text view background color: %@", error);
    }
}

+ (UIColor *)getMsgTextViewBGColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MSG_TEXT_BG_COLOUR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (bgColor && !error) { return bgColor; }
    return [UIColor whiteColor];
}

+ (void)setPlaceHolderColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_PLACE_HOLDER_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving placeholder color: %@", error);
    }
}

+ (UIColor *)getPlaceHolderColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_PLACE_HOLDER_COLOUR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (bgColor && !error) { return bgColor; }
    return [UIColor grayColor];
}

+ (void)setUnreadCountLabelBGColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_UNREAD_COUNT_LABEL_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving unread count label background color: %@", error);
    }
}

+ (UIColor *)getUnreadCountLabelBGColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_UNREAD_COUNT_LABEL_BG_COLOUR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (bgColor && !error) { return bgColor; }
    return [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1];
}

+ (void)setStatusBarBGColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_STATUS_BAR_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving status bar background color: %@", error);
    }
}

+ (UIColor *)getStatusBarBGColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_STATUS_BAR_BG_COLOUR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (bgColor && !error) { return bgColor; }
    return [self getColorForNavigation];
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:style  forKey:KM_CORE_STATUS_BAR_STYLE];
    [userDefaults synchronize];
}

+ (UIStatusBarStyle)getStatusBarStyle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    UIStatusBarStyle style = [userDefaults integerForKey:KM_CORE_STATUS_BAR_STYLE];
    return style ? style : UIStatusBarStyleDefault;
}

+ (void)setMaxTextViewLines:(int)numberOfLines {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:numberOfLines  forKey:KM_CORE_MAX_TEXT_VIEW_LINES];
    [userDefaults synchronize];
}

+ (int)getMaxTextViewLines {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSInteger line = [userDefaults integerForKey:KM_CORE_MAX_TEXT_VIEW_LINES];
    return line ? (int)line : 4;
}

+ (NSString *)getAbuseWarningText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *msg = [userDefaults valueForKey:KM_CORE_ABUSE_WORDS_WARNING_TEXT];
    return msg ? msg :  NSLocalizedStringWithDefaultValue(@"restrictionWorldInfo", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"AVOID USE OF ABUSE WORDS", @"");
    ;
}

+ (void)setAbuseWarningText:(NSString *)warningText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:warningText  forKey:KM_CORE_ABUSE_WORDS_WARNING_TEXT];
    [userDefaults synchronize];
}

+ (void)setMessageAbuseMode:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_ENABLE_MSGTEXT_ABUSE_CHECK];
    [userDefaults synchronize];
}

+ (BOOL)getMessageAbuseMode {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ENABLE_MSGTEXT_ABUSE_CHECK];
}

+ (void)setDateColor:(UIColor *)dateColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:dateColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MSG_DATE_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving date color: %@", error);
    }
}

+ (UIColor *)getDateColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MSG_DATE_COLOR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5];
}

+ (void)setMsgDateColor:(UIColor *)dateColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:dateColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MSG_SEPERATE_DATE_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving message date color: %@", error);
    }
}

+ (UIColor *)getMsgDateColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MSG_SEPERATE_DATE_COLOR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor blackColor];
}

+ (void)setReceiverUserProfileOption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_ENABLE_RECEIVER_USER_PROFILE];
    [userDefaults synchronize];
}

+ (BOOL)getReceiverUserProfileOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ENABLE_RECEIVER_USER_PROFILE];
}

+ (void)setCustomMessageFontSize:(float)fontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setFloat:fontSize  forKey:KM_CORE_CUSTOM_MSG_FONT_SIZE];
    [userDefaults synchronize];
}

+ (float)getCustomMessageFontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    float size = [userDefaults floatForKey:KM_CORE_CUSTOM_MSG_FONT_SIZE];
    return size ? size : 14;
}

+ (void)setCustomMessageFont:(NSString *)font {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:font  forKey:KM_CORE_CUSTOM_MSG_FONT];
    [userDefaults synchronize];
}

+ (NSString *)getCustomMessageFont {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *font = [userDefaults valueForKey:KM_CORE_CUSTOM_MSG_FONT];
    return font ? font : @"Helvetica";
}

+ (void)setGroupInfoDisabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_GROUP_INFO_DISABLED];
    [userDefaults synchronize];
}

+ (BOOL)isGroupInfoDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_INFO_DISABLED];
}

+ (void)setGroupInfoEditDisabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_GROUP_INFO_EDIT_DISABLED];
    [userDefaults synchronize];
}

+ (BOOL)isGroupInfoEditDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_INFO_EDIT_DISABLED];
}

+ (void)setContactTypeToFilter:(NSMutableArray *)arrayWithIds {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:arrayWithIds  forKey:KM_CORE_FILTER_ONLY_CONTACT_TYPE_ID];
    [userDefaults synchronize];
}

+ (NSMutableArray *)getContactTypeToFilter {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [[userDefaults objectForKey:KM_CORE_FILTER_ONLY_CONTACT_TYPE_ID] mutableCopy];
}

+ (NSString *)getCustomNavigationControllerClassName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *className = [userDefaults stringForKey:KM_CORE_CUSTOM_NAVIGATION_CLASS_NAME];
    return className;
}

+ (void)setNavigationControllerClassName:(NSString *)className {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:className  forKey:KM_CORE_CUSTOM_NAVIGATION_CLASS_NAME];
    [userDefaults synchronize];
}

+ (void)setSubGroupLaunchFlag:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_SUB_GROUP_LAUNCH];
    [userDefaults synchronize];
}

+ (BOOL)getSubGroupLaunchFlag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_SUB_GROUP_LAUNCH];
}

+ (void)setGroupOfTwoFlag:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_GROUP_OF_TWO_FLAG];
    [userDefaults synchronize];
}

+ (BOOL)getGroupOfTwoFlag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_OF_TWO_FLAG];
}

+ (void)setBroadcastGroupEnable:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_BROADCAST_GROUP_ENABLE];
    [userDefaults synchronize];
}

+ (BOOL)isBroadcastGroupEnable {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_BROADCAST_GROUP_ENABLE];
}

+ (void)setListOfViewControllers:(NSArray *)viewList {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:viewList  forKey:KM_CORE_VIEW_CONTROLLER_ARRAY];
    [userDefaults synchronize];
}

+ (NSArray *)getListOfViewControllers {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_VIEW_CONTROLLER_ARRAY];
}

+ (NSString *)getMsgContainerVC {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults stringForKey:KM_CORE_MSG_CONTAINER_VC];
}

+ (void)setMsgContainerVC:(NSString *)className {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:className  forKey:KM_CORE_MSG_CONTAINER_VC];
    [userDefaults synchronize];
}

+ (void)setAudioVideoClassName:(NSString *)className {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:className  forKey:KM_CORE_AUDIO_VIDEO_CLASS];
    [userDefaults synchronize];
}

+ (NSString *)getAudioVideoClassName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_AUDIO_VIDEO_CLASS];
}

+ (void)setClientStoryBoard:(NSString *)storyboard {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:storyboard  forKey:KM_CORE_CLIENT_STORYBOARD];
    [userDefaults synchronize];
}

+ (NSString *)getClientStoryBoard {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CLIENT_STORYBOARD];
}
+ (NSString *)getGroupDeletedTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *title = [userDefaults stringForKey:KM_CORE_GROUP_DELETED_TITLE];
    return title ? title : NSLocalizedStringWithDefaultValue(@"groupDeletedInfo", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"This Group has been Deleted", @"");
}

+ (void)setGroupDeletedTitle:(NSString *)title {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:title  forKey:KM_CORE_GROUP_DELETED_TITLE];
    [userDefaults synchronize];
}

+ (NSString *)getUserDeletedText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *text = [userDefaults valueForKey:KM_CORE_USER_DELETED_TEXT];
    return text ? text :NSLocalizedStringWithDefaultValue(@"userDeletedInfo", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"User has been deleted", @"");
}

+ (void)setUserDeletedText:(NSString *)text {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:text  forKey:KM_CORE_USER_DELETED_TEXT];
    [userDefaults synchronize];
}

+ (UIImage *)getChatListTabIcon {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *iconName = [userDefaults valueForKey:KM_CORE_CHAT_LIST_TAB_ICON];
    UIImage *customImg = nil;
    if (iconName.length) {
        customImg = [UIImage imageNamed:iconName];
    }
    return customImg;
}

+ (void)setChatListTabIcon:(NSString *)imageName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:imageName  forKey:KM_CORE_CHAT_LIST_TAB_ICON];
    [userDefaults synchronize];
}

+ (NSString *)getChatListTabTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *stringtext = [userDefaults valueForKey:KM_CORE_CHAT_LIST_TAB_TITLE];
    return (stringtext && stringtext.length) ? stringtext :NSLocalizedStringWithDefaultValue(@"tabbarChatsTitle", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Chats", @"");
}

+ (void)setChatListTabTitle:(NSString *)title {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:title  forKey:KM_CORE_CHAT_LIST_TAB_TITLE];
    [userDefaults synchronize];
}

+ (UIImage *)getProfileTabIcon {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *iconName = [userDefaults valueForKey:KM_CORE_USER_PROFILE_TAB_ICON];
    UIImage *customImg = nil;
    if (iconName.length) {
        customImg = [UIImage imageNamed:iconName];
    }
    return customImg;
}

+ (void)setProfileTabIcon:(NSString *)imageName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:imageName  forKey:KM_CORE_USER_PROFILE_TAB_ICON];
    [userDefaults synchronize];
}

+ (NSString *)getProfileTabTitle {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *stringtext = [userDefaults valueForKey:KM_CORE_USER_PROFILE_TAB_TITLE];
    return (stringtext && stringtext.length) ? stringtext : NSLocalizedStringWithDefaultValue(@"tabbarProfileTitle", [KMCoreSettings getLocalizableName], [NSBundle mainBundle], @"Profile", @"");
}

+ (void)setProfileTabTitle:(NSString *)title {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:title  forKey:KM_CORE_USER_PROFILE_TAB_TITLE];
    [userDefaults synchronize];
}

+ (void)openChatOnTapUserProfile:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_OPEN_CHAT_ON_USER_PROFILE_TAP];
    [userDefaults synchronize];
}

+ (BOOL)isChatOnTapUserProfile {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_OPEN_CHAT_ON_USER_PROFILE_TAP];
}

+ (void)replyOptionEnabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_MESSAGE_REPLY_ENABLED];
    [userDefaults synchronize];
}

+ (BOOL)isReplyOptionEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_MESSAGE_REPLY_ENABLED];
}

+ (void)setAudioVideoEnabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_AV_ENABLED];
    [userDefaults synchronize];
}

+ (BOOL)isAudioVideoEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_AV_ENABLED];
}

+ (void)enableOrDisableContactsGroup:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_CONTACTS_GROUP];
    [userDefaults synchronize];
}

+ (BOOL)isContactsGroupEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTACTS_GROUP];
}

+ (void)setContactsGroupId:(NSString *)contactsGroupId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:contactsGroupId  forKey:KM_CORE_CONTACTS_GROUP_ID];
    [userDefaults synchronize];
}

+ (NSString *)getContactsGroupId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CONTACTS_GROUP_ID];
}

+ (void)setContactGroupIdList:(NSArray *)contactsGroupIdList {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:contactsGroupIdList  forKey:KM_CORE_CONTACTS_GROUP_ID_LIST];
    [userDefaults synchronize];
}

+ (NSArray*)getContactGroupIdList {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CONTACTS_GROUP_ID_LIST];
}

+ (void)forwardOptionEnableOrDisable:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_FORWARD_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)isForwardOptionEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_FORWARD_OPTION];
}

+ (void)setSwiftFramework:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_SWIFT_FRAMEWORK];
    [userDefaults synchronize];
}

+ (BOOL)isSwiftFramework {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_SWIFT_FRAMEWORK];
}

+ (BOOL)isStorageServiceEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DEDICATED_SERVER];
}

+ (void)enableStorageService:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DEDICATED_SERVER];
    [userDefaults synchronize];
}

+ (BOOL)isGoogleCloudServiceEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GOOGLE_CLOUD_SERVICE_ENABLE];
}

+ (void)enableGoogleCloudService:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_GOOGLE_CLOUD_SERVICE_ENABLE];
    [userDefaults synchronize];
}

+ (void)setHideAttachmentsOption:(NSMutableArray *)array {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:array  forKey:KM_CORE_HIDE_ATTACHMENT_OPTION];
    [userDefaults synchronize];
}

+ (NSArray *)getHideAttachmentsOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_HIDE_ATTACHMENT_OPTION];
}

+ (void)setTemplateMessages:(NSMutableDictionary *)dictionary {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:dictionary  forKey:KM_CORE_TEMPLATE_MESSAGES];
    [userDefaults synchronize];
}

+ (NSMutableDictionary *)getTemplateMessages {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_TEMPLATE_MESSAGES];
}

+ (BOOL)isTemplateMessageEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_TEMPLATE_MESSAGE_VIEW];
}

+ (void)enableTeamplateMessage:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_TEMPLATE_MESSAGE_VIEW];
    [userDefaults synchronize];
}

+ (BOOL)isCameraOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":camera"]);
}

+ (BOOL)isPhotoGalleryOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":gallery"]);
}

+ (BOOL)isSendAudioOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":audio"]);
}

+ (BOOL)isSendVideoOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":video"]);
}

+ (BOOL)isLocationOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":location"]);
}

+ (BOOL)isBlockUserOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":blockUser"]);
}

+ (BOOL)isShareContactOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":shareContact"]);
}

+ (BOOL)isAttachmentButtonHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":attachmentbutton"]);
}

+ (BOOL)isDocumentOptionHidden {
    return ([[self getHideAttachmentsOption] containsObject:@":document"] || !self.isDocumentOptionEnabled);
}

+ (BOOL)isDocumentOptionEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DOCUMENT_OPTION];
}

+ (void)enableDocumentOption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DOCUMENT_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)isS3StorageServiceEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_S3_STORAGE_SERVICE];
}

+ (void)enableS3StorageService:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_S3_STORAGE_SERVICE];
    [userDefaults synchronize];
}

// This will set the default group type (to be used when "Create Group" button is pressed).
+ (void)setDefaultGroupType:(NSInteger)type {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setInteger:type  forKey:KM_CORE_DEFAULT_GROUP_TYPE];
    [userDefaults synchronize];
}

+ (NSInteger)getDefaultGroupType {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return([userDefaults integerForKey:KM_CORE_DEFAULT_GROUP_TYPE ]);
}

/// If enabled, all the videos (recieved or sent) will be saved in the gallery.
+ (void)enableSaveVideosToGallery:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_SAVE_VIDEOS_TO_GALLERY];
}

+ (BOOL)isSaveVideoToGalleryEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_SAVE_VIDEOS_TO_GALLERY];
}

+ (void)enableQuickAudioRecording:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_ENABLE_QUICK_AUDIO_RECORDING];
}

+ (BOOL)isQuickAudioRecordingEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ENABLE_QUICK_AUDIO_RECORDING];
}

+ (void)setUserRoleName:(NSString*)roleName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:roleName  forKey:KM_CORE_USER_ROLE_NAME];
    [userDefaults synchronize];
}

+ (NSString *)getUserRoleName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *stringtext = [userDefaults valueForKey:KM_CORE_USER_ROLE_NAME];
    return stringtext ? stringtext : @"USER";
}

+ (void)setConversationCloseButton:(BOOL)option {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:option  forKey:KM_CORE_GROUP_CONVEERSATION_CLOSE];
    [userDefaults synchronize];
}

+ (BOOL)isConversationCloseButtonEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUP_CONVEERSATION_CLOSE];
}

+ (void)setDropShadowInNavigationBar:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DROP_IN_SHADOW_IN_NAVIGATION_BAR];
    [userDefaults synchronize];
}

+ (BOOL)isDropShadowInNavigationBarEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DROP_IN_SHADOW_IN_NAVIGATION_BAR];
}

+ (void)setLocalizableName:(NSString *)localizableName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:localizableName  forKey:KM_CORE_APPLOZIC_LOCALIZABLE];
    [userDefaults synchronize];
}

+ (NSString *)getLocalizableName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_APPLOZIC_LOCALIZABLE];
}

+ (void)setCategoryName:(NSString *)categoryName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:categoryName  forKey:KM_CORE_CATEGORY_NAME];
    [userDefaults synchronize];
}

+ (NSString *)getCategoryName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CATEGORY_NAME];
}

+ (BOOL)isDeleteConversationOptionEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DELETE_CONVERSATION_OPTION];
}

+ (void)setDeleteConversationOption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DELETE_CONVERSATION_OPTION];
    [userDefaults synchronize];
}

+ (BOOL)isContactSearchEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CONTACT_SEARCH];
}

+ (void)enableContactSearch:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_CONTACT_SEARCH];
    [userDefaults synchronize];
}

+ (BOOL)isChannelMembersInfoInNavigationBarEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_CHANNEL_MEMBER_INFO_IN_SUBTITLE];
}

+ (UIColor *)getTabBarBackgroundColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_TABBAR_BACKGROUND_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:0.5];
}
+ (void)setTabBarBackgroundColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_TABBAR_BACKGROUND_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving tab bar background color: %@", error);
    }
    
}
+ (UIColor *)getTabBarSelectedItemColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_TABBAR_SELECTED_ITEM_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor blueColor];
}
+ (void)setTabBarSelectedItemColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_TABBAR_SELECTED_ITEM_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving tab bar selected item color: %@", error);
    }
}
+ (UIColor *)getTabBarUnSelectedItemColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_TABBAR_UNSELECTED_ITEM_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor grayColor];
}
+ (void)setTabBarUnSelectedItemColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_TABBAR_UNSELECTED_ITEM_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving tab bar unselected item color: %@", error);
    }
}
+ (UIColor *)getAttachmentIconColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_ATTACHMENT_ITEM_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (!error) { return color; }
    return [UIColor grayColor];
}
+ (void)setAttachmentIconColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_ATTACHMENT_ITEM_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving attachment icon color: %@", error);
    }
}
+ (UIColor *)getSendIconColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_SEND_ITEM_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor whiteColor];
}
+ (void)setSendIconColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_SEND_ITEM_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send icon color: %@", error);
    }
}
+ (UIColor *)getMessageSubtextColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MESSAGE_SUBTEXT_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor colorWithRed:144.0/255 green:144.0/255 blue:144.00/255 alpha:1.0];
}
+ (void)setMessageSubtextColour:(UIColor *)color{
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MESSAGE_SUBTEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving send message sub text color: %@", error);
    }
}
+ (UIColor *)getMessageListTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MESSAGE_TEXT_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor colorWithRed:107.0/255 green:107.0/255 blue:107.0/255 alpha:1.0];
}
+ (void)setMessageListTextColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MESSAGE_TEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving message list text color: %@", error);
    }
}
+ (UIColor *)getProfileMainColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_PROFILE_MAIN_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
}
+ (void)setProfileMainColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error){
        [userDefaults setObject:colorData  forKey:KM_CORE_PROFILE_MAIN_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving profile main color: %@", error);
    }
}
+ (UIColor *)getProfileSubColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_PROFILE_SUB_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor colorWithRed:0.93 green:0.98 blue:1.00 alpha:1.0];
}
+ (void)setProfileSubColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_PROFILE_SUB_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving profile sub color: %@", error);
    }
}
+ (UIColor *)getNewContactMainColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_NEW_CONTACT_MAIN_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
}
+ (void)setNewContactMainColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_NEW_CONTACT_MAIN_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving new contact main color: %@", error);
    }
}
+ (UIColor *)getNewContactSubColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_NEW_CONTACT_SUB_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor whiteColor];
}
+ (void)setNewContactSubColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_NEW_CONTACT_SUB_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving new contact sub color: %@", error);
    }
}
+ (UIColor *)getNewContactTextColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_NEW_CONTACT_TEXT_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return nil;
}
+ (void)setNewContactTextColour:(UIColor *)color{
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_NEW_CONTACT_TEXT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving new contact text color: %@", error);
    }
}
+ (UIColor *)getSearchBarTintColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_SEARCHBAR_TINT_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return nil;
}
+ (void)setSearchBarTintColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_SEARCHBAR_TINT_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving search bar tint color: %@", error);
    }
}
+ (UIColor *)getMessagesViewBackgroundColour {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_MESSAGES_VIEW_BG_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return color; }
    return [UIColor whiteColor];
}
+ (void)setMessagesViewBackgroundColour:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_MESSAGES_VIEW_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving message view background color: %@", error);
    }
}

+ (UIColor *)getChatViewControllerBackgroundColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *colorData = [userDefaults objectForKey:KM_CORE_CHAT_VIEW_BG_COLOUR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
}
+ (void)setChatViewControllerBackgroundColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_CHAT_VIEW_BG_COLOUR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving chat view controller background color: %@", error);
    }
}

+ (void)showChannelMembersInfoInNavigationBar:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_CHANNEL_MEMBER_INFO_IN_SUBTITLE];
    [userDefaults synchronize];
}

+ (NSArray *)metadataKeysToHideMessages {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_HIDE_MESSAGES_WITH_METADATA_KEYS];
}

+ (void)hideMessagesWithMetadataKeys:(NSArray *)keys {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:keys  forKey:KM_CORE_HIDE_MESSAGES_WITH_METADATA_KEYS];
    [userDefaults synchronize];
}

+ (BOOL)isMultiSelectGalleryViewDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:ALDisableMultiSelectGalleryView];
}
+ (void)disableMultiSelectGalleryView:(BOOL)enabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:enabled forKey:ALDisableMultiSelectGalleryView];
    [userDefaults synchronize];
}

+ (BOOL)is5MinVideoLimitInGalleryEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_5MIN_VIDEO_LIMIT_IN_GALLERY];
}
+ (void)enable5MinVideoLimitInGallery:(BOOL)enabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:enabled  forKey:KM_CORE_5MIN_VIDEO_LIMIT_IN_GALLERY];
    [userDefaults synchronize];
}

+ (void)setBackgroundColorForAttachmentPlusIcon:(UIColor *)backgroundColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *backgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:backgroundColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:backgroundColorData  forKey:KM_CORE_BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving attachment plus icon background color: %@", error);
    }
}

+ (UIColor *)getBackgroundColorForAttachmentPlusIcon {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *backgroundColorData = [userDefaults objectForKey:KM_CORE_BACKGROUND_COLOR_FOR_ATTACHMENT_PLUS_ICON];
    NSError *error;
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:backgroundColorData error:&error];
    if (!error) { return backgroundColor; }
    return nil;
}

+ (void)clearAll {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSUserDefaults *oldUserDefaults = [KMCoreSettings getOldUserDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    NSArray *keyArray = [dictionary allKeys];
    for (NSString *defaultKeyString in keyArray) {
        if ([defaultKeyString hasPrefix:@"com.applozic"] &&
            ![defaultKeyString isEqualToString:KM_CORE_APN_DEVICE_TOKEN] &&
            ![defaultKeyString isEqualToString:KM_CORE_VOIP_DEVICE_TOKEN]) {
            [oldUserDefaults removeObjectForKey:defaultKeyString];
            [oldUserDefaults synchronize];
        }
        if ([defaultKeyString hasPrefix:@"io.kommunciate.core"] &&
            ![defaultKeyString isEqualToString:KM_CORE_APN_DEVICE_TOKEN] &&
            ![defaultKeyString isEqualToString:KM_CORE_VOIP_DEVICE_TOKEN]) {
            [userDefaults removeObjectForKey:defaultKeyString];
            [userDefaults synchronize];
        }
    }
}

+ (BOOL)isTextStyleInCellEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_TEXT_STYLE_FOR_CELL];
}

+ (void)enableTextStyleCell:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_TEXT_STYLE_FOR_CELL];
    [userDefaults synchronize];
}

+ (void)setChatCellTextFontSize:(float)fontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setFloat:fontSize  forKey:KM_CORE_CHAT_CELL_FONT_SIZE];
    [userDefaults synchronize];
}

+ (float)getChatCellTextFontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    float size = [userDefaults floatForKey:KM_CORE_CHAT_CELL_FONT_SIZE];
    return size ? size : 14;
}

+ (void)setChannelCellTextFontSize:(float)fontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setFloat:fontSize  forKey:KM_CORE_CHANNEL_CELL_FONT_SIZE];
    [userDefaults synchronize];
}

+ (float)getChannelCellTextFontSize {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    float size = [userDefaults floatForKey:KM_CORE_CHANNEL_CELL_FONT_SIZE];
    return size ? size : 14;
}

+ (void)setBackgroundColorForAudioRecordingView:(UIColor *)backgroundColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *backgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:backgroundColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:backgroundColorData  forKey:KM_CORE_AUDIO_RECORDING_VIEW_BACKGROUND_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving audio recording background color: %@", error);
    }
}
+ (UIColor *)getBackgroundColorForAudioRecordingView {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *backgroundColorData = [userDefaults objectForKey:KM_CORE_AUDIO_RECORDING_VIEW_BACKGROUND_COLOR];
    NSError *error;
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:backgroundColorData error:&error];
    if (backgroundColor && !error) { return backgroundColor; }
    return [UIColor lightGrayColor];
}

+ (void)setColorForSlideToCancelText:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *textColorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:textColorData  forKey:KM_CORE_SLIDE_TO_CANCEL_TEXT_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving slide to cancel color: %@", error);
    }
}
+ (UIColor *)getColorForSlideToCancelText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *textColorData = [userDefaults objectForKey:KM_CORE_SLIDE_TO_CANCEL_TEXT_COLOR];
    NSError *error;
    UIColor *textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
    if (textColor && !error) { return textColor; }
    return [UIColor darkGrayColor];
}

+ (void)setColorForAudioRecordingText:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *textColorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:textColorData  forKey:KM_CORE_AUDIO_RECORDING_TEXT_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving audio recording text color: %@", error);
    }
}
+ (UIColor *)getColorForAudioRecordingText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *textColorData = [userDefaults objectForKey:KM_CORE_AUDIO_RECORDING_TEXT_COLOR];
    NSError *error;
    UIColor *textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
    if (textColor && !error) { return  textColor; }
    return [UIColor redColor];
}

+ (void)setFontForAudioView:(NSString *)font {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:font  forKey:KM_CORE_AUDIO_RECORD_VIEW_FONT];
    [userDefaults synchronize];
}
+ (NSString *)getFontForAudioView {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *font = [userDefaults valueForKey:KM_CORE_AUDIO_RECORD_VIEW_FONT];
    return font ? font : @"Helvetica";
}

+ (void)enableNewAudioDesign:(BOOL)enable {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:enable  forKey:KM_CORE_ENABLE_NEW_AUDIO_DESIGN];
    [userDefaults synchronize];
}

+ (BOOL)isNewAudioDesignEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_ENABLE_NEW_AUDIO_DESIGN];
}

+ (void)setBackgroundColorForReplyView:(UIColor *)backgroudColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:backgroudColor requiringSecureCoding: YES error:&error];
    if (!error) {
        [userDefaults setObject:receiveColorData  forKey:KM_CORE_BACKGROUND_COLOR_FOR_REPLY_VIEW];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving reply view background color: %@", error);
    }
}

+ (UIColor *)getBackgroundColorForReplyView {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *sendColorData = [userDefaults objectForKey:KM_CORE_BACKGROUND_COLOR_FOR_REPLY_VIEW];
    NSError *error;
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:sendColorData error:&error];
    if (backgroundColor && !error) { return backgroundColor; }
    return [UIColor grayColor];
}

+ (void)setHideMediaSelectOption:(NSMutableArray *)array {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:array  forKey:KM_CORE_MEDIA_SELECT_OPTIONS];
    [userDefaults synchronize];
}

+ (NSArray *)getHideMediaSelectOption {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_MEDIA_SELECT_OPTIONS];
}

+ (BOOL)imagesHiddenInGallery {
    return [self getHideMediaSelectOption] && [[self getHideMediaSelectOption] containsObject:@":image"];
}

+ (BOOL)videosHiddenInGallery {
    return [self getHideMediaSelectOption] && [[self getHideMediaSelectOption] containsObject:@":video"];
}

+ (void)setChannelActionMessageBgColor:(UIColor *)bgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *bgColorData = [NSKeyedArchiver archivedDataWithRootObject:bgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:bgColorData  forKey:KM_CORE_CHANNEL_ACTION_MESSAGE_BG_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving channel action message background color: %@", error);
    }
}

+ (UIColor *)getChannelActionMessageBgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *bgColorData = [userDefaults objectForKey:KM_CORE_CHANNEL_ACTION_MESSAGE_BG_COLOR];
    NSError *error;
    UIColor *bgColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:bgColorData error:&error];
    if (bgColor && !error) { return  bgColor; }
    return [UIColor lightGrayColor];
}

+ (void)setChannelActionMessageTextColor:(UIColor *)textColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *txtColorData = [NSKeyedArchiver archivedDataWithRootObject:textColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:txtColorData  forKey:KM_CORE_CHANNEL_ACTION_MESSAGE_TEXT_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving channel action message text color: %@", error);
    }
}

+ (UIColor *)getChannelActionMessageTextColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *textColorData = [userDefaults objectForKey:KM_CORE_CHANNEL_ACTION_MESSAGE_TEXT_COLOR];
    NSError *error;
    UIColor *txtColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
    if (txtColor && !error) { return txtColor; }
    return [UIColor blackColor];
}

+ (void)setUserIconFirstNameColorCodes:(NSMutableDictionary *)nsMutableDictionary {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:nsMutableDictionary  forKey:KM_CORE_ALPHABETIC_COLOR_CODES];
    [userDefaults synchronize];
}

+ (NSArray*)getUserIconFirstNameColorCodes {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults objectForKey:KM_CORE_ALPHABETIC_COLOR_CODES];
}

+ (void)setIsUnblockInChatDisabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DISABLE_UNBLOCK_FROM_CHAT];
    [userDefaults synchronize];
}

+ (BOOL)isUnblockInChatDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    BOOL key =   [userDefaults boolForKey:KM_CORE_DISABLE_UNBLOCK_FROM_CHAT];
    return key;
}

+ (void)setupSuiteAndMigrate {
    [KMCoreSettings migrateUserDefaultsToAppGroups];
}

+ (NSString *)getShareExtentionGroup {
    return [ALUtilityClass getAppGroupsName];
}

+ (NSUserDefaults *)getUserDefaults {
    NSString *appSuiteName = [ALUtilityClass getAppGroupsName];
    return [[NSUserDefaults alloc] initWithSuiteName:appSuiteName];
}

+ (NSUserDefaults *)getOldUserDefaults {
    NSString *appSuiteName = [ALUtilityClass getOldAppGroupsName];
    return [[NSUserDefaults alloc] initWithSuiteName:appSuiteName];
}

+ (void)setUserDefaultsMigratedFlag:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_USER_DEFAULTS_MIGRATION];
    [userDefaults synchronize];
}

+ (BOOL)isUserDefaultsMigrated {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_USER_DEFAULTS_MIGRATION];
}

+ (BOOL)isAddContactButtonForSenderDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_SENT_MESSAGE_CONTACT_BUTTON];
}

+ (void)disableAddContactButtonForSender {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:YES  forKey:KM_CORE_SENT_MESSAGE_CONTACT_BUTTON];
    [userDefaults synchronize];
}

+ (void)setColorForSentContactMsgLabel:(UIColor *)sentContactLabelMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sentContactLabelMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:sendColorData  forKey:KM_CORE_SENT_CONTACT_MSG_LABEL_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving sent contact message color: %@", error);
    }
}

+ (void)setColorForReceivedContactMsgLabel:(UIColor *)receivedMsgColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receivedMsgColor requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:receiveColorData  forKey:KM_CORE_RECEIVED_CONTACT_MSG_LABEL_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving recived contact message color: %@", error);
    }
}

+ (UIColor *)getSentContactMsgLabelColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *sentColorData = [userDefaults objectForKey:KM_CORE_SENT_CONTACT_MSG_LABEL_COLOR];
    NSError *error;
    UIColor *sentContactMsgLabelColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:sentColorData error:&error];
    if (sentContactMsgLabelColor && !error) { return sentContactMsgLabelColor; }
    return [UIColor whiteColor];
}

+ (UIColor *)getReceivedContactMsgLabelColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *receivedColorData = [userDefaults objectForKey:KM_CORE_RECEIVED_CONTACT_MSG_LABEL_COLOR];
    NSError *error;
    UIColor *recivedContactMsgLabelColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:receivedColorData error:&error];
    if (recivedContactMsgLabelColor && !error) { return recivedContactMsgLabelColor; }
    return [UIColor blackColor];
}

+ (void)migrateUserDefaultsToAppGroups {
    //Old NSUserDefaults
    NSUserDefaults *oldUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [oldUserDefaults dictionaryRepresentation];

    NSArray *keyArray = [dictionary allKeys];

    for (NSString *defaultKeyString in keyArray) {
        if ([defaultKeyString hasPrefix:KM_CORE_KEY_PREFIX] &&
            ![defaultKeyString isEqualToString:KM_CORE_APN_DEVICE_TOKEN] &&
            ![defaultKeyString isEqualToString:KM_CORE_VOIP_DEVICE_TOKEN]) {
            [oldUserDefaults removeObjectForKey:defaultKeyString];
            [oldUserDefaults synchronize];
        }
    }

    //Will use the deafault group for access and other places as well
    NSUserDefaults *groupUserDefaults = [KMCoreSettings getUserDefaults];
    if (groupUserDefaults != nil && ![KMCoreSettings isUserDefaultsMigrated]) {
        for (NSString *key in dictionary.allKeys) {
            [groupUserDefaults setObject:dictionary[key] forKey:key];
            [groupUserDefaults synchronize];
        }
        [KMCoreSettings setUserDefaultsMigratedFlag:YES];
    }
}

+ (void)setImagePreviewBackgroundColor:(UIColor *)color {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSError *error;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject: color requiringSecureCoding:YES error:&error];
    if (!error) {
        [userDefaults setObject:colorData  forKey:KM_CORE_IMAGE_PREVIEW_BACKGROUND_COLOR];
        [userDefaults synchronize];
    } else {
        NSLog(@"Error archiving image preview background color: %@", error);
    }
}

+ (UIColor *)getImagePreviewBackgroundColor {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSData *receivedColorData = [userDefaults objectForKey: KM_CORE_IMAGE_PREVIEW_BACKGROUND_COLOR];
    NSError *error;
    UIColor *color = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:receivedColorData error:&error];
    if (color && !error) { return  color; }
    return [UIColor whiteColor];
}

+ (void)restrictedMessageRegexPattern:(NSString *)pattern {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:pattern  forKey:KM_CORE_RESTRICTED_MESSAGE_PATTERN];
    [userDefaults synchronize];
}

+ (NSString *)getRestrictedMessageRegexPattern {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_RESTRICTED_MESSAGE_PATTERN];
}

+ (void)disableInAppNotificationTap:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_DISABLE_NOTIFICATION_TAP];
    [userDefaults synchronize];
}

+ (BOOL)isInAppNotificationTapDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_DISABLE_NOTIFICATION_TAP];
}

+ (void)disableGroupListingTab:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_GROUPS_LIST_TAB];
    [userDefaults synchronize];
}

+ (BOOL)isGroupListingTabDisabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_GROUPS_LIST_TAB];
}

+ (void)enableMessageSearch:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_MESSAGE_SEARCH];
    [userDefaults synchronize];
}

+ (BOOL)isMessageSearchEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_MESSAGE_SEARCH];
}

+ (void)enableMessageDeleteForAllOption:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_MESSAGE_DELETE_FOR_ALL_ENABLED];
    [userDefaults synchronize];
}

+ (BOOL)isMessageDeleteForAllEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_MESSAGE_DELETE_FOR_ALL_ENABLED];
}

+ (void)setPhotosSelectionLimit:(NSInteger)selectionLimit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    if (selectionLimit < 1 || selectionLimit > 20) {
        selectionLimit = 10;
    }
    [userDefaults setInteger:selectionLimit  forKey:KM_CORE_PHOTO_PICKER_SELECTION_LIMIT];
    [userDefaults synchronize];
}

+ (NSInteger)getPhotosSelectionLimit {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSInteger limit = [userDefaults integerForKey:KM_CORE_PHOTO_PICKER_SELECTION_LIMIT];
    return limit > 0 ? limit : 10;
}

+ (void)setMessageMetadata:(NSMutableDictionary *) messageMetadata {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setObject:messageMetadata  forKey:KM_CORE_MESSAGE_META_DATA_KEY];
    [userDefaults synchronize];
}

+ (NSMutableDictionary *)getMessageMetadata {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSDictionary *metadataDictionary = [userDefaults dictionaryForKey:KM_CORE_MESSAGE_META_DATA_KEY];
    NSMutableDictionary *messageMetadata = nil;
    if (metadataDictionary) {
        messageMetadata = [metadataDictionary mutableCopy];
    }
    return messageMetadata;
}

+ (void)setSupportContactUserId:(NSString *)userId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:userId  forKey:KM_CORE_SUPPORT_CONTACT_USER_ID];
    [userDefaults synchronize];
}

+ (NSString *)getSupportContactUserId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_SUPPORT_CONTACT_USER_ID];
}

+ (void) enableAgentApConfiguration:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag  forKey:KM_CORE_AGENTAPP_CONFIGURATION];
    [userDefaults synchronize];
}

+ (BOOL) isAgentAppConfigurationEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_CORE_AGENTAPP_CONFIGURATION];
}
// To store custom bot name which is fetched from chat context.Later in the convesation we will display this as bot's name if customized bot id matches the userid.
+ (void)setCustomBotName:(NSString *)customBotName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:customBotName  forKey:KM_CORE_CUSTOM_BOT_NAME];
    [userDefaults synchronize];
}

+ (NSString *)getCustomBotName {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CUSTOM_BOT_NAME];
}
// To store bot's id to customize its name in conversation screen.
+ (void)setCustomizedBotId:(NSString *)customizedBotId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:customizedBotId  forKey:KM_CORE_CUSTOM_BOT_ID];
    [userDefaults synchronize];
}

+ (NSString *)getCustomizedBotId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_CORE_CUSTOM_BOT_ID];
}

+ (void)clearCustomBotConfiguration {
    [self setCustomBotName:@""];
    [self setCustomizedBotId:@""];
}

+ (void) setZendeskSdkAccountKey:(NSString *)accountKey {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:accountKey forKey:KM_ZENDESK_ACCOUNT_KEY];
    [userDefaults synchronize];
}

+ (NSString *)getZendeskSdkAccountKey {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_ZENDESK_ACCOUNT_KEY];
}

+ (void)setLastZendeskConversationId:(NSNumber *)conversationId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:conversationId forKey:KM_ZENDESK_LAST_CONVERSATION_ID];
    [userDefaults synchronize];
}

+ (NSNumber *)getLastZendeskConversationId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_ZENDESK_LAST_CONVERSATION_ID];
}

+ (void)saveZendeskLastSyncTime:(NSNumber *)lastSyncTime {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:lastSyncTime forKey:KM_ZENDESK_LAST_SYNC_TIME];
    [userDefaults synchronize];
}

+ (NSNumber *)getZendeskLastSyncTime {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_ZENDESK_LAST_SYNC_TIME];
}

// To save language code for STT
+ (void)setSelectedLanguageForSpeechToText:(NSString *)language {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:language forKey:KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT];
    [userDefaults synchronize];
}

+ (NSString *)getSelectedLanguageForSpeechToText {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_SELECTED_LANGUAGE_FOR_SPEECH_TO_TEXT];
}

+ (void)setDefaultOverrideuploadUrl:(NSString *)url {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:url forKey:KM_DEFAULT_UPLOAD_URL];
    [userDefaults synchronize];
}

+ (NSString *)getDefaultOverrideuploadUrl {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    NSString *url = [userDefaults valueForKey:KM_DEFAULT_UPLOAD_URL];
    if (url) {
        return url;
    }
    return @"";
}

+ (void)setDefaultOverrideuploadHeaders:(NSMutableDictionary *)headers {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setValue:headers forKey:KM_DEFAULT_UPLOAD_HEADERS];
    [userDefaults synchronize];
}

+ (NSMutableDictionary *)getDefaultOverrideuploadHeaders {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults valueForKey:KM_DEFAULT_UPLOAD_HEADERS];
}

+ (void)setIsSingleThreadedEnabled:(BOOL)flag {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:flag forKey:KM_IS_SINGLE_THREADED];
    [userDefaults synchronize];
}

+ (BOOL)getIsSingleThreadedEnabled {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:KM_IS_SINGLE_THREADED];
}

+ (void)setIsChatTranscriptSent:(NSString*)groupId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    [userDefaults setBool:true forKey:groupId];
    [userDefaults synchronize];
}

+ (BOOL)isChatTranscriptSent:(NSString*)groupId {
    NSUserDefaults *userDefaults = [KMCoreSettings getUserDefaults];
    return [userDefaults boolForKey:groupId];
}

@end
