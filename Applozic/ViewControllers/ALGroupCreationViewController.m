//
//  ALGroupCreationViewController.m
//  Applozic
//
//  Created by Divjyot Singh on 13/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

//groupNameInput
//groupIcon
#define DEFAULT_GROUP_ICON_IMAGE ([UIImage imageNamed:@"applozic_group_icon.png"])

#import "ALGroupCreationViewController.h"
#import "ALNewContactsViewController.h"
#import "ALChatViewController.h"
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
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
#import "ALRegisterUserClientService.h"
#import "UIImageView+WebCache.h"
#import "ALContactService.h"

@interface ALGroupCreationViewController ()//<ALGroupCreationVCDelegate>
@property (nonatomic,strong) UIImagePickerController * mImagePicker;
@property (nonatomic,strong) NSString * mainFilePath;
@property (nonatomic,strong) NSString * groupImageURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//@property (weak,nonatomic) ALNewContactsViewController* alNewContactViewController;
@end

@implementation ALGroupCreationViewController{
    UIBarButtonItem *nextContacts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nextContacts = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(launchContactSelection:)];
    
    self.navigationItem.rightBarButtonItem = nextContacts;
    self.automaticallyAdjustsScrollViewInsets=NO; //setting to NO helps show UITextView's text at view load
    [self setupGroupIcon:self.groupIconView];
    
    self.mImagePicker = [[UIImagePickerController alloc] init];
    self.mImagePicker.delegate = self;
    self.mImagePicker.allowsEditing = YES;
    
    [self.activityIndicator setHidesWhenStopped:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.groupNameInput becomeFirstResponder];
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.userInteractionEnabled = NO;
    [self.tabBarController.tabBar setHidden:YES];
    // self.alNewContactViewController.delegateGroupCreation = self;
}

- (void)launchContactSelection:(id)sender {
    
    
    //Check if group name text is empty
    if([self.groupNameInput.text isEqualToString:@""]){
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Group Name"
                                              message:@"Please give the group name."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    
    //Moving forward to member selection
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALGroupCreationViewController.class]];
    UIViewController *groupCreation = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    
    //Setting groupName and forGroup flag
    ((ALNewContactsViewController*)groupCreation).forGroup=[NSNumber numberWithInt:GROUP_CREATION];
    ((ALNewContactsViewController*)groupCreation).groupName=self.groupNameInput.text;
    ((ALNewContactsViewController*)groupCreation).groupImageURL=self.groupImageURL;
    
    //Moving to contacts view for group member selection
    [self.navigationController pushViewController:groupCreation animated:YES];
}

#pragma mark - Group Icon setup and events
//========================================
-(void)setupGroupIcon:(UIImageView *)groupIconView{
    groupIconView.clipsToBounds=YES;
    groupIconView.layer.cornerRadius=self.groupIconView.frame.size.width/2;
    groupIconView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    [self addGroupIconViewTapEventTo:groupIconView];
}

-(void)addGroupIconViewTapEventTo:(UIImageView*)groupIconView{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadImage)];
    singleTap.numberOfTapsRequired = 1;
    [groupIconView addGestureRecognizer:singleTap];
}

-(void)uploadImage
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [ALUtilityClass showAlertMessage:@"Camera is not available in device." andTitle:@"Error"];
        return;
    }
    
    self.mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    [self presentViewController:self.mImagePicker animated:YES completion:nil];
    
}

#pragma mark - image picker delegates
//===================================
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * rawImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage * normalizedImage = [ALUtilityClass getNormalizedImage:rawImage];
    [self.groupIconView setImage:normalizedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.mainFilePath = [self getImageFilePath:normalizedImage];
    [self confirmUserForGroupImage:normalizedImage];
    
}

-(NSString *)getImageFilePath:(UIImage *)image
{
    NSString *filePath = [ALImagePickerHandler saveImageToDocDirectory:image];
    return filePath;
}

-(void)confirmUserForGroupImage:(UIImage *)image
{
    
    image = [image getCompressedImageLessThanSize:1];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                    message:@"Are you sure to upload?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self.groupIconView setImage:DEFAULT_GROUP_ICON_IMAGE];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* upload = [UIAlertAction actionWithTitle:@"Upload" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if(![ALDataNetworkConnection checkDataNetworkAvailable])
        {
            ALNotificationView * notification = [ALNotificationView new];
            [notification noDataConnectionNotificationView];;
            return;
        }
        
        NSString * uploadUrl = [[ALUserDefaultsHandler getBASEURL] stringByAppendingString:IMAGE_UPLOAD_URL];
        
        self.groupImageUploadURL = uploadUrl;
        
        //TODO: Call From Delegate !!
        [self proessUploadImage:image uploadURL:uploadUrl withdelegate:self];
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:upload];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)proessUploadImage:(UIImage *)profileImage uploadURL:(NSString *)uploadURL withdelegate:(id)delegate
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.activityIndicator startAnimating];
    NSString *filePath = self.mainFilePath;
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
        connection.connectionType = CONNECTION_TYPE_GROUP_IMG_UPLOAD;
        
        [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] addObject:connection];
        
    }else{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.activityIndicator stopAnimating];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                        message:@"Unable to locate file on device"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//==============================================================================================================================
#pragma NSURL CONNECTION DELEGATES + HELPER METHODS
//==============================================================================================================================

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"GROUP_IMAGE UPLOAD_ERROR :: %@",error.description);
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.activityIndicator stopAnimating];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"GROUP_IMAGE UPLOAD PROGRESS: %lu out of %lu",totalBytesWritten,totalBytesExpectedToWrite);
}

-(void)connectionDidFinishLoading:(ALConnection *)connection
{
    
    NSLog(@"CONNNECTION_FINISHED");
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    if([connection.connectionType isEqualToString:CONNECTION_TYPE_GROUP_IMG_UPLOAD])
    {
        NSString *imageLinkFromServer = [[NSString alloc] initWithData:connection.mData encoding:NSUTF8StringEncoding];
        NSLog(@"GROUP_IMAGE_LINK :: %@",imageLinkFromServer);
        self.groupImageURL = imageLinkFromServer;
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.activityIndicator stopAnimating];
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data
{
    [connection.mData appendData:data];
}

@end
// TextView     = 100
// ImageView    = 102
// Text Field   = 103
