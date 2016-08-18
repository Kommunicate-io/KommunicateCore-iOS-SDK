//
//  ALGroupCreationViewController.h
//  Applozic
//
//  Created by Divjyot Singh on 13/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALGroupCreationViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameInput;
@property (weak, nonatomic) IBOutlet UIImageView *groupIconView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong,nonatomic) NSString * groupImageUploadURL;

@end
