//
//  ALImageActivity.m
//  Applozic
//
//  Created by Divjyot Singh on 26/07/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALImageActivity.h"
#import "ALUtilityClass.h"
#import "ALUIUtilityClass.h"

@implementation ALImageActivity


- (NSString *)activityType {
    return @"com.applozic.framework";
}

- (NSString *)activityTitle {
    return @"Forward Image";
}

- (UIImage *)activityImage {

    return [ALUIUtilityClass getImageFromFramworkBundle:@"forwardActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    ALSLog(ALLoggerSeverityInfo, @"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    ALSLog(ALLoggerSeverityInfo, @"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController {
    ALSLog(ALLoggerSeverityInfo, @"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity {
    //TODO: Open Recent Chats...
    ALSLog(ALLoggerSeverityInfo, @"TODO: Open Recent Chats");

    [self.imageActivityDelegate showContactsToShareImage];
}

@end
