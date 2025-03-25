//
//  NSString+Encode.h
//  Kommunicate
//
//  Created by Divjyot Singh on 21/04/16.
//  Copyright © 2016 kommunicate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encode)

- (NSString *)urlEncodeUsingNSUTF8StringEncoding; // Direct UTF8 encoding
@end
