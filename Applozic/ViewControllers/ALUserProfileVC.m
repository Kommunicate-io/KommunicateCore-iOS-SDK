//
//  ALUserProfileVC.m
//  Applozic
//
//  Created by devashish on 30/06/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "ALUserProfileVC.h"
#import "ALImagePickerHandler.h"
#import "UIImageView+WebCache.h"
#import "ALMessagesViewController.h"
#import <ApplozicCore/ApplozicCore.h>
#import "ALUIUtilityClass.h"
#import "ALNotificationHelper.h"

@interface ALUserProfileVC ()

@property (nonatomic, retain) UIImagePickerController *mImagePicker;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UISwitch *notificationToggle;
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileStatus;

@property (strong, nonatomic) IBOutlet UILabel *notificationTitle;
@property (strong, nonatomic) IBOutlet UILabel *mobileNotification;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UISwitch *onlineToggleSwitch;

@property (weak, nonatomic) IBOutlet UILabel *userNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (strong, nonatomic) UIImage *placeHolderImage;

- (IBAction)editButtonAction:(id)sender;
@end

@implementation ALUserProfileVC {
    NSString *mainFilePath;
    NSString *imageLinkFromServer;
    
    ALContact *myContact;
    ALContactService *alContactService;
    ALUserService *userService;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    alContactService = [[ALContactService alloc] init];
    userService = [[ALUserService alloc] init];
    self.placeHolderImage = [ALUIUtilityClass getImageFromFramworkBundle:@"contact_default_placeholder"];

    [self fetchLoginUserDetails];
    
    // Scales down the switch
    self.notificationToggle.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.onlineToggleSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    [self.profileMainImage setBackgroundColor:[ALApplozicSettings getProfileMainColour]];
    [self.profileMainView setBackgroundColor:[ALApplozicSettings getProfileSubColour]];
    [self.mobileNotification setTextColor:[ALApplozicSettings getProfileMainColour]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchLoginUserDetails {
    NSString *loginUserId = [ALUserDefaultsHandler getUserId];
    [self.activityIndicator startAnimating];

    [userService updateUserDetail:loginUserId
                     withCompletion:^(ALUserDetail *userDetail) {
        self->myContact = [self->alContactService loadContactByKey:@"userId" value:loginUserId];
        [self setupViewWithContact:self->myContact];
        [self.activityIndicator stopAnimating];
    }];
}

- (void)setupViewWithContact:(ALContact *)contact {

    if (contact.contactImageUrl) {
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:contact.contactImageUrl] placeholderImage:self.placeHolderImage];
    } else {
        [self.profileImage setImage:self.placeHolderImage];
    }

    NSString *emptyProfileStatusInfo = NSLocalizedStringWithDefaultValue(@"emptyLabelProfileText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No Status", @"");

    self.displayNameLabel.text = [contact getDisplayName];
    [self.userStatusLabel setText: contact.userStatus != nil ? contact.userStatus : emptyProfileStatusInfo];

    BOOL checkMode = ([ALUserDefaultsHandler getNotificationMode] == AL_NOTIFICATION_DISABLE);
    [self.notificationToggle setOn:(!checkMode) animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addNotificationObserver];
    self.mImagePicker = [UIImagePickerController new];
    self.mImagePicker.delegate = self;
    self.mImagePicker.allowsEditing = YES;
    
    if ([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem]) {
        self.navigationController.navigationBar.translucent = NO;
        [self commonNavBarTheme:self.navigationController];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
        self.profileImage.layer.masksToBounds = YES;
        
        self.uploadImageButton.layer.cornerRadius = self.uploadImageButton.frame.size.width/2;
        self.uploadImageButton.layer.masksToBounds = YES;
    });
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"profileTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Profile", @"");
    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.userView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.profileImage.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.userStatusLabel.textAlignment = NSTextAlignmentRight;
        self.profileStatus.textAlignment = NSTextAlignmentRight;
        self.displayNameLabel.textAlignment = NSTextAlignmentRight;
        self.notificationTitle.textAlignment = NSTextAlignmentRight;
        self.userNameTitle.textAlignment = NSTextAlignmentRight;
        self.mobileNotification.textAlignment = NSTextAlignmentRight;
    }
    
    [self.profileStatus setText: NSLocalizedStringWithDefaultValue(@"profileStatusTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Profile Status", @"")];
    [self.notificationTitle setText:NSLocalizedStringWithDefaultValue(@"notificationsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Notifications", @"")];
    
    [self.mobileNotification setText:NSLocalizedStringWithDefaultValue(@"mobileNotificationsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Mobile Notifications", @"")];
}

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMQTTNotification:)
                                                 name:@"MQTT_APPLOZIC_01"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAPNS:)
                                                 name:@"pushNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUser:)
                                                 name:@"USER_DETAIL_OTHER_VC" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MQTT_APPLOZIC_01" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USER_DETAIL_OTHER_VC" object:nil];

}

- (void)commonNavBarTheme:(UINavigationController *)navigationController {
    [navigationController.navigationBar setTitleTextAttributes: @{
        NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem],
        NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                            size:18]
    }];
    
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    [navigationController.navigationBar addSubview:[ALUIUtilityClass setStatusBarStyle]];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self commonNavBarTheme:navigationController];
}

- (void)showMQTTNotification:(NSNotification *)notifyObject {
    ALMessage *alMessage = (ALMessage *)notifyObject.object;
    
    BOOL flag = (alMessage.groupId && [ALChannelService isChannelMuted:alMessage.groupId]);
    
    if (![alMessage.type isEqualToString:@"5"] && !flag && ![alMessage isMsgHidden]) {
        ALNotificationView *alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                          withAlertMessage:alMessage.message];

        [alNotification showNativeNotificationWithcompletionHandler:^(BOOL show) {

            ALNotificationHelper *helper = [[ALNotificationHelper alloc]init];

            if ([helper isApplozicViewControllerOnTop]) {

                [helper handlerNotificationClick:alMessage.contactIds withGroupId:alMessage.groupId withConversationId:alMessage.conversationId notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
            }

        }];
    }
}

- (void)handleAPNS:(NSNotification *)notification {
    NSString *contactId = notification.object;
    ALSLog(ALLoggerSeverityInfo, @"USER_PROFILE_VC_NOTIFICATION_OBJECT : %@",contactId);
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    NSString *alertValue = [dict valueForKey:@"alertValue"];
    
    ALPushAssist *pushAssist = [ALPushAssist new];
    
    NSArray *myArray = [contactId componentsSeparatedByString:@":"];
    NSNumber *channelKey = nil;
    if (myArray.count > 2) {
        channelKey = @([myArray[1] intValue]);
    }
    
    if ([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]] && [pushAssist.topViewController isKindOfClass:[ALUserProfileVC class]]) {
        ALSLog(ALLoggerSeverityInfo, @"######## USER PROFILE VC : APP_STATE_ACTIVE #########");
        
        ALMessage *alMessage = [[ALMessage alloc] init];
        alMessage.message = alertValue;
        NSArray *myArray = [alMessage.message componentsSeparatedByString:@":"];
        
        if (myArray.count > 1) {
            alertValue = [NSString stringWithFormat:@"%@", myArray[1]];
        } else {
            alertValue = myArray[0];
        }
        
        alMessage.message = alertValue;
        alMessage.contactIds = contactId;
        alMessage.groupId = channelKey;
        
        if ((channelKey && [ALChannelService isChannelMuted:alMessage.groupId]) || [alMessage isMsgHidden]) {
            return;
        }
        
        ALNotificationView *alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                          withAlertMessage:alMessage.message];

        [alNotification showNativeNotificationWithcompletionHandler:^(BOOL show) {

            ALNotificationHelper *helper = [[ALNotificationHelper alloc]init];

            if ([helper isApplozicViewControllerOnTop]) {

                [helper handlerNotificationClick:alMessage.contactIds withGroupId:alMessage.groupId withConversationId:alMessage.conversationId notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
            }
        }];

    } else if ([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]]) {
        ALSLog(ALLoggerSeverityInfo, @"######## USER PROFILE VC : APP_STATE_INACTIVE #########");
        
        [self.tabBarController setSelectedIndex:0];
        UINavigationController *navVC = (UINavigationController *)self.tabBarController.selectedViewController;
        ALMessagesViewController *msgVC = (ALMessagesViewController *)[[navVC viewControllers] objectAtIndex:0];
        if (channelKey) {
            msgVC.channelKey = channelKey;
        } else {
            msgVC.channelKey = nil;
        }
        [msgVC createDetailChatViewController:contactId];
    }
}

- (IBAction)uploadImageAction:(id)sender {
    [self uploadImage];
}

- (IBAction)notificationToggle:(id)sender {
    
    BOOL flag = [self.notificationToggle isOn];
    if ([ALDataNetworkConnection noInternetConnectionNotification]) {
        [self.notificationToggle setOn:(!flag) animated:YES];
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    short modeValue = 2;
    if (flag) {
        modeValue = 0;
    }
    
    [ALRegisterUserClientService updateNotificationMode:modeValue withCompletion:^(ALRegistrationResponse *response, NSError *error) {
        
        ALSLog(ALLoggerSeverityInfo, @"RESPONSE :: %@",response.message);
        ALSLog(ALLoggerSeverityError, @"RESPONSE_ERROR :: %@",error.description);
        if (!error) {
            
            [ALUIUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"notificationStatusUpdateText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Notification setting updated!!!", @"") andTitle:NSLocalizedStringWithDefaultValue(@"alertText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Alert", @"")];
            [ALUserDefaultsHandler setNotificationMode:modeValue];
            [self.notificationToggle setOn:flag animated:YES];
        } else {
            [ALUIUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"unableToUpdateText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to update!!!", @"") andTitle:NSLocalizedStringWithDefaultValue(@"alertText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Alert", @"")];
            [self.notificationToggle setOn:(!flag) animated:YES];
        }
        [self.activityIndicator stopAnimating];
    }];
}

- (void)uploadImage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [ALUIUtilityClass setAlertControllerFrame:alertController andViewController:self];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"photoLibraryText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Photo Library", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadByPhotos];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedStringWithDefaultValue(@"takePhotoText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Take Photo", @"")
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self uploadByCamera];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)uploadByPhotos {
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

- (void)uploadByCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (granted) {
                    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                    [self presentViewController:self.mImagePicker animated:YES completion:nil];
                } else {
                    [ALUIUtilityClass permissionPopUpWithMessage:
                     NSLocalizedStringWithDefaultValue(@"permissionPopMessageForCamera", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Enable Camera Permission", @"")
                                               andViewController:self];
                }
            });
        }];
    } else {
        
        [ALUIUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"permissionNotAvailableMessageForCamera", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Camera is not Available !!!", @"") andTitle:@"OOPS !!!"];
    }
}

//==============================================================================================================================
#pragma IMAGE PICKER DELEGATES
//==============================================================================================================================

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *rawImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage *normalImage = [ALUIUtilityClass getNormalizedImage:rawImage];
    [self.profileImage setImage:normalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    mainFilePath = [self getImageFilePath:normalImage];
    [self confirmUserForProfileImage:normalImage];
}


- (void)confirmUserForProfileImage:(UIImage *)image {
    
    image = [image getCompressedImageLessThanSize:1];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedStringWithDefaultValue(@"confirmationText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Confirmation" , @"") message:NSLocalizedStringWithDefaultValue(@"areYouSureText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Are you sure?" , @"")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUIUtilityClass setAlertControllerFrame:alert andViewController:self];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"CANCEL" , @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        if (self->myContact.contactImageUrl) {
            [self.profileImage sd_setImageWithURL:[NSURL URLWithString:self->myContact.contactImageUrl] placeholderImage:self.placeHolderImage];
        }

        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *upload = [UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"uploadOption", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Upload" , @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
            [self showNoDataNotification];
            return;
        }
        
        NSString *uploadUrl = [KBASE_URL stringByAppendingString:AL_IMAGE_UPLOAD_URL];

        [self.activityIndicator startAnimating];

        ALHTTPManager *manager = [[ALHTTPManager alloc]init];
        [manager uploadProfileImage:image withFilePath:self->mainFilePath uploadURL:uploadUrl withCompletion:^(NSData *_Nullable data, NSError *error) {

            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *imageLinkFromServer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    ALSLog(ALLoggerSeverityInfo, @"PROFILE IMAGE URL :: %@",imageLinkFromServer);
                    self->imageLinkFromServer = imageLinkFromServer;
                    ALUserService *userService = [ALUserService new];
                    [userService updateUserDisplayName:@"" andUserImage:imageLinkFromServer userStatus:@"" withCompletion:^(id theJson, NSError *error) {

                        ALSLog(ALLoggerSeverityInfo, @"SERVER_RESPONSE_IMAGE_UPDATE :: %@",(NSString *)theJson);
                        ALSLog(ALLoggerSeverityError, @"ERROR :: %@",error.description);
                        if (!error)
                        {
                            ALSLog(ALLoggerSeverityInfo, @"IMAGE_UPDATED_SUCCESSFULLY");

                            [ALUIUtilityClass showAlertMessage:NSLocalizedStringWithDefaultValue(@"imageUpdateText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Image Updated Successfully!!!" , @"")  andTitle:NSLocalizedStringWithDefaultValue(@"alertText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Alert" , @"") ];
                            self->myContact.contactImageUrl = self->imageLinkFromServer;
                            [self->alContactService updateContact:self->myContact];

                        }
                        [self.activityIndicator stopAnimating];
                    }];
                });
            } else {
                [self.activityIndicator stopAnimating];
            }
        }];

    }];

    [alert addAction:cancel];
    [alert addAction:upload];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)showNoDataNotification {
    ALNotificationView *notification = [ALNotificationView new];
    [notification noDataConnectionNotificationView];
}

- (NSString *)getImageFilePath:(UIImage *)image {
    NSString *filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
    return filePath;
}

/// Edit user name action callback
- (IBAction)editNameButtonAction:(id)sender {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"yourUserNameAlertTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Your Name" , @"")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [ALUIUtilityClass setAlertControllerFrame:alertController andViewController:self];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedStringWithDefaultValue(@"alertUserNameTextFieldPlaceHolder",
                                                                  [ALApplozicSettings getLocalizableName],
                                                                  [NSBundle mainBundle], @"Enter your name" , @"");
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText",
                                                                                                [ALApplozicSettings getLocalizableName],
                                                                                                [NSBundle mainBundle], @"Cancel" , @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"updateUiButtonText",
                                                                                                [ALApplozicSettings getLocalizableName],
                                                                                                [NSBundle mainBundle], @"Update" , @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        UITextField *displayNameTextField = alertController.textFields.firstObject;
        NSString *enteredDisplayName = [displayNameTextField.text stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (enteredDisplayName.length &&
            ![enteredDisplayName isEqualToString:[self->myContact getDisplayName]]) {

            [self.activityIndicator startAnimating];
            ALUserService *userService = [ALUserService new];
            [userService updateUserDisplayName:displayNameTextField.text
                                  andUserImage:nil
                                    userStatus:nil
                                withCompletion:^(id theJson, NSError *error) {
                if (!error) {
                    self->myContact.displayName = displayNameTextField.text;
                    self.displayNameLabel.text = displayNameTextField.text;
                    [self->alContactService updateContact:self->myContact];
                }
                [self.activityIndicator stopAnimating];
            }];
        }
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)editButtonAction:(id)sender {
    [self alertViewForStatus];
}

- (void)alertViewForStatus {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedStringWithDefaultValue(@"yorStatusAlertTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Your Status" , @"")
                                                                             message:
                                          NSLocalizedStringWithDefaultValue(@"maxCharForStatus", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"(Max 256 characters)" , @"")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUIUtilityClass setAlertControllerFrame:alertController andViewController:self];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.placeholder = NSLocalizedStringWithDefaultValue(@"alertProfileStatusMessage", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Write status here..." , @"");

    }];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:  NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"CANCEL" , @"")
                                
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK" , @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {

        UITextField *statusField = alertController.textFields.firstObject;
        if (statusField.text.length && ![statusField.text isEqualToString:self.userStatusLabel.text]) {

            NSString *statusText = statusField.text;
            if (statusText.length >= 256) {
                statusText = [statusText substringToIndex:255];
            }

            [self.activityIndicator startAnimating];

            ALUserService *userService = [ALUserService new];
            [userService updateUserDisplayName:[self->myContact getDisplayName]
                                  andUserImage:@""
                                    userStatus:statusText
                                withCompletion:^(id theJson, NSError *error) {

                ALSLog(ALLoggerSeverityInfo, @"SERVER_RESPONSE_STATUS_UPDATE :: %@", (NSString *)theJson);
                ALSLog(ALLoggerSeverityError, @"ERROR :: %@",error.description);

                if (!error) {
                    self->myContact.userStatus = statusText;
                    ALSLog(ALLoggerSeverityInfo, @"USER_STATUS_UPDATED_SUCCESSFULLY  %@", self->myContact.userStatus);
                    [self->alContactService updateContact:self->myContact];
                    [self.userStatusLabel setText: statusText];
                    [ALUserDefaultsHandler setLoggedInUserStatus:statusText];
                }

                [self.activityIndicator stopAnimating];

            }];
        }

    }]];

    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)updateUser:(NSNotification *)userUpdateNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        ALUserDetail *userDetail = (ALUserDetail *)userUpdateNotification.object;
        if ([userDetail.userId isEqualToString:[ALUserDefaultsHandler getUserId]]) {
            if (userDetail.displayName) {
                self.displayNameLabel.text = userDetail.displayName;
            }
            if (userDetail.imageLink) {
                [self.profileImage sd_setImageWithURL:[NSURL URLWithString:userDetail.imageLink] placeholderImage:self.placeHolderImage];
            }
            self.userStatusLabel.text = userDetail.userStatus;
            [ALUserDefaultsHandler setLoggedInUserStatus:userDetail.userStatus];
        }
    });
}

@end
