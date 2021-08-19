//
//  ALUIUtilityClass.h
//  Applozic
//
//  Created by apple on 17/02/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplozicCore/ApplozicCore.h>

@interface ALUIUtilityClass : NSObject

+ (UIImage *)getImageFromFramworkBundle:(NSString *) UIImageName;
+ (UIImage *)getVOIPMessageImage:(ALMessage *)alMessage;
+ (void) downloadImageUrlAndSet: (NSString *)blobKey
                     imageView:(UIImageView *)imageView
                  defaultImage:(NSString *)defaultImage;


+ (UIAlertController *)displayLoadingAlertControllerWithText:(NSString *)loadingText;

+ (void)dismissAlertController:(UIAlertController *)alertController
               withCompletion:(void (^)(BOOL dismissed)) completion;
+ (void)movementAnimation:(UIButton *)button andHide:(BOOL)flag;

+ (void)displayToastWithMessage:(NSString *)toastMessage;

+ (UIView *)setStatusBarStyle;

+ (UIImage *)getNormalizedImage:(UIImage *)rawImage;

+ (id)parsedALChatCostomizationPlistForKey:(NSString *)key;

+ (void)showAlertMessage:(NSString *)text andTitle:(NSString *)title;

+ (UIImage *)getImageFromFilePath:(NSString *)filePath;

+ (UIColor*)colorWithHexString:(NSString*)hex;

+ (UIImage *)generateVideoThumbnailImage:(NSString *)videoFilePATH;

+ (UIImage *)generateImageThumbnailForVideoWithURL:(NSURL *)url;

+ (void)imageGeneratorForVideoWithURL:(NSURL *)url withCompletion:(void (^)(UIImage *image)) completion;

+ (void)permissionPopUpWithMessage:(NSString *)msgText andViewController:(UIViewController *)viewController;
+ (void)setAlertControllerFrame:(UIAlertController *)alertController andViewController:(UIViewController *)viewController;
+ (NSString *)getNameAlphabets:(NSString *)actualName;

+ (void)openApplicationSettings;

@end
