//
//  KMViewController.m
//  KommunicateCore-iOS-SDK
//
//  Created by shilwantk on 11/23/2021.
//  Copyright (c) 2021 shilwantk. All rights reserved.
//

#import "KMViewController.h"
#import "ApplozicClient.h"
#import "KMAppDelegate.h"

@interface KMViewController ()

@property(strong, nonatomic) ApplozicClient *client;

@end

@implementation KMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_client initWithApplicationKey:@"2faa0ef06918df6dd5dc8506df6cec267"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loginButtonTapped:(id)sender {
    
    ALUser *user = [[ALUser alloc] initWithUserId:@"test" password:@"1234" email:@"test@test.com" andDisplayName:@"sample user"];
    [_client loginUser: user withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        NSLog(@"%@", rResponse);
    }];
}

-(IBAction)fetchMessageList:(id)sender {
        
    if ([ALUserDefaultsHandler isLoggedIn]) {
        NSLog(@"User already logged in");
        NSLog(@"Fetching message list...");
        ALMessageService *messageService = [[ALMessageService alloc] init];
        [messageService getLatestMessageForUser:@"test"];
    }
}

-(IBAction)logOut:(id)sender {

    [_client logoutUserWithCompletion:^(NSError *error, ALAPIResponse *response) {
        NSLog(error);
    }];
    
}

@end
