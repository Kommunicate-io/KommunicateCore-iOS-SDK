//
//  ALVideoCell.m
//  Applozic
//
//  Created by devashish on 23/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALVideoCell.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import <AVKit/AVKit.h>
#import "ALUIUtilityClass.h"

// Constants
static CGFloat const BUBBLE_PADDING_X = 13;
static CGFloat const BUBBLE_PADDING_WIDTH = 120;
static CGFloat const BUBBLE_PADDING_HEIGHT = 160;

static CGFloat const CHANNEL_PADDING_X = 5;
static CGFloat const CHANNEL_PADDING_Y = 2;
static CGFloat const CHANNEL_PADDING_HEIGHT = 20;

static CGFloat const IMAGE_VIEW_PADDING_X = 5;
static CGFloat const IMAGE_VIEW_PADDING_Y = 5;
static CGFloat const IMAGE_VIEW_WIDTH = 10;
static CGFloat const IMAGE_VIEW_HEIGHT = 10;

static CGFloat const DATE_PADDING_WIDTH = 20;
static CGFloat const DATE_HEIGHT = 20;
static CGFloat const DATE_WIDTH = 80;

static CGFloat const MSG_STATUS_WIDTH = 20;
static CGFloat const MSG_STATUS_HEIGHT = 20;

static CGFloat const DOWNLOAD_RETRY_X = 45;
static CGFloat const DOWNLOAD_RETRY_Y = 20;

static CGFloat const USER_PROFILE_PADDING_X = 5;
static CGFloat const USER_PROFILE_PADDING_X_OUTBOX = 50;
static CGFloat const USER_PROFILE_WIDTH = 45;
static CGFloat const USER_PROFILE_HEIGHT = 45;

@implementation ALVideoCell {
    CGFloat msgFrameHeight;
}
- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 50 , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        [self.mDowloadRetryButton addTarget:self action:@selector(downloadRetryAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoFullScreen:)];
        self.tapper.numberOfTapsRequired = 1;
        [self.contentView addSubview:self.mImageView];
        [self.mImageView setImage: [ALUIUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];

        self.videoPlayFrontView = [[UIImageView alloc] init];
        [self.videoPlayFrontView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
        [self.videoPlayFrontView setContentMode:UIViewContentModeScaleAspectFit];
        [self.videoPlayFrontView setImage: [ALUIUtilityClass getImageFromFramworkBundle:@"playImage.png"]];
        [self.contentView addSubview:self.videoPlayFrontView];
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.videoPlayFrontView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        [self.contentView addSubview:self.frontView];
    }
    
    return self;
}

- (void) addShadowEffects {
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
}

- (instancetype) populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize {
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString *theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    self.mDowloadRetryButton.alpha = 1;
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];
    
    self.progresLabel.alpha = 0;
    [self.mNameLabel setHidden:YES];
    self.mMessage = alMessage;
    
    [self.mMessageStatusImageView setHidden:YES];
    [self.mChannelMemberName setHidden:YES];
    [self.replyParentView setHidden:YES];
    
    
    [self.imageWithText setHidden:YES];
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width - 130 font:self.imageWithText.font.fontName fontSize:self.imageWithText.font.pointSize];
    
    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
    NSString *receiverName = [alContact getDisplayName];
    
    
    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];
    
    
    if ([alMessage isReceivedMessage]) {
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0,
                                                        USER_PROFILE_WIDTH, USER_PROFILE_HEIGHT)];
        
        if ([ALApplozicSettings isUserProfileHidden]) {
            [self.mUserProfileImageView setFrame:CGRectMake(USER_PROFILE_PADDING_X, 0, 0, USER_PROFILE_HEIGHT)];
        }
        
        self.mUserProfileImageView.layer.cornerRadius = self.mUserProfileImageView.frame.size.width/2;
        self.mUserProfileImageView.layer.masksToBounds = YES;
        
        
        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_HEIGHT;
        
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;
        
        //initial buble reference
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH,
                                                  requiredHeight)];
        if (alMessage.groupId) {
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setText:receiverName];
            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary]];
            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width , CHANNEL_PADDING_HEIGHT);
            
            requiredHeight = requiredHeight + self.mChannelMemberName.frame.size.height;
            imageViewY = imageViewY +  self.mChannelMemberName.frame.size.height;
            
        }
        
        if (alMessage.isAReplyMessage) {
            [self processReplyOfChat:alMessage andViewSize:viewSize];
            
            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;
            
        }
        
        //resize according to view
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                  self.mUserProfileImageView.frame.origin.y,
                                                  viewSize.width - BUBBLE_PADDING_WIDTH,
                                                  requiredHeight)];
        
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                             imageViewY,
                                             self.mBubleImageView.frame.size.width - IMAGE_VIEW_WIDTH,
                                             imageViewHeight)];        if (alMessage.message.length > 0)
                                                 
                                                 if (alMessage.message.length > 0) {
                                                     [self.imageWithText setHidden:NO];
                                                     self.imageWithText.textColor = [ALApplozicSettings getReceiveMsgTextColor];
                                                     self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                                                             0, viewSize.width - BUBBLE_PADDING_WIDTH,
                                                                                             (viewSize.width - BUBBLE_PADDING_HEIGHT) +
                                                                                             theTextSize.height + 20);
                                                     
                                                     self.imageWithText.frame = CGRectMake(self.mImageView.frame.origin.x,
                                                                                           self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10,
                                                                                           self.mImageView.frame.size.width, theTextSize.height);
                                                 }
        
        [self.mDateLabel setFrame:CGRectMake(self.mBubleImageView.frame.origin.x,
                                             self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                             DATE_WIDTH, DATE_HEIGHT)];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];
        
        if (alContact.contactImageUrl) {
            [ALUIUtilityClass downloadImageUrlAndSet:alContact.contactImageUrl imageView:self.mUserProfileImageView defaultImage:@"contact_default_placeholder"];
        } else {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary];
        }
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_X,
                                                      self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_Y,
                                                      90, 40)];
        
        [self setupProgressValueX: (self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2 - 30)
                             andY: (self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2 - 30)];
        
        if (alMessage.imageFilePath == nil) {
            [self.mDowloadRetryButton setHidden:NO];
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        } else {
            [self.mDowloadRetryButton setHidden:YES];
        }
        
        if (alMessage.inProgress == YES) {
            self.progresLabel.alpha = 1;
            [self.mDowloadRetryButton setHidden:YES];
        } else {
            self.progresLabel.alpha = 0;
        }

    } else {
        [self.mUserProfileImageView setFrame:CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX, 5, 0, USER_PROFILE_WIDTH)];
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_HEIGHT;
        
        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60),
                                                  0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        if (alMessage.isAReplyMessage) {
            [self processReplyOfChat:alMessage andViewSize:viewSize ];
            
            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;
            
        }
        
        [self.mBubleImageView setFrame:CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60),
                                                  0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight)];
        
        [self.contentView sendSubviewToBack:self.mBubleImageView];
        [self.mImageView setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                             imageViewY,
                                             self.mBubleImageView.frame.size.width - IMAGE_VIEW_WIDTH,
                                             imageViewHeight)];
        
        
        
        [self.mDowloadRetryButton setFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_X,
                                                      self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_Y,
                                                      90, 40)];
        
        [self setupProgressValueX: (self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2 - 30)
                             andY: (self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2 - 30)];
        
        if (alMessage.message.length > 0) {
            [self.imageWithText setHidden:NO];
            self.imageWithText.backgroundColor = [UIColor clearColor];
            self.imageWithText.textColor = [ALApplozicSettings getSendMsgTextColor];
            
            self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0,
                                                    viewSize.width - BUBBLE_PADDING_WIDTH,
                                                    (viewSize.width - BUBBLE_PADDING_HEIGHT) + theTextSize.height + 20);
            
            self.imageWithText.frame = CGRectMake(self.mBubleImageView.frame.origin.x + 5,
                                                  self.mBubleImageView.frame.origin.y + self.mImageView.frame.size.height + 10,
                                                  self.mImageView.frame.size.width, theTextSize.height);
            
        }
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x +
                                            self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_WIDTH,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        
        if (alMessage.inProgress == YES) {
            self.progresLabel.alpha = 1;
            ALSLog(ALLoggerSeverityInfo, @"calling you progress label....");
        } else if (!alMessage.imageFilePath && alMessage.fileMeta.blobKey) {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        } else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey) {
            
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
        msgFrameHeight = self.mBubleImageView.frame.size.height;
    }
    
    [self.contentView bringSubviewToFront:self.videoPlayFrontView];
    [self.videoPlayFrontView setFrame:self.mImageView.frame];
    [self.videoPlayFrontView setHidden:YES];

    if (alMessage.imageFilePath != nil) {
        if (alMessage.fileMeta.blobKey) {
            [self.frontView addGestureRecognizer:self.tapper];
            [self.videoPlayFrontView setHidden:NO];
        } else {
            [self.videoPlayFrontView setHidden:YES];
        }
    } else {
        [self.mImageView setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
        [self.videoPlayFrontView setHidden:YES];
        [self.frontView removeGestureRecognizer:self.tapper];
    }

    [self setupVideoThumbnailInView];
    [self.mImageView setBackgroundColor:[UIColor whiteColor]];
    
    [self addShadowEffects];
    self.frontView.frame = self.mBubleImageView.frame;
    self.imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;
    
    if ([alMessage isSentMessage] && ((self.channel && self.channel.type != OPEN) || !self.channel)) {
        self.mMessageStatusImageView.hidden = NO;
        NSString *imageName = [self getMessageStatusIconName:self.mMessage];
        self.mMessageStatusImageView.image = [ALUIUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    [self.contentView bringSubviewToFront:self.replyParentView];

    return self;
}

- (void)setupVideoThumbnailInView {
    NSString *imagePath = nil;
    if (self.mMessage.imageFilePath) {
        imagePath = [ALUtilityClass getPathFromDirectory:self.mMessage.imageFilePath];
        self.videoFileURL =  [NSURL fileURLWithPath:imagePath];
    }

    if (self.mMessage.fileMeta.thumbnailFilePath) {
        NSURL *documentDirectory = [ALUtilityClass getApplicationDirectoryWithFilePath:self.mMessage.fileMeta.thumbnailFilePath];
        [self.mImageView sd_setImageWithURL: [NSURL fileURLWithPath:documentDirectory.path] placeholderImage:[ALUIUtilityClass getImageFromFramworkBundle:@"VIDEO.png"] options:0];
    } else if (self.mMessage.fileMeta.thumbnailUrl && self.mMessage.fileMeta.thumbnailUrl.length > 0) {
        [self.mImageView setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"VIDEO.png"]];
        [self.delegate thumbnailDownloadWithMessageObject:self.mMessage];
    } else if (imagePath) {
        [self.mImageView setImage:[ALUIUtilityClass generateVideoThumbnailImage:imagePath]];
    }
}

- (void) downloadRetryAction {
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void) setupProgressValueX:(CGFloat)cooridinateX andY:(CGFloat)cooridinateY {
    self.progresLabel = [[KAProgressLabel alloc] init];
    self.progresLabel.cancelButton.frame = CGRectMake(10, 10, 40, 40);
    [self.progresLabel.cancelButton setBackgroundImage:[ALUIUtilityClass getImageFromFramworkBundle:@"DELETEIOSX.png"] forState:UIControlStateNormal];
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

- (void)videoFullScreen:(UITapGestureRecognizer *)sender {
    AVPlayerViewController *avPlayerViewController = [[AVPlayerViewController alloc] init];
    avPlayerViewController.player = [AVPlayer playerWithURL:self.videoFileURL];
    [self.delegate showVideoFullScreen:avPlayerViewController];
}

- (void) cancelAction {
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)]) {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)openUserChatVC {
    [self.delegate processUserChatView:self.mMessage];
}

- (void)processOpenChat {
    [self.delegate handleTapGestureForKeyBoard];
    [self.delegate openUserChat:self.mMessage];
}

@end
