//
//  ALImagePickerHandler.m
//  ChatApp
//
//  Created by Kumar, Sawant (US - Bengaluru) on 9/23/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALImagePickerHandler.h"
#import "UIImage+Utility.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

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
//    NSData * videoData = [NSData dataWithContentsOfURL:videoURL];
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSString * tempPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/VID-%f.mp4",[[NSDate date] timeIntervalSince1970] * 1000]];
//    
//    [videoData writeToFile:tempPath atomically:YES];
    
    NSString * videoPath1 = @"";
     NSString * tempPath =@"";
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    videoPath1 =[docDir stringByAppendingString:[NSString stringWithFormat:@"/VID-%f.mov",[[NSDate date] timeIntervalSince1970] * 1000]];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [videoData writeToFile:videoPath1 atomically:NO];

    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath1] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
       tempPath  = [docDir stringByAppendingString:[NSString stringWithFormat:@"/VID-%f.mp4",[[NSDate date] timeIntervalSince1970] * 1000]];
        exportSession.outputURL = [NSURL fileURLWithPath:tempPath];
        NSLog(@"Final file = %@",tempPath);
        exportSession.outputFileType = AVFileTypeMPEG4;

        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    
                    break;
                    
                default:
                    
                    break;
                    
            }
            UISaveVideoAtPathToSavedPhotosAlbum(tempPath, self, nil, nil);
            
        }];
        
    }

    return tempPath;
}



@end
