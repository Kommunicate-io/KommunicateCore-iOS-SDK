//
//  ViewController.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALUIView+Toast.h"
#import "ALMessagesViewController.h"
#import "UIImageView+WebCache.h"
#import "ALColorUtility.h"
#import "ALChatLauncher.h"
#import "ALGroupCreationViewController.h"
#import "ALNotificationHelper.h"
#import <Applozic/Applozic-Swift.h>
#import "ALSearchResultViewController.h"
#import "ALUIUtilityClass.h"

static const int LAUNCH_GROUP_OF_TWO = 4;
static const int REGULAR_CONTACTS = 0;
static const int BROADCAST_GROUP_CREATION = 5;
static const CGFloat NAVIGATION_TEXT_SIZE = 20;
// Constants
static CGFloat const DEFAULT_TOP_LANDSCAPE_CONSTANT = 34;
static CGFloat const DEFAULT_TOP_PORTRAIT_CONSTANT = 64;
static NSInteger const ALMQTT_MAX_RETRY = 3;

//==============================================================================================================================================
// Private interface
//==============================================================================================================================================

@interface ALMessagesViewController ()<UITableViewDataSource, UITableViewDelegate, ALMessagesDelegate, ALMQTTConversationDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
- (IBAction)backButtonAction:(id)sender;
- (void)emptyConversationAlertLabel;
// Constants

// IBOutlet
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mTableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

// Private Variables
@property (nonatomic, strong) NSMutableArray *mContactsMessageListArray;
@property (nonatomic, strong) UIColor *navColor;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (strong, nonatomic) UILabel *emptyConversationText;
@property (strong, nonatomic) ALMQTTConversationService *alMqttConversationService;
@property (strong, nonatomic)  NSMutableDictionary *colourDictionary;
@property (strong, nonatomic) UIBarButtonItem *barButtonItem;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIBarButtonItem *startNewButton;

@property (nonatomic, strong) ALMessageDBService *dBService;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) ALSearchResultViewController *searchResultVC;

@property (strong, nonatomic) ALCustomSearchBar *customSearchBar;

@property (strong, nonatomic) ALMessageService *messageService;
@property (strong, nonatomic) ALChannelService *channelService;
@property (strong, nonatomic) ALUserService *userService;
@property (nonatomic) NSInteger mqttRetryCount;

@end

// $$$$$$$$$$$$$$$$$$ Class Extension for solving Constraints Issues.$$$$$$$$$$$$$$$$$$$$
@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

- (NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

@implementation ALMessagesViewController


-(void)setupServices {
    self.messageService = [[ALMessageService alloc] init];
    self.channelService = [[ALChannelService alloc] init];
    self.userService = [[ALUserService alloc] init];
}
//==============================================================================================================================================
#pragma mark - VIEW LIFE CYCLE
//==============================================================================================================================================

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupServices];
    self.extendedLayoutIncludesOpaqueBars = true;

    [self setUpTableView];
    self.mTableView.allowsMultipleSelectionDuringEditing = NO;

    self.alMqttConversationService = [ALMQTTConversationService sharedInstance];

    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.size.height/2 - navigationHeight,
                                                                           self.view.frame.size.width, 30)];
    
    [self.emptyConversationText setText:[ALApplozicSettings getEmptyConversationText]];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.emptyConversationText];
    self.emptyConversationText.hidden = YES;
    
    if ((self.channelKey || self.userIdToLaunch)) {
        [self createAndLaunchChatView ];
    }
    [_mTableView setBackgroundColor:[ALApplozicSettings getMessagesViewBackgroundColour]];
    self.colourDictionary = [ALApplozicSettings getUserIconFirstNameColorCodes];
}

- (void)setupNavigationButtons {

    if (self.navigationItem.titleView == nil) {
        UIColor *itemColor = [ALApplozicSettings getColorForNavigationItem];

        NSMutableArray *rightSideNavItems = [[NSMutableArray alloc] init];

        if (![ALUserDefaultsHandler isNavigationRightButtonHidden]) {


            self.startNewButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self
                                                                                 action:@selector(navigationRightButtonAction)];
            [self.startNewButton setTintColor:itemColor];
            [self.startNewButton setEnabled:![ALUserDefaultsHandler isLoggedInUserDeactivated]];
            [rightSideNavItems addObject: self.startNewButton];

        }

        if (ALApplozicSettings.isMessageSearchEnabled) {
            UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                          target:self
                                                                                          action:@selector(searchButtonAction)];

            [searchButton setTintColor:itemColor];
            [rightSideNavItems addObject: searchButton];
        }

        if ([ALApplozicSettings isRefreshChatButtonEnabledInMsgVc]) {
            self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(refreshMessageList)];
            [self.refreshButton setTintColor:itemColor];
            [rightSideNavItems addObject: self.refreshButton];
        }

        if (rightSideNavItems && rightSideNavItems.count) {
            [self.navigationItem setRightBarButtonItems:rightSideNavItems];
        }

        if (![ALUserDefaultsHandler isBackButtonHidden]) {
            self.barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton: NSLocalizedStringWithDefaultValue(@"back", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], [ALApplozicSettings getTitleForBackButtonMsgVC], @"")]];
            [self.navigationItem setLeftBarButtonItem:self.barButtonItem];
        }
    }
}

- (void)loadMessages:(NSNotification *)notification {
    [self.dBService getMessages:self.childGroupList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self subscribeToConversationWithCompletionHandler:^(BOOL connected) {
        if (!connected) {
            ALSLog(ALLoggerSeverityInfo, @"MQTT subscribe to conversation faild in ALMessagesViewController");
        }
    }];
    /// Setup the delegate in viewWillAppear
    self.alMqttConversationService.mqttConversationDelegate = self;
    if ([ALApplozicSettings isDropShadowInNavigationBarEnabled]) {
        [self dropShadowInNavigationBar];
    }

    [self.navigationController.navigationBar addSubview:[ALUIUtilityClass setStatusBarStyle]];
    [self.tabBarController.tabBar setHidden:[ALUserDefaultsHandler isBottomTabBarHidden]];

    if (self.parentGroupKey && [ALApplozicSettings getSubGroupLaunchFlag]) {
        [self intializeSubgroupMessages];
    }

    [self prepareViewController];

    [self setupNavigationButtons];

    [self setupSearchViewController];

    //register for notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationhandler:) name:@"pushNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageHandler:) name:NEW_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTable" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChannelSync:)
                                                 name:@"Update_channel_Info" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastSeenAtStatusPUSH:) name:@"update_USER_STATUS" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages:) name:@"CONVERSATION_DELETION" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCallForUser:) name:@"USER_DETAILS_UPDATE_CALL" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateBroadCastMessages) name:@"BROADCAST_MSG_UPDATE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationUnreadCount:) name:@"Update_unread_count" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordDidHideNotification)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageMetaDataUpdate:)
                                                 name:AL_MESSAGE_META_DATA_UPDATE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoggedInUserDeactivated:)
                                                 name:ALLoggedInUserDidChangeDeactivateNotification object:nil];


    [self.navigationController.navigationBar setTitleTextAttributes: @{
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                            size:NAVIGATION_TEXT_SIZE]
    }];
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"chatTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], [ALApplozicSettings getTitleForConversationScreen], @"");
    
    
    if ([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem]) {
        [self.navigationController.navigationBar setTitleTextAttributes: @{
            NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem],
            NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                                size:NAVIGATION_TEXT_SIZE]
        }];
        
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
    }

    [self callLastSeenStatusUpdate];
}

- (void)prepareViewController {
    [self.mActivityIndicator startAnimating];
    self.dBService = [[ALMessageDBService alloc] init];
    self.dBService.delegate = self;
    [self.dBService getMessages:self.childGroupList];
}

- (void)intializeSubgroupMessages {
    ALChannelService *channelService = [ALChannelService new];
    self.childGroupList = [[NSMutableArray alloc] initWithArray:[channelService fetchChildChannelsWithParentKey:self.parentGroupKey]];
}

// Channel details update notification
- (void)updateChannelSync:(NSNotification *)notification {
    ALChannel *channel =  notification.object;
    ALChannelService *channelService = [[ALChannelService alloc]init];
    channel =  [channelService getChannelByKey:channel.key];
    if (channel) {
        ALContactCell *contactCell = [self getCellForGroup:channel.key];
        if (contactCell) {
            [contactCell updateProfileImageAndUnreadCountWithChannel:channel orContact:nil withColourDictionary:self.colourDictionary];
        }
    }
}


// Update channel/user unread count notification
- (void)updateConversationUnreadCount:(NSNotification *)notification {
    NSDictionary *dictionary =  notification.object;
    if (dictionary) {
        ALContactCell *cell = nil;
        NSString *userId = [ dictionary objectForKey:@"userId"];
        if (userId) {
            cell = [self getCell:userId];
        } else {
            NSNumber  *channelKey = [ dictionary objectForKey:@"channelKey"];
            cell = [self getCellForGroup:channelKey];
        }
        if (cell) {
            cell.unreadCountLabel.text = @"";
            [cell.unreadCountLabel setHidden:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.userIdToLaunch = nil;
    self.channelKey = nil;
    if (self.detailChatViewController) {
        self.detailChatViewController.isVisible = NO;
    }
    if ([self.mActivityIndicator isAnimating]) {
        [self.emptyConversationText setHidden:YES];
    } else {
        [self emptyConversationAlertLabel];
    }
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
        [self noDataNotificationView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.view setNeedsLayout];
    [self.navigationController.view layoutIfNeeded];
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    //unregister for notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Update_channel_Info" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BROADCAST_MSG_UPDATE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Update_unread_count" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

//==============================================================================================================================================
#pragma mark - NAVIGATION SHADOW EFFECTS
//==============================================================================================================================================

- (void)dropShadowInNavigationBar {
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.navigationBar.layer.shadowRadius = 10;
    self.navigationController.navigationBar.layer.masksToBounds = NO;
}

- (void)emptyConversationAlertLabel {
    if (self.mContactsMessageListArray.count == 0) {
        [self.emptyConversationText setHidden:NO];
    } else {
        [self.emptyConversationText setHidden:YES];
    }
}

//==============================================================================================================================================
#pragma mark - NAVIGATION RIGHT BUTTON ACTION + CONTACT LAUNCH FOR USER/SUB GROUP
//==============================================================================================================================================

- (void)navigationRightButtonAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALNewContactsViewController *contactVC = (ALNewContactsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    contactVC.forGroup = [NSNumber numberWithInt:REGULAR_CONTACTS];
    if ([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId) {
        [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    }
    
    if (self.parentGroupKey && [ALApplozicSettings getSubGroupLaunchFlag]) {
        contactVC.forGroup = [NSNumber numberWithInt:LAUNCH_GROUP_OF_TWO];
        ALChannelService *channelService = [ALChannelService new];
        contactVC.parentChannel = [channelService getChannelByKey:self.parentGroupKey];
        contactVC.childChannels = [[NSMutableArray alloc] initWithArray:[channelService fetchChildChannelsWithParentKey:self.parentGroupKey]];
    }
    
    [self.navigationController pushViewController:contactVC animated:YES];
}

/************************************  REFRESH CONVERSATION IF RIGHT BUTTON IS REFRESH BUTTON **************************************************/

- (void)refreshMessageList {
    NSString *toastMsg = @"Syncing messages with the server,\n it might take few mins!";
    [self.view makeToast:toastMsg duration:1.0 position:CSToastPositionBottom title:nil];
    
    [ALMessageService getLatestMessageForUser:[ALUserDefaultsHandler getDeviceKeyString] withCompletion:^(NSMutableArray  *messageList, NSError *error) {
        
        if (error) {
            ALSLog(ALLoggerSeverityError, @"ERROR: IN REFRESH MSG VC :: %@",error);
            return;
        }
        ALSLog(ALLoggerSeverityInfo, @"REFRESH MSG VC");
    }];
}

- (void)setupSearchViewController {

    if (self.navigationItem.titleView == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];

        _searchResultVC = (ALSearchResultViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ALSearchViewController"];

        self.searchController = [[UISearchController alloc] initWithSearchResultsController:_searchResultVC];
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.autocapitalizationType =  UITextAutocapitalizationTypeNone;
        self.searchController.hidesNavigationBarDuringPresentation = NO;

        self.customSearchBar = [[ALCustomSearchBar alloc] initWithSearchBar:self.searchController.searchBar];
        NSString *searchLabel = NSLocalizedStringWithDefaultValue(@"SearchLabelText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Search...", @"");
        self.searchController.searchBar.placeholder = searchLabel;
        if (@available(iOS 13.0, *)) {
            self.searchController.searchBar.searchTextField.backgroundColor = [UIColor whiteColor];
            self.searchController.automaticallyShowsCancelButton = YES;
        } else {
            self.searchController.searchBar.showsCancelButton = YES;
        }
        self.definesPresentationContext = YES;
    }
}

- (void)searchButtonAction {
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationItem setRightBarButtonItems:nil];
        [self.navigationItem setLeftBarButtonItem:nil];
        self.navigationItem.titleView = self.customSearchBar;
        [self.customSearchBar show:YES];
    } completion:^(BOOL finished) {
        [self.customSearchBar becomeFirstResponder];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpTableView {
    self.mContactsMessageListArray = [NSMutableArray new];
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConversationTableNotification:)
                                                 name:@"updateConversationTableNotification"
                                               object:nil];
}

//==============================================================================================================================================
#pragma mark - ALMessagesDelegate
//==============================================================================================================================================

- (void)reloadTable:(NSNotification*)notification {
    [self updateMessageList:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:@"reloadTable"];
}

- (void)getMessagesArray:(NSMutableArray *)messagesArray {
    [self.mActivityIndicator stopAnimating];
    
    if (messagesArray.count == 0) {
        [[self emptyConversationText] setHidden:NO];
    } else {
        [[self emptyConversationText] setHidden:YES];
    }
    
    self.mContactsMessageListArray = messagesArray;
    [self.mTableView reloadData];
    ALSLog(ALLoggerSeverityInfo, @"GETTING MESSAGE ARRAY");
}

- (void)didUpdateBroadCastMessages {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dBService getMessages:nil];
        [self.mTableView reloadData];
    });
}

//==============================================================================================================================================
#pragma mark - UPDATE MESSAGE LIST
//==============================================================================================================================================

- (void)updateMessageList:(NSMutableArray *)messagesArray {
    NSUInteger index = 0;
    
    if (messagesArray.count) {
        [self.emptyConversationText setHidden:YES];
    }

    BOOL isreloadRequire = NO;
    for(ALMessage *msg in messagesArray) {

        ALContactCell *contactCell;
        ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
        ALChannelService *channelService = [[ALChannelService alloc] init];
        if (msg.groupId) {
            msg.contactIds = NULL;
            contactCell = [self getCellForGroup:msg.groupId];
        } else {
            contactCell = [self getCell:msg.contactIds];
        }
        
        if (msg.contentType == AV_CALL_HIDDEN_NOTIFICATION) {
            //            ALVOIPNotificationHandler *voipHandler = [ALVOIPNotificationHandler sharedManager];
            //            [voipHandler handleAVMsg:msg andViewController:self];
        } else if (contactCell) {
            contactCell.mMessageLabel.text = msg.message;
            ALContact *alContact = nil;
            ALChannel *channel = nil;

            if (msg.groupId != nil) {
                channel = [channelService getChannelByKey:msg.groupId];
            } else {
                alContact = [contactDBService loadContactByKey:@"userId" value:msg.contactIds];
            }

            [contactCell updateProfileImageAndUnreadCountWithChannel:channel orContact:alContact withColourDictionary:self.colourDictionary];

            BOOL isToday = [ALUtilityClass isToday:[NSDate dateWithTimeIntervalSince1970:[msg.createdAtTime doubleValue]/1000]];
            contactCell.mTimeLabel.text = [msg getCreatedAtTime:isToday];
            [contactCell displayAttachmentMediaType:msg];
            
        } else {
            index = [self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(ALMessage *almessage, NSUInteger idx, BOOL *stop) {

                if (msg.groupId) {
                    return [almessage.groupId isEqualToNumber:msg.groupId];
                } else {
                    if ([ALApplozicSettings getSubGroupLaunchFlag]) {
                        return NO;
                    }
                    return [almessage.to isEqualToString:msg.to];
                }
            }];

            isreloadRequire = YES;
            if (index != NSNotFound) {
                [self.mContactsMessageListArray replaceObjectAtIndex:index withObject:msg];
            } else {
                if (msg.groupId) {
                    isreloadRequire = NO;
                    [channelService getChannelInformation:msg.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {

                        BOOL channelFlag = ([ALApplozicSettings getSubGroupLaunchFlag] && [alChannel.parentKey isEqualToNumber:self.parentGroupKey]);
                        BOOL categoryFlag =  [ALApplozicSettings getCategoryName] && [alChannel isPartOfCategory:[ALApplozicSettings getCategoryName]];

                        if ((channelFlag || categoryFlag) ||
                            !([ALApplozicSettings getSubGroupLaunchFlag] || [ALApplozicSettings getCategoryName])) {
                            [self.mContactsMessageListArray insertObject:msg atIndex:0];
                            [self.mTableView reloadData];
                        }
                    }];
                } else {
                    [self.mContactsMessageListArray insertObject:msg atIndex:0];
                }
            }
            
            ALSLog(ALLoggerSeverityInfo, @"contact cell not found ....");
        }
    }
    if (isreloadRequire) {
        [self.mTableView reloadData];
    }
}

- (ALContactCell *)getCell:(NSString *)key {
    int index = (int)[self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(id element, NSUInteger idx, BOOL *stop) {
        
        ALMessage *message = (ALMessage*)element;
        if ([message.contactIds isEqualToString:key] && (message.groupId.intValue == 0 || message.groupId == nil)) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:1];
    ALContactCell *contactCell = (ALContactCell *)[self.mTableView cellForRowAtIndexPath:path];
    
    return contactCell;
}

- (ALContactCell *)getCellForGroup:(NSNumber *)groupKey {
    int index = (int)[self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop) {
        
        ALMessage *message = (ALMessage*)element;
        if ([message.groupId isEqualToNumber:groupKey]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:1];
    ALContactCell *contactCell  = (ALContactCell *)[self.mTableView cellForRowAtIndexPath:path];
    
    return contactCell;
}

- (NSIndexPath*) getIndexPathForMessage:(NSString*)messageKey {
    int index = (int)[self.mContactsMessageListArray indexOfObjectPassingTest:^BOOL(id element,NSUInteger idx,BOOL *stop) {
        ALMessage *message = (ALMessage*)element;
        if ([message.key isEqualToString:messageKey]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];

    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:1];
    return path;
}

//==============================================================================================================================================
#pragma mark - TABLE VIEW DELEGATES METHODS
//==============================================================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.mTableView == nil) ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            if ([ALApplozicSettings getGroupOption]) {
                return 1;
            } else {
                return 0;
            }
        }break;
            
        case 1: {
            return self.mContactsMessageListArray.count>0?[self.mContactsMessageListArray count]:0;
        }break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ALContactCell *contactCell;
    
    switch (indexPath.section) {
        case 0: {
            //Cell for group button....
            contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"groupCell"];
            
            //Add group button.....
            UIButton *newBtn = (UIButton*)[contactCell viewWithTag:101];
            [newBtn addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
            newBtn.userInteractionEnabled = YES;
            
            
            [newBtn setTitle:NSLocalizedStringWithDefaultValue(@"createGroupOptionTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Create Group", @"")
                    forState:UIControlStateNormal];
            [newBtn sizeToFit];
            [newBtn setTitleColor:[ALApplozicSettings getMessageListTextColor] forState:UIControlStateNormal];

            // Add group button.....
            UIButton *newBroadCast = (UIButton*)[contactCell viewWithTag:102];
            [newBroadCast addTarget:self action:@selector(createBroadcastGroup:) forControlEvents:UIControlEventTouchUpInside];
            
            [newBroadCast sizeToFit];
            
            [newBroadCast setTitle:NSLocalizedStringWithDefaultValue(@"broadcastGroupOptionTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"New Broadcast", @"")
                          forState:UIControlStateNormal];
            
            newBroadCast.userInteractionEnabled = [ALApplozicSettings isBroadcastGroupEnable];
            [newBroadCast setHidden:![ALApplozicSettings isBroadcastGroupEnable]];
            [newBroadCast setTitleColor:[ALApplozicSettings getMessageListTextColor] forState:UIControlStateNormal];

        }break;

        case 1: {
            //Add rest of messageList
            contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
            ALMessage *message = (ALMessage *)self.mContactsMessageListArray[indexPath.row];
            [contactCell updateWithMessage:message withColourDictionary:self.colourDictionary];
        }break;

        default:
            return [[UITableViewCell alloc] init];
            break;
    }
    [contactCell setBackgroundColor:[ALApplozicSettings getMessagesViewBackgroundColour]];
    return contactCell;
}

//==============================================================================================================================================
#pragma mark - TABLE VIEW DATASOURCE METHODS
//==============================================================================================================================================

/*********************************************  ACTION ON TAP OF TABLE CELL ******************************************************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        ALMessage *message = self.mContactsMessageListArray[indexPath.row];
        [self createDetailChatViewControllerWithMessage:message];
        ALContactCell *contactCell = (ALContactCell *)[tableView cellForRowAtIndexPath:indexPath];
        int count = [contactCell.unreadCountLabel.text intValue];
        if (count) {
            self.detailChatViewController.refresh = YES;
        }
    }
}

- (void)createDetailChatViewController:(NSString *)contactIds {
    if (!(self.detailChatViewController)) {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    if ([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId) {
        [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    }
    self.detailChatViewController.contactIds = contactIds;
    self.detailChatViewController.chatViewDelegate = self;
    self.detailChatViewController.channelKey = self.channelKey;
    [self.navigationController pushViewController:self.detailChatViewController animated:YES];
}

- (void)createDetailChatViewControllerWithMessage:(ALMessage *)message {
    [self createDetailChatViewControllerWithUserId:message.contactIds withGroupId:message.groupId withConversationId:message.conversationId];
}

- (void)createDetailChatViewControllerWithUserId:(NSString *)contactId withGroupId:(NSNumber *)groupId withConversationId:(NSNumber *)conversationId {

    if (!(self.detailChatViewController)) {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }

    self.detailChatViewController.conversationId = conversationId;

    if ([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId) {
        [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    }

    if (groupId) {
        self.detailChatViewController.channelKey = groupId;
        self.detailChatViewController.contactIds = nil;

        ALChannelService *channelService = [[ALChannelService alloc] init];
        ALChannel *alChannel = [channelService getChannelByKey:groupId];

        if (alChannel.type == GROUP_OF_TWO) {
            NSString *contactId = [alChannel getReceiverIdInGroupOfTwo];
            ALContactService *contactService = [ALContactService new];
            ALContact *alContact = [contactService loadContactByKey:@"userId" value:contactId];
            self.detailChatViewController.contactIds = alContact.userId;
        }
    } else {
        self.detailChatViewController.channelKey = nil;
        self.detailChatViewController.contactIds = contactId;
    }

    self.detailChatViewController.alChannel = nil;
    self.detailChatViewController.alContact = nil;
    self.detailChatViewController.chatViewDelegate = self;

    ALPushAssist *pushAssist = [[ALPushAssist alloc]init];

    if (![pushAssist.topViewController isKindOfClass:ALChatViewController.class]) {
        [self.navigationController pushViewController:self.detailChatViewController animated:YES];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = 40.0;
    } else {
        height = 81.5;
    }
    
    return height;
}

//==============================================================================================================================================
#pragma mark - TABLE VIEW EDITING METHODS
//==============================================================================================================================================

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
}

/************************************************  DELETE CONVERSATION ON SWIPE ********************************************************/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ALSLog(ALLoggerSeverityInfo, @"DELETE_PRESSED");
        if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
            [self noDataNotificationView];
            return;
        }
        ALMessage *alMessageobj = self.mContactsMessageListArray[indexPath.row];

        if ([self.channelService isChannelLeft:[alMessageobj getGroupId]]) {
            
            [self.dBService deleteAllMessagesByContact:nil orChannelKey:[alMessageobj getGroupId]];
            [self.channelService setUnreadCountZeroForGroupID:[alMessageobj getGroupId]];
        }
        
        [self.messageService deleteMessageThread:alMessageobj.contactIds orChannelKey:[alMessageobj getGroupId]
                                  withCompletion:^(NSString *string, NSError *error) {
            
            if (error) {
                ALSLog(ALLoggerSeverityError, @"DELETE_FAILED_CONVERSATION_ERROR_DESCRIPTION :: %@", error.description);
                [ALUIUtilityClass displayToastWithMessage:@"Delete failed"];
                return;
            }
            NSArray *theFilteredArray;
            if ([alMessageobj getGroupId]) {

                theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                    [NSPredicate predicateWithFormat:@"groupId = %@",[alMessageobj getGroupId]]];
            } else {
                theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                    [NSPredicate predicateWithFormat:@"contactIds = %@ AND groupId = %@",alMessageobj.contactIds,nil]];
            }
            
            [self subProcessDeleteMessageThread:theFilteredArray];

            if ([ALChannelService isChannelDeleted:[alMessageobj getGroupId]]) {
                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                [channelDBService deleteChannel:[alMessageobj getGroupId]];
            }
        }];
    }
}

- (void)subProcessDeleteMessageThread:(NSArray *)theFilteredArray {
    ALSLog(ALLoggerSeverityInfo, @"GETTING_FILTERED_ARRAY_COUNT :: %lu", (unsigned long)theFilteredArray.count);
    [self.mContactsMessageListArray removeObjectsInArray:theFilteredArray];
    [self emptyConversationAlertLabel];
    [self.mTableView reloadData];
}

//==============================================================================================================================================
#pragma mark - NOTIFICATION OBSERVERS
//==============================================================================================================================================

- (void)updateConversationTableNotification:(NSNotification *)notification {
    ALMessage *theMessage = notification.object;
    ALSLog(ALLoggerSeverityInfo, @"NOTIFICATION_FOR_TABLE_UPDATE :: %@", theMessage.message);
    NSArray *theFilteredArray = [self.mContactsMessageListArray
                                 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIds = %@", theMessage.contactIds]];
    //check for group id also
    ALMessage *theLatestMessage = theFilteredArray.firstObject;
    if (theLatestMessage != nil && ![theMessage.createdAtTime isEqualToNumber: theLatestMessage.createdAtTime]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mContactsMessageListArray removeObject:theLatestMessage];
            [self.mContactsMessageListArray insertObject:theMessage atIndex:0];
            [self.mTableView reloadData];
        });
    }
}

//==============================================================================================================================================
#pragma mark - VIEW ORIENTATION METHODS
//==============================================================================================================================================

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIInterfaceOrientation toOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
        (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)) {
        self.mTableViewTopConstraint.constant = - DEFAULT_TOP_LANDSCAPE_CONSTANT;
    } else {
        self.mTableViewTopConstraint.constant = - DEFAULT_TOP_PORTRAIT_CONSTANT;
    }
    [self.view layoutIfNeeded];
}

//==============================================================================================================================================
#pragma mark - MQTT SERVICE DELEGATE METHODS
//==============================================================================================================================================

- (void)mqttDidConnected {
    if (self.detailChatViewController) {
        [self.detailChatViewController subscrbingChannel];
    }
}

- (void)updateCallForUser:(NSNotification *)notifyObj {
    NSString *userID = (NSString *)notifyObj.object;
    [self updateUserDetail:userID];
}

- (void)updateUserDetail:(NSString *)userId {
    ALSLog(ALLoggerSeverityInfo, @"ALMSGVC : USER_DETAIL_CHANGED_CALL_UPDATE");
    [self.userService updateUserDetail:userId withCompletion:^(ALUserDetail *userDetail) {

        if (!userDetail) {
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_DETAIL_OTHER_VC" object:userDetail];

        ALContactCell *contactCell = [self getCell:userId];
        if (contactCell) {
            UILabel*nameIcon = (UILabel *)[contactCell viewWithTag:102];
            [nameIcon setText:[ALColorUtility getAlphabetForProfileImage:[userDetail getDisplayName]]];
            
            if (userDetail.getDisplayName) {
                contactCell.mUserNameLabel.text = userDetail.getDisplayName;
            }
            
            NSURL *URL = [NSURL URLWithString:userDetail.imageLink];
            if (URL) {
                [contactCell.mUserImageView sd_setImageWithURL:URL placeholderImage:nil options:SDWebImageRefreshCached];
                nameIcon.hidden = YES;
            } else {
                nameIcon.hidden = NO;
                [contactCell.mUserImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
                contactCell.mUserImageView.backgroundColor = [ALColorUtility getColorForAlphabet:[userDetail getDisplayName] colorCodes:self.colourDictionary];
            }
            [self.detailChatViewController setRefresh:YES];
        }
        [self.detailChatViewController subProcessDetailUpdate:userDetail];
    }];
}

- (void)reloadDataForUserBlockNotification:(NSString *)userId andBlockFlag:(BOOL)flag {
    [self.detailChatViewController checkUserBlockStatus];
    ALPushAssist *pushAssist =  [[ALPushAssist alloc] init];
    if ([pushAssist.topViewController isKindOfClass:[ALMessagesViewController class]]) {
        [self.detailChatViewController.label setHidden:YES];
        
        ALContactCell *contactCell = [self getCell:userId];
        if (contactCell && [ALApplozicSettings getVisibilityForOnlineIndicator]) {
            [contactCell.onlineImageMarker setHidden:flag];
        }
    }
}

- (void)syncCall:(ALMessage *)alMessage andMessageList:(NSMutableArray *)messageArray {
    ALPushAssist *top = [[ALPushAssist alloc] init];
    ALNotificationHelper *helper = [[ALNotificationHelper alloc]init];

    [self.detailChatViewController setRefresh: YES];
    
    if ([self.detailChatViewController isVisible]) {
        [self.detailChatViewController syncCall:alMessage updateUI:[NSNumber numberWithInt:APP_STATE_ACTIVE] alertValue:alMessage.message];
    } else if ([helper isApplozicViewControllerOnTop]) {

        if ([top.topViewController isKindOfClass:[ALMessagesViewController class]]) {
            [self updateMessageList:messageArray];
        }

        if ([alMessage isSentMessage] || (alMessage.groupId && [ALChannelService isChannelMuted:alMessage.groupId]) || [alMessage isMsgHidden]) {
            return;
        }

        ALNotificationView *alnotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                          withAlertMessage:alMessage.message];

        [alnotification showNativeNotificationWithcompletionHandler:^(BOOL show) {
            [helper handlerNotificationClick:alMessage.contactIds withGroupId:alMessage.groupId withConversationId:alMessage.conversationId notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
        }];
    }

}

- (void)delivered:(NSString *)messageKey contactId:(NSString *)contactId withStatus:(int)status {
    if (messageKey != nil) {
        [self.detailChatViewController updateDeliveryReport:messageKey withStatus:status];
    }
}

- (void)updateStatusForContact:(NSString *) contactId withStatus:(int)status {
    if ([[self.detailChatViewController contactIds] isEqualToString: contactId]) {
        [self.detailChatViewController updateStatusReportForConversation:status];
    }
}

- (void)updateTypingStatus:(NSString *)applicationKey userId:(NSString *)userId status:(BOOL)status {
    ALSLog(ALLoggerSeverityInfo, @"==== (MSG_VC) Received typing status %d for: %@ ====", status, userId);
    ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
    ALContact *alContact = [contactDBService loadContactByKey:@"userId" value: userId];
    if ((alContact.block || alContact.blockBy) && !self.detailChatViewController.channelKey) {
        return;
    }
    
    if ([self.detailChatViewController.contactIds isEqualToString:userId] || self.detailChatViewController.channelKey) {
        [self.detailChatViewController showTypingLabel:status userId:userId];
    }
}

- (void)updateLastSeenAtStatus:(ALUserDetail *) alUserDetail {
    if ([self.detailChatViewController.contactIds isEqualToString:alUserDetail.userId]) {
        [self.detailChatViewController updateLastSeenAtStatus:alUserDetail];
    } else if ([ALApplozicSettings getSubGroupLaunchFlag] || [ALApplozicSettings getGroupOfTwoFlag]) {
        [self.mTableView reloadData];
    } else {
        ALContactCell *contactCell = [self getCell:alUserDetail.userId];
        [contactCell.onlineImageMarker setHidden:YES];
        if (alUserDetail.connected && [ALApplozicSettings getVisibilityForOnlineIndicator]) {
            [contactCell.onlineImageMarker setHidden:NO];
        }
        
        ALContactDBService *contactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [contactDBService loadContactByKey:@"userId" value:alUserDetail.userId];
        BOOL isUserDeleted = [contactDBService isUserDeleted:alUserDetail.userId];
        if (alContact.block || alContact.blockBy || isUserDeleted) {
            [contactCell.onlineImageMarker setHidden:YES];
        }
    }
}

- (void)updateLastSeenAtStatusPUSH:(NSNotification*)notification {
    [self updateLastSeenAtStatus:notification.object];
}

- (void)mqttConnectionClosed {

    if (self.mqttRetryCount >= ALMQTT_MAX_RETRY) {
        return;
    }

    BOOL isBackgroundState = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);

    if ([ALDataNetworkConnection checkDataNetworkAvailable]
        && !isBackgroundState) {
        __weak ALMessagesViewController *weakSelf = self;

        double intervalSeconds = 0.0;

        if (self.mqttRetryCount == 1) {
            intervalSeconds = [ALUtilityClass randomNumberBetween:1 maxNumber:10] * 60.0;
        } else if (self.mqttRetryCount == 2) {
            intervalSeconds = [ALUtilityClass randomNumberBetween:10 maxNumber:20] * 60.0;
        }

        self.mqttRetryCount++;
        
        ALSLog(ALLoggerSeverityError, @"MQTT retry in MessagesViewController will start after %.f seconds and the retry count is : %ld",intervalSeconds, (long)self.mqttRetryCount);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(intervalSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [weakSelf subscribeToConversationWithCompletionHandler:^(BOOL connected) {
                if (!connected) {
                    ALSLog(ALLoggerSeverityError, @"MQTT subscribe to conversation failed to retry on mqttConnectionClosed in ALMessagesViewController");
                }
            }];
        });
    }
}

- (void)subscribeToConversationWithCompletionHandler:(void (^)(BOOL connected))completion  {

    if ([ALDataNetworkConnection checkDataNetworkAvailable]) {
        if (self.alMqttConversationService) {
            [self.alMqttConversationService subscribeToConversationWithTopic:[ALUserDefaultsHandler getUserKeyString] withCompletionHandler:^(BOOL subscribed, NSError *error) {
                if (error) {
                    completion(false);
                    return;
                }
                completion(true);
            }];
        }
    } else {
        completion(false);
    }
}

- (void)keybordDidHideNotification {

    if ([self.navigationController.visibleViewController isKindOfClass:self.class]
        && [ALApplozicSettings isMessageSearchEnabled]
        && [self.searchController.searchBar.text isEqualToString:@""]) {
        self.navigationItem.titleView = nil;
        [self setupNavigationButtons];
    }
}

- (void)onAppDidBecomeActive {
    [self callLastSeenStatusUpdate];
    // Check for any new messages in data base for current latest message createdAtTime
    NSMutableArray *messagesArray = self.mContactsMessageListArray;
    if (messagesArray.count > 0) {
        ALMessage *message = messagesArray.firstObject;
        ALConversationListRequest *conversationListRequest = [[ALConversationListRequest alloc] init];
        conversationListRequest.endTimeStamp = [NSNumber numberWithLong:(message.createdAtTime.longValue + 1)];
        NSMutableArray *latestMessageArray = [self.dBService fetchLatestMessagesFromDatabaseWithRequestList:conversationListRequest];
        [self addMessageToListWithMessageArray:latestMessageArray];
    }
}

- (void)callLastSeenStatusUpdate {
    [self.userService getLastSeenUpdateForUsers:[ALUserDefaultsHandler getLastSeenSyncTime] withCompletion:^(NSMutableArray *userDetailArray)
     {
        for(ALUserDetail *userDetail in userDetailArray) {
            [self updateLastSeenAtStatus:userDetail];
        }
    }];
}

- (ALMessage *)getMessageFromAlertValue:(NSString *) alertValue {
    ALMessage *msg = [[ALMessage alloc] init];
    msg.message = alertValue;
    NSArray *myArray = [msg.message componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    if (myArray.count > 1) {
        alertValue = [NSString stringWithFormat:@"%@", myArray[1]];
    } else {
        alertValue = myArray[0];
    }
    msg.message = alertValue;
    msg.groupId = self.channelKey;
    return msg;
}

- (void)pushNotificationhandler:(NSNotification *) notification {
    NSString *notificationObject = notification.object;
    NSString *contactId = nil;
    NSNumber *conversationId = nil;
    NSArray *myArray = [notificationObject componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    if (myArray.count > 2) {
        self.channelKey = @([ myArray[1] intValue]);
        contactId = myArray[2];
    } else if (myArray.count == 2) {
        self.channelKey = nil;
        contactId = myArray[0];
        conversationId = @([myArray[1] intValue]);
    } else {
        self.channelKey = nil;
        contactId = myArray[0];
    }
    
    
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    NSString *alertValue = [dict valueForKey:@"alertValue"];
    
    ALMessage *message = [self getMessageFromAlertValue:alertValue];
    message.contactIds = contactId;
    message.groupId = self.channelKey;
    if (conversationId) {
        message.conversationId = conversationId;
    }
    
    if (self.isViewLoaded && self.view.window && [updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]]) {
        [self syncCall:message andMessageList:nil];
    } else if ([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]]) {
        [self createDetailChatViewControllerWithMessage:message];
        //      [self.detailChatViewController fetchAndRefresh];
        [self.detailChatViewController setRefresh: YES];
    } else if ([NSNumber numberWithInt:APP_STATE_BACKGROUND]) {
        /*
         # Synced before already!
         # NSLog(@"APP_STATE_BACKGROUND HANDLER");
         */
    }
}

- (void)dealloc {
    [self.alMqttConversationService unsubscribeToConversation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USER_DETAILS_UPDATE_CALL" object:nil];
}

- (IBAction)backButtonAction:(id)sender {
    UIViewController *uiController = [self.navigationController popViewControllerAnimated:YES];
    if (!uiController) {
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)getVisibleState {
    if ((self.isViewLoaded && self.view.window) ||
        (self.detailChatViewController && self.detailChatViewController.isViewLoaded && self.detailChatViewController.view.window)) {
        ALSLog(ALLoggerSeverityInfo, @"VIEW_CONTROLLER IS VISIBLE");
        return YES;
    } else {
        ALSLog(ALLoggerSeverityInfo, @"VIEW_CONTROLLER IS NOT VISIBLE");
        return NO;
    }
}

//==============================================================================================================================================
#pragma mark - CUSTOM NAVIGATION BACK BUTTON
//==============================================================================================================================================

- (UIView *)setCustomBackButton:(NSString *)text {
    UIImage *backImage = [ALUIUtilityClass getImageFromFramworkBundle:@"bbb.png"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backImage];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[ALApplozicSettings getColorForNavigationItem]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5,
                                                               imageView.frame.origin.y + 5 , 20, 15)];
    
    [label setTextColor:[ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                            imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    
    view.bounds = CGRectMake(view.bounds.origin.x + 8, view.bounds.origin.y - 1, view.bounds.size.width, view.bounds.size.height);
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        label.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    [view addSubview:imageView];
    [view addSubview:label];
    
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    backTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:backTap];
    return view;
}

- (void)back:(id)sender {
    UIViewController *uiController = [self.navigationController popViewControllerAnimated:YES];
    if (!uiController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)newMessageHandler:(NSNotification *)notification {

    NSMutableArray *messageArray = notification.object;
    [self addMessageToListWithMessageArray:messageArray];
}

- (void)addMessageToListWithMessageArray:(NSMutableArray *)messageArray {

    if (messageArray.count < 1) {
        return;
    }

    NSMutableArray *allMessagesArray = self.mContactsMessageListArray;
    ALChannelService *channelService = [[ALChannelService alloc]init];


    for(ALMessage *message in messageArray) {

        if ([message isVOIPNotificationMessage]) {
            continue;
        }

        NSArray *theFilteredArray;
        if ([message getGroupId]) {

            theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"groupId = %@",[message getGroupId]]];
        } else {
            theFilteredArray = [self.mContactsMessageListArray filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"contactIds = %@ AND groupId = %@",message.contactIds,nil]];
        }


        if (message.groupId) {

            ALChannel *channel =  [channelService getChannelByKey:message.groupId];

            BOOL channelFlag = ([ALApplozicSettings getSubGroupLaunchFlag] && [channel.parentKey isEqualToNumber:self.parentGroupKey]);
            BOOL categoryFlag =  [ALApplozicSettings getCategoryName] && [channel isPartOfCategory:[ALApplozicSettings getCategoryName]];

            BOOL ignoreMessageAddingFlag =  (channelFlag || categoryFlag || !([ALApplozicSettings getSubGroupLaunchFlag] || [ALApplozicSettings getCategoryName]));

            if (!ignoreMessageAddingFlag) {
                continue;
            }
        }


        NSUInteger index = 0;
        if (theFilteredArray.count) {
            ALMessage *firstMessage = theFilteredArray.firstObject;
            index = [allMessagesArray indexOfObject:firstMessage];
            if (index != NSNotFound ) {
                allMessagesArray[index] = message;
            }
        } else {
            [allMessagesArray addObject:message];
        }

    }
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAtTime" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    [allMessagesArray sortUsingDescriptors:descriptors];

    self.mContactsMessageListArray = allMessagesArray;
    [self emptyConversationAlertLabel];
    [self.mTableView reloadData];
}

//==============================================================================================================================================
#pragma mark - CREATE GROUP METHOD
//==============================================================================================================================================

- (IBAction)createGroup:(id)sender {
    if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
        [self noDataNotificationView];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:[self class]]];
    
    ALGroupCreationViewController *groupCreation = (ALGroupCreationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ALGroupCreationViewController"];
    
    groupCreation.isViewForUpdatingGroup = NO;
    
    if ([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId) {
        [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    }
    
    if (self.parentGroupKey && [ALApplozicSettings getSubGroupLaunchFlag]) {
        groupCreation.parentChannelKey = self.parentGroupKey;
    }
    
    [self.navigationController pushViewController:groupCreation animated:YES];
}

- (void)noDataNotificationView {
    ALNotificationView *notification = [ALNotificationView new];
    [notification noDataConnectionNotificationView];
}

- (void)createAndLaunchChatView {
    if (!(self.detailChatViewController)) {
        self.detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    }
    
    self.detailChatViewController.contactIds = self.userIdToLaunch;
    self.detailChatViewController.channelKey = self.channelKey;
    self.detailChatViewController.chatViewDelegate = self;
    [self.detailChatViewController serverCallForLastSeen];
    
    [self.navigationController pushViewController:self.detailChatViewController animated:YES];
}

- (void)insertChannelMessage:(NSNumber *)channelKey {
    ALMessage *channelMessage = [ALMessage new];
    channelMessage.groupId = channelKey;
    NSMutableArray *grpMesgArray = [[NSMutableArray alloc] initWithObjects:channelMessage, nil];
    [self updateMessageList:grpMesgArray];
}

- (IBAction)createBroadcastGroup:(id)sender {
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
        [self noDataNotificationView];
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:[self class]]];

    if ([ALApplozicSettings isContactsGroupEnabled ] && _contactsGroupId) {
        [ALApplozicSettings setContactsGroupId:_contactsGroupId];
    }
    ALNewContactsViewController *contactVC = (ALNewContactsViewController *)[storyboard
                                                                             instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    contactVC.forGroup = [NSNumber numberWithInt:BROADCAST_GROUP_CREATION];
    [self.navigationController pushViewController:contactVC animated:YES];
}

- (void)onLoggedInUserDeactivated:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;

    if (!userInfo ||
        !self.startNewButton) {
        return;
    }

    [self.startNewButton setEnabled:![[userInfo valueForKey:@"DEACTIVATED"] isEqualToString:@"true"]];
}

//==============================================================================================================================================
#pragma mark - CHAT VIEW DELEGATE FOR PUSH Custom VC
//==============================================================================================================================================

- (void)handleCustomActionFromChatVC:(UIViewController *)chatViewController andWithMessage:(ALMessage *)alMessage {
    [self.messagesViewDelegate handleCustomActionFromMsgVC:chatViewController andWithMessage:alMessage];
}

//==============================================================================================================================================
#pragma mark - TABLE SCROLL DELEGATE METHOD
//==============================================================================================================================================

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.parentGroupKey && [ALApplozicSettings getSubGroupLaunchFlag]) {
        ALSLog(ALLoggerSeverityInfo, @"NOT REQUIRE FOR PARENT GROUP");
        return;
    }
    
    ALSLog(ALLoggerSeverityInfo, @"END_SCROCLLING_TRY");
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    
    if (y > (h - reload_distance)) {
        [self fetchMoreMessages:scrollView];
    }
}

- (void)fetchMoreMessages:(UIScrollView*)aScrollView {
    [self.mActivityIndicator startAnimating];
    [self.mTableView setUserInteractionEnabled:NO];
    
    if (![ALUserDefaultsHandler getFlagForAllConversationFetched]) {
        [self.dBService fetchConversationfromServerWithCompletion:^(BOOL flag) {

            [self.mActivityIndicator stopAnimating];
            [self.mTableView setUserInteractionEnabled:YES];
        }];
    } else {
        if ([ALApplozicSettings getVisibilityForNoMoreConversationMsgVC]) {
            [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
            [TSMessage showNotificationWithTitle:NSLocalizedStringWithDefaultValue(@"noMoreConversations", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No more conversations", @"")
                                            type:TSMessageNotificationTypeWarning];
        }
        [self.mActivityIndicator stopAnimating];
        [self.mTableView setUserInteractionEnabled:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        [self.searchResultVC searchWithKey:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if ([searchText isEqual: @""]) {
        [self.searchResultVC clearAndShowEmptyView];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [self.searchResultVC clearAndShowEmptyView];
    [self.customSearchBar show:NO];
    [self.customSearchBar resignFirstResponder];
    self.navigationItem.titleView = nil;
    [self setupNavigationButtons];
}

- (void)onMessageMetaDataUpdate:(NSNotification *)notification {
    if (self.mContactsMessageListArray.count == 0) {
        return;
    }
    
    ALMessage *message = (ALMessage *)notification.object;
    NSIndexPath *path = [self getIndexPathForMessage:message.key];
    if ([self isValidIndexPath:path]) {
        ALMessage *alMessage = self.mContactsMessageListArray[path.row];
        if ([alMessage.key isEqualToString:message.key]) {
            alMessage.metadata = message.metadata;
            [self reloadDataWithMessageKey:message.key andMessage:alMessage withValidIndexPath:path];
        }
    }
}

- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath {
    return self.mTableView &&
    indexPath.row != -1 &&
    indexPath.section < [self.mTableView numberOfSections] &&
    indexPath.row < [self.mTableView numberOfRowsInSection:indexPath.section];
}

- (void)reloadDataWithMessageKey:(NSString *)messageKey
                      andMessage:(ALMessage *)alMessage
              withValidIndexPath:(NSIndexPath *)path {
    NSInteger newCount = self.mContactsMessageListArray.count;
    NSInteger oldCount = [self.mTableView numberOfRowsInSection:path.section];
    ALMessage *message = self.mContactsMessageListArray[path.row];
    if ([message.key isEqualToString:messageKey]) {
        self.mContactsMessageListArray[path.row] = alMessage;
    }
    if (newCount > oldCount) {
        ALSLog(ALLoggerSeverityInfo, @"Message list shouldn't have more number of rows then the numberOfRowsInSection before update reloading tableView");
        [self.mTableView reloadData];
        return;
    } else {
        [self.mTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
