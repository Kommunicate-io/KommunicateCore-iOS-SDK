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
#import "ALLogger.h"

static NSString *const REGISTER_USER_STRING = @"rest/ws/register/client";

@implementation ALRequestHandler

+ (NSMutableURLRequest *)createGETRequestWithUrlString:(NSString *)urlString
                                           paramString:(NSString *)paramString {
    return [self createGETRequestWithUrlString:urlString
                                   paramString:paramString
                                      ofUserId:nil];
}

+ (NSMutableURLRequest *)createGETRequestWithUrlString:(NSString *)urlString
                                           paramString:(NSString *)paramString
                                              ofUserId:(NSString *)userId {

    NSMutableURLRequest *requestGetURL = [[NSMutableURLRequest alloc] init];
    NSURL *requestURL = nil;
    if (paramString != nil) {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
    } else {
        requestURL = [NSURL URLWithString:urlString];
    }
    ALSLog(ALLoggerSeverityInfo, @"GET_URL :: %@", requestURL);
    [requestGetURL setURL:requestURL];
    [requestGetURL setTimeoutInterval:600];
    [requestGetURL setHTTPMethod:@"GET"];
    [self addGlobalHeader:requestGetURL ofUserId:userId];
    return requestGetURL;
}

+ (NSMutableURLRequest *)createPOSTRequestWithUrlString:(NSString *)urlString
                                            paramString:(NSString *)paramString {
    return [self createPOSTRequestWithUrlString:urlString
                                    paramString:paramString
                                       ofUserId:nil];
}

+ (NSMutableURLRequest *)createPOSTRequestWithUrlString:(NSString *)urlString
                                            paramString:(NSString *)paramString
                                               ofUserId:(NSString *)userId {

    NSMutableURLRequest *postRequestURL = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [postRequestURL setTimeoutInterval:600];
    [postRequestURL setHTTPMethod:@"POST"];

    if (paramString != nil) {
        NSData *postData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        if([ALUserDefaultsHandler getEncryptionKey] && ![urlString hasSuffix:REGISTER_USER_STRING] && ![urlString hasSuffix:@"rest/ws/register/update"]) {
            NSData *encryptedData = [postData AES128EncryptedDataWithKey:[ALUserDefaultsHandler getEncryptionKey]];
            NSData *base64Encoded = [encryptedData base64EncodedDataWithOptions:0];
            postData = base64Encoded;
        }
        [postRequestURL setHTTPBody:postData];
        [postRequestURL setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
    }
    ALSLog(ALLoggerSeverityInfo, @"POST_URL :: %@", urlString);
    [self addGlobalHeader:postRequestURL ofUserId:userId];
    return postRequestURL;
}

+ (NSMutableURLRequest *)createGETRequestWithUrlStringWithoutHeader:(NSString *)urlString
                                                        paramString:(NSString *)paramString {
    NSMutableURLRequest *requestGetURL = [[NSMutableURLRequest alloc] init];
    NSURL *requestURL = nil;
    if (paramString != nil) {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
    } else {
        requestURL = [NSURL URLWithString:urlString];
    }
    ALSLog(ALLoggerSeverityInfo, @"GET_URL :: %@", requestURL);
    [requestGetURL setURL:requestURL];
    [requestGetURL setTimeoutInterval:600];
    [requestGetURL setHTTPMethod:@"GET"];
    return requestGetURL;
}

+ (NSMutableURLRequest *)createPatchRequestWithUrlString:(NSString *)urlString
                                             paramString:(NSString *)paramString {
    NSMutableURLRequest *patchURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    NSURL *theUrl = nil;
    if (paramString != nil) {
        theUrl =
        [NSURL URLWithString: [NSString stringWithFormat:@"%@?%@", urlString, paramString]];
    } else {
        theUrl = [NSURL URLWithString: urlString];
    }
    [patchURLRequest setURL:theUrl];
    [patchURLRequest setTimeoutInterval:600];
    [patchURLRequest setHTTPMethod:@"PATCH"];
    [self addGlobalHeader:patchURLRequest ofUserId:nil];
    ALSLog(ALLoggerSeverityInfo, @"PATCH_URL :: %@", theUrl);
    return patchURLRequest;
}

+ (void)addGlobalHeader:(NSMutableURLRequest *)request
               ofUserId:(NSString *)userId {
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *appMoudle = [ALUserDefaultsHandler getAppModuleName];
    if (appMoudle) {
        [request addValue:appMoudle forHTTPHeaderField:@"App-Module-Name"];
    }
    
    NSString *deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];
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

