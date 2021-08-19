//
//  ALReceiverUserProfileVC.m
//  Applozic
//
//  Created by devashish on 01/08/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALReceiverUserProfileVC.h"
#import "UIImageView+WebCache.h"
#import "ALUIUtilityClass.h"

@interface ALReceiverUserProfileVC ()

@end

@implementation ALReceiverUserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setUpProfileItems];
    [self setTapGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMuteInfo:)
                                                 name:@"Update_user_mute_info" object:nil];

}

-(void)updateMuteInfo:(NSNotification*)notification {
    
    ALUserDetail *userDetail =  notification.object;
    if (userDetail) {
        if ([userDetail isNotificationMuted]) {
            [self.muteUserLabel setText:[NSString stringWithFormat: NSLocalizedStringWithDefaultValue(@"unMuteUser", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unmute", @"")]];
        } else {
            [self.muteUserLabel setText:[NSString stringWithFormat: NSLocalizedStringWithDefaultValue(@"muteUser", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Mute", @"")]];
        }
    }
    
}

-(void)setTapGesture{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processChat)];
    tapGesture.numberOfTapsRequired = 1;
    [self.muteUserLabel setUserInteractionEnabled:YES];
    [self.muteUserLabel addGestureRecognizer:tapGesture];
}

-(void)processChat {
    
    if ([self.alContact isNotificationMuted]) {
        [self unmuteUser];
        
    } else {
        
        [self showActionAlert];
    }
    
}


-(void) showActionAlert {
    UIAlertController *theController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [ALUIUtilityClass setAlertControllerFrame:theController andViewController:self];
    
    [theController addAction:[UIAlertAction actionWithTitle: NSLocalizedStringWithDefaultValue(@"cancelOptionText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
    
    
    [theController addAction:[UIAlertAction actionWithTitle:[@"8 " stringByAppendingString:NSLocalizedStringWithDefaultValue(@"hrs", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Hrs", @"")] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self sendMuteRequestWithButtonIndex:0];
    }]];

    
    [theController addAction:[UIAlertAction actionWithTitle: [@"1 " stringByAppendingString:NSLocalizedStringWithDefaultValue(@"week", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Week", @"")] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self sendMuteRequestWithButtonIndex:1];
    }]];

    
    [theController addAction:[UIAlertAction actionWithTitle: [@"1 " stringByAppendingString:NSLocalizedStringWithDefaultValue(@"year", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Year", @"")]  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self sendMuteRequestWithButtonIndex:2];
    }]];

    [self presentViewController:theController animated:YES completion:nil];
}

-(void)sendMuteRequestWithButtonIndex:(NSInteger)buttonIndex {

    long currentTimeStemp = [[NSNumber numberWithLong:([[NSDate date] timeIntervalSince1970]*1000)] longValue];
    
    
    NSNumber *notificationAfterTime =0;
    
    switch(buttonIndex) {
            
        case 0:
            
            notificationAfterTime= [NSNumber numberWithLong:(currentTimeStemp + 8*60*60*1000)];
            break;
            
        case 1:
            notificationAfterTime= [NSNumber numberWithDouble:(currentTimeStemp + 7*24*60*60*1000)];
            break;
            
        case 2:
            notificationAfterTime= [NSNumber numberWithDouble:(currentTimeStemp + 365*24*60*60*1000)];
            break;
            
        default:break;
    }
    
    if (notificationAfterTime) {
        [self sendMuteRequestWithTime:notificationAfterTime];
    }

}

-(void) unmuteUser {
    long secsUtc1970 = [[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] ] longValue ]*1000L;
    
    [self sendMuteRequestWithTime:[NSNumber numberWithLong:secsUtc1970]];
}


-(void) sendMuteRequestWithTime:(NSNumber*) time{
    
    ALMuteRequest *alMuteRequest = [ALMuteRequest new];
    alMuteRequest.userId = self.alContact.userId;
    alMuteRequest.notificationAfterTime = time;
    
    ALUserService *userService = [[ALUserService alloc ] init];
    [userService muteUser:alMuteRequest withCompletion:^(ALAPIResponse *response, NSError *error) {
        
        if (response && [response.status isEqualToString:@"success"]) {
            self.alContact.notificationAfterTime= alMuteRequest.notificationAfterTime;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.alContact isNotificationMuted]) {
                    [self.muteUserLabel setText:[NSString stringWithFormat: NSLocalizedStringWithDefaultValue(@"unMuteUser", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unmute", @"")]];
                } else {
                    [self.muteUserLabel setText:[NSString stringWithFormat: NSLocalizedStringWithDefaultValue(@"muteUser", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Mute", @"")]];
                }
                
            });

        }
    }];
    
}



-(void)setUpProfileItems {
    [self.displayName setText:[self.alContact getDisplayName]];
    NSString *lastSeenString = @"";
    
    if (self.alContact.isNotificationMuted) {
        [self.muteUserLabel setText:@"Unmute"];
    } else {
        [self.muteUserLabel setText:@"Mute"];
    }
    
    if (self.alContact.lastSeenAt) {
        lastSeenString = self.alContact.connected ? @"Online" : [self getLastSeenString:self.alContact.lastSeenAt];
    }
    [self.lastSeen setText:lastSeenString];
    
    [self.userStatus setText:self.alContact.userStatus];
    [self.emailId setText:self.alContact.email ? self.alContact.email : @"Not Available"];
    [self.phoneNo setText:self.alContact.contactNumber ? self.alContact.contactNumber : @"Not Available"];
    
    [self.profileImageView setImage:[ALUIUtilityClass getImageFromFramworkBundle:@"contact_default_placeholder"]];
    if (self.alContact.contactImageUrl) {
        [ALUIUtilityClass downloadImageUrlAndSet:_alContact.contactImageUrl imageView:_profileImageView defaultImage:@"contact_default_placeholder"];
    }
    
    [self.callButton setEnabled:NO];
    if (self.alContact.contactNumber) {
        [self.callButton setEnabled:YES];
    }
    
    if ([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem]) {
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
        [self.navigationController.navigationBar addSubview:[ALUIUtilityClass setStatusBarStyle]];
    }
}

-(NSString *)getLastSeenString:(NSNumber *)lastSeen {
    ALUtilityClass *utility = [ALUtilityClass new];
    [utility getExactDate:lastSeen];
    NSString *text = [NSString stringWithFormat:@"Last seen %@ %@", utility.msgdate, utility.msgtime];
    return text;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Update_user_mute_info" object:nil];
}

- (IBAction)callButtonAction:(id)sender {
    
    NSURL *phoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.alContact.contactNumber]];
    [[UIApplication sharedApplication] openURL:phoneNumber options:@{} completionHandler:nil];
}
@end
