//
//  ALUtilityClass.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALUtilityClass.h"
#import "ALConstant.h"
#import "ALAppLocalNotifications.h"
#import "TSMessage.h"
#import "TSMessageView.h"
#import "ALPushAssist.h"
#import "ALAppLocalNotifications.h"
#import "ALUserDefaultsHandler.h"
#import "ALContactDBService.h"
#import "ALContact.h"
#import "ALLogger.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

NSString * const AL_DEFAULT_APP_GROUP = @"group.com.applozic.share";
NSString * const AL_APP_GROUPS_ACCESS_KEY = @"ALAppGroupsKey";

@implementation ALUtilityClass

+ (NSString *)formatTimestamp:(NSTimeInterval)timeInterval toFormat:(NSString *)formatString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
    [formatter setDateFormat:formatString];
    formatter.timeZone = [NSTimeZone localTimeZone];
    
    NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];

    return dateString;
}

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary {

    NSString *jsonString = nil;
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        ALSLog(ALLoggerSeverityError, @"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

+ (BOOL)isToday:(NSDate *)todayDate {
    
    BOOL result = NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:todayDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if ([today isEqualToDate:otherDate]) {
        //do stuff
        result = YES;
    }
    return result;
}

+ (NSString *)fileMIMEType:(NSString *)filePath {
    NSString *mimeType = nil;
    if (filePath) {
        NSString *fileExtension = [filePath pathExtension];
        NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)uti, kUTTagClassMIMEType);
    }
    return mimeType;
}

+ (CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize {
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    CGSize stringSize = frame.size;

    return stringSize;
}


+ (void)thirdDisplayNotificationTS:(NSString *)toastMessage
                   andForContactId:(NSString *)contactId
                       withGroupId:(NSNumber *)groupID
                 completionHandler:(void (^)(BOOL))handler {

    if ([ALUserDefaultsHandler getNotificationMode] == AL_NOTIFICATION_DISABLE) {
        return;
    }
    //3rd Party View is Opened.........
    ALContact *contact = nil;
    ALContactDBService *contactDatabase = [[ALContactDBService alloc] init];
    contact = [contactDatabase loadContactByKey:@"userId" value:contactId];

    ALChannel *channel = nil;
    ALChannelDBService *channelDatabaseService = [[ALChannelDBService alloc] init];

    NSString *title;
    if (groupID != nil) {
        channel = [channelDatabaseService loadChannelByKey:groupID];
        title = channel.name;
    } else {
        title = contact.getDisplayName;
    }

    ALPushAssist *pushAssist = [[ALPushAssist alloc] init];
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];

    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];

    [TSMessage showNotificationInViewController:pushAssist.topViewController
                                          title:title
                                       subtitle:toastMessage
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:^(void){

        handler(YES);
    }
                                    buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
    
}

+ (NSString *)getFileNameWithCurrentTimeStamp {
    NSString *resultString = [@"IMG-" stringByAppendingString: @([[NSDate date] timeIntervalSince1970]).stringValue];
    return resultString;
}

- (void)getExactDate:(NSNumber *)dateValue {
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970: [dateValue doubleValue]/1000];
    
    NSDate *currentDate = [[NSDate alloc] init];
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyy"];
    
    NSString *todayDate = [format stringFromDate:currentDate];
    NSString *yesterdayDate = [format stringFromDate:yesterday];
    NSString *serverDate = [format stringFromDate:date];
    self.msgdate = serverDate;
    
    if ([serverDate isEqualToString:todayDate]) {
        self.msgdate = NSLocalizedStringWithDefaultValue(@"todayMsgViewText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"today" , @"");
    } else if ([serverDate isEqualToString:yesterdayDate]) {
        self.msgdate = NSLocalizedStringWithDefaultValue(@"yesterdayMsgViewText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"yesterday" , @"");
    }
    
    [format setDateFormat:@"hh:mm a"];
    [format setAMSymbol:@"am"];
    [format setPMSymbol:@"pm"];
    
    self.msgtime = [format stringFromDate:date];
}

+ (BOOL)isThisDebugBuild {
    BOOL debug;
#ifdef DEBUG
    ALSLog(ALLoggerSeverityInfo, @"DEBUG_MODE");
    debug = YES;
#else
    ALSLog(ALLoggerSeverityInfo, @"RELEASE_MODE");
    debug = NO;
#endif
    return debug;
}

+ (NSString *)getDevieUUID {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return uuid;
}

+ (BOOL)checkDeviceKeyString:(NSString *)string {
    NSArray *array = [string componentsSeparatedByString:@":"];
    NSString *deviceString = (NSString *)[array firstObject];
    return [deviceString isEqualToString:[ALUtilityClass getDevieUUID]];
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    NSString *stringTime = @"";
    
    if (hours) {
        stringTime = [NSString stringWithFormat:@"%ld Hr %02ld Min %02ld Sec", (long)hours, (long)minutes, (long)seconds];
    } else if (minutes) {
        stringTime = [NSString stringWithFormat:@"%ld Min %ld Sec", (long)minutes, (long)seconds];
    } else {
        stringTime = [NSString stringWithFormat:@"%ld Sec", (long)seconds];
    }
    
    return stringTime;
}

+ (NSString *)getLocationURL:(ALMessage *)alMessage {
    NSString *latLongArgument = [self formatLocationJson:alMessage];
    NSString *finalURl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%@&key=%@",
                          latLongArgument,latLongArgument,[ALUserDefaultsHandler getGoogleMapAPIKey]];
    return finalURl;
}

+ (NSString *)getLocationURL:(ALMessage *)alMessage size:(CGRect)withSize {

    NSString *latLongArgument = [self formatLocationJson:alMessage];

    NSString *staticMapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?format=png&markers=%@&key=%@&zoom=13&size=%dx%d&scale=1",latLongArgument,
                              [ALUserDefaultsHandler getGoogleMapAPIKey], 2*(int)withSize.size.width, 2*(int)withSize.size.height];
    
    return staticMapURL;
}

+ (NSString *)formatLocationJson:(ALMessage *)locationALMessage {
    NSError *error;
    NSData *objectData = [locationALMessage.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonStringDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&error];
    
    NSArray *latLog = [[NSArray alloc] initWithObjects:[jsonStringDictionary valueForKey:@"lat"],[jsonStringDictionary valueForKey:@"lon"], nil];
    
    if (!latLog.count) {
        return [self processMapURL:locationALMessage];
    }
    
    NSString *latLongArgument = [NSString stringWithFormat:@"%@,%@", latLog[0], latLog[1]];
    return latLongArgument;
}

+ (NSString *)processMapURL:(ALMessage *)message {
    NSArray *arrayOfURL = [message.message componentsSeparatedByString:@"="];
    NSString *coordinate = (NSString *)[arrayOfURL lastObject];
    return coordinate;
}

+ (NSString *)getFileExtensionWithFileName:(NSString *)fileName {
    NSArray *componentsArray = [fileName componentsSeparatedByString:@"."];
    return componentsArray.count  > 0 ? [componentsArray lastObject]:nil;
}

+ (NSURL *)getDocumentDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)getAppsGroupDirectory {

    NSURL *urlForDocumentsDirectory;
    NSString *shareExtentionGroupName = [ALApplozicSettings getShareExtentionGroup];
    if (shareExtentionGroupName) {
        urlForDocumentsDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:shareExtentionGroupName];
    }
    return urlForDocumentsDirectory;
}

+ (NSURL *)getApplicationDirectoryWithFilePath:(NSString *)path {

    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    directory = [directory URLByAppendingPathComponent:path];
    return directory;
}

+ (NSURL *)getAppsGroupDirectoryWithFilePath:(NSString *)path {

    NSURL *urlForDocumentsDirectory = [ALUtilityClass getAppsGroupDirectory];
    if (urlForDocumentsDirectory) {
        urlForDocumentsDirectory = [urlForDocumentsDirectory URLByAppendingPathComponent:path];
    }
    return urlForDocumentsDirectory;
}

+ (NSData *)compressImage:(NSData *)data {
    float compressRatio;
    switch (data.length) {
        case 0 ...  10 * 1024 * 1024:
            return data;
        case (10 * 1024 * 1024 + 1) ... 50 * 1024 * 1024:
            compressRatio = 0.5; //50%
            break;
        default:
            compressRatio = 0.1; //10%;
    }
    UIImage *image = [[UIImage alloc] initWithData: data];
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
    float imgRatio = actualWidth / actualHeight;
    float maxRatio = maxWidth / maxHeight;

    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if (imgRatio < maxRatio) {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        } else if(imgRatio > maxRatio) {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        } else {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }

    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressRatio);
    UIGraphicsEndImageContext();
    return imageData;
}

+ (NSURL *)moveFileToDocumentsWithFileURL:(NSURL *)url {

    NSString *fileName = url.lastPathComponent;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%f_%@",[[NSDate date] timeIntervalSince1970] * 1000, fileName];
    NSURL *documentFileURL = [ALUtilityClass getApplicationDirectoryWithFilePath:uniqueFileName];
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;

        if ([fileManager fileExistsAtPath:documentFileURL.path]) {
            [fileManager removeItemAtURL:documentFileURL error:&error];
        }

        if (error) {
            return nil;
        }

        [fileManager moveItemAtPath:url.path toPath:documentFileURL.path error:&error];

        if (error) {
            return nil;
        }
    }  @catch (NSException *exception) {
        return nil;
    }
    return documentFileURL;
}

+ (NSString *)getPathFromDirectory:(NSString *)imageFilePath {

    NSURL *documentDirectory = [ALUtilityClass getApplicationDirectoryWithFilePath:imageFilePath];
    NSString *filePath = documentDirectory.path;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *documentURL = [ALUtilityClass getAppsGroupDirectoryWithFilePath:imageFilePath];
        if (documentURL != nil) {
            filePath = documentURL.path;
        }
    }
    return filePath;
}

+ (NSString *)saveImageToDocDirectory:(UIImage *)image {
    NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *timeStamp = [NSString stringWithFormat:@"IMG-%f.jpeg",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString *filePath = [documentDirectoryPath stringByAppendingPathComponent:timeStamp];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}

+ (UIImage *)setVideoThumbnail:(NSString *)videoFilePATH {
    NSURL *url = [NSURL fileURLWithPath:videoFilePATH];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return thumbnail;
}

+ (NSString *)getAppGroupsName {
    NSString *appGroupsId = [[NSBundle mainBundle] objectForInfoDictionaryKey:AL_APP_GROUPS_ACCESS_KEY];
    if (appGroupsId
        && appGroupsId.length > 0) {
        return appGroupsId;
    }
    return AL_DEFAULT_APP_GROUP;
}

+ (NSInteger)randomNumberBetween:(NSInteger)minimum maxNumber:(NSInteger)maximum {
    return minimum + arc4random_uniform((uint32_t)(maximum - minimum + 1));
}

/// get the bundle if its SWIFT_PACKAGE will use the runtime bundle of SPM else will use the bundle from class
+ (NSBundle*)getBundle {
#if SWIFT_PACKAGE
    return SWIFTPM_MODULE_BUNDLE;
#else
    return [NSBundle bundleForClass:[ALUtilityClass class]];
#endif
}

@end
