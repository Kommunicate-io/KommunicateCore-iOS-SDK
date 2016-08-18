//
//  ALImagePickerHandler.m
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALImagePickerHandler.h"
#import "UIImage+Utility.h"

@implementation ALImagePickerHandler


+(NSString *) saveImageToDocDirectory:(UIImage *) image
{
    NSString * docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * timestamp = [NSString stringWithFormat:@"IMG-%f.jpeg",[[NSDate date] timeIntervalSince1970] * 1000];
    NSString * filePath = [docDirPath stringByAppendingPathComponent:timestamp];
    NSData * imageData = [image getCompressedImageData];
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
}

+(NSString *) saveVideoToDocDirectory:(NSURL *)videoURL
{
    NSData * videoData = [NSData dataWithContentsOfURL:videoURL];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * tempPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/VID-%f.mp4",[[NSDate date] timeIntervalSince1970] * 1000]];
    [videoData writeToFile:tempPath atomically:YES];

    return tempPath;
}



@end
