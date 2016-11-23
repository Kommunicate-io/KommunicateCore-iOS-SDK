//
//  ALUserProfileVC.m
//  Applozic
//
//  Created by devashish on 30/06/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Utility.h"
#import "ALUserProfileVC.h"
#import "ALApplozicSettings.h"
#import "ALUtilityClass.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALImagePickerHandler.h"
#import "ALRequestHandler.h"
#import "ALResponseHandler.h"
#import "ALNotificationView.h"
#import "ALDataNetworkConnection.h"
#import "ALUserService.h"
#import "ALRegisterUserClientService.h"
#import "UIImageView+WebCache.h"
#import "ALContactService.h"
#import "ALConstant.h"


@interface ALUserProfileVC () <NSURLConnectionDataDelegate>

@property (nonatomic, retain) UIImagePickerController * mImagePicker;
@property (nonatomic, strong) ALConnection * alConnection;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UISwitch *notificationToggle;
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UISwitch *onlineToggleSwitch;

- (IBAction)editButtonAction:(id)sender;
@end

@implementation ALUserProfileVC
{
    NSString *mainFilePath;
    NSString *imageLinkFromServer;
    
    ALContact * myContact;
    ALContactService * alContactService;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
     // Scales down the switch
    self.notificationToggle.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.onlineToggleSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mImagePicker = [UIImagePickerController new];
    self.mImagePicker.delegate = self;
    self.mImagePicker.allowsEditing = YES;
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        self.navigationController.navigationBar.translucent = NO;
        [self commonNavBarTheme:self.navigationController];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
        self.profileImage.layer.masksToBounds = YES;
        
        self.uploadImageButton.layer.cornerRadius = self.uploadImageButton.frame.size.width/2;
        self.uploadImageButton.layer.masksToBounds = YES;
    });

    self.navigationItem.title = @"Profile";
    [self.profileImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]];
    NSData *imageData = [NSData dataWithContentsOfFile:[ALUserDefaultsHandler getProfileImageLink]];
    NSURL *serverImageURL = [NSURL URLWithString:[ALUserDefaultsHandler getProfileImageLinkFromServer]];
    if(imageData)
    {
        UIImage *imageFile = [UIImage imageWithData:imageData];
        [self.profileImage setImage:imageFile];
    }
    else if(serverImageURL)
    {
        [self.profileImage sd_setImageWithURL:serverImageURL];
    }
    
    alContactService = [[ALContactService alloc] init];
    myContact = [alContactService loadContactByKey:@"userId" value:[ALUserDefaultsHandler getUserId]];
    self.userNameLabel.text = [myContact getDisplayName];
    self.userDesignationLabel.text = @"Manager";
    [self.userStatusLabel setText:[ALUserDefaultsHandler getLoggedInUserStatus] ? [ALUserDefaultsHandler getLoggedInUserStatus] : @"Profile Status"];
 
    BOOL checkMode = ([ALUserDefaultsHandler getNotificationMode] == NOTIFICATION_DISABLE);
    [self.notificationToggle setOn:(!checkMode) animated:YES];
    
}

-(void)commonNavBarTheme:(UINavigationController *)navigationController
{
    [navigationController.navigationBar setTitleTextAttributes: @{
                                                                  NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem],
                                                                  NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                                                                                       size:18]
                                                                  }];
    
    [navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
    [navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    [navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self commonNavBarTheme:navigationController];
}

//#pragma mark - Table view data source   [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:contact.contactImageUrl]];
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)uploadImageAction:(id)sender {
    [self uploadImage];
}

- (IBAction)notificationToggle:(id)sender {

    BOOL flag = [self.notificationToggle isOn];
    if([ALDataNetworkConnection noInternetConnectionNotification])
    {
        [self.notificationToggle setOn:(!flag) animated:YES];
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    short modeValue = 2;
    if(flag)
    {
        modeValue = 0;
    }
    
    [ALRegisterUserClientService updateNotificationMode:modeValue withCompletion:^(ALRegistrationResponse *response, NSError *error) {
        
        NSLog(@"RESPONSE :: %@",response.message);
        NSLog(@"RESPONSE_ERROR :: %@",error.description);
        if(!error)
        {
            [ALUtilityClass showAlertMessage:@"Notification setting updated!!!" andTitle:@"Alert"];
            [ALUserDefaultsHandler setNotificationMode:modeValue];
            [self.notificationToggle setOn:flag animated:YES];
        }
        else
        {
            [ALUtilityClass showAlertMessage:@"Unable to update!!!" andTitle:@"Alert"];
            [self.notificationToggle setOn:(!flag) animated:YES];
        }
        [self.activityIndicator stopAnimating];
    }];
}

-(void)uploadImage
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [ALUtilityClass setAlertControllerFrame:alertController andViewController:self];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadByPhotos];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self uploadByCamera];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)uploadByPhotos
{
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
}

-(void)uploadByCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (granted)
                {
                    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                    [self presentViewController:self.mImagePicker animated:YES completion:nil];
                }
                else
                {
                    [ALUtilityClass permissionPopUpWithMessage:@"Enable Camera Permission" andViewController:self];
                }
            });
        }];
    }
    else
    {
        [ALUtilityClass showAlertMessage:@"Camera is not Available !!!" andTitle:@"OOPS !!!"];
    }
}

//==============================================================================================================================
#pragma IMAGE PICKER DELEGATES
//==============================================================================================================================

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

    UIImage * rawImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage * normalImage = [ALUtilityClass getNormalizedImage:rawImage];
    [self.profileImage setImage:normalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    mainFilePath = [self getImageFilePath:normalImage];
    [self confirmUserForProfileImage:normalImage];
}

//==============================================================================================================================
#pragma NSURL CONNECTION DELEGATES + HELPER METHODS
//==============================================================================================================================

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"PROFILE_IMAGE_UPLOAD_ERROR :: %@",error.description);
    [self.activityIndicator stopAnimating];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"TOTAL_BYTES_WRITTEN :: %lu",totalBytesWritten);
}

-(void)connectionDidFinishLoading:(ALConnection *)connection
{
    NSLog(@"CONNNECTION_FINISHED");
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    if([connection.connectionType isEqualToString:CONNECTION_TYPE_USER_IMG_UPLOAD])
    {
        imageLinkFromServer = [[NSString alloc] initWithData:connection.mData encoding:NSUTF8StringEncoding];
        NSLog(@"IMAGE_LINK :: %@",imageLinkFromServer);
        ALUserService *userService = [ALUserService new];
        [userService updateUserDisplayName:@"" andUserImage:imageLinkFromServer userStatus:@"" withCompletion:^(id theJson, NSError *error) {
            
            NSLog(@"SERVER_RESPONSE_IMAGE_UPDATE :: %@",(NSString *)theJson);
            NSLog(@"ERROR :: %@",error.description);
            if(!error)
            {
                NSLog(@"IMAGE_UPDATED_SUCCESSFULLY");
                [ALUtilityClass showAlertMessage:@"Image Updated Successfully!!!" andTitle:@"Alert"];
                [ALUserDefaultsHandler setProfileImageLinkFromServer:imageLinkFromServer];
                
            }
        }];
    }
     [self.activityIndicator stopAnimating];
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    [connection.mData appendData:data];
}

-(void)confirmUserForProfileImage:(UIImage *)image
{
    
    image = [image getCompressedImageLessThanSize:1];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUtilityClass setAlertControllerFrame:alert andViewController:self];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* upload = [UIAlertAction actionWithTitle:@"Upload" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if(![ALDataNetworkConnection checkDataNetworkAvailable])
        {
            [self showNoDataNotification];
            return;
        }
        
        NSString * uploadUrl = [KBASE_URL stringByAppendingString:IMAGE_UPLOAD_URL];
        [self proessUploadImage:image uploadURL:uploadUrl withdelegate:self];
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:upload];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)showNoDataNotification
{
    ALNotificationView * notification = [ALNotificationView new];
    [notification noDataConnectionNotificationView];
}

-(NSString *)getImageFilePath:(UIImage *)image
{
    NSString *filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
    [ALUserDefaultsHandler setProfileImageLink:filePath];
    return filePath;
}

-(void)proessUploadImage:(UIImage *)profileImage uploadURL:(NSString *)uploadURL withdelegate:(id)delegate
{
    [self.activityIndicator startAnimating];
    NSString *filePath = mainFilePath;
    NSMutableURLRequest * request = [ALRequestHandler createPOSTRequestWithUrlString:uploadURL paramString:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        //Create boundary, it can be anything
        NSString *boundary = @"------ApplogicBoundary4QuqLuM1cE5lMwCy";
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        // post body
        NSMutableData *body = [NSMutableData data];
        NSString *FileParamConstant = @"file";
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSLog(@"IMAGE_DATA :: %f",imageData.length/1024.0);
        
        //Assuming data is not nil we add this to the multipart form
        if (imageData)
        {

            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", FileParamConstant, @"imge_123_profile"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n\r\n", @"image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // setting the body of the post to the request
        [request setHTTPBody:body];
        // set URL
        [request setURL:[NSURL URLWithString:uploadURL]];

        ALConnection * connection = [[ALConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES];
        connection.connectionType = CONNECTION_TYPE_USER_IMG_UPLOAD;
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
        
    }
    
}

-(IBAction)editButtonAction:(id)sender
{
    [self alertViewForStatus];
}

-(void)alertViewForStatus
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your Status"
                                                                             message:@"(Max 256 characters)"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [ALUtilityClass setAlertControllerFrame:alertController andViewController:self];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
         textField.placeholder = @"Write status here...";
     }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"CANCEL"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
            
            UITextField *statusField = alertController.textFields.firstObject;
            if(statusField.text.length && ![statusField.text isEqualToString:self.userStatusLabel.text])
            {
                
                NSString * statusText = statusField.text;
                if(statusText.length >= 256)
                {
                    statusText = [statusText substringToIndex:255];
                }
                
                [self.activityIndicator startAnimating];
                
                ALUserService *userService = [ALUserService new];
                [userService updateUserDisplayName:self.userNameLabel.text
                                      andUserImage:@""
                                        userStatus:statusText
                                    withCompletion:^(id theJson, NSError *error) {
                    
                    NSLog(@"SERVER_RESPONSE_STATUS_UPDATE :: %@", (NSString *)theJson);
                    NSLog(@"ERROR :: %@",error.description);
                    
                    if(!error)
                    {
                        NSLog(@"USER_STATUS_UPDATED_SUCCESSFULLY");
                        myContact.userStatus = statusText;
                        NSLog(@"USER_STATUS_UPDATED_SUCCESSFULLY  %@", myContact.userStatus);
                        [alContactService updateContact:myContact];
                        [self.userStatusLabel setText: statusText];
                        [ALUserDefaultsHandler setLoggedInUserStatus:statusText];

                    }

                    [self.activityIndicator stopAnimating];
                                        
                }];
            }
            
        }]];
    
     [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
