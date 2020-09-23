//
//  ALAudioCell.m
//  Applozic
//
//  Created by devashish on 20/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALAudioCell.h"
#import "UIImageView+WebCache.h"
#import "ALMediaPlayer.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALMessageClientService.h"

// Constants
static CGFloat const DATE_LABEL_SIZE = 12;
static CGFloat const DOWNLOAD_RETRY_WIDTH = 60;
static CGFloat const DOWNLOAD_RETRY_HEIGHT = 60;

static CGFloat const DATE_HEIGHT = 20;
static CGFloat const DATE_WIDTH = 80;
static CGFloat const DATE_PADDING_X = 20;

static CGFloat const MSG_STATUS_WIDTH = 20;
static CGFloat const MSG_STATUS_HEIGHT = 20;
static CGFloat const BUBBLE_PADDING_X = 13;
static CGFloat const BUBBLE_PADDING_WIDTH = 50;
static CGFloat const BUBBLE_PADDING_HEIGHT = 70;

static CGFloat const CHANNEL_PADDING_X = 5;
static CGFloat const CHANNEL_PADDING_Y = 2;
static CGFloat const CHANNEL_PADDING_WIDTH = 5;
static CGFloat const CHANNEL_HEIGHT = 20;

static CGFloat const BUTTON_PADDING_X = 5;
static CGFloat const BUTTON_PADDING_Y = 5;
static CGFloat const BUTTON_PADDING_WIDTH = 60;
static CGFloat const BUTTON_PADDING_HEIGHT = 60;

static CGFloat const PROGRESS_HEIGHT = 30;
static CGFloat const MEDIATRACKLENGTH_HEIGHT = 20;
static CGFloat const MEDIATRACKLENGTH_WIDTH = 80;
static CGFloat const AL_MEDIA_TRACK_PROGRESS_PADDING_Y = 30;

static CGFloat const USER_PROFILE_PADDING_X = 5;
static CGFloat const USER_PROFILE_PADDING_X_OUTBOX = 50;
static CGFloat const USER_PROFILE_WIDTH = 45;
static CGFloat const USER_PROFILE_HEIGHT = 45;

@interface ALAudioCell()

@end

@implementation ALAudioCell
{
    CGFloat msgFrameHeight;
    CGFloat ORDINATE_CONSTANT;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        
          [self.contentView sizeToFit];
        
        
        self.playPauseStop = [[UIButton alloc] init];
        [self.playPauseStop addTarget:self action:@selector(mediaButtonAction) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:self.playPauseStop];
        
        self.mediaTrackProgress = [[UIProgressView alloc] init];
        [self.contentView addSubview:self.mediaTrackProgress];
        
        self.mediaTrackLength = [[UILabel alloc] init];
        [self.mediaTrackLength setTextColor:[UIColor blackColor]];
        [self.mediaTrackLength setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:DATE_LABEL_SIZE]];
        [self.contentView addSubview:self.mediaTrackLength];
        
        [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
        
        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryAction) forControlEvents:UIControlEventTouchUpInside];
        
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.playPauseStop.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mediaTrackProgress.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mediaTrackLength.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.playPauseStop.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            
        }
        [self.contentView addSubview:self.frontView];
        [self.contentView bringSubviewToFront:self.playPauseStop];
    }
    
    return self;
}

-(void) addShadowEffects
{
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

-(instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    self.mediaTrackLength.text = [self getAudioLength:alMessage.imageFilePath];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];

    self.mMessage = alMessage;
    self.progresLabel.alpha = 0;
    
    [self.playPauseStop setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.replyParentView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    self.mBubleImageView.backgroundColor = [UIColor whiteColor];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    [self.mMessageStatusImageView setHidden:YES];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = [alContact getDisplayName];
    [self.replyUIView removeFromSuperview];
    
    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];
    
    if([alMessage isReceivedMessage])
    {
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT)];
        
        if([ALApplozicSettings isUserProfileHidden])
        {
            [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT)];
        }
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
         
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:alMessage.to]];
        
        if(alContact.contactImageUrl)
        {
            ALMessageClientService * messageClientService = [[ALMessageClientService alloc]init];
            [messageClientService downloadImageUrlAndSet:alContact.contactImageUrl imageView:self.mUserProfileImageView defaultImage:@"ic_contact_picture_holo_light.png"];
        }
        else
        {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:alMessage.to colorCodes:self.alphabetiColorCodesDictionary];
        }
         CGFloat requiredHeight  = BUBBLE_PADDING_HEIGHT;
        CGFloat paypauseBUttonY = self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y ;
            
  [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width/2 + BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        
        if(alMessage.groupId)
        {
         
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary]];
            [self.mChannelMemberName setText:receiverName];
   
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width - CHANNEL_PADDING_WIDTH, CHANNEL_HEIGHT);
            
            requiredHeight =  requiredHeight + self.mChannelMemberName.frame.size.height;
            paypauseBUttonY = paypauseBUttonY + self.mChannelMemberName.frame.size.height;
            
        }    
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            requiredHeight =  requiredHeight + self.replyParentView.frame.size.height;
            paypauseBUttonY = paypauseBUttonY + self.replyParentView.frame.size.height;
            
        }
                    
            [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width/2 + BUBBLE_PADDING_WIDTH, requiredHeight)];
             [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                paypauseBUttonY,
                                                BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.playPauseStop.frame.origin.x ,
                                                      self.playPauseStop.frame.origin.y,
                                                      DOWNLOAD_RETRY_WIDTH, DOWNLOAD_RETRY_HEIGHT)];
        
        [self setupProgressValueX: (self.playPauseStop.frame.origin.x) andY: (self.playPauseStop.frame.origin.y)];
        
        CGFloat progressBarWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 30;
        
        CGFloat progressX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        [self.mediaTrackProgress setFrame:CGRectMake(progressX, self.playPauseStop.frame.origin.y+AL_MEDIA_TRACK_PROGRESS_PADDING_Y,
                                                     progressBarWidth, PROGRESS_HEIGHT)];
        
        [self.mediaTrackLength setFrame:CGRectMake(self.mediaTrackProgress.frame.origin.x,
                                                   self.mediaTrackProgress.frame.origin.y + self.mediaTrackProgress.frame.size.height,
                                                   MEDIATRACKLENGTH_WIDTH, MEDIATRACKLENGTH_HEIGHT)];
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.size.height + self.mBubleImageView.frame.origin.y,
                                             DATE_WIDTH, DATE_HEIGHT)];
        
        if (alMessage.imageFilePath == nil)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"DownloadiOS.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.mDowloadRetryButton setHidden:YES];
        }
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            [self.mDowloadRetryButton setHidden:YES];
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
    
    
    }else
    {

        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 0, 0, USER_PROFILE_HEIGHT)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        
        [self.mBubleImageView setFrame:CGRectMake(viewSize.width - (viewSize.width/2 + 50) - 10,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width/2 + BUBBLE_PADDING_WIDTH, BUBBLE_PADDING_HEIGHT)];
  
        if(alMessage.isAReplyMessage)
        {
            [self processReplyOfChat:alMessage andViewSize:viewSize ];
            
            [self.mBubleImageView setFrame:CGRectMake(viewSize.width - (viewSize.width/2 + 50) - 10,
                                                      self.mUserProfileImageView.frame.origin.y,
                                                      viewSize.width/2 + BUBBLE_PADDING_WIDTH, BUBBLE_PADDING_HEIGHT+ self.replyParentView.frame.size.height)];
            [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                    self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y + self.replyParentView.frame.size.height,
                                                    BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
            
        }
        else
        {
            
            [self.playPauseStop setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + BUTTON_PADDING_X,
                                                    self.mBubleImageView.frame.origin.y + BUTTON_PADDING_Y,
                                                    BUTTON_PADDING_WIDTH, BUTTON_PADDING_HEIGHT)];
            
        }
                [self.mDowloadRetryButton setFrame:CGRectMake(self.playPauseStop.frame.origin.x ,
                                                     self.playPauseStop.frame.origin.y,
                                                      DOWNLOAD_RETRY_WIDTH, DOWNLOAD_RETRY_WIDTH)];
        
        [self setupProgressValueX: (self.playPauseStop.frame.origin.x) andY: (self.playPauseStop.frame.origin.y)];
        
        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        CGFloat progressBarWidth = self.mBubleImageView.frame.size.width - self.playPauseStop.frame.size.width - 30;
        
        CGFloat progressX = self.playPauseStop.frame.origin.x + self.playPauseStop.frame.size.width + 10;
        
        [self.mediaTrackProgress setFrame:CGRectMake(progressX,
                                                     self.playPauseStop.frame.origin.y+AL_MEDIA_TRACK_PROGRESS_PADDING_Y
                                                     ,progressBarWidth, PROGRESS_HEIGHT)];
        
        [self.mediaTrackLength setFrame:CGRectMake(self.mediaTrackProgress.frame.origin.x,
                                                   self.mediaTrackProgress.frame.origin.y + self.mediaTrackProgress.frame.size.height,
                                                   MEDIATRACKLENGTH_WIDTH, MEDIATRACKLENGTH_HEIGHT)];
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) -
                                           theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
            ALSLog(ALLoggerSeverityInfo, @"calling you progress label....");
        }
        
        else if(!alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"DownloadiOS.png"] forState:UIControlStateNormal];
        }
        
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"UploadiOS2.png"] forState:UIControlStateNormal];
        }
        
    }

    self.frontView.frame = self.mBubleImageView.frame;
    if(alMessage.imageFilePath != nil && alMessage.fileMeta.blobKey)
    {
        NSURL * soundFileURL;
        NSURL *documentDirectory =  [ALUtilityClass getApplicationDirectoryWithFilePath:alMessage.imageFilePath];
        NSString *filePath = documentDirectory.path;

        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            soundFileURL = [NSURL fileURLWithPath:documentDirectory.path];
        }else{
            NSURL *appGroupDirectory =  [ALUtilityClass getAppsGroupDirectoryWithFilePath:alMessage.imageFilePath];

            if(appGroupDirectory){
                soundFileURL = [NSURL fileURLWithPath:appGroupDirectory.path];
            }
        }

        ALSLog(ALLoggerSeverityInfo, @"SOUND_URL :: %@",[soundFileURL path]);
        [self.playPauseStop setHidden:NO];
    }
    
    self.playPauseStop.layer.cornerRadius = self.playPauseStop.frame.size.width/2;
    self.playPauseStop.layer.masksToBounds = YES;
    
    self.mDowloadRetryButton.layer.cornerRadius = self.mDowloadRetryButton.frame.size.width/2;
    self.mDowloadRetryButton.layer.masksToBounds = YES;
    
    [self addShadowEffects];
    
    self.mDateLabel.text = theDate;
    
    if ([alMessage isSentMessage] && ((self.channel && self.channel.type != OPEN) || !self.channel)) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName = [self getMessageStatusIconName:self.mMessage];
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    [self.contentView bringSubviewToFront:self.replyUIView];
    
    return self;
    
}

-(void) cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) dowloadRetryAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void) dealloc
{
    if(self.mMessage.fileMeta)
    {
        //  [self.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

-(void) setupProgressValueX:(CGFloat)cooridinateX andY:(CGFloat)cooridinateY
{
    self.progresLabel = [[KAProgressLabel alloc] init];
    self.progresLabel.cancelButton.frame = CGRectMake(10, 10, 40, 40);
    [self.progresLabel.cancelButton setBackgroundImage:[ALUtilityClass getImageFromFramworkBundle:@"DELETEIOSX.png"] forState:UIControlStateNormal];
    [self.progresLabel setFrame:CGRectMake(cooridinateX, cooridinateY, 60, 60)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview: self.progresLabel];
}


-(void) mediaButtonAction
{
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];
    
    if( [mediaPlayer isPlayingCurrentKey:self.mMessage.key ] )
    {
        if(!mediaPlayer.audioPlayer.isPlaying)
        {
            [mediaPlayer resumeAudio];
            [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PAUSE.png"] forState: UIControlStateNormal];
        }
        else
        {
            [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
            [mediaPlayer pauseAudio];
        }
    }else{

        if(mediaPlayer.audioPlayer.isPlaying) {
            [mediaPlayer stopPlaying];
        }
        mediaPlayer.delegate = self;
        mediaPlayer.key = self.mMessage.key;
        [mediaPlayer playAudio:self.mMessage.imageFilePath];
        [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PAUSE.png"] forState: UIControlStateNormal];

    }
}

-(NSString*) getAudioLength:(NSString*)path
{

    NSString * duration = [ALMediaPlayer getTotalDuration:path];

    NSString *audioLength = [NSString stringWithFormat:@"0:00 / %@", duration];

    return audioLength;
}

-(void) getProgressOfTrack
{
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];

    NSInteger durationMinutes = [mediaPlayer.audioPlayer duration] / 60;
    NSInteger durationSeconds = [mediaPlayer.audioPlayer duration] - durationMinutes * 60;
    
    NSInteger currentTimeMinutes = [mediaPlayer.audioPlayer currentTime] / 60;
    NSInteger currentTimeSeconds = [mediaPlayer.audioPlayer currentTime] - currentTimeMinutes * 60;
    
    NSString *progressString = [NSString stringWithFormat:@"%ld:%02ld / %ld:%02ld", (long)currentTimeMinutes, (long)currentTimeSeconds, (long)durationMinutes, (long)durationSeconds];
    
    [self.mediaTrackProgress setProgress: [mediaPlayer.audioPlayer currentTime] / [mediaPlayer.audioPlayer duration]];
    [self.mediaTrackLength setText: progressString];
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.playPauseStop setImage:[ALUtilityClass getImageFromFramworkBundle:@"PLAY.png"] forState: UIControlStateNormal];
    self.mediaTrackLength.text = [self getAudioLength:self.mMessage.imageFilePath];
    [self.mediaTrackProgress setProgress: 0.0];
    ALMediaPlayer * mediaPlayer =  [ALMediaPlayer sharedInstance];
    [mediaPlayer.audioPlayer stop];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
     ALSLog(ALLoggerSeverityInfo, @"##observer is called....%f",self.progresLabel.endDegree);
}

-(void) hidePlayButtonOnUploading
{
    [self.playPauseStop setHidden:YES];
}

-(void)openUserChatVC
{
    [self.delegate processUserChatView:self.mMessage];
}

-(void)processOpenChat
{
    [self.delegate handleTapGestureForKeyBoard];
    [self.delegate openUserChat:self.mMessage];
}

@end
