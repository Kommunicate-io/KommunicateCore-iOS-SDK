//
//  ALMediaBaseCell.m
//  Applozic
//
//  Created by devashish on 19/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALMediaBaseCell.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"

static CGFloat const DATE_LABEL_SIZE = 12;

@implementation ALMediaBaseCell
{
    float heightLocation;
    UITapGestureRecognizer * tapForUserChatView;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.mUserProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        self.mUserProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mUserProfileImageView.clipsToBounds = YES;
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        [self.contentView addSubview:self.mUserProfileImageView];
        
        self.mNameLabel = [[UILabel alloc] init];
        [self.mNameLabel setTextColor:[UIColor whiteColor]];
        [self.mNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.mNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        self.mNameLabel.textAlignment = NSTextAlignmentCenter;
        self.mNameLabel.layer.cornerRadius = self.mNameLabel.frame.size.width/2;
        self.mNameLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:self.mNameLabel];
        
        self.mBubleImageView = [[UIImageView alloc] init];
        self.mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        self.mBubleImageView.layer.cornerRadius = 5;
        self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.mBubleImageView];
        
        self.replyParentView = [[UIView alloc] init];
        self.replyParentView.contentMode = UIViewContentModeScaleToFill;
        self.replyParentView.layer.cornerRadius = 5;
        self.replyParentView.backgroundColor = [UIColor greenColor];
        [self.replyParentView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer * replyViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureForReplyView:)];
        replyViewTapGesture.numberOfTapsRequired=1;
        [self.replyParentView addGestureRecognizer:replyViewTapGesture];
        
        [self.contentView addSubview:self.replyParentView];
        
        self.mImageView = [[UIImageView alloc] init];
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5 , self.mBubleImageView.frame.origin.y + 15 , self.mBubleImageView.frame.size.width - 10 , self.mBubleImageView.frame.size.height - 40 );self.
        
        self.mImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mImageView.clipsToBounds = YES;
        self.mImageView.backgroundColor = [UIColor grayColor];
        self.mImageView.userInteractionEnabled = YES;
        self.mImageView.layer.cornerRadius = 5;
        
        self.mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                                    self.mImageView.frame.origin.y + self.mImageView.frame.size.height + 5,
                                                                    100, 20)];
        
        self.mDateLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE];
        self.mDateLabel.textColor = [ALApplozicSettings getDateColor];
        self.mDateLabel.numberOfLines = 1;
        
        [self.contentView addSubview:self.mDateLabel];
        
        
        self.mMessageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20)];
        
        self.mMessageStatusImageView.contentMode = UIViewContentModeScaleToFill;
        self.mMessageStatusImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mMessageStatusImageView];
        
        self.mDowloadRetryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.mDowloadRetryButton setContentMode:UIViewContentModeCenter];
        [self.mDowloadRetryButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        self.mDowloadRetryButton.layer.cornerRadius = 4;
        [self.mDowloadRetryButton.titleLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.contentView addSubview:self.mDowloadRetryButton];

        self.imageWithText = [[UITextView alloc] init];
        [self.imageWithText setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:[ALApplozicSettings getChatCellTextFontSize]]];
        self.imageWithText.editable = NO;
        self.imageWithText.scrollEnabled = NO;
        self.imageWithText.textContainerInset = UIEdgeInsetsZero;
        self.imageWithText.textContainer.lineFragmentPadding = 0;
        self.imageWithText.dataDetectorTypes = UIDataDetectorTypeLink;
        [self.contentView addSubview:self.imageWithText];
        
        self.mChannelMemberName = [[UILabel alloc] init];
        self.mChannelMemberName.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        self.mChannelMemberName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mChannelMemberName];
        



        if (IS_IPHONE_5)
        {
            heightLocation = 180.0;
        }
        if(IS_IPHONE_6)
        {
            heightLocation = 220.0;
        }
        if (IS_IPHONE_6_PLUS)
        {
            heightLocation = 280.0;
        }
        
        [self.mUserProfileImageView setUserInteractionEnabled:YES];
        tapForUserChatView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserChatVC)];
        tapForUserChatView.numberOfTapsRequired = 1;
        [self.mUserProfileImageView addGestureRecognizer:tapForUserChatView];
        
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mNameLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.replyParentView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mDateLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mMessageStatusImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mDowloadRetryButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.imageWithText.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mChannelMemberName.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }

        self.frontView = [[ALTappableView alloc] init];
        self.frontView.backgroundColor = [UIColor clearColor];
        self.frontView.alpha = 1.0;

        UILongPressGestureRecognizer * menuTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
        menuTapGesture.minimumPressDuration = 1.0;
        menuTapGesture.cancelsTouchesInView = NO;
        [self.frontView addGestureRecognizer:menuTapGesture];

    }
    
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    self.mMessage = alMessage;
    return self;
}

-(void) dowloadRetryButtonAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void)setupProgress{

}

-(void)hidePlayButtonOnUploading
{
    
}

-(void)cancelAction{

}

-(void)openUserChatVC
{
    
}

-(void)processForwardMessage
{
    [self.delegate processForwardMessage:self.mMessage];
}


-(void)processMessageReply
{
    [self.delegate processMessageReply:self.mMessage];
    
}

-(void)processReplyOfChat:(ALMessage*)almessage andViewSize:(CGSize)viewSize
{
    
    if(!almessage.isAReplyMessage)
    {
        return;
    }
    
    NSString * messageReplyId = [almessage.metadata valueForKey:AL_MESSAGE_REPLY_KEY];
    ALMessage * replyMessage = [[ALMessageService new] getALMessageByKey:messageReplyId];
    
    if(replyMessage == nil){
        return;
    }
    
    self.replyParentView.hidden=NO;
    
    ALSLog(ALLoggerSeverityInfo, @"processReplyOfChat called");
    self.replyUIView = [[MessageReplyView alloc] init];
    
    [self.replyUIView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat replyWidthRequired = [self.replyUIView getWidthRequired:replyMessage andViewSize:viewSize];
    
    
    if( (self.mBubleImageView.frame.size.width) > replyWidthRequired )
    {
        replyWidthRequired = (self.mBubleImageView.frame.size.width);
        ALSLog(ALLoggerSeverityInfo, @"replyWidthRequired is less from parent one : %f", replyWidthRequired);
    }
    else
    {
        replyWidthRequired = replyWidthRequired;
        ALSLog(ALLoggerSeverityInfo, @"replyWidthRequired is grater from parent one : %f", replyWidthRequired);
        
    }
    
    CGFloat bubbleXposition = self.mBubleImageView.frame.origin.x +5;
    
    
    if(almessage.groupId && almessage.isReceivedMessage)
    {
        self.replyParentView.frame =
        CGRectMake( bubbleXposition ,
                   self.mChannelMemberName.frame.origin.y + self.mChannelMemberName.frame.size.height,
                   replyWidthRequired-10,
                   60);
        
    }else if(!almessage.groupId & !almessage.isSentMessage  ){
        self.replyParentView.frame =
        CGRectMake( bubbleXposition -1 ,
                   self.mBubleImageView.frame.origin.y+3 ,
                   replyWidthRequired-10,
                   60);
        
    }else{
        self.replyParentView.frame =
        CGRectMake( bubbleXposition,
                   self.mBubleImageView.frame.origin.y +3,
                   replyWidthRequired-10,
                   60);
        
    }
    
    
    NSArray *viewsToRemove = [self.replyParentView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self.replyParentView setBackgroundColor:[ALApplozicSettings getBackgroundColorForReplyView]];
    [self.replyUIView populateUI:almessage withSuperView:self.replyParentView];
    [self.replyParentView addSubview:self.replyUIView];
}

-(void)tapGestureForReplyView:(id)sender{
    
    [self.delegate scrollToReplyMessage:self.mMessage];
    
}

-(NSString *)getMessageStatusIconName:(ALMessage *)alMessage {

    switch (alMessage.status.intValue) {
        case DELIVERED_AND_READ :
            return @"ic_action_read.png";
            break;
        case READ :
            return @"ic_action_read.png";
            break;
        case DELIVERED:
            return @"ic_action_message_delivered.png";
            break;
        case SENT:
            return @"ic_action_message_sent.png";
            break;
        default:
            return @"ic_action_about.png";
            break;
    }
}


-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void) proccessTapForMenu:(UITapGestureRecognizer *)longPressGestureRecognizer {

    UIView * superView = [longPressGestureRecognizer.view superview];
    UIView * gestureView = longPressGestureRecognizer.view;

    if (!superView || !gestureView || !self.canBecomeFirstResponder) {
        return;
    }

    UIMenuController * sharedMenuController =  [UIMenuController sharedMenuController] ;

    if (![gestureView canBecomeFirstResponder] ||
        sharedMenuController.isMenuVisible) {
        return;
    }

    [gestureView becomeFirstResponder];
    [self processKeyBoardHideTap];

    UIMenuItem * messageForwardMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"forwardOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Forward", @"") action:@selector(messageForward:)];
    UIMenuItem * messageReplyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"replyOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Reply", @"") action:@selector(messageReply:)];

    if ([self.mMessage.type isEqualToString:AL_IN_BOX]) {

        [sharedMenuController setMenuItems: @[messageForwardMenuItem,
                                              messageReplyMenuItem]];

    } else if ([self.mMessage.type isEqualToString:AL_OUT_BOX]) {

        UIMenuItem * deleteForAllMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"deleteForAll", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Delete for all", @"") action:@selector(deleteMessageForAll:)];

        UIMenuItem * msgInfoMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"infoOptionTitle", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Info", @"") action:@selector(msgInfo:)];

        [sharedMenuController setMenuItems: @[msgInfoMenuItem,
                                              messageReplyMenuItem,
                                              messageForwardMenuItem,
                                              deleteForAllMenuItem]];
    }

    [sharedMenuController setTargetRect:gestureView.frame inView:superView];
    [sharedMenuController setMenuVisible:YES animated:YES];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    if (self.channel && self.channel.type == OPEN) {
        return NO;
    }

    if (![self.mMessage isMessageSentToServer]) {
        return action == @selector(delete:);
    }

    if ([self.mMessage isSentMessage] && self.mMessage.groupId) {
        return (self.mMessage.isDownloadRequired ?
                (action == @selector(delete:) ||
                 [self isMessageDeleteForAllMenuEnabled:action] ||
                 action == @selector(msgInfo:)):
                (action == @selector(delete:) ||
                 action == @selector(msgInfo:) ||
                 [self isMessageDeleteForAllMenuEnabled:action] ||
                 [self isForwardMenuEnabled:action] ||
                 [self isMessageReplyMenuEnabled:action]));
    }
    
    return (self.mMessage.isDownloadRequired ?
            (action == @selector(delete:)):
            (action == @selector(delete:)||
             [self isForwardMenuEnabled:action] ||
             [self isMessageReplyMenuEnabled:action]));
}

-(BOOL)isMessageReplyMenuEnabled:(SEL) action {
    return ([ALApplozicSettings isReplyOptionEnabled] &&
            action == @selector(messageReply:));
}

-(BOOL)isForwardMenuEnabled:(SEL) action {
    return ([ALApplozicSettings isForwardOptionEnabled] &&
            action == @selector(messageForward:));
}

-(BOOL)isMessageDeleteForAllMenuEnabled:(SEL) action {
    return ([ALApplozicSettings isMessageDeleteForAllEnabled] &&
            action == @selector(deleteMessageForAll:));
}

-(void) messageForward:(id)sender {
    ALSLog(ALLoggerSeverityInfo, @"Message forward option is pressed");
    [self processForwardMessage];
}

-(void) processKeyBoardHideTap {
    [self.delegate handleTapGestureForKeyBoard];
}

-(void) messageReply:(id)sender {
    ALSLog(ALLoggerSeverityInfo, @"Message reply option is pressed");
    [self processMessageReply];
}

-(void) delete:(id)sender {
    //UI
    ALSLog(ALLoggerSeverityInfo, @"message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];

    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {

        ALSLog(ALLoggerSeverityError, @"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

- (void)msgInfo:(id)sender {
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];

    __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;

    [msgInfoVC setMessage:self.mMessage andHeaderHeight:self.mBubleImageView.frame.size.height withCompletionHandler:^(NSError *error) {

        if(!error)
        {
            [self.delegate loadViewForMedia:weakObj];
        }
        else
        {
            [self.delegate showAnimationForMsgInfo:NO];
        }
    }];
}

-(void)deleteMessageForAll:(id)sender {
    [self.delegate deleteMessasgeforAll:self.mMessage];
}

@end
