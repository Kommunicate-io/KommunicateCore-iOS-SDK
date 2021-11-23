//
//  ALRequestHandler.h
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALRequestHandler : NSObject

+ (NSMutableURLRequest *)createGETRequestWithUrlString:(NSString *)urlString
                                           paramString:(NSString *)paramString;

+ (NSMutableURLRequest *)createGETRequestWithUrlString:(NSString *)urlString
                                           paramString:(NSString *)paramString
                                              ofUserId:(NSString *)userId;

+ (NSMutableURLRequest *)createPOSTRequestWithUrlString:(NSString *)urlString
                                            paramString:(NSString *)paramString
                                               ofUserId:(NSString *)userId;

+ (NSMutableURLRequest *)createPOSTRequestWithUrlString:(NSString *)urlString
                                            paramString:(NSString *)paramString;

+ (NSMutableURLRequest *)createGETRequestWithUrlStringWithoutHeader:(NSString *)urlString
                                                        paramString:(NSString *)paramString;

+ (NSMutableURLRequest *)createPatchRequestWithUrlString:(NSString *)urlString
                                             paramString:(NSString *)paramString;

@end
