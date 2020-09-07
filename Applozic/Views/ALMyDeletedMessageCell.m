//
//  ALDeletedMessageCell.m
//  Applozic
//
//  Created by Sunil on 20/08/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import "ALMyDeletedMessageCell.h"
#import "ALApplozicSettings.h"
#import "ALUIConstant.h"
#import "ALUtilityClass.h"

static CGFloat const DATE_LABEL_SIZE = 12;

static CGFloat const BUBLE_VIEW_RIGHT_PADDING = 27;
static CGFloat const BUBLE_VIEW_BOTTOM_PADDING = 5;
static CGFloat const BUBLE_VIEW_LEFT_PADDING = 90;
static CGFloat const BUBLE_VIEW_TOP_PADDING = 5;

static CGFloat const DELETED_IMAGE_VIEW_TOP_PADDING = 5;
static CGFloat const DELETED_IMAGE_VIEW_LEFT_PADDING = 7;
static CGFloat const DELETED_IMAGE_VIEW_HEIGHT_PADDING = 35;
static CGFloat const DELETED_IMAGE_VIEW_WIDTH_PADDING = 35;

static CGFloat const MESSAGE_LABEL_TOP_PADDING = 5;
static CGFloat const MESSAGE_LABEL_BOTTOM_PADDING = 5;
static CGFloat const MESSAGE_LABEL_RIGHT_PADDING = 5;

static CGFloat const DATE_LABEL_BOTTOM_PADDING = 10;
static CGFloat const DATE_LABEL_WIDTH_PADDING = 70;


@interface ALMyDeletedMessageCell()

@property (nonatomic,retain) NSLayoutConstraint * dateLabelHeight;

@end

@implementation ALMyDeletedMessageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(void)setupView {
    [super setupView];
    self.mMessageLabel.textColor = [ALApplozicSettings getSendMsgTextColor];

    if ([ALApplozicSettings getSendMsgColor]) {
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
    } else {
        self.mBubleImageView.backgroundColor = [UIColor whiteColor];
    }

    UIImage * image = [ALUtilityClass getImageFromFramworkBundle:@"round_not_interested_white.png"];
    [self.mDeletedIcon setImage:image];
    self.backgroundColor = [UIColor clearColor];
}

-(void)addViewConstraints {
    [super addViewConstraints];

    [self.mBubleImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:BUBLE_VIEW_LEFT_PADDING].active = YES;
    [self.mBubleImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-BUBLE_VIEW_RIGHT_PADDING].active = YES;
    [self.mBubleImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:BUBLE_VIEW_TOP_PADDING].active = YES;
    [self.mBubleImageView.bottomAnchor constraintEqualToAnchor:self.mDateLabel.topAnchor constant:-BUBLE_VIEW_BOTTOM_PADDING].active = YES;

    [self.mDeletedIcon.topAnchor constraintEqualToAnchor:self.mBubleImageView.topAnchor constant:DELETED_IMAGE_VIEW_TOP_PADDING].active = YES;
    [self.mDeletedIcon.leadingAnchor constraintEqualToAnchor:self.mBubleImageView.leadingAnchor constant:DELETED_IMAGE_VIEW_LEFT_PADDING].active = YES;
    [self.mDeletedIcon.widthAnchor constraintEqualToConstant:DELETED_IMAGE_VIEW_WIDTH_PADDING].active = YES;
    [self.mDeletedIcon.heightAnchor constraintEqualToConstant:DELETED_IMAGE_VIEW_HEIGHT_PADDING].active = YES;

    [self.mMessageLabel.leadingAnchor constraintEqualToAnchor:self.mDeletedIcon.trailingAnchor].active = YES;
    [self.mMessageLabel.trailingAnchor constraintEqualToAnchor:self.mBubleImageView.trailingAnchor constant:-MESSAGE_LABEL_RIGHT_PADDING].active = YES;
    [self.mMessageLabel.topAnchor constraintEqualToAnchor:self.mBubleImageView.topAnchor constant:MESSAGE_LABEL_TOP_PADDING].active = YES;
    [self.mMessageLabel.bottomAnchor constraintEqualToAnchor:self.mBubleImageView.bottomAnchor constant:-MESSAGE_LABEL_BOTTOM_PADDING].active = YES;

    [self.mDateLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-DATE_LABEL_BOTTOM_PADDING].active = YES;
    [self.mDateLabel.trailingAnchor constraintEqualToAnchor:self.mBubleImageView.trailingAnchor].active = YES;
    [self.mDateLabel.widthAnchor constraintEqualToConstant:DATE_LABEL_WIDTH_PADDING].active = YES;
    self.dateLabelHeight = [self.mDateLabel.heightAnchor constraintEqualToConstant:0];
    self.dateLabelHeight.active = YES;

    [self.frontView.leadingAnchor constraintEqualToAnchor:self.mBubleImageView.leadingAnchor].active = YES;
    [self.frontView.trailingAnchor constraintEqualToAnchor:self.mBubleImageView.trailingAnchor].active = YES;
    [self.frontView.topAnchor constraintEqualToAnchor:self.mBubleImageView.topAnchor].active = YES;
    [self.frontView.bottomAnchor constraintEqualToAnchor:self.mBubleImageView.bottomAnchor].active = YES;

}

-(void) update:(ALMessage *)message {
    [super update:message];

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@", [message getCreatedAtTimeChat:today]];

    NSString *fontName = [ALApplozicSettings getFontFace];
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:DATE_LABEL_WIDTH_PADDING
                                                   font:fontName
                                               fontSize:DATE_LABEL_SIZE];
    self.dateLabelHeight.constant = roundf(theDateSize.height);
}

+(CGFloat)getDeletedMessageCellHeight:(ALMessage *)alMessage
                         andCellFrame:(CGRect)cellFrame {

    NSString * deletedMessageText =  NSLocalizedStringWithDefaultValue(@"deletedMessageText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"This message has been deleted", @"");
    CGSize theTextSize = [ALUIConstant textSizeWithText:deletedMessageText andCellFrame:cellFrame];

    CGFloat height = roundf(theTextSize.height) +
    BUBLE_VIEW_TOP_PADDING +
    BUBLE_VIEW_BOTTOM_PADDING +
    MESSAGE_LABEL_TOP_PADDING +
    MESSAGE_LABEL_BOTTOM_PADDING +
    20; // 20 Padding

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@", [alMessage getCreatedAtTimeChat:today]];

    NSString *fontName = [ALApplozicSettings getFontFace];
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:DATE_LABEL_WIDTH_PADDING
                                                   font:fontName
                                               fontSize:DATE_LABEL_SIZE];
    height = height + DATE_LABEL_BOTTOM_PADDING + roundf(theDateSize.height);
    return height;
}

@end
