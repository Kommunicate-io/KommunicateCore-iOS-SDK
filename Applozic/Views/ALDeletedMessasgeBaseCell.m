//
//  ALDeletedMessasgeBaseCell.m
//  Applozic
//
//  Created by Sunil on 21/08/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import "ALDeletedMessasgeBaseCell.h"
#import "ALUtilityClass.h"
#import "ALMessageService.h"

@implementation ALDeletedMessasgeBaseCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self setupView];
        [self addViewConstraints];
    }
    return self;
}

-(void)setupView {

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.mBubleImageView = [[UIImageView alloc] init];
    self.mBubleImageView.contentMode = UIViewContentModeScaleToFill;
    self.mBubleImageView.layer.cornerRadius = 5;
    self.mBubleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
    [self.contentView addSubview:self.mBubleImageView];

    self.mDeletedIcon = [[UIImageView alloc] init];
    self.mDeletedIcon.contentMode = UIViewContentModeScaleToFill;
    self.mDeletedIcon.backgroundColor = [UIColor clearColor];
    self.mDeletedIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mDeletedIcon];

    self.mDateLabel = [[UILabel alloc] init];
    self.mDateLabel.font = [UIFont fontWithName:[ALApplozicSettings getFontFace] size:12];
    self.mDateLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.mDateLabel.textColor = [ALApplozicSettings getDateColor];
    self.mDateLabel.numberOfLines = 1;
    [self.contentView addSubview:self.mDateLabel];

    self.mMessageLabel = [[UILabel alloc] init];
    self.mMessageLabel.numberOfLines = 0;
    self.mMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.mMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.mMessageLabel.font = [self getDynamicFontWithDefaultSize:[ALApplozicSettings getChatCellTextFontSize] fontName:[ALApplozicSettings getFontFace]];
    [self.contentView addSubview:self.mMessageLabel];

    self.frontView = [[ALTappableView alloc] init];
    self.frontView.backgroundColor = [UIColor clearColor];
    self.frontView.alpha = 1.0;
    self.frontView.translatesAutoresizingMaskIntoConstraints = NO;
    self.frontView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.frontView];

    UILongPressGestureRecognizer * menuTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(proccessTapForMenu:)];
    menuTapGesture.minimumPressDuration = 1.0;
    menuTapGesture.cancelsTouchesInView = NO;
    [self.frontView addGestureRecognizer:menuTapGesture];

    self.backgroundColor = [UIColor clearColor];
}

-(void)addViewConstraints {
}

-(UIFont *)getDynamicFontWithDefaultSize:(CGFloat)size fontName:(NSString *)fontName
{
    UIFont *defaultFont = [UIFont fontWithName:fontName size:size];
    if (!defaultFont) {
        defaultFont = [UIFont systemFontOfSize:size];
    }

    if ([ALApplozicSettings getChatCellFontTextStyle] && [ALApplozicSettings isTextStyleInCellEnabled]) {
        if (@available(iOS 10.0, *)) {
            return [UIFont preferredFontForTextStyle:[ALApplozicSettings getChatCellFontTextStyle]];
        }
    }
    return defaultFont;
}


-(void)update:(ALMessage *)message {
    self.mMessage = message;

    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[message.createdAtTime doubleValue]/1000]];
    NSString * theDate = [NSString stringWithFormat:@"%@",[message getCreatedAtTimeChat:today]];

    NSString * deletedMessageText =  NSLocalizedStringWithDefaultValue(@"deletedMessageText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"This message has been deleted", @"");

    self.mDateLabel.text = theDate;
    self.mMessageLabel.text = deletedMessageText;
}

-(void) proccessTapForMenu:(UITapGestureRecognizer *)longPressGestureRecognizer {

    UIView * superView = [longPressGestureRecognizer.view superview];
    UIView * gestureView = longPressGestureRecognizer.view;

    if (!superView ||
        !gestureView ||
        !self.canBecomeFirstResponder) {
        return;
    }

    UIMenuController * sharedMenuController =  [UIMenuController sharedMenuController];

    if (![gestureView canBecomeFirstResponder] ||
        sharedMenuController.isMenuVisible) {
        return;
    }

    [gestureView becomeFirstResponder];

    [sharedMenuController setTargetRect:gestureView.frame inView:superView];
    [sharedMenuController setMenuVisible:YES animated:YES];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    if (self.channel &&
        self.channel.type == OPEN) {
        return NO;
    }

    return action == @selector(delete:);
}

-(void) delete:(id)sender {
    //UI
    ALSLog(ALLoggerSeverityInfo, @"Message to deleteUI %@",self.mMessage.message);
    [self.delegate deleteMessageFromView:self.mMessage];

    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString *string, NSError *error) {

        ALSLog(ALLoggerSeverityError, @"DELETE MESSAGE ERROR :: %@", error.description);
    }];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

@end
