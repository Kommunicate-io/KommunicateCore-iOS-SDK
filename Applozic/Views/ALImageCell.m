//
//  ALImageCell.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//


#import "ALImageCell.h"
#import "UIImageView+WebCache.h"
#import "ALColorUtility.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "UIImage+MultiFormat.h"
#import "ALUIUtilityClass.h"
#import "ALUIImage+animatedGIF.h"

// Constants
static CGFloat const DOWNLOAD_RETRY_PADDING_X = 45;
static CGFloat const DOWNLOAD_RETRY_PADDING_Y = 20;

static CGFloat const MAX_WIDTH = 150;
static CGFloat const MAX_WIDTH_DATE = 130;

static CGFloat const IMAGE_VIEW_PADDING_X = 5;
static CGFloat const IMAGE_VIEW_PADDING_Y = 5;
static CGFloat const IMAGE_VIEW_PADDING_WIDTH = 10;
static CGFloat const IMAGE_VIEW_PADDING_HEIGHT = 10;

static CGFloat const DATE_HEIGHT = 20;
static CGFloat const DATE_PADDING_X = 20;

static CGFloat const MSG_STATUS_WIDTH = 20;
static CGFloat const MSG_STATUS_HEIGHT = 20;
static CGFloat const IMAGE_VIEW_WITHTEXT_PADDING_Y = 10;
static CGFloat const BUBBLE_PADDING_X = 13;
static CGFloat const BUBBLE_PADDING_Y = 120;
static CGFloat const BUBBLE_PADDING_WIDTH = 120;
static CGFloat const BUBBLE_PADDING_HEIGHT = 120;
static CGFloat const BUBBLE_PADDING_X_OUTBOX = 60;
static CGFloat const BUBBLE_PADDING_HEIGHT_TEXT = 20;

static CGFloat const CHANNEL_PADDING_X = 5;
static CGFloat const CHANNEL_PADDING_Y = 5;
static CGFloat const CHANNEL_PADDING_HEIGHT = 20;

static CGFloat const USER_PROFILE_PADDING_X_OUTBOX = 50;
static CGFloat const USER_PROFILE_HEIGHT = 45;
static CGFloat const USER_PROFILE_PADDING_X = 5;

@implementation ALImageCell {
    CGFloat msgFrameHeight;
    NSURL *theUrl;
}

UIViewController *modalCon;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {

        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x
                                                    + self.mBubleImageView.frame.size.width/2.0 - 50,
                                                    self.mBubleImageView.frame.origin.y +
                                                    self.mBubleImageView.frame.size.height/2.0 - 50 ,
                                                    100, 40);

        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
        tapper.numberOfTapsRequired = 1;
        [self.frontView addGestureRecognizer:tapper];
        [self.contentView addSubview:self.mImageView];

        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            self.mImageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }

        [self.contentView addSubview:self.frontView];
    }

    return self;
}

- (instancetype)populateCell:(ALMessage *)alMessage viewSize:(CGSize)viewSize {
    [super populateCell:alMessage viewSize:viewSize];

    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;
    [self.replyParentView setHidden:YES];

    [self.mDowloadRetryButton setHidden:NO];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString *theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];

    ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];

    NSString *receiverName = [alContact getDisplayName];

    self.mMessage = alMessage;

    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:MAX_WIDTH
                                                   font:self.mDateLabel.font.fontName
                                               fontSize:self.mDateLabel.font.pointSize];

    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:viewSize.width - MAX_WIDTH_DATE
                                                   font:self.imageWithText.font.fontName
                                               fontSize:self.imageWithText.font.pointSize];



    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.imageWithText setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];

    UITapGestureRecognizer *tapForOpenChat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processOpenChat)];
    tapForOpenChat.numberOfTapsRequired = 1;
    [self.mUserProfileImageView setUserInteractionEnabled:YES];
    [self.mUserProfileImageView addGestureRecognizer:tapForOpenChat];

    if ([alMessage isReceivedMessage]) { //@"4" //Recieved Message

        [self.contentView bringSubviewToFront:self.mChannelMemberName];

        if ([ALApplozicSettings isUserProfileHidden]) {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0, 0,
                                                          45);
        } else {
            self.mUserProfileImageView.frame = CGRectMake(USER_PROFILE_PADDING_X, 0,
                                                          45,45);
        }

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];

        self.mNameLabel.frame = self.mUserProfileImageView.frame;

        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:receiverName]];

        //Shift for message reply and channel name..

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_PADDING_HEIGHT;

        CGFloat imageViewY = self.mBubleImageView.frame.origin.y + IMAGE_VIEW_PADDING_Y;

        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);

        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;


        if (alMessage.getGroupId) {
            [self.mChannelMemberName setHidden:NO];
            [self.mChannelMemberName setText:receiverName];

            [self.mChannelMemberName setTextColor: [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary]];


            self.mChannelMemberName.frame = CGRectMake(self.mBubleImageView.frame.origin.x + CHANNEL_PADDING_X,
                                                       self.mBubleImageView.frame.origin.y + CHANNEL_PADDING_Y,
                                                       self.mBubleImageView.frame.size.width, CHANNEL_PADDING_HEIGHT);

            requiredHeight = requiredHeight + self.mChannelMemberName.frame.size.height;
            imageViewY = imageViewY +  self.mChannelMemberName.frame.size.height;
        }


        if (alMessage.isAReplyMessage) {
            [self processReplyOfChat:alMessage andViewSize:viewSize];

            requiredHeight = requiredHeight + self.replyParentView.frame.size.height;
            imageViewY = imageViewY +  self.replyParentView.frame.size.height;

        }
        self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, requiredHeight);
        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                           imageViewY,
                                           self.mBubleImageView.frame.size.width - IMAGE_VIEW_PADDING_WIDTH ,
                                           imageViewHeight);


        [self setupProgress];

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        if (alMessage.message.length > 0) {
            self.imageWithText.textColor = [ALApplozicSettings getReceiveMsgTextColor];

            self.mBubleImageView.frame = CGRectMake(self.mUserProfileImageView.frame.size.width + BUBBLE_PADDING_X,
                                                    0, viewSize.width - BUBBLE_PADDING_Y,
                                                    (viewSize.width - BUBBLE_PADDING_HEIGHT)
                                                    + theTextSize.height + BUBBLE_PADDING_HEIGHT_TEXT);

            self.imageWithText.frame = CGRectMake(self.mImageView.frame.origin.x,
                                                  self.mImageView.frame.origin.y + self.mImageView.frame.size.height + 5,
                                                  self.mImageView.frame.size.width, theTextSize.height);

            [self.imageWithText setHidden:NO];

            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];
        } else {
            self.mDowloadRetryButton.alpha = 1;
            [self.imageWithText setHidden:YES];
        }

        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x,
                                           self.mBubleImageView.frame.origin.y +
                                           self.mBubleImageView.frame.size.height,
                                           theDateSize.width,
                                           DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

        if (alMessage.imageFilePath == NULL) {
            ALSLog(ALLoggerSeverityInfo, @" file path not found making download button visible ....ALImageCell");
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];

        } else {
            self.mDowloadRetryButton.alpha = 0;
        }
        if (alMessage.inProgress == YES) {
            ALSLog(ALLoggerSeverityInfo, @" In progress making download button invisible ....");
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
        } else {
            self.progresLabel.alpha = 0;
        }

        if (alContact.contactImageUrl) {
            [ALUIUtilityClass downloadImageUrlAndSet:alContact.contactImageUrl imageView:self.mUserProfileImageView defaultImage:@"contact_default_placeholder"];
        } else {
            [self.mUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:receiverName colorCodes:self.alphabetiColorCodesDictionary];
        }
    } else { //Sent Message

        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];

        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - USER_PROFILE_PADDING_X_OUTBOX,
                                                      0, 0, USER_PROFILE_HEIGHT);

        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                0, viewSize.width - BUBBLE_PADDING_WIDTH, viewSize.width - BUBBLE_PADDING_HEIGHT);

        self.mBubleImageView.layer.shadowOpacity = 0.3;
        self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
        self.mBubleImageView.layer.shadowRadius = 1;
        self.mBubleImageView.layer.masksToBounds = NO;

        CGFloat requiredHeight = viewSize.width - BUBBLE_PADDING_HEIGHT;
        CGFloat imageViewHeight = requiredHeight -IMAGE_VIEW_PADDING_HEIGHT;

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



        self.mImageView.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                           imageViewY,
                                           self.mBubleImageView.frame.size.width - IMAGE_VIEW_PADDING_WIDTH,
                                           imageViewHeight);

        if (alMessage.message.length > 0) {
            [self.imageWithText setHidden:NO];
            self.imageWithText.backgroundColor = [UIColor clearColor];
            self.imageWithText.textColor = [ALApplozicSettings getSendMsgTextColor];
            self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + BUBBLE_PADDING_X_OUTBOX),
                                                    0, viewSize.width - BUBBLE_PADDING_WIDTH,
                                                    viewSize.width - BUBBLE_PADDING_HEIGHT
                                                    + theTextSize.height + BUBBLE_PADDING_HEIGHT_TEXT);

            self.imageWithText.frame = CGRectMake(self.mBubleImageView.frame.origin.x + IMAGE_VIEW_PADDING_X,
                                                  self.mImageView.frame.origin.y + self.mImageView.frame.size.height + IMAGE_VIEW_WITHTEXT_PADDING_Y,
                                                  self.mImageView.frame.size.width, theTextSize.height);

            [self.contentView bringSubviewToFront:self.mDateLabel];
            [self.contentView bringSubviewToFront:self.mMessageStatusImageView];

        } else {
            [self.imageWithText setHidden:YES];
        }

        msgFrameHeight = self.mBubleImageView.frame.size.height;

        self.mDateLabel.textAlignment = NSTextAlignmentLeft;

        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x +
                                            self.mBubleImageView.frame.size.width) - theDateSize.width - DATE_PADDING_X,
                                           self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height,
                                           theDateSize.width, DATE_HEIGHT);

        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width,
                                                        self.mDateLabel.frame.origin.y,
                                                        MSG_STATUS_WIDTH, MSG_STATUS_HEIGHT);

        [self setupProgress];

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

    }

    self.frontView.frame = self.mBubleImageView.frame;

    self.mDowloadRetryButton.frame = CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - DOWNLOAD_RETRY_PADDING_X,
                                                self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - DOWNLOAD_RETRY_PADDING_Y,
                                                90, 40);

    if ([alMessage isSentMessage] && ((self.channel && self.channel.type != OPEN) || !self.channel)) {

        self.mMessageStatusImageView.hidden = NO;
        NSString *imageName = [self getMessageStatusIconName:self.mMessage];
        self.mMessageStatusImageView.image = [ALUIUtilityClass getImageFromFramworkBundle:imageName];
    }

    self.imageWithText.text = alMessage.message;
    self.mDateLabel.text = theDate;

    theUrl = nil;

    if (alMessage.imageFilePath != NULL) {

        NSURL *documentDirectory =  [ALUtilityClass getApplicationDirectoryWithFilePath:alMessage.imageFilePath];
        NSString *filePath = documentDirectory.path;

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {

            theUrl = [NSURL fileURLWithPath:filePath];
            [self setInImageView:theUrl];
        } else {
            NSURL *appGroupDirectory =  [ALUtilityClass getAppsGroupDirectoryWithFilePath:alMessage.imageFilePath];
            if (appGroupDirectory) {
                theUrl = [NSURL fileURLWithPath:appGroupDirectory.path];
                [self setInImageView:theUrl];
            }
        }
    } else {
        if (alMessage.fileMeta.thumbnailFilePath == nil) {
            [self.delegate thumbnailDownloadWithMessageObject:alMessage];
        } else {

            NSURL *documentDirectory =  [ALUtilityClass getApplicationDirectoryWithFilePath:alMessage.fileMeta.thumbnailFilePath];
            NSString *filePath = documentDirectory.path;

            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [self setInImageView:[NSURL fileURLWithPath:filePath]];
            } else {

                NSURL *appGroupDirectory =  [ALUtilityClass getAppsGroupDirectoryWithFilePath:alMessage.fileMeta.thumbnailFilePath];

                if (appGroupDirectory) {
                    [self setInImageView:[NSURL fileURLWithPath:appGroupDirectory.path]];
                }
            }
        }

    }

    return self;

}

- (void) setInImageView:(NSURL*)url {
    NSString *stringUrl = url.absoluteString;
    if (stringUrl != nil && [stringUrl localizedCaseInsensitiveContainsString:@"gif"]) {
        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:url];
        [self.mImageView setImage: image];
        return;
    }
    [self.mImageView sd_setImageWithURL:url placeholderImage:nil options:0];
}

#pragma mark - KAProgressLabel Delegate Methods -

- (void)cancelAction {
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)]) {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) dowloadRetryButtonAction {
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void)dealloc {
    if (super.mMessage.fileMeta) {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }
}

- (void)setMMessage:(ALMessage *)mMessage {
    //TODO: error ...observer shoud be there...
    if (super.mMessage.fileMeta) {
        [super.mMessage.fileMeta removeObserver:self forKeyPath:@"progressValue" context:nil];
    }

    super.mMessage = mMessage;
    [super.mMessage.fileMeta addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
}

- (void)imageFullScreen:(UITapGestureRecognizer*)sender {
    if (self.mImageView.image && self.mMessage.imageFilePath) {
        [self.delegate showImagePreviewWithFilePath:self.mMessage.imageFilePath];
    } else {
        ALSLog(ALLoggerSeverityWarn, @"Image is not downloaded");
    }
}

- (void)setupProgress {
    self.progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(self.mImageView.frame.origin.x + self.mImageView.frame.size.width/2.0 - 25, self.mImageView.frame.origin.y + self.mImageView.frame.size.height/2.0 - 25, 50, 50)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview:self.progresLabel];

}

- (void)dismissModalView:(UITapGestureRecognizer*)gesture {
    [modalCon dismissViewControllerAnimated:YES completion:nil];
}


- (void)copy:(id)sender {

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{

        UIPasteboard *appPasteBoard = UIPasteboard.generalPasteboard;
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [docDir stringByAppendingPathComponent:self.mMessage.imageFilePath];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        BOOL isFileExist = [fileManager fileExistsAtPath: filePath];
        if (isFileExist) {
            UIImage  *image = [[UIImage alloc] initWithContentsOfFile:filePath];
            appPasteBoard.image = [image copy];
        }

    });

}


- (void)openUserChatVC {
    [self.delegate processUserChatView:self.mMessage];
}

- (void)processOpenChat {
    [self.delegate handleTapGestureForKeyBoard];
    [self.delegate openUserChat:self.mMessage];
}

- (void)msgInfo:(id)sender {
    [self.delegate showAnimationForMsgInfo:YES];
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *msgInfoVC = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];

    msgInfoVC.contentURL = theUrl;

    __weak typeof(ALMessageInfoViewController *) weakObj = msgInfoVC;
    [msgInfoVC setMessage:self.mMessage andHeaderHeight:msgFrameHeight withCompletionHandler:^(NSError *error) {

        if (!error) {
            [self.delegate loadViewForMedia:weakObj];
        } else {
            [self.delegate showAnimationForMsgInfo:NO];
        }
    }];
}
@end
