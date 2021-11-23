//
//  ALJWTClaim.m
//  ApplozicCore
//
//  Created by apple on 12/03/21.
//  Copyright © 2021 applozic Inc. All rights reserved.
//

#import "ALJWTClaim.h"

@implementation ALJWTClaim

-(instancetype)initWithValue:(id)value {
    self.value = value;
    return self;
}

- (NSString *)string {
    if ([self.value isKindOfClass:[NSString class]]) {
        return (NSString *)self.value;
    }
    return nil;
}

-(NSNumber *)doubleValue {
    NSNumber * doubleVal = nil;
    if (self.string) {
        doubleVal = [NSNumber numberWithDouble:[self.string doubleValue]];
    } else if ([self.value isKindOfClass:[NSNumber class]]) {
        doubleVal = (NSNumber *)self.value;
    }
    return doubleVal;
}

-(NSDate *)date {
    NSNumber *dateDoublevalue = self.doubleValue;
    if (dateDoublevalue == nil || dateDoublevalue.doubleValue < 0) {
        return nil;
    }

    NSDate * claimDate =  [[NSDate date] initWithTimeIntervalSince1970:dateDoublevalue.doubleValue];
    return claimDate;
}

- (NSMutableArray<NSString *> *)array {

    if ([self.value isKindOfClass:[NSMutableArray class]]) {
        return  (NSMutableArray *)self.value;
    }

    if (self.string) {
        return [[NSMutableArray alloc] initWithObjects:self.string, nil];
    }
    return nil;
}

@end
