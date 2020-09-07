//
//  ALContactMessageBaseCell.m
//  Applozic
//
//  Created by apple on 26/06/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import "ALContactMessageBaseCell.h"
#import "ALUtilityClass.h"
#import "UIImageView+WebCache.h"
#import "ALApplozicSettings.h"
#import "ALConstant.h"
#import "ALContact.h"
#import "ALColorUtility.h"
#import "ALContactDBService.h"
#import "ALMessageService.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALVCardClass.h"
#import "ALMessageClientService.h"


@implementation ALContactMessageBaseCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.contactProfileImage = [[UIImageView alloc] init];
        [self.contactProfileImage setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.contactProfileImage];

        self.userContact = [[UILabel alloc] init];
        [self.userContact setBackgroundColor:[UIColor clearColor]];
        [self.userContact setTextColor:[UIColor blackColor]];
        [self.userContact setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.userContact setNumberOfLines:2];
        [self.contentView addSubview:self.userContact];

        self.emailId = [[UILabel alloc] init];
        [self.emailId setBackgroundColor:[UIColor clearColor]];
        [self.emailId setTextColor:[UIColor blackColor]];
        [self.emailId setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.emailId setNumberOfLines:2];
        [self.contentView addSubview:self.emailId];

        self.contactPerson = [[UILabel alloc] init];
        [self.contactPerson setBackgroundColor:[UIColor clearColor]];
        [self.contactPerson setTextColor:[UIColor blackColor]];
        [self.contactPerson setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.contentView addSubview:self.contactPerson];

        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.userContact.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.emailId.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.contactPerson.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        [self.contentView addSubview:self.frontView];
    }
    return self;
}


-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;
    self.mDowloadRetryButton.alpha = 0;

    self.mMessage = alMessage;

    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    [self.replyParentView setHidden:YES];

    [self.userContact setText:@"PHONE NO"];
    [self.emailId setText:@"EMAIL ID"];
    [self.contactPerson setText:@"CONTACT NAME"];
    [self.replyUIView removeFromSuperview];

    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];


    if((!alMessage.imageFilePath && alMessage.fileMeta.blobKey) || (alMessage.imageFilePath && !alMessage.fileMeta.blobKey))
    {
        [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
    }

    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;

    return self;

}

//==================================================================================================
#pragma mark - KAProgressLabel Delegate Methods
//==================================================================================================

-(void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)dowloadRetryActionButton
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
}

-(void)openUserChatVC
{
    [self.delegate processUserChatView:self.mMessage];
}

- (void)msgInfo:(id)sender
{
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];

    msgInfoVC.VCardClass = self.vCardClass;

    __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;

    [msgInfoVC setMessage:self.mMessage andHeaderHeight:self.msgFrameHeight withCompletionHandler:^(NSError *error) {

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

-(void)processOpenChat
{
    [self.delegate handleTapGestureForKeyBoard];
    [self.delegate openUserChat:self.mMessage];
}

@end
