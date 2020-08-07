//
//  ALAuthClientService.m
//  Applozic
//
//  Created by Sunil on 15/06/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import "ALAuthClientService.h"
#import "ALResponseHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"

@implementation ALAuthClientService

static NSString *const USERID = @"userId";
static NSString *const APPLICATIONID = @"applicationId";
static NSString *const AL_AUTH_TOKEN_REFRESH_URL = @"/rest/ws/register/refresh/token";

-(void)refreshAuthTokenForLoginUserWithCompletion:(void (^)(ALAPIResponse *apiResponse, NSError *error))completion {

    if (![ALUserDefaultsHandler isLoggedIn] || ![ALUserDefaultsHandler getApplicationKey]) {
        NSError * reponseError = [NSError errorWithDomain:@"Applozic" code:1
                                                 userInfo:[NSDictionary dictionaryWithObject:@"User is not logged in or applicationId is nil"
                                                                                      forKey:NSLocalizedDescriptionKey]];
        completion(nil, reponseError);
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:[ALUserDefaultsHandler getUserId] forKey:USERID];
    [dictionary setObject:[ALUserDefaultsHandler getApplicationKey] forKey:APPLICATIONID];

    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *theParamString = [[NSString alloc] initWithData:postdata encoding: NSUTF8StringEncoding];

    NSString * theUrlString = [NSString stringWithFormat:@"%@%@", KBASE_URL, AL_AUTH_TOKEN_REFRESH_URL];

    NSMutableURLRequest * theRequest = [self createPostRequestWithURL:theUrlString withParamString:theParamString];

    [ALResponseHandler processRequest:theRequest andTag:@"REFRESH_AUTH_TOKEN_OF_USER" WithCompletionHandler:^(id theJson, NSError *theError) {
        if(theError){
            ALSLog(ALLoggerSeverityError, @"Error in refreshing a auth token for user  : %@", theError);
            completion(nil, theError);
            return;
        }

        NSString *responseString  = (NSString *)theJson;
        ALSLog(ALLoggerSeverityInfo, @"RESPONSE_REFRESH_AUTH_TOKEN_OF_USER : %@",responseString);

        ALAPIResponse *apiResponse = [[ALAPIResponse alloc] initWithJSONString:responseString];

        if([apiResponse.status isEqualToString:@"error"]) {
            NSError * reponseError =
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

    NSMutableURLRequest * theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [theRequest setTimeoutInterval:600];
    [theRequest setHTTPMethod:@"POST"];

    if (paramString != nil) {
        NSData * thePostData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [theRequest setHTTPBody:thePostData];
        [theRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[thePostData length]] forHTTPHeaderField:@"Content-Length"];
    }
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString * appMoudle = [ALUserDefaultsHandler getAppModuleName];
    if (appMoudle) {
        [theRequest addValue:appMoudle forHTTPHeaderField:@"App-Module-Name"];
    }
    NSString * deviceKeyString = [ALUserDefaultsHandler getDeviceKeyString];

    if (deviceKeyString) {
        [theRequest addValue:deviceKeyString forHTTPHeaderField:@"Device-Key"];
    }
    [theRequest addValue:[ALUserDefaultsHandler getApplicationKey] forHTTPHeaderField:@"Application-Key"];
    return theRequest;
}

@end
