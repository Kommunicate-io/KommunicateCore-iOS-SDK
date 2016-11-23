//
//  ALLocationCell.m
//  Applozic
//
//  Created by devashish on 01/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"
#define DATE_LABEL_SIZE 12

#import "ALLocationCell.h"
#import "Applozic.h"
#import "UIImageView+WebCache.h"
#import "ALMessageInfoViewController.h"

@implementation ALLocationCell
{
    CGFloat CELL_HEIGHT;
    CGFloat CELL_WIDTH;
    CGFloat ADJUST_HEIGHT;
    CGFloat ADJUST_WIDTH;
    CGFloat BUBBLE_ABSCISSA;
    CGFloat BUBBLE_ORIDANTE;
    CGFloat FLOAT_CONSTANT;
    CGFloat ADJUST_USER_PROFILE;
    CGFloat USER_PROFILE_CONSTANT;
    CGFloat ZERO;
    CGFloat USER_PROFILE_ABSCISSA;
    CGFloat msgFrameHeight;
    CGFloat DATE_HEIGHT;
    CGFloat MSG_STATUS_CONSTANT;
    
    NSURL * theUrl;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMaps:)];
        tapper.numberOfTapsRequired = 1;
        [self.mImageView addGestureRecognizer:tapper];
        [self.contentView addSubview:self.mImageView];
        
        FLOAT_CONSTANT = 5;
        ADJUST_HEIGHT = 10;
        ADJUST_WIDTH = 10;
        ADJUST_USER_PROFILE = 13;
        USER_PROFILE_CONSTANT = 45;
        ZERO = 0;
        DATE_HEIGHT = 21;
        MSG_STATUS_CONSTANT = 20;
    }
    
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];
    
    self.mUserProfileImageView.alpha = 1;
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    
    NSString * receiverName = [alContact getDisplayName];
    
    self.mMessage = alMessage;
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    
    CELL_WIDTH = viewSize.width - 120;
    CELL_HEIGHT = viewSize.width - 220;
    
    if([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        [self.contentView bringSubviewToFront:self.mChannelMemberName];
        
        USER_PROFILE_ABSCISSA = 8;
        
        self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, ZERO, USER_PROFILE_CONSTANT, USER_PROFILE_CONSTANT);
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, ZERO, ZERO, USER_PROFILE_CONSTANT);
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];

        BUBBLE_ABSCISSA = self.mUserProfileImageView.frame.size.width + ADJUST_USER_PROFILE;
        
        self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + FLOAT_CONSTANT,
                                           self.mBubleImageView.frame.origin.y + FLOAT_CONSTANT,
                                           self.mBubleImageView.frame.size.width - ADJUST_WIDTH,
                                           self.mBubleImageView.frame.size.height - ADJUST_HEIGHT);
        
        if(alMessage.groupId)
        {
            CELL_HEIGHT = viewSize.width - 190;
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName]];
            self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
            
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                       self.mBubleImageView.frame.origin.y + 2,
                                                       self.mBubleImageView.frame.size.width + 30, 20);
            
            self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + FLOAT_CONSTANT,
                                               self.mChannelMemberName.frame.origin.y + self.mChannelMemberName.frame.size.height + 3,
                                               self.mBubleImageView.frame.size.width - ADJUST_WIDTH,
                                               self.mBubleImageView.frame.size.height - ADJUST_HEIGHT - self.mChannelMemberName.frame.size.height);
        }
        
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y +
                                           self.mBubleImageView.frame.size.height,
                                           theDateSize.width,
                                           DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_CONSTANT, MSG_STATUS_CONSTANT);
        
        if(alContact.contactImageUrl)
        {
            NSURL * URL = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:URL];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName];
        }
        
    }
    else
    {
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        USER_PROFILE_ABSCISSA = viewSize.width - 50;
        self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_ABSCISSA, FLOAT_CONSTANT, ZERO, USER_PROFILE_CONSTANT);

        BUBBLE_ABSCISSA = viewSize.width - self.mUserProfileImageView.frame.origin.x + 60;
        self.mBubleImageView.frame = CGRectMake(BUBBLE_ABSCISSA, ZERO, CELL_WIDTH, CELL_HEIGHT);
        
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + FLOAT_CONSTANT,
                                           self.mBubleImageView.frame.origin.y + FLOAT_CONSTANT,
                                           self.mBubleImageView.frame.size.width - ADJUST_WIDTH,
                                           self.mBubleImageView.frame.size.height - ADJUST_HEIGHT);
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y, MSG_STATUS_CONSTANT, MSG_STATUS_CONSTANT);

    
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue)
        {
            case DELIVERED_AND_READ :
            {
                imageName = @"ic_action_read.png";
            }
            break;
            case DELIVERED:
            {
                imageName = @"ic_action_message_delivered.png";
            }
            break;
            case SENT:
            {
                imageName = @"ic_action_message_sent.png";
            }
            break;
            default:
            {
                imageName = @"ic_action_about.png";
            }
            break;
        }
        
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }

    self.mDateLabel.text = theDate;
    theUrl = nil;
    NSString *latLongArgument = [self formatLocationJson:alMessage];
    
    if([ALDataNetworkConnection checkDataNetworkAvailable])
    {
        NSString * finalURl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%@&key=%@",
                               latLongArgument,latLongArgument,[ALUserDefaultsHandler getGoogleMapAPIKey]];
        
        theUrl = [NSURL URLWithString:finalURl];
        [self.mImageView sd_setImageWithURL:theUrl];
    }
    else
    {
        [self.mImageView setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_map_no_data.png"]];
    }
    
    [self addShadowEffects];
    
    return self;
}

-(void) addShadowEffects
{
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(NSString*)formatLocationJson:(ALMessage *)locationAlMessage
{
    NSError *error;
    NSData *objectData = [locationAlMessage.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonStringDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
  
    NSArray* latLog = [[NSArray alloc] initWithObjects:[jsonStringDic valueForKey:@"lat"],[jsonStringDic valueForKey:@"lon"], nil];
    
    if(!latLog.count)
    {
        return [self processMapUrl:locationAlMessage];
    }
    
    NSString *latLongArgument = [NSString stringWithFormat:@"%@,%@", latLog[0], latLog[1]];
    return latLongArgument;
}

-(NSString *)processMapUrl:(ALMessage *)message
{
    NSArray * URL_ARRAY = [message.message componentsSeparatedByString:@"="];
    NSString * coordinate = (NSString *)[URL_ARRAY lastObject];
    return coordinate;
}

-(void)showMaps:(UITapGestureRecognizer *)sender
{
    NSString * URLString = [NSString stringWithFormat:@"https://maps.google.com/maps?q=loc:%@",[self formatLocationJson:super.mMessage]];
    NSURL * locationURL = [NSURL URLWithString:URLString];
    [[UIApplication sharedApplication] openURL:locationURL];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT] && self.mMessage.groupId)
    {
        return (action == @selector(delete:)|| action == @selector(msgInfo:));
    }
    
    return (action == @selector(delete:));
}

-(void) delete:(id)sender
{
    [self.delegate deleteMessageFromView:self.mMessage];
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {
        
        NSLog(@"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

- (void)msgInfo:(id)sender
{
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
    msgInfoVC.contentURL = theUrl;
     __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;
    [msgInfoVC setMessage:self.mMessage andHeaderHeight:msgFrameHeight withCompletionHandler:^(NSError *error) {
        
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

@end
