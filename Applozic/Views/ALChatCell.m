//
//  ALChatCell.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#define MESSAGE_TEXT_SIZE 14
#define DATE_LABEL_SIZE 12

#import "ALChatCell.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"
#import "UIImageView+WebCache.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALMessageService.h"
#import "ALMessageDBService.h"
#import "UIImage+Utility.h"
#import "ALColorUtility.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALUIConstant.h"

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

#define USER_PROFILE_PADDING_X 5
#define USER_PROFILE_WIDTH 45
#define USER_PROFILE_HEIGHT 45

#define BUBBLE_PADDING_X 13
#define BUBBLE_PADDING_WIDTH 20
#define BUBBLE_PADDING_X_OUTBOX 27
#define BUBBLE_PADDING_HEIGHT 20
#define BUBBLE_PADDING_HEIGHT_GRP 35

#define MESSAGE_PADDING_X 10
#define MESSAGE_PADDING_Y 10
#define MESSAGE_PADDING_Y_GRP 5
#define MESSAGE_PADDING_WIDTH 20
#define MESSAGE_PADDING_HEIGHT 20

#define CHANNEL_PADDING_X 10
#define CHANNEL_PADDING_Y 2
#define CHANNEL_PADDING_WIDTH 30
#define CHANNEL_PADDING_HEIGHT 20

#define DATE_PADDING_X 20
#define DATE_PADDING_WIDTH 20
#define DATE_HEIGHT 20

#define MSG_STATUS_WIDTH 20
#define MSG_STATUS_HEIGHT 20

@implementation ALChatCell
{
    CGFloat msgFrameHeight;
    UITapGestureRecognizer * tapForCustomView;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.mUserProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        self.mUserProfileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mUserProfileImageView.layer.cornerRadius=self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.mUserProfileImageView];
        
        self.mBubleImageView = [[UIImageView alloc] init];
        self.mBubleImageView.contentMode = UIViewContentModeScaleToFill;
        self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        self.mBubleImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.mBubleImageView];
        
        self.mNameLabel = [[UILabel alloc] init];
        [self.mNameLabel setTextColor:[UIColor whiteColor]];
        [self.mNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.mNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        self.mNameLabel.textAlignment = NSTextAlignmentCenter;
        self.mNameLabel.layer.cornerRadius = self.mNameLabel.frame.size.width/2;
        self.mNameLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:self.mNameLabel];
        
        self.mMessageLabel = [[ALHyperLabel alloc] init];
        self.mMessageLabel.numberOfLines = 0;

        NSString *fontName = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_CHAT_FONTNAME];
        
        if (!fontName) {
            fontName = DEFAULT_FONT_NAME;
        }
        
        self.mMessageLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_TEXT_SIZE];
        self.mMessageLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.mMessageLabel];
        
        self.mChannelMemberName = [[UILabel alloc] init];
        self.mChannelMemberName.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        self.mChannelMemberName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mChannelMemberName];
        
        self.mDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 25)];
        self.mDateLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE];
        self.mDateLabel.textColor = [ALApplozicSettings getDateColor];
        self.mDateLabel.numberOfLines = 1;
        [self.contentView addSubview:self.mDateLabel];
        
        self.mMessageStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mDateLabel.frame.origin.x+
                                                                                     self.mDateLabel.frame.size.width,
                                                                                     self.mDateLabel.frame.origin.y, 20, 20)];
        self.mMessageStatusImageView.contentMode = UIViewContentModeScaleToFill;
        self.mMessageStatusImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mMessageStatusImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.userInteractionEnabled = YES;
        
        tapForCustomView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processTapGesture)];
        tapForCustomView.numberOfTapsRequired = 1;
        
        self.hyperLinkArray = [NSMutableArray new];
    }
    
    
    return self;
    
}


-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    
    [self.hyperLinkArray removeAllObjects];
    self.mUserProfileImageView.alpha = 1;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    self.mMessage = alMessage;
    [self processHyperLink];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    
    NSString * receiverName = [alContact getDisplayName];
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width-115
                                                   font:self.mMessageLabel.font.fontName
                                               fontSize:self.mMessageLabel.font.pointSize];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150
                                                   font:self.mDateLabel.font.fontName
                                               fontSize:self.mDateLabel.font.pointSize];
    
    CGSize receiverNameSize = [ALUtilityClass getSizeForText:receiverName
                                                    maxWidth:viewSize.width - 115
                                                        font:self.mChannelMemberName.font.fontName
                                                    fontSize:self.mChannelMemberName.font.pointSize];
    
    [self.mBubleImageView setHidden:NO];
    [self.mDateLabel setHidden:NO];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentLeft];
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    self.mMessageStatusImageView.hidden = YES;
    [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
    self.mUserProfileImageView.backgroundColor = [UIColor whiteColor];
    self.mMessageLabel.backgroundColor = [UIColor clearColor];
    
    if([alMessage.type isEqualToString:@"100"])
    {
        [self dateTextSetupForALMessage:alMessage withViewSize:viewSize andTheTextSize:theTextSize];
    }
    else if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X,
                                                          0, USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT);
        }
        
        if([ALApplozicSettings getReceiveMsgColor])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + 13,
                                                0, theTextSize.width + BUBBLE_PADDING_WIDTH,
                                                theTextSize.height + BUBBLE_PADDING_HEIGHT);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + MESSAGE_PADDING_X ,
                                              self.mBubleImageView.frame.origin.y + MESSAGE_PADDING_Y,
                                              theTextSize.width, theTextSize.height);
        
        if([alMessage getGroupId])
        {
            [self.mChannelMemberName setHidden:NO];
            
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            
            if(theTextSize.width < receiverNameSize.width)
            {
                theTextSize.width = receiverNameSize.width;
            }
            
            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X, 0,
                                                    theTextSize.width + BUBBLE_PADDING_WIDTH,
                                                    theTextSize.height + BUBBLE_PADDING_HEIGHT_GRP);
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width + CHANNEL_PADDING_WIDTH, CHANNEL_PADDING_HEIGHT);
            
            self.mMessageLabel.frame = CGRectMake(self.mChannelMemberName.frame.origin.x,
                                                  self.mChannelMemberName.frame.origin.y + self.mChannelMemberName.frame.size.height + MESSAGE_PADDING_Y_GRP,
                                                  theTextSize.width, theTextSize.height);
            
            [self.mChannelMemberName setText:receiverName];
        }
        
        self.mMessageLabel.textColor = [ALApplozicSettings getReceiveMsgTextColor];
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width + DATE_PADDING_WIDTH, DATE_HEIGHT);
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
    }
    else    //Sent Message
    {
        if([ALApplozicSettings getSendMsgColor])
        {
            self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        }
        else
        {
            self.mBubleImageView.backgroundColor = [UIColor whiteColor];
        }
        self.mUserProfileImageView.alpha = 0;
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - 53, 0, 0, 45);
        
        self.mMessageStatusImageView.hidden = NO;
        
        
        self.mBubleImageView.frame = CGRectMake((viewSize.width - theTextSize.width - BUBBLE_PADDING_X_OUTBOX) , 0,
                                                theTextSize.width + BUBBLE_PADDING_WIDTH,
                                                theTextSize.height + BUBBLE_PADDING_HEIGHT);
        
        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.mMessageLabel.textColor = [ALApplozicSettings getSendMsgTextColor];
        
        self.mMessageLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x + MESSAGE_PADDING_X,
                                              MESSAGE_PADDING_Y, theTextSize.width, theTextSize.height);
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width)
                                           - theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);
        
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);
        
        UIMenuItem * testMenuItem = [[UIMenuItem alloc] initWithTitle:@"Info" action:@selector(msgInfo:)];
        [[UIMenuController sharedMenuController] setMenuItems: @[testMenuItem]];
        [[UIMenuController sharedMenuController] update];
        
    }
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && (alMessage.contentType != ALMESSAGE_CHANNEL_NOTIFICATION)) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue) {
            case DELIVERED_AND_READ :{
                imageName = @"ic_action_read.png";
            }break;
            case DELIVERED:{
                imageName = @"ic_action_message_delivered.png";
            }break;
            case SENT:{
                imageName = @"ic_action_message_sent.png";
            }break;
            default:{
                imageName = @"ic_action_about.png";
            }break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    self.mDateLabel.text = theDate;
    
    /*    =========================== FOR PUSH VC ON TAP =============================  */
    
    //   CHECKING IF MESSAGE META-DATA DICTIONARY HAVE SOME DATA
    
    if(self.mMessage.metadata.count)
    {
        [self.mBubleImageView setUserInteractionEnabled:YES];
        [self.mBubleImageView addGestureRecognizer:tapForCustomView];
    }
    
    /*    ====================================== END =================================  */
    
    self.mMessageLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_TEXT_SIZE];
    if(alMessage.contentType == ALMESSAGE_CONTENT_TEXT_HTML)
    {
        
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithData:[self.mMessage.message dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                 options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        self.mMessageLabel.attributedText = attributedString;
    }
    else
    {
        NSDictionary *attrs = @{
                                NSFontAttributeName : self.mMessageLabel.font,
                                NSForegroundColorAttributeName : self.mMessageLabel.textColor
                                };
        
        self.mMessageLabel.linkAttributeDefault = @{
                                                    NSFontAttributeName : self.mMessageLabel.font,
                                                    NSForegroundColorAttributeName :[UIColor blueColor],
                                                    NSUnderlineStyleAttributeName : [NSNumber numberWithInt:NSUnderlineStyleThick]
                                                    };
    
        if (self.mMessage.message){
            self.mMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:self.mMessage.message attributes:attrs];
        }
        [self setHyperLinkAttribute];
    }
    
    return self;
    
}

-(void)dateTextSetupForALMessage:(ALMessage *)alMessage withViewSize:(CGSize)viewSize andTheTextSize:(CGSize)theTextSize
{
    [self.mDateLabel setHidden:YES];
    [self.mBubleImageView setHidden:YES];
    CGFloat dateY = 0;
    [self.mMessageLabel setFrame:CGRectMake(0, dateY, viewSize.width, theTextSize.height+10)];
    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setText:alMessage.message];
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setTextColor:[ALApplozicSettings getMsgDateColor]];
    self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT);
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (action == @selector(copy:) || action == @selector(delete:) || action == @selector(msgInfo:));
    }
    return (action == @selector(copy:) || action == @selector(delete:));
}

// Default copy method
- (void)copy:(id)sender
{
    NSLog(@"Copy in ALChatCell, messageId: %@", self.mMessage.message);
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    if(self.mMessage.message != NULL)
    {
        //    [pasteBoard setString:cell.textLabel.text];
        [pasteBoard setString:self.mMessage.message];
    }
    else
    {
        [pasteBoard setString:@""];
    }
    
}

-(void) delete:(id)sender
{
    NSLog(@"Delete in ALChatCell pressed");
    
    //UI
    NSLog(@"message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {
        
        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

-(void)msgInfo:(id)sender
{
    [self.delegate showAnimation:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
    __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;
    
    [msgInfoVC setMessage:self.mMessage andHeaderHeight:msgFrameHeight withCompletionHandler:^(NSError *error) {
        
        if(!error)
        {
            [self.delegate loadView:weakObj];
        }
        else
        {
            [self.delegate showAnimation:NO];
        }
    }];
}

-(void)processTapGesture
{
    [self.delegate processALMessage:self.mMessage];
}

-(void)processHyperLink
{
    if(self.mMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION || !self.mMessage.message.length) // AVOID HYPERLINK FOR GROUP OPERATION MESSAGE OBJECT
    {
        return;
    }
    
    NSString * source = self.mMessage.message;
    NSDataDetector * detector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink)
                                                                error:nil];
    
    NSArray * matches = [detector matchesInString:source options:0 range:NSMakeRange(0, [source length])];
    
    for(NSTextCheckingResult * link in matches)
    {
        if(link.URL)
        {
            NSString * actualLinkString = [source substringWithRange:link.range];
            [self.hyperLinkArray addObject:actualLinkString];
        }
        else if (link.phoneNumber)
        {
            [self.hyperLinkArray addObject:link.phoneNumber.description];
        }
    }
}

-(void)setHyperLinkAttribute
{
    if(self.mMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION || !self.mMessage.message.length)
    {
        return;
    }
    
    void(^handler)(ALHyperLabel *label, NSString *substring) = ^(ALHyperLabel *label, NSString *substring){
        
        if(substring.integerValue)
        {
            NSNumber * contact = [NSNumber numberWithInteger:substring.integerValue];
            NSURL * phoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",contact]];
            [[UIApplication sharedApplication] openURL:phoneNumber];
        }
        else
        {
            if([substring hasPrefix:@"http"])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:substring]];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",substring]]];
            }
        }
    };
    
    NSArray * nsArrayLink = [NSArray arrayWithArray:[self.hyperLinkArray mutableCopy]];
    [self.mMessageLabel setLinksForSubstrings:nsArrayLink withLinkHandler: handler];
}



@end
