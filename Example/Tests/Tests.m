//
//  KommunicateCore-iOS-SDKTests.m
//  KommunicateCore-iOS-SDKTests
//
//  Created by shilwantk on 11/23/2021.
//  Copyright (c) 2021 shilwantk. All rights reserved.
//

@import XCTest;
@import KommunicateCore_iOS_SDK;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    [KMCoreUserDefaultsHandler clearAll];
    [super tearDown];
}

- (void)testKommunicateClientStoresApplicationKey
{
    NSString *applicationKey = @"test-application-key";

    KommunicateClient *client = [[KommunicateClient alloc] initWithApplicationKey:applicationKey];

    XCTAssertNotNil(client);
    XCTAssertEqualObjects([KMCoreUserDefaultsHandler getApplicationKey], applicationKey);
}

@end

