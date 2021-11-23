//
//  ALJWT.m
//  ApplozicCore
//
//  Created by apple on 12/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALJWT.h"
#import "ALJWTClaim.h"

@implementation ALJWT

-(instancetype) initWithJWTString:(NSString *) jwt {
    NSArray * parts = [jwt componentsSeparatedByString:@"."];
    if (parts.count == 3) {
        self.header = [self decodeJWTPart:parts[0]];
        self.body = [self decodeJWTPart:parts[1]];
        self.signature = parts[2];
        self.string = jwt;
    } else {
        NSException* invalidPartException = [NSException
                                             exceptionWithName:NSGenericException
                                             reason:[NSString stringWithFormat:@"Malformed jwt token %@ has %lu parts when it should have 3 parts ",jwt, (unsigned long)parts.count]
                                             userInfo:nil];

        @throw invalidPartException;
    }

    return self;
}

@synthesize audience;

@synthesize body;

@synthesize expired;

@synthesize expiresAt;

@synthesize header;

@synthesize identifier;

@synthesize issuedAt;

@synthesize issuer;

@synthesize notBefore;

@synthesize signature;

@synthesize string;

@synthesize subject;

- (NSDate *)expiresAt {
    return [self claimWithName:@"exp"].date;
}

- (NSString *)issuer {
    return [self claimWithName:@"iss"].string;
}

- (NSString *)subject {
    return [self claimWithName:@"sub"].string;
}

- (NSMutableArray *)audience {
    return [self claimWithName:@"aud"].array;
}

- (NSDate *)issuedAt {
    return [self claimWithName:@"iat"].date;
}

- (NSDate *)notBefore {
    return [self claimWithName:@"nbf"].date;
}

- (NSString *)identifier {
    return [self claimWithName:@"jti"].string;
}

- (BOOL)expired {
    NSDate *date = self.expiresAt;
    if (date) {
        return ([date compare:[NSDate date]] != NSOrderedDescending);
    }
    return NO;
}

-(NSMutableDictionary <NSString *, id>*) decodeJWTPart:(NSString *)valueString {

    NSData *bodyData = [self base64UrlDecode:valueString];
    if (!bodyData) {
        NSException* invalidBase64UrlException = [NSException
                                                  exceptionWithName:NSGenericException
                                                  reason:[NSString stringWithFormat:@" Malformed jwt token, failed to decode base64Url value : %@" , valueString]
                                                  userInfo:nil];

        @throw invalidBase64UrlException;
        return nil;
    }

    if (bodyData) {
        NSError *error;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:bodyData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];

        if (!error) {
            return [[NSMutableDictionary alloc] initWithDictionary:payload];
        } else {
            NSException* jsonException = [NSException
                                          exceptionWithName:NSGenericException
                                          reason:[NSString stringWithFormat:@" Malformed jwt token, failed to parse JSON value from base64Url : %@" , valueString]
                                          userInfo:nil];
            @throw jsonException;
            return nil;
        }
    }
    return nil;
}

-(NSData *)base64UrlDecode:(NSString *)valueString {

    NSString *base64 = [[valueString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"];

    double length = (double)[base64 lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    double requiredLength = 4 * ceil(length/4.0);
    double paddingLength = requiredLength - length;

    if (paddingLength > 0 ) {
        NSString * padding = [@"" stringByPaddingToLength:(NSInteger)(paddingLength) withString:@"=" startingAtIndex:0];
        base64 = [base64  stringByAppendingString:padding];
    }

    return [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
}


-(ALJWTClaim *) claimWithName:(NSString *)name {
    id value = self.body[name];
    return [[ALJWTClaim alloc] initWithValue:value];
}

+ (ALJWT * _Nullable)decodeWithJwt:(NSString *)jwtValue
                                error:(NSError * *)error {

    @try {
        ALJWT *jWTObj = [[ALJWT alloc] initWithJWTString:jwtValue];
        return jWTObj;
    } @catch (NSException *exception) {
        NSString *exceptionMessage =  exception.reason;
        *error = [NSError errorWithDomain:@"Applozic"
                                     code:1
                                 userInfo:@{NSLocalizedDescriptionKey : exceptionMessage}];
    }
    return nil;
}

@end
