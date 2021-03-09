//
//  ALAppLocalNotifications.m
//  Applozic
//
//  Created by devashish on 07/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALAppLocalNotifications.h"
#import "ALUtilityClass.h"
#import "ALPushAssist.h"
#import "ALMessageDBService.h"
#import "ALMessageService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessageService.h"
#import "ALUserService.h"
#import "ALMQTTConversationService.h"
#import "ALConversationService.h"
#import "ALApplozicSettings.h"
#import "ALLogger.h"

@implementation ALAppLocalNotifications


+(ALAppLocalNotifications *)appLocalNotificationHandler
{
    static ALAppLocalNotifications * localNotificationHandler = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        localNotificationHandler = [[self alloc] init];
    });
    
    return localNotificationHandler;
}

-(void)dataConnectionNotificationHandler{

    [self dataConnectionHandler];
}

-(void)dataConnectionHandler
{
    [ALApplozicSettings setupSuiteAndMigrate];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
                                                 name:AL_kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    

    self.googleReach = [ALReachability reachabilityWithHostname:@"www.google.com"];
    
    [self.googleReach startNotifier];

    self.localWiFiReach = [ALReachability reachabilityForLocalWiFi];
    
    self.localWiFiReach.reachableOnWWAN = NO;

    [self.localWiFiReach startNotifier];

    self.internetConnectionReach = [ALReachability reachabilityForInternetConnection];

    [self.internetConnectionReach startNotifier];
    
}

-(void)reachabilityChanged:(NSNotification*)note
{
    ALReachability * reach = [note object];
    
    if(reach == self.googleReach)
    {
        if([reach isReachable])
        {
            ALSLog(ALLoggerSeverityInfo, @"========== IF googleReach ============");
        }
        else
        {
            ALSLog(ALLoggerSeverityInfo, @"========== ELSE googleReach ============");
        }
    }
    else if (reach == self.localWiFiReach)
    {
        if([reach isReachable])
        {
            ALSLog(ALLoggerSeverityInfo, @"========== IF localWiFiReach ============");
        }
        else
        {
            ALSLog(ALLoggerSeverityInfo, @"========== ELSE localWiFiReach ============");
        }
    }
    else if (reach == self.internetConnectionReach)
    {
        if([reach isReachable])
        {
            ALSLog(ALLoggerSeverityInfo, @"========== IF internetConnectionReach ============");
            [self proactivelyConnectMQTT];
            [ALMessageService syncMessages];

            ALMessageService *messageService = [[ALMessageService alloc]init];
            [messageService processPendingMessages];

            ALUserService *userService = [ALUserService new];
            [userService blockUserSync: [ALUserDefaultsHandler getUserBlockLastTimeStamp]];

        }
        else
        {
            ALSLog(ALLoggerSeverityInfo, @"========== ELSE internetConnectionReach ============");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORK_DISCONNECTED" object:nil];
        }
    }
    
}

-(void)proactivelyConnectMQTT
{
    ALMQTTConversationService *alMqttConversationService = [ALMQTTConversationService sharedInstance];
    [alMqttConversationService subscribeToConversation];
}

-(void)proactivelyDisconnectMQTT
{
    ALMQTTConversationService *alMqttConversationService = [ALMQTTConversationService sharedInstance];
    [alMqttConversationService unsubscribeToConversation];
}

-(void)appWillEnterBackground:(NSNotification *)notification
{
    [self proactivelyDisconnectMQTT];
    [ALLogger saveLogArray];
}

//receiver
- (void)onAppDidBecomeActive:(NSNotification *)notification
{
    [self proactivelyConnectMQTT];
    [ALMessageService syncMessages];
}


-(void)dealloc
{
    ALSLog(ALLoggerSeverityInfo, @"DEALLOC METHOD CALLED");
}


@end
