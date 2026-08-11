//
//  KMViewController.m
//  KommunicateCore-iOS-SDK
//
//  Created by shilwantk on 11/23/2021.
//  Copyright (c) 2021 shilwantk. All rights reserved.
//

#import "KMViewController.h"
@import KommunicateCore_iOS_SDK;
#import "KMAppDelegate.h"

@interface KMViewController ()

@property(strong, nonatomic) KommunicateClient *client;
@end

@implementation KMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.client = [[KommunicateClient alloc] initWithApplicationKey:@"2faa0ef06918df6dd5dc8506df6cec267"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loginButtonTapped:(id)sender {
    
    KMCoreUser *user = [[KMCoreUser alloc] initWithUserId:@"test" password:@"1234" email:@"test@test.com" andDisplayName:@"sample user"];
    [self.client loginUser:user withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
            NSLog(@"Login failed: %@", error.localizedDescription);
            return;
        }

        NSLog(@"Login successful: %@", rResponse);
    }];
}

-(IBAction)fetchMessageList:(id)sender {
        
    if ([KMCoreUserDefaultsHandler isLoggedIn]) {
        NSLog(@"User already logged in");
        NSLog(@"Fetching message list...");
        KMCoreMessageService *messageService = [[KMCoreMessageService alloc] init];
        [messageService getLatestMessageForUser:@"test"];
    }
}

-(IBAction)logOut:(id)sender {

    [self.client logoutUserWithCompletion:^(NSError *error, ALAPIResponse *response) {
        NSLog(@"%@", error);
    }];
    
}

@end
