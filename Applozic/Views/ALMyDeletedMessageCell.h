//
//  ALDeletedMessageCell.h
//  Applozic
//
//  Created by Sunil on 20/08/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALDeletedMessasgeBaseCell.h"

@interface ALMyDeletedMessageCell : ALDeletedMessasgeBaseCell

+(CGFloat)getDeletedMessageCellHeight:(ALMessage *)alMessage
                         andCellFrame:(CGRect)cellFrame;
@end
