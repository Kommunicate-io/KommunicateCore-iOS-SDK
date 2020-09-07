//
//  ALContactCell.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALContactCell.h"
#import "ALContactService.h"
#import "ALMessageClientService.h"
#import "ALColorUtility.h"
#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"

static const CGFloat USER_NAME_LABEL_SIZE = 18;
static const CGFloat MESSAGE_LABEL_SIZE = 14;
static const CGFloat TIME_LABEL_SIZE = 12;
static const CGFloat IMAGE_NAME_LABEL_SIZE = 14;

@implementation ALContactCell

- (void)awakeFromNib {
    [[self mUserNameLabel] setTextAlignment:NSTextAlignmentNatural];
    [[self mMessageLabel] setTextAlignment:NSTextAlignmentNatural];
    [[self imageNameLabel] setTextAlignment:NSTextAlignmentNatural];
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)updateWithMessage:(ALMessage*) message
    withColourDictionary:(NSMutableDictionary *)colourDictionary {

    [self.mUserNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:USER_NAME_LABEL_SIZE]];
    [self.mMessageLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_LABEL_SIZE]];
    [self.mTimeLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:TIME_LABEL_SIZE]];
    [self.imageNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:IMAGE_NAME_LABEL_SIZE]];

    self.unreadCountLabel.backgroundColor = [ALApplozicSettings getUnreadCountLabelBGColor];
    self.unreadCountLabel.layer.cornerRadius = self.unreadCountLabel.frame.size.width/2;
    self.unreadCountLabel.layer.masksToBounds = YES;

    self.mUserImageView.layer.cornerRadius = self.mUserImageView.frame.size.width/2;
    self.mUserImageView.layer.masksToBounds = YES;

    [self.onlineImageMarker setBackgroundColor:[UIColor clearColor]];

    self.mUserNameLabel.textColor = [ALApplozicSettings getMessageListTextColor];
    self.mTimeLabel.textColor = [ALApplozicSettings getMessageSubtextColour];
    self.mMessageLabel.textColor = [ALApplozicSettings getMessageSubtextColour];

    if ([message.groupId intValue]) {
        ALChannelService *channelService = [[ALChannelService alloc] init];
        [channelService getChannelInformation:message.groupId
                           orClientChannelKey:nil
                               withCompletion:^(ALChannel *alChannel) {
            [self updateProfileImageAndUnreadCountWithChannel:alChannel orContact:nil withColourDictionary:colourDictionary];
        }];
    } else {
        ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [contactDBService loadContactByKey:@"userId" value: message.to];
        [self updateProfileImageAndUnreadCountWithChannel:nil
                                                orContact:alContact
                                     withColourDictionary:colourDictionary];
    }

    self.mMessageLabel.text = message.message;
    self.mMessageLabel.hidden = NO;
    BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    self.mTimeLabel.text = [message getCreatedAtTime:isToday];
    [self displayAttachmentMediaType:message];
}

-(void)updateProfileImageAndUnreadCountWithChannel:(ALChannel*) alChannel
                                         orContact:(ALContact*)contact
                              withColourDictionary:(NSMutableDictionary *)colourDictionary {

    UILabel* nameIcon = (UILabel*)[self viewWithTag:102];
    nameIcon.textColor = [UIColor whiteColor];

    ALContactService * contactService = [ALContactService new];
    self.mUserImageView.backgroundColor = [UIColor clearColor];
    if (alChannel) {

        if (alChannel.type == GROUP_OF_TWO) {
            NSString * receiverId =  [alChannel getReceiverIdInGroupOfTwo];
            ALContact* grpContact = [contactService loadContactByKey:@"userId" value:receiverId];
            self.mUserNameLabel.text = [grpContact getDisplayName];
            self.onlineImageMarker.hidden = (!grpContact.connected);
            if (grpContact.contactImageUrl.length) {
                ALMessageClientService * messageClientService = [[ALMessageClientService alloc]init];
                [messageClientService downloadImageUrlAndSet:grpContact.contactImageUrl imageView:self.mUserImageView defaultImage:nil];
                self.imageNameLabel.hidden = YES;
                nameIcon.hidden = YES;
            } else {
                nameIcon.hidden = NO;
                [self.mUserImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
                self.mUserImageView.backgroundColor = [ALColorUtility getColorForAlphabet:[grpContact getDisplayName] colorCodes: colourDictionary];
                [nameIcon setText:[ALColorUtility getAlphabetForProfileImage:[grpContact getDisplayName]]];
            }
        } else {

            NSString *placeHolderImage ;
            if (alChannel.type == BROADCAST) {
                placeHolderImage = @"broadcast_group.png";
                [self.mUserImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"broadcast_group.png"]];
            } else {
                placeHolderImage = @"applozic_group_icon.png";
                [self.mUserImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"applozic_group_icon.png"]];
            }

            ALMessageClientService * messageClientService = [[ALMessageClientService alloc]init];
            [messageClientService downloadImageUrlAndSet:alChannel.channelImageURL imageView:self.mUserImageView defaultImage:placeHolderImage];

            nameIcon.hidden = YES;
            self.mUserNameLabel.text = [alChannel name];
            self.onlineImageMarker.hidden = YES;
        }
    } else {
        self.mUserNameLabel.text = [contact getDisplayName];
        self.onlineImageMarker.hidden = (!contact.connected);
        if (contact.contactImageUrl.length) {
            ALMessageClientService * messageClientService = [[ALMessageClientService alloc]init];
            [messageClientService downloadImageUrlAndSet:contact.contactImageUrl imageView:self.mUserImageView defaultImage:@"ic_contact_picture_holo_light.png"];
            self.imageNameLabel.hidden = YES;
            nameIcon.hidden= YES;
        } else {
            nameIcon.hidden = NO;
            [self.mUserImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            self.mUserImageView.backgroundColor = [ALColorUtility getColorForAlphabet:[contact getDisplayName] colorCodes:colourDictionary];
            [nameIcon setText:[ALColorUtility getAlphabetForProfileImage:[contact getDisplayName]]];
        }
    }
    int count = (alChannel) ? alChannel.unreadCount.intValue :contact.unreadCount.intValue;
    if (count == 0) {
        self.unreadCountLabel.text = @"";
        [self.unreadCountLabel setHidden:YES];
    } else {
        [self.unreadCountLabel setHidden:NO];
        self.unreadCountLabel.text=[NSString stringWithFormat:@"%i",count];

    }
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
    BOOL isUserDeleted = [contactDBService isUserDeleted:contact.userId];

    if (contact &&
        (contact.block ||
         contact.blockBy ||
         isUserDeleted ||
         ![ALApplozicSettings getVisibilityForOnlineIndicator])) {
        [self.onlineImageMarker setHidden:YES];
    }
}

-(void)displayAttachmentMediaType:(ALMessage *)message {

    if ([message isDeletedForAll]) {
        UIColor *subtextColour = [ALApplozicSettings getMessageSubtextColour];
        self.mMessageLabel.hidden = YES;
        self.imageMarker.hidden = NO;
        self.imageNameLabel.hidden = NO;
        self.imageNameLabel.text = NSLocalizedStringWithDefaultValue(@"deletedMessageText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"This message has been deleted", @"");

        UIImage *deletedIcon = [ALUtilityClass getImageFromFramworkBundle:@"round_not_interested_white.png"];
        deletedIcon = [deletedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageMarker.tintColor = subtextColour;
        self.imageMarker.image = deletedIcon;
        self.imageNameLabel.textColor = subtextColour;
    } else if (message.fileMeta ||
        message.contentType == ALMESSAGE_CONTENT_LOCATION) {
        self.mMessageLabel.hidden = YES;
        self.imageMarker.hidden = NO;
        self.imageNameLabel.hidden = NO;

        if ([message.fileMeta.contentType hasPrefix:@"image"]) {
            self.imageNameLabel.text = NSLocalizedStringWithDefaultValue(@"image", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Image", @"");

            self.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_camera.png"];
        } else if ([message.fileMeta.contentType hasPrefix:@"video"]) {
            self.imageNameLabel.text = NSLocalizedStringWithDefaultValue(@"video", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Video", @"");
            self.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_video.png"];
        } else if (message.contentType == ALMESSAGE_CONTENT_LOCATION) {
            self.mMessageLabel.hidden = YES;
            self.imageNameLabel.text = NSLocalizedStringWithDefaultValue(@"location", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Location", @"");
            self.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"location_filled.png"];
        } else if (message.fileMeta.contentType) {
            self.imageNameLabel.text =  NSLocalizedStringWithDefaultValue(@"attachment", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Attachment", @"");
            self.imageMarker.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_action_attachment.png"];
        } else {
            self.imageNameLabel.hidden = YES;
            self.imageMarker.hidden = YES;
            self.mMessageLabel.hidden = NO;
        }
        UIColor *subTextColour = [ALApplozicSettings getMessageSubtextColour];
        self.imageNameLabel.textColor = subTextColour;
        self.mMessageLabel.textColor = subTextColour;
        self.imageMarker.tintColor = subTextColour;
    } else if (message.contentType == 103) {
        self.mMessageLabel.hidden = YES;
        self.imageNameLabel.hidden = NO;
        self.imageMarker.hidden = NO;
        self.imageNameLabel.text = [message getVOIPMessageText];
        self.imageMarker.image = [ALUtilityClass getVOIPMessageImage:message];
    } else {
        self.imageNameLabel.hidden = YES;
        self.imageMarker.hidden = YES;
        self.mMessageLabel.hidden = NO;
    }
}

@end
