//
//  NSString+Encode.m
//  Kommunicate
//
//  Created by Divjyot Singh on 21/04/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (Encode)

- (NSString *)urlEncodeUsingNSUTF8StringEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
@end
