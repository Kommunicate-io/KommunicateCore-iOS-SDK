//
//  ALRequestHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALRequestHandler.h"
#import "ALUtilityClass.h"
#import "ALUserDefaultsHandler.h"
#import "NSString+Encode.h"
#import "ALUser.h"
#import "NSData+AES.h"
#import "ALAuthService.h"

static NSString *const REGISTER_USER_STRING = @"rest/ws/register/client";

@implementation ALRequestHandler

+(NSMutableURLRequest *) createGETRequestWithUrlString:(NSString *) urlString
                                           paramString:(NSString *) paramString {
    return [self createGETRequestWithUrlString:urlString
                                   paramString:paramString
                                      ofUserId:nil];
}

+(NSMutableURLRequest *) createGETRequestWithUrlString:(NSString *) urlString
                                           paramString:(NSString *) paramString
                                              ofUserId:(NSString *) userId {

    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] init];
    NSURL * theUrl = nil;
    if (paramString != nil) {
        theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
    } else {
        theUrl = [NSURL URLWithString:urlString];
    }
    ALSLog(ALLoggerSeverityInfo, @"GET_URL :: %@", theUrl);
    [theRequest setURL:theUrl];
    [theRequest setTimeoutInterval:600];
    [theRequest setHTTPMethod:@"GET"];
    [self addGlobalHeader:theRequest ofUserId:userId];
    return theRequest;
}

+(NSMutableURLRequest *) createPOSTRequestWithUrlString:(NSString *) urlString
                                            paramString:(NSString *) paramString {
    return [self createPOSTRequestWithUrlString:urlString
                                    paramString:paramString
                                       ofUserId:nil];
}

+(NSMutableURLRequest *) createPOSTRequestWithUrlString:(NSString *) urlString
                                            paramString:(NSString *) paramString
                                               ofUserId:(NSString *)userId {

    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [theRequest setTimeoutInterval:600];
    [theRequest setHTTPMethod:@"POST"];

    if (paramString != nil) {
        NSData * thePostData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        if([ALUserDefaultsHandler getEncryptionKey] && ![urlString hasSuffix:REGISTER_USER_STRING] && ![urlString hasSuffix:@"rest/ws/register/update"]) {
            NSData *postData = [thePostData AES128EncryptedDataWithKey:[ALUserDefaultsHandler getEncryptionKey]];
            NSData *base64Encoded = [postData base64EncodedDataWithOptions:0];
            thePostData = base64Encoded;
        }
        [theRequest setHTTPBody:thePostData];
        [theRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[thePostData length]] forHTTPHeaderField:@"Content-Length"];
    }
    ALSLog(ALLoggerSeverityInfo, @"POST_URL :: %@", urlString);
    [self addGlobalHeader:theRequest ofUserId:userId];
    return theRequest;
}

+(NSMutableURLRequest *) createGETRequestWithUrlStringWithoutHeader:(NSString *) urlString
                                                        paramString:(NSString *) paramString {
    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] init];
    NSURL * theUrl = nil;
    if (paramString != nil) {
        theUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
    } else {
        theUrl = [NSURL URLWithString:urlString];
    }
    ALSLog(ALLoggerSeverityInfo, @"GET_URL :: %@", theUrl);
    [theRequest setURL:theUrl];
    [theRequest setTimeoutInterval:600];
    [theRequest setHTTPMethod:@"GET"];
    return theRequest;
}

+(NSMutableURLRequest *) createPatchRequestWithUrlString:(NSString *) urlString
                                             paramString:(NSString *) paramString {
    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    NSURL *theUrl = nil;
    if (paramString != nil) {
        theUrl =
        [NSURL URLWithString: [NSString stringWithFormat:@"%@?%@", urlString, paramString]];
    } else {
        theUrl = [NSURL URLWithString: urlString];
    }
    [theRequest setURL:theUrl];
    [theRequest setTimeoutInterval:600];
    [theRequest setHTTPMethod:@"PATCH"];
    [self addGlobalHeader:theRequest ofUserId:nil];
    ALSLog(ALLoggerSeverityInfo, @"PATCH_URL :: %@", theUrl);
    return theRequest;
}

+(void) addGlobalHeader:(NSMutableURLRequest*) request
               ofUserId:(NSString *)userId {
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString * appMoudle = [ALUserDefaultsHandler getAppModuleName];
    if (appMoudle) {
        [request addValue:appMoudle forHTTPHeaderField:@"App-Module-Name"];
    }
    
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
    if (deviceKeyString) {
        [request addValue:deviceKeyString forHTTPHeaderField:@"Device-Key"];
    }
    
    if (userId) {
        [request setValue:[userId urlEncodeUsingNSUTF8StringEncoding] forHTTPHeaderField:@"Of-User-Id"];
    }
    
    if ([ALUserDefaultsHandler getUserRoleType] == 8 && userId != nil) {
        NSString *product = @"true";
        [request setValue:product forHTTPHeaderField:@"Apz-Product-App"];
        [request addValue:[ALUserDefaultsHandler getApplicationKey] forHTTPHeaderField:@"Apz-AppId"];
    } else {
        [request addValue:[ALUserDefaultsHandler getApplicationKey] forHTTPHeaderField:@"Application-Key"];
    }
}


@end

