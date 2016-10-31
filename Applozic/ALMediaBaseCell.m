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


@implementation ALMediaBaseCell
{
    float heightLocation;
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
        [self.imageWithText setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:MESSAGE_TEXT_SIZE]];
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
        
        UIMenuItem * msgInfo = [[UIMenuItem alloc] initWithTitle:@"Info" action:@selector(msgInfo:)];
        [[UIMenuController sharedMenuController] setMenuItems: @[msgInfo]];
        [[UIMenuController sharedMenuController] update];

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
    }
    
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    return self;
}

-(void) dowloadRetryButtonAction
{
    [self.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

- (void)msgInfo:(id)sender{

}

-(void)setupProgress{

}

-(void)hidePlayButtonOnUploading
{
    
}

-(void)cancelAction{

}

@end
