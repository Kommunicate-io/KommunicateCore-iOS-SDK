//
//  ALCustomCell.m
//  Applozic
//
//  Created by Divjyot Singh on 05/05/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALCustomCell.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"

@implementation ALCustomCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize
{
    [super populateCell:alMessage viewSize:viewSize];

    [self.mMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.mMessageLabel setText:alMessage.message];
    [self.mMessageLabel setBackgroundColor:[UIColor clearColor]];
    [self.mMessageLabel setTextColor:[UIColor blackColor]];
    [self.mMessageLabel setUserInteractionEnabled:NO];
    
    [self.mDateLabel setHidden:YES];
    self.mUserProfileImageView.alpha = 0;
    self.mNameLabel.hidden = YES;
    self.mChannelMemberName.hidden = YES;
    self.mMessageStatusImageView.hidden = YES;
    
    
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message maxWidth:viewSize.width-115 font:self.mMessageLabel.font.fontName fontSize:self.mMessageLabel.font.pointSize];
    
    int padding  =  10 ;
    CGPoint theTextPoint = CGPointMake(([UIScreen mainScreen].bounds.size.width/2)-(theTextSize.width/2)-padding,
                                       padding/2);
    
    CGRect frame = CGRectMake(theTextPoint.x,
                              theTextPoint.y,
                              theTextSize.width + (2*padding),
                              theTextSize.height + padding);

    self.mBubleImageView.backgroundColor = [ALApplozicSettings getCustomMessageBackgroundColor];
    [self.mBubleImageView setFrame:frame];
    [self.mBubleImageView setHidden:NO];
    
    [self.mMessageLabel setFrame: CGRectMake(frame.origin.x,
                                             padding,
                                             frame.size.width,
                                             frame.size.height)];

    return self;
}
@end
