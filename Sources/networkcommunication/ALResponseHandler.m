//
//  ALResponseHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALResponseHandler.h"
#import "NSData+AES.h"
#import "ALUserDefaultsHandler.h"
#import "ALAuthService.h"
#import "ALLogger.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>
#import "ALUtilityClass.h"

// ASN.1 header for RSA 2048 public key
static const uint8_t rsa2048Asn1Header[] = {
    0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
};

@interface ALResponseHandler () <NSURLSessionDelegate>
@end

@implementation ALResponseHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupService];
    }
    return self;
}

-(void)setupService {
    self.authService = [[ALAuthService alloc] init];
}

static NSString *const message_SomethingWentWrong = @"SomethingWentWrong";

- (void)processRequest:(NSMutableURLRequest *)theRequest
                andTag:(NSString *)tag
 WithCompletionHandler:(void (^)(id, NSError *))reponseCompletion {

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];

    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {

        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;

        if (httpURLResponse.statusCode == 401) {
            //Trigger LOGOUT_UNAUTHORIZED_USER notification incase of 401 response.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUT_UNAUTHORIZED_USER"
                                                                object:nil
                                                              userInfo:nil];
        }

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

        if (httpURLResponse.statusCode != 200 && httpURLResponse.statusCode != 201) {
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


- (void)authenticateAndProcessRequest:(NSMutableURLRequest *)theRequest
                               andTag:(NSString *)tag
                WithCompletionHandler:(void (^)(id, NSError *))completion {

    [self authenticateRequest:theRequest WithCompletion:^(NSMutableURLRequest *urlRequest, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        [self processRequest:urlRequest
                      andTag:tag
       WithCompletionHandler:^(id theJson, NSError *theError) {
            completion(theJson, theError);
        }];
    }];
}

- (NSArray<NSString *> *)fetchExpectedPublicKeyHashesFromBundle:(NSBundle *)bundle {
    // Try fetching from the main bundle info dictionary
    NSDictionary *infoPlistDict = [bundle infoDictionary];
    NSArray *keys = infoPlistDict[@"KMExpectedPublicKeyHashBase64"];
    
    if (keys != nil) {
        return keys;
    }
    
    // If not found, try fetching from a specific plist file (For SPM)
    NSString *plistPath = [bundle pathForResource:@"KommunicateCore-Info" ofType:@"plist"];
    if (plistPath != nil) {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        keys = plistDict[@"KMExpectedPublicKeyHashBase64"];
        
        if (keys != nil) {
            return keys;
        }
    }

    return nil;
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {

    if (![challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        return;
    }

    if (![ALUserDefaultsHandler isKMSSLPinningEnabled]) {
        // SSL pinning is disabled, trust the server's certificate
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        return;
    }
    
    // Load the expected public key hashes from the Info.plist
    NSBundle *bundle = [ALUtilityClass getBundle];
    NSArray *kExpectedPublicKeyHashBase64 = [self fetchExpectedPublicKeyHashesFromBundle:bundle];

    
    if (!kExpectedPublicKeyHashBase64) {
        NSLog(@"Expected public key hashes not found in Info.plist.");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }
    
    // Extract the server's public key from the challenge
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    SecKeyRef serverPublicKey = SecCertificateCopyKey(serverCertificate);
    
    if (!serverPublicKey) {
        NSLog(@"Error: Unable to extract public key from certificate.");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    // Get the public key in raw byte format
    CFErrorRef error = NULL;
    NSData *serverPublicKeyData = (__bridge_transfer NSData *)SecKeyCopyExternalRepresentation(serverPublicKey, &error);
    CFRelease(serverPublicKey);
    
    if (error || !serverPublicKeyData) {
        NSLog(@"Error extracting public key: %@", error ? (__bridge NSError *)error : @"Unknown error");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    // Prepend ASN.1 header to the public key data
    NSMutableData *publicKeyWithHeader = [NSMutableData dataWithBytes:rsa2048Asn1Header length:sizeof(rsa2048Asn1Header)];
    [publicKeyWithHeader appendData:serverPublicKeyData];

    // Calculate the SHA-256 hash of the public key with ASN.1 header
    unsigned char hashedBytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(publicKeyWithHeader.bytes, (CC_LONG)publicKeyWithHeader.length, hashedBytes);
    NSData *publicKeyHash = [NSData dataWithBytes:hashedBytes length:CC_SHA256_DIGEST_LENGTH];

    // Convert public key hash to Base64
    NSString *publicKeyHashBase64 = [publicKeyHash base64EncodedStringWithOptions:0];

    // Compare with expected public key hashes
    if ([kExpectedPublicKeyHashBase64 containsObject:publicKeyHashBase64]) {
        // The hash matches, proceed with the connection
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        // The hash doesn't match, cancel the connection
        NSLog(@"Public key hash does not match. Connection canceled.");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)authenticateRequest:(NSMutableURLRequest *)request
             WithCompletion:(void (^)(NSMutableURLRequest *urlRequest, NSError *error)) completion {

    [self.authService validateAuthTokenAndRefreshWithCompletion:^(NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSMutableURLRequest *urlRequest = request;
        NSString *authToken = [ALUserDefaultsHandler getAuthToken];
        if (authToken) {
            [urlRequest addValue:[ALUserDefaultsHandler getAuthToken] forHTTPHeaderField:@"X-Authorization"];
        }
        completion(urlRequest, nil);
    }];
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

