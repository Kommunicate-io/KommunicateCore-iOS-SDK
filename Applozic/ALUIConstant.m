//
//  ALUIConstant.m
//  Applozic
//
//  Created by devashish on 23/04/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

@import UIKit;
#import "ALUIConstant.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"
#import "ALChannelMsgCell.h"

@implementation ALUIConstant


+(CGSize) getFrameSize
{
    CGSize PHONE_SIZE = [UIScreen mainScreen].bounds.size;
    return PHONE_SIZE;
}

+(CGSize)textSize:(ALMessage *)theMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:theMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:[ALApplozicSettings getFontFace]
                                               fontSize:15];
    
    return theTextSize;
}

//=========================================================================================================
#pragma ChatViewController TABLE CELL HEIGHT CONSTANTS
//=========================================================================================================

+(CGFloat)getLocationCellHeight:(CGRect)cellFrame
{
    CGFloat HEIGHT = cellFrame.size.width - 140;
    return HEIGHT;
}

+(CGFloat)getDateCellHeight
{
    CGFloat HEIGHT = 30;
    return HEIGHT;
}

+(CGFloat)getAudioCellHeight
{
    CGFloat HEIGHT = 130;
    return HEIGHT;
}

+(CGFloat)getContactCellHeight
{
    CGFloat HEIGHT = 265;
    return HEIGHT;
}

+(CGFloat)getDocumentCellHeight
{
    CGFloat HEIGHT = 130;
    return HEIGHT;
}

+(CGFloat)getVideoCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGFloat HEIGHT = cellFrame.size.width - 60;
    if(alMessage.message.length > 0)
    {
        CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
        HEIGHT = theTextSize.height + HEIGHT;
    }
    
    return HEIGHT;
}

+(CGFloat)getImageCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame  // NEED CHECK AGAIN image & image with text
{
    CGFloat HEIGHT = cellFrame.size.width - 70;
    if(alMessage.message.length > 0)
    {
        CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
        HEIGHT = theTextSize.height + HEIGHT;
    }
    
    return HEIGHT;
}

+(CGFloat)getChatCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame  // NEED CHECK AGAIN TEXT CELL
{
    CGSize theTextSize = [self textSize:alMessage andCellFrame:cellFrame];
    CGFloat HEIGHT = theTextSize.height + 70;
    
    return HEIGHT;
}

+(CGFloat)getCustomChatCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:[ALApplozicSettings getCustomMessageFont]
                                               fontSize:[ALApplozicSettings getCustomMessageFontSize]];
    
    CGFloat HEIGHT = theTextSize.height + 40;
    
    return HEIGHT;
}

+(CGFloat)getChannelMsgCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    CGSize theTextSize = [ALUtilityClass getSizeForText:alMessage.message
                                               maxWidth:cellFrame.size.width - 115
                                                   font:@"Helvetica"
                                               fontSize:CH_MESSAGE_TEXT_SIZE];
    
    CGFloat HEIGHT = theTextSize.height + 30;
    
    return HEIGHT;
}

+ (CGFloat) getCellHeight:(ALMessage *)alMessage andCellFrame:(CGRect)cellFrame
{
    
    if(alMessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        return [self getLocationCellHeight:cellFrame];
    }
    else if([alMessage.type isEqualToString:@"100"])
    {
        return [self getDateCellHeight];
    }
    else if(alMessage.contentType == ALMESSAGE_CHANNEL_NOTIFICATION)
    {
        return [self getChannelMsgCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"video"])
    {
        return [self getVideoCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"audio"])
    {
        return [self getAudioCellHeight];
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_CUSTOM)
    {
         return [self getCustomChatCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_DEFAULT)
    {
        return [self getChatCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if ([alMessage.fileMeta.contentType hasPrefix:@"image"])
    {
        return [self getImageCellHeight:alMessage andCellFrame:cellFrame];
    }
    else if (alMessage.contentType == (short)ALMESSAGE_CONTENT_VCARD)
    {
        return [self getContactCellHeight];
    }
    else
    {
        return [self getDocumentCellHeight];
    }
}

@end
