//
//  ALAuthClientService.m
//  Applozic
//
//  Created by Sunil on 15/06/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAuthClientService.h"
#import "ALResponseHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"
#import "ALLogger.h"
#import "NSData+AES.h"

@implementation ALAuthClientService

static NSString *const USERID = @"userId";
static NSString *const APPLICATIONID = @"applicationId";
static NSString *const AL_AUTH_TOKEN_REFRESH_URL = @"/rest/ws/register/refresh/token";
static NSString *const message_SomethingWentWrong = @"SomethingWentWrong";

-(void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {

    if (![ALUserDefaultsHandler isLoggedIn] || ![ALUserDefaultsHandler getApplicationKey]) {
        NSError *reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                userInfo:[NSDictionary dictionaryWithObject:@"User is not logged in or applicationId is nil"
                                                                                     forKey:NSLocalizedDescriptionKey]];
        completion(nil, reponseError);
        return;
    }

    NSMutableDictionary *JSONDictionary = [NSMutableDictionary new];
    [JSONDictionary setObject:[ALUserDefaultsHandler getUserId] forKey:USERID];
    [JSONDictionary setObject:[ALUserDefaultsHandler getApplicationKey] forKey:APPLICATIONID];

    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:0 error:&error];
    NSString *refreshTokenParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];

    NSString *refreshTokenURLString = [NSString stringWithFormat:@"%@%@", KBASE_URL, AL_AUTH_TOKEN_REFRESH_URL];

    NSMutableURLRequest *refreshTokenRequest = [self createPostRequestWithURL:refreshTokenURLString withParamString:refreshTokenParamString];

    [self processRequest:refreshTokenRequest andTag:@"REFRESH_AUTH_TOKEN_OF_USER" WithCompletionHandler:^(id theJson, NSError *theError) {
        if (theError) {
            ALSLog(ALLoggerSeverityError, @"Error in refreshing a auth token for user  : %@", theError);
            completion(nil, theError);
            return;
        }

        NSString *responseString = (NSString *)theJson;
        ALSLog(ALLoggerSeverityInfo, @"RESPONSE_REFRESH_AUTH_TOKEN_OF_USER : %@",responseString);

        ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:responseString];

        if ([apiResponse.status isEqualToString:AL_RESPONSE_ERROR]) {
            NSError *reponseError =
            [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:@"ERROR IN JSON FOR REFRESH AUTH TOKEN"
                                                                                             forKey:NSLocalizedDescriptionKey]];
            completion(nil, reponseError);
            return;
        }
        completion(apiResponse, nil);
    }];
}

-(NSMutableURLRequest *)createPostRequestWithURL:(NSString *)urlString
                                 withParamString:(NSString *)paramString {

    NSMutableURLRequest *postURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [postURLRequest setTimeoutInterval:600];
    [postURLRequest setHTTPMethod:@"POST"];

    if (paramString != nil) {
        NSData *postRequestData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [postURLRequest setHTTPBody:postRequestData];
        [postURLRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postRequestData length]] forHTTPHeaderField:@"Content-Length"];
    }
    [postURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *appMoudle = [ALUserDefaultsHandler getAppModuleName];
    if (appMoudle) {
        [postURLRequest addValue:appMoudle forHTTPHeaderField:@"App-Module-Name"];
    }
    NSString *deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];

    if (deviceKeyString) {
        [postURLRequest addValue:deviceKeyString forHTTPHeaderField:@"Device-Key"];
    }
    [postURLRequest addValue:[ALUserDefaultsHandler getApplicationKey] forHTTPHeaderField:@"Application-Key"];
    return postURLRequest;
}

- (void)processRequest:(NSMutableURLRequest *)theRequest
                andTag:(NSString *)tag
 WithCompletionHandler:(void (^)(id, NSError *))reponseCompletion {

    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {

        NSHTTPURLResponse *theHttpResponse = (NSHTTPURLResponse *)response;

        if (connectionError.code == kCFURLErrorUserCancelledAuthentication) {
            NSString *failingURL = connectionError.userInfo[@"NSErrorFailingURLStringKey"] != nil ? connectionError.userInfo[@"NSErrorFailingURLStringKey"]:@"Empty";
            ALSLog(ALLoggerSeverityError, @"Authentication error: HTTP 401 : ERROR CODE : %ld, FAILING URL: %@",  (long)connectionError.code,  failingURL);

            dispatch_async(dispatch_get_main_queue(), ^{
                reponseCompletion(nil,[self errorWithDescription:@"Authentication error: 401"]);
            });
            return;
        } else if (connectionError.code == kCFURLErrorNotConnectedToInternet) {
            NSString *failingURL = connectionError.userInfo[@"NSErrorFailingURLStringKey"] != nil ? connectionError.userInfo[@"NSErrorFailingURLStringKey"]:@"Empty";
            ALSLog(ALLoggerSeverityError, @"NO INTERNET CONNECTIVITY, ERROR CODE : %ld, FAILING URL: %@",  (long)connectionError.code, failingURL);
            dispatch_async(dispatch_get_main_queue(), ^{
                reponseCompletion(nil,[self errorWithDescription:@"No Internet connectivity"]);
            });
            return;
        } else if (connectionError) {
            ALSLog(ALLoggerSeverityError, @"ERROR_RESPONSE : %@ && ERROR:CODE : %ld ", connectionError.description, (long)connectionError.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                reponseCompletion(nil, [self errorWithDescription:connectionError.localizedDescription]);
            });
            return;
        }

        if (theHttpResponse.statusCode != 200 && theHttpResponse.statusCode != 201) {
            NSMutableString *errorString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            ALSLog(ALLoggerSeverityError, @"api error : %@ - %@",tag,errorString);
            dispatch_async(dispatch_get_main_queue(), ^{
                reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            });
            return;
        }

        if (data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            });
            ALSLog(ALLoggerSeverityError, @"api error - %@",tag);
            return;
        }

        id theJson = nil;

        // DECRYPTING DATA WITH KEY
        if ([ALUserDefaultsHandler getEncryptionKey] &&
            ![tag isEqualToString:@"CREATE ACCOUNT"] &&
            ![tag isEqualToString:@"CREATE FILE URL"] &&
            ![tag isEqualToString:@"UPDATE NOTIFICATION MODE"] &&
            ![tag isEqualToString:@"FILE DOWNLOAD URL"]) {

            NSData *base64DecodedData = [[NSData alloc] initWithBase64EncodedData:data options:0];
            NSData *theData = [base64DecodedData AES128DecryptedDataWithKey:[ALUserDefaultsHandler getEncryptionKey]];

            if (theData == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
                });
                ALSLog(ALLoggerSeverityError, @"api error - %@",tag);
                return;
            }

            if (theData.bytes) {

                NSString *dataToString = [NSString stringWithUTF8String:[theData bytes]];

                data = [dataToString dataUsingEncoding:NSUTF8StringEncoding];

            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
                });
                ALSLog(ALLoggerSeverityError, @"api error - %@",tag);
                return;
            }
        }

        if ([tag isEqualToString:@"CREATE FILE URL"] ||
            [tag isEqualToString:@"IMAGE POSTING"]) {
            theJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            /*TODO: Right now server is returning server's Error with tag <html>.
             it should be proper jason response with errocodes.
             We need to remove this check once fix will be done in server.*/

            NSError *error = [self checkForServerError:theJson];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    reponseCompletion(nil, error);
                });
                return;
            }
        } else {
            NSError *theJsonError = nil;

            theJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&theJsonError];

            if (theJsonError) {
                NSMutableString *responseString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //CHECK HTML TAG FOR ERROR
                NSError *error = [self checkForServerError:responseString];
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        reponseCompletion(nil, error);
                    });
                    return;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        reponseCompletion(responseString,nil);
                    });
                    return;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            reponseCompletion(theJson,nil);
        });
    }];
    [sessionDataTask resume];
}

- (NSError *)errorWithDescription:(NSString *)reason {
    return [NSError errorWithDomain:@"Applozic" code:1 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]];
}

- (NSError *)checkForServerError:(NSString *)response {
    if ([response hasPrefix:@"<html>"] || [response isEqualToString:[@"error" uppercaseString]]) {
        NSError *error = [NSError errorWithDomain:@"Internal Error" code:500 userInfo:nil];
        return error;
    }
    return NULL;
}

@end
