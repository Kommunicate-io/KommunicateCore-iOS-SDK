//
//  ALNotificationView.m
//  ChatApp
//
//  Created by Devashish on 06/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALNotificationView.h"

@implementation ALNotificationView


/*********************
 GROUP_NAME
 CONTACT_NAME: MESSAGE
 *********************
 
 *********************
 CONTACT_NAME
 MESSAGE
 *********************/


-(instancetype)initWithAlMessage:(ALMessage*)alMessage  withAlertMessage: (NSString *) alertMessage
{
    self = [super init];
    self.text =[self getNotificationText:alMessage];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 0;
    self.userInteractionEnabled = YES;
    self.contactId = alMessage.contactIds;
    self.groupId = alMessage.groupId;
    self.conversationId = alMessage.conversationId;
    self.alMessageObject = alMessage;
    return self;
}

-(NSString*)getNotificationText:(ALMessage *)alMessage
{
    
    if(alMessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        return NSLocalizedStringWithDefaultValue(@"shareadLocationText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Shared a Location", @"") ;
    }
    else if(alMessage.contentType == ALMESSAGE_CONTENT_VCARD)
    {
        return NSLocalizedStringWithDefaultValue(@"shareadContactText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Shared a Contact", @"");
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_CAMERA_RECORDING)
    {
        return NSLocalizedStringWithDefaultValue(@"shareadVideoText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Shared a Video", @"");
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_AUDIO)
    {
        return NSLocalizedStringWithDefaultValue(@"shareadAudioText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Shared an Audio", @"");
    }
    else if (alMessage.contentType == AV_CALL_MESSAGE)
    {
        return [alMessage getVOIPMessageText];
        
    }else if (alMessage.contentType == ALMESSAGE_CONTENT_ATTACHMENT ||
             [alMessage.message isEqualToString:@""] || alMessage.fileMeta != NULL)
    {
        return NSLocalizedStringWithDefaultValue(@"shareadAttachmentText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Shared an Attachment", @"");
    }
    else{
        return alMessage.message;
    }

}

- (void)customizeMessageView:(TSMessageView *)messageView
{
    messageView.alpha = 0.4;
    messageView.backgroundColor=[UIColor blackColor];
}


#pragma mark- Our SDK views notification
//=======================================

-(void)showNativeNotificationWithcompletionHandler:(void (^)(BOOL))handler
{
    if(self.groupId)
    {
        [[ ALChannelService new] getChannelInformation:self.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel3) {
            [ self buildAndShowNotificationWithcompletionHandler:^(BOOL response){
                handler(response);
            }];
        }];
    } else {
        [ self buildAndShowNotificationWithcompletionHandler:^(BOOL response){
            handler(response);
        }];
    }
}

-(void)buildAndShowNotificationWithcompletionHandler:(void (^)(BOOL))handler
{

    if([self.alMessageObject isNotificationDisabled])
    {
        return;
    }
    
    NSString * title; // Title of Notification Banner (Display Name or Group Name)
    NSString * subtitle = self.text; //Message to be shown

    ALPushAssist * top = [[ALPushAssist alloc] init];

    ALContactDBService * contactDbService = [[ALContactDBService alloc] init];
    ALContact * alcontact = [contactDbService loadContactByKey:@"userId" value:self.contactId];

    ALChannel * alchannel = [[ALChannel alloc] init];
    ALChannelDBService * channelDbService = [[ALChannelDBService alloc] init];

    if(self.groupId && self.groupId.intValue != 0)
    {
        NSString * contactName;
        NSString * groupName;

        alchannel = [channelDbService loadChannelByKey:self.groupId];
        alcontact.userId = (alcontact.userId != nil ? alcontact.userId:@"");

        groupName = [NSString stringWithFormat:@"%@",(alchannel.name != nil ? alchannel.name : self.groupId)];

        if (alchannel.type == GROUP_OF_TWO)
        {
            ALContact * grpContact = [contactDbService loadContactByKey:@"userId" value:[alchannel getReceiverIdInGroupOfTwo]];
            groupName = [grpContact getDisplayName];
        }

        NSArray *notificationComponents = [alcontact.getDisplayName componentsSeparatedByString:@":"];
        if(notificationComponents.count > 1)
        {
            contactName = [[contactDbService loadContactByKey:@"userId" value:[notificationComponents lastObject]] getDisplayName];
        }
        else
        {
            contactName = alcontact.getDisplayName;
        }

        if(self.alMessageObject.contentType == ALMESSAGE_CHANNEL_NOTIFICATION)
        {
            title = self.text;
            subtitle = @"";
        }
        else
        {
            title    = groupName;
            subtitle = [NSString stringWithFormat:@"%@:%@",contactName,subtitle];
        }
    }
    else
    {
        title = alcontact.getDisplayName;
        subtitle = self.text;
    }

    // ** Attachment ** //
    if(self.alMessageObject.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        subtitle = [NSString stringWithFormat:@"Shared location"];
    }

    subtitle = (subtitle.length > 20) ? [NSString stringWithFormat:@"%@...",[subtitle substringToIndex:17]] : subtitle;

    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];

    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];


    [TSMessage showNotificationInViewController:top.topViewController
                                          title:title
                                       subtitle:subtitle
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:
     ^(void){
         handler(true);
     }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}

-(void)showGroupLeftMessage
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"youHaveLeftGroupMesasge", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"You have left this group", @"") type:TSMessageNotificationTypeWarning];
}

-(void)noDataConnectionNotificationView
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"noInternetMessage", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No Internet Connectivity", @"")
                                    type:TSMessageNotificationTypeWarning];
}

+(void)showLocalNotification:(NSString *)text
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle:text type:TSMessageNotificationTypeWarning];
}

+(void)showPromotionalNotifications:(NSString *)text
{
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
    
    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setDuration:10.0];
    [[TSMessageView appearance] setMessageIcon:appIcon];
    
    [TSMessage showNotificationWithTitle:[ALApplozicSettings getNotificationTitle] subtitle:text
                                    type:TSMessageNotificationTypeMessage];

}

+(void)showNotification:(NSString *)message
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeWarning];
}


@end
