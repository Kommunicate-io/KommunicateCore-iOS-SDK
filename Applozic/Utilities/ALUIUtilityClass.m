//
//  ALUIUtilityClass.m
//  Applozic
//
//  Created by Sunil on 17/02/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALUIUtilityClass.h"
#import "UIImageView+WebCache.h"
#import "ALUtilityClass.h"
#import "ALUIImage+animatedGIF.h"
#import <AVFoundation/AVFoundation.h>

@implementation ALUIUtilityClass

+(UIImage *)getImageFromFramworkBundle:(NSString *) UIImageName{

    NSBundle * bundle = [NSBundle bundleForClass:ALUIUtilityClass.class];
    UIImage *image = [UIImage imageNamed:UIImageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+(UIImage *)getVOIPMessageImage:(ALMessage *)alMessage
{
    NSString *msgType = (NSString *)[alMessage.metadata objectForKey:@"MSG_TYPE"];
    BOOL flag = [[alMessage.metadata objectForKey:@"CALL_AUDIO_ONLY"] boolValue];

    NSString * imageName = @"";

    if([msgType isEqualToString:@"CALL_MISSED"] || [msgType isEqualToString:@"CALL_REJECTED"])
    {
        imageName = @"missed_call.png";
    }
    else if([msgType isEqualToString:@"CALL_END"])
    {
        imageName = flag ? @"audio_call.png" : @"ic_action_video.png";
    }

    UIImage *image = [self getImageFromFramworkBundle:imageName];

    return image;
}

+(void) downloadImageUrlAndSet: (NSString *) blobKey
                     imageView:(UIImageView *) imageView
                  defaultImage:(NSString *) defaultImage {

    if (blobKey) {
        NSURL * theUrl1 = [NSURL URLWithString:blobKey];
        [imageView sd_setImageWithURL:theUrl1 placeholderImage:[ALUIUtilityClass getImageFromFramworkBundle:defaultImage] options:SDWebImageRefreshCached];
    }
}

+(UIAlertController *)displayLoadingAlertControllerWithText:(NSString *)loadingText {

    UIAlertController * uiAlertController = [UIAlertController
                                             alertControllerWithTitle:loadingText
                                             message:nil
                                             preferredStyle:UIAlertControllerStyleAlert];

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    UIViewController * uiViewController = [[UIViewController alloc] init];
    uiViewController.preferredContentSize = activityIndicatorView.frame.size;
    activityIndicatorView.color = [UIColor grayColor];
    [activityIndicatorView startAnimating];
    [uiViewController.view addSubview:activityIndicatorView];
    [uiAlertController setValue:uiViewController forKey:@"contentViewController"];
    ALPushAssist * pushAssit = [[ALPushAssist alloc] init];
    [pushAssit.topViewController presentViewController:uiAlertController animated:true completion:nil];
    return uiAlertController;
}

+(void)dismissAlertController:(UIAlertController *)alertController
               withCompletion:(void (^)(BOOL dismissed)) completion {
    [alertController dismissViewControllerAnimated:YES completion:^{
        completion(YES);
    }];
}

+(void)showRetryUIAlertControllerWithButtonClickCompletionHandler:(void (^)(BOOL clicked)) completion {

    ALPushAssist *pushAssist = [[ALPushAssist alloc]init];
    UIViewController* topVC = pushAssist.topViewController;

    if (!topVC || !topVC.navigationController) {
        completion(false);
        return;
    }

    NSString *alertTitle = NSLocalizedStringWithDefaultValue(@"RetryAlertTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Error connecting" , @"");

    NSString *alertMessage = NSLocalizedStringWithDefaultValue(@"RetryAlertMessage", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Failed to connect." , @"");

    UIAlertController * uiAlertController = [UIAlertController
                                             alertControllerWithTitle:alertTitle
                                             message:alertMessage
                                             preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* retryButton = [UIAlertAction
                                  actionWithTitle:NSLocalizedStringWithDefaultValue(@"RetryButtonText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Retry" , @"")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {

        completion(true);
    }];

    [uiAlertController addAction:retryButton];
    [topVC.navigationController presentViewController:uiAlertController animated:true completion:nil];
}

+(void)movementAnimation:(UIButton *)button andHide:(BOOL)flag
{
    if(flag)  // FADE IN
    {
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 0;
        } completion: ^(BOOL finished) {
            button.hidden = finished;
        }];
    }
    else
    {
        button.alpha = 0;  // FADE OUT
        button.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 1;
        }];
    }
}


+(void)displayToastWithMessage:(NSString *)toastMessage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {

        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel * toastView = [[UILabel alloc] init];
        [toastView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        toastView.text = toastMessage;
        [toastView setTextColor:[ALApplozicSettings getColorForToastText]];
        toastView.backgroundColor = [ALApplozicSettings getColorForToastBackground];
        toastView.textAlignment = NSTextAlignmentCenter;
        [toastView setNumberOfLines:2];
        CGFloat width =  keyWindow.frame.size.width - 60;
        toastView.frame = CGRectMake(0, 0, width, 80);
        toastView.layer.cornerRadius = toastView.frame.size.height/2;
        toastView.layer.masksToBounds = YES;
        toastView.center = keyWindow.center;

        [keyWindow addSubview:toastView];

        [UIView animateWithDuration: 3.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
            toastView.alpha = 0.0;
        }
                         completion: ^(BOOL finished) {
            [toastView removeFromSuperview];
        }
         ];
    }];
}

+(UIView *)setStatusBarStyle
{
    UIApplication * app = [UIApplication sharedApplication];
    CGFloat height = app.statusBarFrame.size.height;
    CGFloat width = app.statusBarFrame.size.width;
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -height, width, height)];
    statusBarView.backgroundColor = [ALApplozicSettings getStatusBarBGColor];
    return statusBarView;
}


+(UIImage *)getNormalizedImage:(UIImage *)rawImage
{
    if(rawImage.imageOrientation == UIImageOrientationUp)
        return rawImage;

    UIGraphicsBeginImageContextWithOptions(rawImage.size, NO, rawImage.scale);
    [rawImage drawInRect:(CGRect){0, 0, rawImage.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return normalizedImage;
}

+(id)parsedALChatCostomizationPlistForKey:(NSString *)key {

    id value = nil;

    NSDictionary *values = [ALUIUtilityClass dictionary];

    if ([key isEqualToString:APPLOZIC_TOPBAR_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_TOPBAR_COLOR];
        if (color) {
            value = [ALUIUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_BACKGROUND_COLOR]) {
        NSString *color= [values valueForKey:APPLOZIC_CHAT_BACKGROUND_COLOR];
        if (color) {
            value = [ALUIUtilityClass colorWithHexString:color];
        }
    }else if ([key isEqualToString:APPLOZIC_CHAT_FONTNAME]) {

        value = [values valueForKey:APPLOZIC_CHAT_FONTNAME];
    }else if ([key isEqualToString:APPLOGIC_TOPBAR_TITLE_COLOR]){
        NSString *color = [values valueForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
        if (color) {
            value = [ALUIUtilityClass colorWithHexString:color];
        }
    }
    return value;
}

+ (NSDictionary *)dictionary {
    static NSDictionary *parsedDict = nil;
    if (parsedDict == nil) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ALChatCostomization" ofType:@"plist"];
        parsedDict=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return parsedDict;
}

+(void)showAlertMessage:(NSString *)text andTitle:(NSString *)title
{

    UIAlertController * uiAlertController = [UIAlertController
                                             alertControllerWithTitle:title
                                             message:text
                                             preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK" , @"")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {

    }];

    [uiAlertController addAction:okButton];
    ALPushAssist *pushAssist = [[ALPushAssist alloc]init];
    [pushAssist.topViewController.navigationController presentViewController:uiAlertController animated:YES completion:nil];


}

+(UIImage *)getImageFromFilePath:(NSString *)filePath{

    UIImage *image;
    if (filePath != NULL)
    {
        NSURL *documentDirectory =  [ALUtilityClass getApplicationDirectoryWithFilePath:filePath];
        NSString *filePath = documentDirectory.path;
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            image =  [self getImageFromNSURL:documentDirectory];
        }else{
            NSURL *appGroupDirectory =  [ALUtilityClass getAppsGroupDirectoryWithFilePath:filePath];
            if(appGroupDirectory){
                image =   [self getImageFromNSURL:appGroupDirectory];
            }
        }
    }
    return image;

}

+(UIImage*)getImageFromNSURL:(NSURL *)url{
    UIImage *image;
    NSString * pathExtenion = url.pathExtension;
    if(pathExtenion != nil && [pathExtenion isEqualToString:@"gif"]){
        image  = [UIImage animatedImageWithAnimatedGIFURL:url];
    }else{
        image =   [[UIImage alloc] initWithContentsOfFile:url.path];
    }
    return image;
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *colorString = [[hex stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    NSString *cString = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(UIImage *)setVideoThumbnail:(NSString *)videoFilePATH
{
    NSURL *url = [NSURL fileURLWithPath:videoFilePATH];
    UIImage * processThumbnail = [self subProcessThumbnail:url];
    return processThumbnail;
}

+(UIImage *)subProcessThumbnail:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage * thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return thumbnail;
}


+(void)subVideoImage:(NSURL *)url  withCompletion:(void (^)(UIImage *image)) completion{

    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);

    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){

        if (result != AVAssetImageGeneratorSucceeded) {
            ALSLog(ALLoggerSeverityError, @"couldn't generate thumbnail, error:%@", error);
        }

        completion([UIImage imageWithCGImage:im]);
    };

    CGSize maxSize = CGSizeMake(128, 128);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}


+(void)permissionPopUpWithMessage:(NSString *)msgText andViewController:(UIViewController *)viewController
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"applicationSettings", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Application Settings" , @"")    message:msgText
                                                                       preferredStyle:UIAlertControllerStyleAlert];

    [ALUIUtilityClass setAlertControllerFrame:alertController andViewController:viewController];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel" , @"")  style:UIAlertActionStyleCancel handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringWithDefaultValue(@"settings", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Settings" , @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [ALUIUtilityClass openApplicationSettings];
    }]];

    [viewController presentViewController:alertController animated:YES completion:nil];
}

// FOR IPAD DEVICES
+(void)setAlertControllerFrame:(UIAlertController *)alertController andViewController:(UIViewController *)viewController
{
    if(IS_IPAD)
    {
        alertController.popoverPresentationController.sourceView = viewController.view;
        CGSize size = viewController.view.bounds.size;
        CGRect frame = CGRectMake((size.width/2.0), (size.height/2.0), 1.0, 1.0); // (x, y, popup point X, popup point Y);
        alertController.popoverPresentationController.sourceRect = frame;
        [alertController.popoverPresentationController setPermittedArrowDirections:0]; // HIDING POPUP ARROW
    }
}

+(NSString *)getNameAlphabets:(NSString *)actualName
{
    NSString *alpha = @"";

    NSRange whiteSpaceRange = [actualName rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound)
    {
        NSArray *listNames = [actualName componentsSeparatedByString:@" "];
        NSString *firstLetter = [[listNames[0] substringToIndex:1] uppercaseString];
        NSString *lastLetter = [[listNames[1] substringToIndex:1] uppercaseString];
        alpha = [[firstLetter stringByAppendingString: lastLetter] uppercaseString];
    }
    else
    {
        NSString *firstLetter = [actualName substringToIndex:1];
        alpha = [firstLetter uppercaseString];
    }
    return alpha;
}

+(void)openApplicationSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}

@end
