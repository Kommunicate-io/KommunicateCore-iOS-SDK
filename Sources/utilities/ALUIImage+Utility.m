//
//  UIImage+Utility.m
//  ChatApp
//
//  Created by shaik riyaz on 22/08/15.
//  Copyright (c) 2015 kommunicate. All rights reserved.
//

#import "KMCoreSettings.h"
#import "ALUIImage+Utility.h"

#define  DEFAULT_MAX_FILE_UPLOAD_SIZE 25

@implementation UIImage (Utility)

- (double)getImageSizeInMb {
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    return (imageData.length/1024.0)/1024.0;
}

- (UIImage *)getCompressedImageLessThanSize:(double)sizeInMb {
    
    UIImage *originalImage = self;
    
    NSData *imageData = nil;
    
    int numberOfAttempts = 0;
    
    while (self.getImageSizeInMb > sizeInMb && numberOfAttempts < 5) {
        
        numberOfAttempts = numberOfAttempts + 1;
        
        imageData = UIImageJPEGRepresentation(self,0.9);
        
        originalImage = [UIImage imageWithData:imageData];
    }
    return originalImage;
}

- (NSData *)getCompressedImageData {
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = [KMCoreSettings getMaxCompressionFactor];
    NSInteger maxSize = ([KMCoreSettings getMaxImageSizeForUploadInMB] == 0) ? DEFAULT_MAX_FILE_UPLOAD_SIZE : [KMCoreSettings getMaxImageSizeForUploadInMB];
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    
    while (((imageData.length/1024.0)/1024.0) > maxSize & compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(self, compression);
        
    }
    return imageData;
}


@end
