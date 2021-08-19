//
//  ALNewContactsViewController.m
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALNewContactsViewController.h"
#import "ALNewContactCell.h"
#import "ALChatViewController.h"
#import "ALMessagesViewController.h"
#import "ALColorUtility.h"
#import "UIImageView+WebCache.h"
#import "ALGroupCreationViewController.h"
#import "ALGroupDetailViewController.h"
#import "ALSubViewController.h"
#import "ALNotificationHelper.h"
#import "ALUIUtilityClass.h"
#import "ALChannelCreateResponse.h"

const int DEFAULT_TOP_LANDSCAPE_CONSTANT = 34;
const int DEFAULT_TOP_PORTRAIT_CONSTANT = 64;
static const int REGULAR_CONTACTS = 0;
static const int GROUP_CREATION = 1;
static const int GROUP_ADDITION = 2;
static const int IMAGE_SHARE = 3;
static const int LAUNCH_GROUP_OF_TWO = 4;
static const int BROADCAST_GROUP_CREATION = 5;
static const int SHOW_CONTACTS = 101;
static const int SHOW_GROUP = 102;

@interface ALNewContactsViewController ()<ApplozicAttachmentDelegate>

@property (strong, nonatomic) NSMutableArray *contactList;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) UIAlertController *uiAlertController;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filteredContactList;

@property (strong, nonatomic) NSString *stopSearchText;
@property (strong, nonatomic) ApplozicClient *applozicClient;

@property (nonatomic, retain) UIProgressView *uiProgress;

@property  NSUInteger lastSearchLength;

@property (strong,nonatomic)NSMutableSet *groupMembers;

@property (strong,nonatomic) NSNumber *groupOrContacts;
@property (strong, nonatomic) NSMutableArray *alChannelsList;
@property (nonatomic)NSInteger selectedSegment;
@property (strong, nonatomic) UILabel *emptyConversationText;
@property (strong, nonatomic) ALContactService *contactService;
@property (strong, nonatomic) ALChannelService *channelService;

@end

@implementation ALNewContactsViewController {
    UIBarButtonItem *barButtonItem;
}
@synthesize delegate;

-(void)setupServices {
    self.channelService = [ALChannelService new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupServices];
    [[self activityIndicator] startAnimating];
    self.selectedSegment = 0;
    [ALUserDefaultsHandler setContactServerCallIsDone:NO];

    self.contactService = [[ALContactService alloc] init];
    self.applozicClient = [[ApplozicClient alloc ]initWithApplicationKey:ALUserDefaultsHandler.getApplicationKey];
    self.applozicClient.attachmentProgressDelegate = self;

    [self.segmentControl setTitle:  NSLocalizedStringWithDefaultValue(@"contactsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"") forSegmentAtIndex:0];
    
    [self.segmentControl setTitle:  NSLocalizedStringWithDefaultValue(@"groupsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Groups" , @"") forSegmentAtIndex:1];
    
    self.contactList = [NSMutableArray new];
    [self handleFrameForOrientation];
    [self.contactsTableView setBackgroundColor:[UIColor whiteColor]];

    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,y, self.view.frame.size.width, 40)];
    self.searchBar.delegate = self;
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    self.searchBar.placeholder =  NSLocalizedStringWithDefaultValue(@"searchInfo", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Search..." , @"") ;
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        UITextField *searchTextField = [((UITextField *)[self.searchBar.subviews objectAtIndex:0]).subviews lastObject];
        searchTextField.layer.cornerRadius = 15.0f;
        searchTextField.textAlignment = NSTextAlignmentRight;
    }
    [self.view addSubview:self.searchBar];
    
    [self.searchBar setUserInteractionEnabled:NO];
    if (self.parentChannel) {
        [self launchProcessForSubgroups];
        [self.searchBar setUserInteractionEnabled:YES];
    } else if ([ALApplozicSettings getFilterContactsStatus] && ![ALApplozicSettings isContactsGroupEnabled]) {
        [self proccessRegisteredContactsCall:NO];
    } else if ([ALApplozicSettings getOnlineContactLimit] && ![ALApplozicSettings isContactsGroupEnabled]) {
        [self processFilterListWithLastSeen];
        [self onlyGroupFetch];
        [self.searchBar setUserInteractionEnabled:YES];
    } else if ( [ALApplozicSettings isContactsGroupEnabled] && [ALApplozicSettings getContactsGroupId] && ![ALApplozicSettings getFilterContactsStatus]) {
        [self proccessContactsGroupCall];
    } else if ( [ALApplozicSettings isContactsGroupEnabled] && [ALApplozicSettings getContactGroupIdList] && ![ALApplozicSettings getFilterContactsStatus]) {
        [self proccessContactsGroupList];
    } else {
        [self subProcessContactFetch];
        [self.searchBar setUserInteractionEnabled:YES];
    }

    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton: NSLocalizedStringWithDefaultValue(@"back", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Back" , @"")]];
    
    self.colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
    
    self.groupMembers=[[NSMutableSet alloc] init];
    
    [self emptyConversationAlertLabel];
    
    [self.segmentControl setTintColor:[ALApplozicSettings getNewContactMainColour]];
    [self.segmentControl setBackgroundColor:[ALApplozicSettings getNewContactSubColour]];
    
    UIColor *textColor = [ALApplozicSettings getNewContactTextColour];
    if (textColor != nil) {
        NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:textColor forKey:NSForegroundColorAttributeName];
        [self.segmentControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
        [self.segmentControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateNormal];
    }
    
    [_searchBar setBarTintColor:[ALApplozicSettings getSearchBarTintColour]];
}

- (void)subProcessContactFetch {
    ALChannelDBService *alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchConversationsGroupByContactId];
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

- (void)onlyGroupFetch {
    ALChannelDBService *alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

- (void) dismissKeyboard {
    // add self
    [self.searchBar resignFirstResponder];
}

- (void)viewWillLayoutSubviews {
    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    self.searchBar.frame = CGRectMake(0,y, self.view.frame.size.width, 40);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Due to changes in top layout guide in iOS 11, top constraint was behaving differently and tableview would not be visible properly.
    if (!TS_SYSTEM_VERSION_LESS_THAN(@"11.0")) {
        self.tableViewTopSegmentConstraint.constant = 0;
    }
    self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS]; //default
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"contactsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"");
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    if ([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem]) {
        [self.navigationController.navigationBar setTitleTextAttributes: @{
            NSForegroundColorAttributeName:[ALApplozicSettings getColorForNavigationItem],
            NSFontAttributeName:[UIFont fontWithName:[ALApplozicSettings getFontFace]
                                                size:18]
        }];
        
        [self.navigationController.navigationBar addSubview:[ALUIUtilityClass setStatusBarStyle]];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
        
    }
    
    BOOL groupRegular = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:REGULAR_CONTACTS]];
    BOOL subGroupContacts = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:LAUNCH_GROUP_OF_TWO]];
    
    if (groupRegular) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showMQTTNotification:)
                                                     name:@"MQTT_APPLOZIC_01"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAPNS:)
                                                     name:@"pushNotification"
                                                   object:nil];
    }
    
    if ((!groupRegular && self.forGroup != NULL && !subGroupContacts)) {
        [self updateView];
    }
    
    if ([ALApplozicSettings isGroupListingTabDisabled]) {
        [self.navigationItem setTitle:NSLocalizedStringWithDefaultValue(@"contactsTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Contacts" , @"")];
        [self.segmentControl setSelectedSegmentIndex:0];
        [self.segmentControl setHidden:YES];
    }
    
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    float y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    self.searchBar.frame = CGRectMake(0,y, self.view.frame.size.width, 40);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:@"USER_DETAIL_OTHER_VC" object:nil];
}

- (void)showMQTTNotification:(NSNotification *)notifyObject {
    ALMessage *alMessage = (ALMessage *)notifyObject.object;
    
    BOOL flag = (alMessage.groupId && [ALChannelService isChannelMuted:alMessage.groupId]);
    
    if (![alMessage.type isEqualToString:@"5"] && !flag && ![alMessage isMsgHidden]) {
        ALNotificationView *alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                          withAlertMessage:alMessage.message];
        [alNotification showNativeNotificationWithcompletionHandler:^(BOOL show) {

            ALNotificationHelper *helper = [[ALNotificationHelper alloc] init];

            [helper handlerNotificationClick:alMessage.contactIds withGroupId:alMessage.groupId withConversationId:alMessage.conversationId notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
        }];
    }
}

- (void)handleAPNS:(NSNotification *)notification {
    NSString *contactId = notification.object;
    ALSLog(ALLoggerSeverityInfo, @"CONTACT_VC_NOTIFICATION_OBJECT : %@",contactId);
    NSDictionary *dict = notification.userInfo;
    NSNumber *updateUI = [dict valueForKey:@"updateUI"];
    NSString *alertValue = [dict valueForKey:@"alertValue"];
    
    NSArray *myArray = [contactId componentsSeparatedByString:@":"];
    NSNumber *channelKey = nil;
    if (myArray.count > 2) {
        channelKey = @([myArray[1] intValue]);
    }
    ALPushAssist *pushAssist = [ALPushAssist new];
    if ([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_ACTIVE]] && [pushAssist.topViewController isKindOfClass:[ALNewContactsViewController class]]) {
        ALSLog(ALLoggerSeverityInfo, @"######## CONTACT VC : APP_STATE_ACTIVE #########");
        
        ALMessage *alMessage = [[ALMessage alloc] init];
        alMessage.message = alertValue;
        NSArray *myArray = [alMessage.message componentsSeparatedByString:@":"];
        
        if (myArray.count > 1) {
            alertValue = [NSString stringWithFormat:@"%@", myArray[1]];
        } else {
            alertValue = myArray[0];
        }
        
        alMessage.message = alertValue;
        alMessage.contactIds = contactId;
        alMessage.groupId = channelKey;
        
        if ((channelKey && [ALChannelService isChannelMuted:alMessage.groupId]) || ([alMessage isMsgHidden])) {
            return;
        }
        
        ALNotificationView *alNotification = [[ALNotificationView alloc] initWithAlMessage:alMessage
                                                                          withAlertMessage:alMessage.message];
        [alNotification showNativeNotificationWithcompletionHandler:^(BOOL show) {

            ALNotificationHelper *helper = [[ALNotificationHelper alloc] init];

            [helper handlerNotificationClick:alMessage.contactIds withGroupId:alMessage.groupId withConversationId:alMessage.conversationId notificationTapActionDisable:[ALApplozicSettings isInAppNotificationTapDisabled]];
        }];

    } else if ([updateUI isEqualToNumber:[NSNumber numberWithInt:APP_STATE_INACTIVE]]) {
        ALSLog(ALLoggerSeverityInfo, @"######## CONTACT VC : APP_STATE_INACTIVE #########");
        ALNewContactsViewController *contactVC = self;
        ALMessagesViewController *msgVC = (ALMessagesViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        
        if (channelKey) {
            msgVC.channelKey = channelKey;
        } else {
            msgVC.channelKey = nil;
        }
        
        [msgVC createDetailChatViewController:contactId];
        
        NSMutableArray *viewsArray = [NSMutableArray arrayWithArray:msgVC.navigationController.viewControllers];
        if ([viewsArray containsObject:contactVC]) {
            [viewsArray removeObject:contactVC];
        }
        msgVC.navigationController.viewControllers = viewsArray;
    }
}

- (void)updateView {
    [self.tabBarController.tabBar setHidden:YES];
    [self.segmentControl setSelectedSegmentIndex:0];
    [self.segmentControl setHidden:YES];
    
    BOOL groupCreation = ([self.forGroup isEqualToNumber:[NSNumber numberWithInt:GROUP_CREATION]]
                          || [self.forGroup isEqualToNumber:[NSNumber numberWithInt:BROADCAST_GROUP_CREATION]]);
    if (groupCreation) {
        self.contactsTableView.editing=YES;
        self.contactsTableView.allowsMultipleSelectionDuringEditing = YES;
        self.done = [[UIBarButtonItem alloc]
                     initWithTitle:NSLocalizedStringWithDefaultValue(@"doneText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Done" , @"")
                     style:UIBarButtonItemStylePlain
                     target:self
                     action:@selector(createNewGroup:)];
        
        self.navigationItem.rightBarButtonItem = self.done;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden: NO];
    self.forGroup = [NSNumber numberWithInt:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USER_DETAIL_OTHER_VC" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MQTT_APPLOZIC_01" object:nil];
}

- (void)updateUser:(NSNotification *)notifyObj {
    ALUserDetail *userDetail = (ALUserDetail *)notifyObj.object;
    ALNewContactCell *newContactCell = [self getCell:userDetail.userId];
    if (newContactCell && self.selectedSegment == 0) {
        [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:userDetail.imageLink] placeholderImage:nil options:SDWebImageRefreshCached];
        newContactCell.contactPersonName.text = [userDetail getDisplayName];
    }
}

- (ALNewContactCell *)getCell:(NSString *)key {
    int index = (int)[self.filteredContactList indexOfObjectPassingTest:^BOOL(id element, NSUInteger idx, BOOL *stop) {
        
        ALContact *contact = (ALContact *)element;
        if ([contact.userId isEqualToString:key]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    ALNewContactCell *contactCell = (ALNewContactCell *)[self.contactsTableView cellForRowAtIndexPath:path];
    
    return contactCell;
}

- (void)emptyConversationAlertLabel {
    if (self.filteredContactList.count) {
        return;
    }
    
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.origin.y + self.view.frame.size.height/2,
                                                                           self.view.frame.size.width, 30)];
    [self.view addSubview:self.emptyConversationText];
    
    [self setTextForEmpty];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.emptyConversationText setHidden:YES];
}

- (void)setTextForEmpty {
    
    NSString *msgText = NSLocalizedStringWithDefaultValue(@"noContactFoundText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No contact found" , @"");
    if (self.selectedSegment == 1) {
        msgText = NSLocalizedStringWithDefaultValue(@"noContactFoundText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"No group found" , @"");
    }
    [self.emptyConversationText setText:msgText];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsTableView?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.filteredContactList.count;
    if (self.selectedSegment == 1) {
        count = self.filteredContactList.count;
    }
    if (count == 0) {
        if (![self.activityIndicator isAnimating]) {
            [self.emptyConversationText setHidden:NO];
            [self setTextForEmpty];
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *individualCellIdentifier = @"NewContactCell";
    ALNewContactCell *newContactCell = (ALNewContactCell *)[tableView dequeueReusableCellWithIdentifier:individualCellIdentifier];
    NSUInteger randomIndex = random()% [self.colors count];
    UILabel *nameIcon = (UILabel*)[newContactCell viewWithTag:101];
    [nameIcon setTextColor:[UIColor whiteColor]];
    [nameIcon setHidden:YES];
    [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil options:SDWebImageRefreshCached];
    newContactCell.contactPersonName.text = @"";
    [newContactCell.contactPersonImageView setHidden:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        newContactCell.contactPersonImageView.layer.cornerRadius = newContactCell.contactPersonImageView.frame.size.width/2;
        newContactCell.contactPersonImageView.layer.masksToBounds = YES;
    });
    
    [self.emptyConversationText setHidden:YES];
    [self.contactsTableView setHidden:NO];
    
    @try {
        switch (self.groupOrContacts.intValue) {
            case SHOW_CONTACTS: {
                ALContact *contact = (ALContact *)[self.filteredContactList objectAtIndex:indexPath.row];
                newContactCell.contactPersonName.text = [contact getDisplayName];
                
                
                if (contact) {
                    if (contact.contactImageUrl) {
                        [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:contact.contactImageUrl] placeholderImage:[ALUIUtilityClass getImageFromFramworkBundle:@"contact_default_placeholder"] options:SDWebImageRefreshCached];
                        
                    } else {
                        [nameIcon setHidden:NO];
                        [newContactCell.contactPersonImageView setImage:[ALColorUtility imageWithSize:CGRectMake(0, 0, 55, 55)
                                                                                        WithHexString:self.colors[randomIndex]]];
                        [newContactCell.contactPersonImageView addSubview:nameIcon];
                        [nameIcon  setText:[ALColorUtility getAlphabetForProfileImage:[contact getDisplayName]]];
                    }
                    
                    if (self.forGroup.intValue == GROUP_ADDITION && [self.contactsInGroup containsObject:contact.userId]) {
                        newContactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
                        newContactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
                    } else if ((self.forGroup.intValue == GROUP_CREATION || self.forGroup.intValue == BROADCAST_GROUP_CREATION) && [contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]) {
                        [self disableOrRemoveCell:newContactCell];
                    } else {
                        newContactCell.backgroundColor = [UIColor whiteColor];
                        newContactCell.selectionStyle = UITableViewCellSelectionStyleGray ;
                    }
                    
                    for (NSString *userID in  self.groupMembers) {
                        if ([userID isEqualToString:contact.userId]) {
                            
                            
                            [self.contactsTableView selectRowAtIndexPath:indexPath
                                                                animated:YES
                                                          scrollPosition:UITableViewScrollPositionNone];
                            [self tableView:self.contactsTableView didSelectRowAtIndexPath:indexPath];
                            
                            ALSLog(ALLoggerSeverityInfo, @"SELECTED:%@",contact.userId);
                            
                        } else {
                            ALSLog(ALLoggerSeverityInfo, @"NOT SELECTED :%@",contact.userId);
                        }
                    }
                }
            }break;
            case SHOW_GROUP: {
                if (self.filteredContactList.count) {
                    ALChannel *channel = (ALChannel *)[self.filteredContactList objectAtIndex:indexPath.row];
                    newContactCell.contactPersonName.text = [channel name];
                    newContactCell.contactPersonImageView.image = [ALUIUtilityClass getImageFromFramworkBundle:@"applozic_group_icon"];
                    [ALUIUtilityClass downloadImageUrlAndSet:channel.channelImageURL imageView:newContactCell.contactPersonImageView defaultImage:@"applozic_group_icon"];
                    [nameIcon setHidden:YES];
                } else {
                    [self.contactsTableView setHidden:YES];
                    [self.emptyConversationText setHidden:NO];
                    [self setTextForEmpty];
                }
            }break;
            default:
                break;
        }
        
    } @catch (NSException *exception) {
        
        ALSLog(ALLoggerSeverityInfo, @"RAISED_EXP :: %@",exception.description);
    }

    return newContactCell;
}
- (void)disableOrRemoveCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    [contactCell setUserInteractionEnabled:NO];
    
}

- (void)maskOutCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    contactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.forGroup.intValue) {
        case GROUP_CREATION: {
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            [self.groupMembers addObject:contact.userId];
        }break;
        case BROADCAST_GROUP_CREATION: {
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            [self.groupMembers addObject:contact.userId];
        }break;
        case GROUP_ADDITION: {
            if (![self checkInternetConnectivity:tableView andIndexPath:indexPath]) {
                return;
            }
            
            ALContact *contact = self.filteredContactList[indexPath.row];
            
            if ([self.contactsInGroup containsObject:contact.userId]) {
                return;
            }
            
            [self turnUserInteractivityForNavigationAndTableView:NO];
            [delegate addNewMembertoGroup:contact withCompletion:^(NSError *error, ALAPIResponse *response) {
                
                if (error) {
                    [TSMessage showNotificationWithTitle:NSLocalizedStringWithDefaultValue(@"unableToAddMemberText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to add new member" , @"") type:TSMessageNotificationTypeError];

                    [self setUserInteraction:YES];
                } else {
                    
                    [self backToDetailView];
                    [self turnUserInteractivityForNavigationAndTableView:YES];
                    [self setUserInteraction:YES];
                }
                
            }];
        }break;
        case IMAGE_SHARE:{
        }break;
        case LAUNCH_GROUP_OF_TWO: {
            if (self.selectedSegment == 0) {
                ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
                [self initiateGroupOfTwoChat:self.parentChannel andUser:contact];
            } else {
                ALChannel *channel = [self.filteredContactList objectAtIndex:indexPath.row];
                [self launchChatForContact:nil withChannelKey:channel.key];
            }
        }break;
        default: { //DEFAULT : Launch contact!
            NSNumber *key = nil;
            NSString *userId = @"";
            if (self.selectedSegment == 0) {
                ALContact *selectedContact = self.filteredContactList[indexPath.row];
                userId = selectedContact.userId;
            } else {
                ALChannel *selectedChannel = self.filteredContactList[indexPath.row];
                key = selectedChannel.key;
                userId = nil;
            }
            [self launchChatForContact:userId withChannelKey:key];
        }
            
    }
}

- (void)setUserInteraction:(BOOL)flag {
    [self.contactsTableView setUserInteractionEnabled:flag];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.forGroup isEqualToNumber:[NSNumber numberWithInt:1]]) {
        ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
        [self.groupMembers removeObject:contact.userId];
    }
}

- (BOOL)checkInternetConnectivity:(UITableView*)tableView andIndexPath:(NSIndexPath *)indexPath {
    if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
        [[self activityIndicator] stopAnimating];
        ALNotificationView *notification = [ALNotificationView new];
        [notification noDataConnectionNotificationView];
        if (tableView) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return NO;
    }
    return YES;
}

- (void) fetchConversationsGroupByContactId {
    
    ALDBHandler *theDbHandler = [ALDBHandler sharedInstance];
    
    // get all unique contacts
    
    NSFetchRequest *theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    
    [theRequest setReturnsDistinctResults:YES];
    NSPredicate *contactFilterPredicate;
    NSMutableArray *filterArray =  [ALApplozicSettings getContactTypeToFilter];
    
    if (filterArray) {
        contactFilterPredicate = [NSPredicate predicateWithFormat:@"contactType IN %@", filterArray];
    }

    NSString *supportUserId = [ALApplozicSettings getSupportContactUserId];

    if (![ALUserDefaultsHandler getLoginUserConatactVisibility]) {
        NSPredicate *predicate = nil;
        if (supportUserId && supportUserId.length > 0) {
            NSArray *userIdArray = [[NSArray alloc] initWithObjects:[ALUserDefaultsHandler getUserId], supportUserId, nil];
            predicate = [NSPredicate predicateWithFormat:@"NOT (userId IN %@) AND deletedAtTime == nil", userIdArray];

        } else {
            predicate = [NSPredicate predicateWithFormat:@"userId !=%@ AND deletedAtTime == nil", [ALUserDefaultsHandler getUserId]];
        }

        if (contactFilterPredicate) {
            contactFilterPredicate =[NSCompoundPredicate andPredicateWithSubpredicates:@[contactFilterPredicate, predicate]];
        } else {
            contactFilterPredicate =predicate;
        }
    }
    
    if (contactFilterPredicate) {
        [theRequest setPredicate:contactFilterPredicate];
    }
    
    NSArray *theArray = [theDbHandler executeFetchRequest:theRequest withError:nil];

    if (theArray.count > 0) {
        for (DB_CONTACT *dbContact in theArray) {

            ALContact *contact = [[ALContact alloc] init];

            contact.userId = dbContact.userId;
            contact.fullName = dbContact.fullName;
            contact.contactNumber = dbContact.contactNumber;
            contact.displayName = dbContact.displayName;
            contact.contactImageUrl = dbContact.contactImageUrl;
            contact.email = dbContact.email;
            contact.localImageResourceName = dbContact.localImageResourceName;
            contact.contactType = dbContact.contactType;
            contact.status = dbContact.status;
            [self.contactList addObject:contact];
        }

        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.filteredContactList = [NSMutableArray arrayWithArray:[self.contactList sortedArrayUsingDescriptors:descriptors]];

        if (supportUserId && supportUserId.length > 0) {
            ALContact *supportContact = [self.contactService loadContactByKey:@"userId" value:supportUserId];
            [self.filteredContactList insertObject:supportContact atIndex:0];
        }

        [self.contactList removeAllObjects];
        self.contactList = [NSMutableArray arrayWithArray:self.filteredContactList];
        [[self activityIndicator] stopAnimating];
        [self.contactsTableView reloadData];

    } else {
        [[self activityIndicator] stopAnimating];
    }

}

#pragma mark orientation method
//=============================
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleFrameForOrientation];
    
}

- (void)handleFrameForOrientation {
    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
        (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)) {
        self.mTableViewTopConstraint.constant = - DEFAULT_TOP_LANDSCAPE_CONSTANT;
    } else {
        self.mTableViewTopConstraint.constant = - DEFAULT_TOP_PORTRAIT_CONSTANT;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    // Do the search...
    ALChatViewController *theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    theVC.contactIds = searchBar.text;
    if (self.selectedSegment == 0 && [ALApplozicSettings isContactSearchEnabled]) {
        [[self activityIndicator] startAnimating];
        
        if (searchBar.text) {
            ALUserService *userservice = [[ALUserService alloc] init];
            [userservice getListOfUsersWithUserName:searchBar.text withCompletion:^(ALAPIResponse *response, NSError *error) {
                
                if (!error &&  [response.status isEqualToString:@"success"]) {
                    [self.filteredContactList removeAllObjects];
                    [self.contactList removeAllObjects];
                    [self subProcessContactFetch];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getSerachResult:self.stopSearchText];
                    });
                }
                [[self activityIndicator] stopAnimating];
                
            }];
        }
    }
    
    
}

#pragma mark - Search Bar Delegate Methods -
//========================================
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.stopSearchText = searchText;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSerachResult:searchText];
    });
    
}

- (void)getSerachResult:(NSString*)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *searchPredicate;
        
        if (self.selectedSegment == 0) {
            searchPredicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ OR userId CONTAINS[cd] %@ OR contactNumber CONTAINS[cd] %@ OR fullName CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@", searchText, searchText, searchText, searchText,searchText];
        } else {
            searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        }
        
        if (self.lastSearchLength > searchText.length) {
            NSArray *searchResults;
            if (self.selectedSegment == 0) {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            } else {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        } else {
            NSArray *searchResults;
            if (self.selectedSegment == 0) {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            } else {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
    } else {
        [self.filteredContactList removeAllObjects];
        if (self.selectedSegment == 0) {
            [self.filteredContactList addObjectsFromArray:self.contactList];
        } else {
            [self.filteredContactList addObjectsFromArray:self.alChannelsList];
        }
        
    }
    
    self.lastSearchLength = searchText.length;
    [self.contactsTableView reloadData];
}


- (void)back:(id)sender {
    if (self.directContactVCLaunch || self.directContactVCLaunchForForward) {
        if (self.directContactVCLaunch) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_SHARE_EXTENSION" object:nil];
        }
        [self  dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIViewController *viewControllersFromStack = [self.navigationController popViewControllerAnimated:YES];
        if (!viewControllersFromStack) {
            self.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)launchChatForContact:(NSString *)contactId  withChannelKey:(NSNumber*)channelKey {
    
    
    if (self.directContactVCLaunchForForward)  {
        switch (self.selectedSegment) {
            case 0:
                if (![self.contactService isUserDeleted:contactId]) {
                    self.alMessage.contactIds = contactId;
                    self.alMessage.to = contactId;
                    self.alMessage.groupId = nil;
                    [self.forwardDelegate proccessReloadAndForwardMessage:self.alMessage];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    ALSLog(ALLoggerSeverityInfo, @"User is deleted !!");
                }
                break;
            case 1: {
                if (![self.channelService isChannelLeft:channelKey] && ![ALChannelService isChannelDeleted:channelKey]) {
                    self.alMessage.contactIds = nil;
                    self.alMessage.groupId = channelKey;
                    [self.forwardDelegate proccessReloadAndForwardMessage:self.alMessage];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    ALSLog(ALLoggerSeverityInfo, @"Group is deleted or your not in this group !!");
                }
            } break;
            default:
                break;
        }
        
        return;
    } else if (self.directContactVCLaunch) {
        self.alMessage.contactIds = contactId;
        self.alMessage.groupId = channelKey;
        [self showAlertControllerView];
        [self sendMessage:self.alMessage];
        return;
    }
    
    BOOL isFoundInBackStack = false;
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *currentVC in viewControllersFromStack) {
        ALSLog(ALLoggerSeverityInfo, @"IN_NAVIGATION-BAR ::VCs : %@",currentVC.description);
        if ([currentVC isKindOfClass:[ALMessagesViewController class]]) {
            [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
            ALSLog(ALLoggerSeverityInfo, @"IN_NAVIGATION-BAR :: found in backStack .....launching from current vc");
            [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
            isFoundInBackStack = true;
        } else if ([currentVC isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]) {
            [self launchChatWithUserId:contactId orChannelKey:channelKey];
            isFoundInBackStack = true;
            break;
        }
    }
    
    if (!isFoundInBackStack) {
        ALSLog(ALLoggerSeverityInfo, @"NOT_FOUND_IN_BACKSTACK_OF_NAVIAGTION");
        self.tabBarController.selectedIndex=0;
        UINavigationController *uicontroller =  self.tabBarController.selectedViewController;
        NSMutableArray *viewControllersFromStack = [uicontroller.childViewControllers mutableCopy];
        
        for (UIViewController *currentVC in viewControllersFromStack) {
            if ([currentVC isKindOfClass:[ALMessagesViewController class]]) {
                [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
                ALSLog(ALLoggerSeverityInfo, @"IN_TAB-BAR :: found in backStack .....launching from current vc");
                [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
            }
        }
    } else {
        //remove ALNewContactsViewController from back stack...
        
        viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
        if (viewControllersFromStack.count >=2 &&
            [[viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]]) {
            [viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
            self.navigationController.viewControllers = viewControllersFromStack;
        }
    }
}

- (void)showAlertControllerView{
    self.uiAlertController = [UIAlertController alertControllerWithTitle:@""
                                                                 message:NSLocalizedStringWithDefaultValue(@"SendingMessage", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Sending..." , @"")
                                                          preferredStyle:UIAlertControllerStyleAlert];

    self.uiProgress = [[UIProgressView alloc] init];

    [self.uiProgress setProgress:0];

    self.uiProgress.frame = CGRectMake(10, 17,
                                       250,0);
    [self.uiAlertController.view addSubview:self.uiProgress];
    [self presentViewController:self.uiAlertController animated:YES completion:nil];
}

- (UIView *)setCustomBackButton:(NSString *)text {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [ALUIUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , @"back".length, 15)];
    [label setTextColor: [ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        label.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
    
}

#pragma mark- Segment Control
//===========================
- (IBAction)segmentControlAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    self.selectedSegment = segmentedControl.selectedSegmentIndex;
    [self.filteredContactList removeAllObjects];
    
    if (self.selectedSegment == 0) {
        //toggle the Contacts view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.contactList];
    } else {
        //toggle the Group view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_GROUP];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.alChannelsList];
    }
    [self.contactsTableView reloadData];
}

#pragma mark - Create group method
//================================
- (void)createNewGroup:(id)sender {
    if (![self checkInternetConnectivity:nil andIndexPath:nil]) {
        return;
    }
    
    BOOL isForBroadCast = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:BROADCAST_GROUP_CREATION]];
    
    [self turnUserInteractivityForNavigationAndTableView:NO];
    //check whether at least two memebers selected
    if (self.groupMembers.count < 2 && !isForBroadCast) {
        
        [self turnUserInteractivityForNavigationAndTableView:YES];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedStringWithDefaultValue(@"groupMembersTitle", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Group Members" , @"")
                                              message:NSLocalizedStringWithDefaultValue(@"selectMembersText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Please select minimum two members" , @"")
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [ALUIUtilityClass setAlertControllerFrame:alertController andViewController:self];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringWithDefaultValue(@"okText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"OK", @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
            ALSLog(ALLoggerSeverityInfo, @"OK action");
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
        
    }
    
    //Server Call
    NSMutableArray *memberList = [NSMutableArray arrayWithArray:self.groupMembers.allObjects];
    if ([ALApplozicSettings getSubGroupLaunchFlag]) {

        ALChannelInfo *channelInfo = [[ALChannelInfo alloc] init];
        channelInfo.groupName = self.groupName;
        channelInfo.groupMemberList = memberList;
        channelInfo.imageUrl = self.groupImageURL;
        channelInfo.type = PUBLIC;
        channelInfo.parentKey = self.parentChannel.key;

        [self.channelService createChannelWithChannelInfo:channelInfo withCompletion:^(ALChannelCreateResponse *response, NSError *error) {
            [[self activityIndicator] stopAnimating];

            if (!error
                && [response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];

                for (UIViewController *aViewController in allViewControllers) {
                    if ([aViewController isKindOfClass:[ALMessagesViewController class]]) {
                        ALMessagesViewController *messageVC = (ALMessagesViewController *)aViewController;
                        [messageVC insertChannelMessage:response.alChannel.key];
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }

            } else {
                [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"") type:TSMessageNotificationTypeError];
                [self turnUserInteractivityForNavigationAndTableView:YES];
            }
        }];
    } else if (isForBroadCast) {
        [self.channelService createBroadcastChannelWithMembersList:memberList
                                                        andMetaData:nil
                                                     withCompletion:^(ALChannel *alChannel, NSError *error) {
            if (alChannel) {
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                for (UIViewController *aViewController in allViewControllers) {
                    if ([aViewController isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]) {

                        [self.navigationController popToViewController:aViewController animated:YES];

                    } else if ([aViewController isKindOfClass:[ALMessagesViewController class]]) {
                        ALMessagesViewController *messageVC = (ALMessagesViewController *)aViewController;
                        [messageVC insertChannelMessage:alChannel.key];
                        [self.navigationController popToViewController:aViewController animated:YES];
                    } else if ([ALPushAssist isViewObjIsMsgContainerVC:aViewController]) {
                        ALSubViewController *msgSubView = (ALSubViewController *)aViewController;
                        [msgSubView.msgView insertChannelMessage:alChannel.key];
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
            } else {
                [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"")  type:TSMessageNotificationTypeError];
                [self turnUserInteractivityForNavigationAndTableView:YES];
            }

            [[self activityIndicator] stopAnimating];
        }];
    } else {
        NSInteger channelType = PUBLIC;
        if ([ALApplozicSettings getDefaultGroupType]) {
            channelType = [ALApplozicSettings getDefaultGroupType];
        }

        ALChannelInfo *channelInfo = [[ALChannelInfo alloc] init];
        channelInfo.groupName = self.groupName;
        channelInfo.groupMemberList = memberList;
        channelInfo.imageUrl = self.groupImageURL;
        channelInfo.type = channelType;

        [self.channelService createChannelWithChannelInfo:channelInfo withCompletion:^(ALChannelCreateResponse *response, NSError *error) {
            [[self activityIndicator] stopAnimating];

            if (!error
                && [response.status isEqual:AL_RESPONSE_SUCCESS]) {
                //Updating view, popping to MessageList View
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];

                for (UIViewController *aViewController in allViewControllers) {
                    if ([aViewController isKindOfClass:NSClassFromString([ALApplozicSettings getMsgContainerVC])]) {

                        [self.navigationController popToViewController:aViewController animated:YES];

                    } else if ([aViewController isKindOfClass:[ALMessagesViewController class]]) {
                        ALMessagesViewController *messageVC = (ALMessagesViewController *)aViewController;
                        [messageVC insertChannelMessage:response.alChannel.key];
                        [self.navigationController popToViewController:aViewController animated:YES];
                    } else if ([ALPushAssist isViewObjIsMsgContainerVC:aViewController]) {
                        ALSubViewController *msgSubView = (ALSubViewController*)aViewController;
                        [msgSubView.msgView insertChannelMessage:response.alChannel.key];
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
            } else {
                [TSMessage showNotificationWithTitle: NSLocalizedStringWithDefaultValue(@"unableToCreateGroupText", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to create group. Please try again", @"") type:TSMessageNotificationTypeError];
                [self turnUserInteractivityForNavigationAndTableView:YES];
            }

        }];
    }
    if (![ALDataNetworkConnection checkDataNetworkAvailable]) {
        [self turnUserInteractivityForNavigationAndTableView:YES];
    }
}


- (void)turnUserInteractivityForNavigationAndTableView:(BOOL)option {
    [self.contactsTableView setUserInteractionEnabled:option];
    [[[self navigationController] navigationBar] setUserInteractionEnabled:option];
    [[self searchBar] setUserInteractionEnabled:option];
    [[self searchBar] resignFirstResponder];
    if (option == YES) {
        [[self activityIndicator] stopAnimating];
    } else {
        [[self activityIndicator] startAnimating];
    }
    
}


# pragma mark - Dummy group message method
//========================================
- (void) addDummyMessage:(NSNumber *)channelKey {
    ALDBHandler *theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService *messageDBService = [[ALMessageDBService alloc]init];
    
    ALMessage *theMessage = [ALMessage new];
    theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString];
    theMessage.sendToDevice = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.key = @"welcome-message-temp-key-string";
    theMessage.fileMetaKey = @"";//4
    theMessage.contentType = ALMESSAGE_CONTENT_DEFAULT;
    theMessage.type = @"101";
    theMessage.message = @"You have created a new group, Say Hi to members :)";
    theMessage.groupId = channelKey;
    theMessage.status = [NSNumber numberWithInt:DELIVERED_AND_READ];
    theMessage.sentToServer = TRUE;
    
    //UI update...
    NSMutableArray *updateArr=[[NSMutableArray alloc] initWithObjects:theMessage, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:updateArr];
    
    //db insertion..
    [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler saveContext];
    
}

#pragma mar - Member Addition to group
//====================================
- (void)backToDetailView{
    
    self.forGroup = [NSNumber numberWithInt:0];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ALGroupDetailViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

- (void)processFilterListWithLastSeen {
    ALUserService *userService = [ALUserService new];
    [userService fetchOnlineContactFromServer:^(NSMutableArray *array, NSError *error) {
        
        if (error) {
            [self.activityIndicator stopAnimating];
            [self.emptyConversationText setHidden:NO];
            [self.emptyConversationText setText: NSLocalizedStringWithDefaultValue(@"unableToFetachContacts", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to fetch contacts", @"") ];
            return;
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastSeenAt" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
        self.filteredContactList = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:descriptors]];
        ALSLog(ALLoggerSeverityInfo, @"ARRAY_COUNT : %lu",(unsigned long)self.filteredContactList.count);
        [[self activityIndicator] stopAnimating];
        [self.contactsTableView reloadData];
        [self emptyConversationAlertLabel];
        
    }];
}

- (void)launchProcessForSubgroups {
    NSMutableSet *allMemberSet = nil;
    NSMutableArray *allMemberArray = [NSMutableArray new];
    [self.childChannels addObject:self.parentChannel];
    self.alChannelsList = [NSMutableArray new];
    
    for (ALChannel *childChannel in self.childChannels) {
        if (childChannel.type != GROUP_OF_TWO) {
            NSMutableArray *childArray = [self.channelService getListOfAllUsersInChannel:childChannel.key];
            [allMemberArray addObjectsFromArray:childArray];
            if ([childArray containsObject:[ALUserDefaultsHandler getUserId]]) {
                [self.alChannelsList addObject:childChannel];
            }
        }
    }
    
    [self.alChannelsList removeObject:self.parentChannel];
    
    allMemberSet = [NSMutableSet setWithArray:[allMemberArray mutableCopy]];
    
    NSMutableArray *contactList = [NSMutableArray new];
    
    for (NSString *userId in allMemberSet) {
        ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
        if (![contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]) {
            [contactList addObject:contact];
        }
    }
    
    self.contactList = [NSMutableArray arrayWithArray:contactList];
    
    self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
    [[self activityIndicator] stopAnimating];
    [self.contactsTableView reloadData];
    
}

- (void)initiateGroupOfTwoChat:(ALChannel *)parentChannel andUser:(ALContact *)alContact {
    ALContact *loginContact = [self.contactService loadContactByKey:@"userId" value:[ALUserDefaultsHandler getUserId]];
    NSMutableArray *userList = [NSMutableArray arrayWithObjects:alContact.userId, loginContact.userId, nil];
    
    // ALSO SORT USERS
    NSString *clientChannelKey = [NSString stringWithFormat:@"%@:%@:%@",parentChannel.key, loginContact.userId, alContact.userId];
    NSString *channelName = [NSString stringWithFormat:@"GROUP:%@:%@",[loginContact getDisplayName],[alContact getDisplayName]];
    NSComparisonResult result = [loginContact.userId compare:alContact.userId];
    
    if (result == NSOrderedDescending) {
        channelName = [NSString stringWithFormat:@"GROUP:%@:%@",[alContact getDisplayName],[loginContact getDisplayName]];
        clientChannelKey = [NSString stringWithFormat:@"%@:%@:%@",parentChannel.key, alContact.userId, loginContact.userId];
    }
    
    //CHECK IF CONVERSATION ALREADY THERE
    ALChannel *previousChannel = [self.channelService fetchChannelWithClientChannelKey:clientChannelKey];
    if (!previousChannel) {
        
        ALChannelInfo *channelInfo = [[ALChannelInfo alloc] init];
        channelInfo.clientGroupId = clientChannelKey;
        channelInfo.groupName = channelName;
        channelInfo.groupMemberList = userList;
        channelInfo.type = GROUP_OF_TWO;
        channelInfo.parentKey = parentChannel.key;
        
        [self.channelService createChannelWithChannelInfo:channelInfo
                                           withCompletion:^(ALChannelCreateResponse *response, NSError *error) {
            if (!error
                && [response.status isEqualToString:AL_RESPONSE_SUCCESS]) {
                [self chatLaunchForGroupOfTwo:response.alChannel andUser:alContact];
            }
        }];
    } else {
        ALSLog(ALLoggerSeverityInfo, @"GROUP FOUND : %@",previousChannel.clientChannelKey);
        [self chatLaunchForGroupOfTwo:previousChannel andUser:alContact];
    }
}

- (void)chatLaunchForGroupOfTwo:(ALChannel *)channel andUser:(ALContact *)alContact {
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *currentVC in viewControllersFromStack) {
        ALSLog(ALLoggerSeverityInfo, @"CLASS NAME : %@",currentVC.description);
        if ([currentVC isKindOfClass:[ALMessagesViewController class]]) {
            // LAUNCH VIA BACK STACK FROM MSG VC
            ALMessagesViewController *msgViewObject = (ALMessagesViewController *)currentVC;
            msgViewObject.channelKey = channel.key;
            [msgViewObject createDetailChatViewController:alContact.userId];
        }
    }
    viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    if (viewControllersFromStack.count >=2 &&
        [[viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]]) {
        [viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
        self.navigationController.viewControllers = viewControllersFromStack;
    }
}

- (void)launchChatWithUserId:(NSString *) userID
                orChannelKey:(NSNumber *) channelKey {
    ALChatViewController *detailChatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    detailChatViewController.contactIds = userID;
    detailChatViewController.channelKey = channelKey;
    [self.navigationController pushViewController:detailChatViewController animated:NO];
}

//==============================================================================================================================================
#pragma mark - TABLE SCROLL DELEGATE METHOD
//==============================================================================================================================================

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![ALUserDefaultsHandler isContactScrollingIsInProgress] &&
        self.groupOrContacts.intValue == SHOW_CONTACTS && ![ALApplozicSettings isContactsGroupEnabled]) {
        ALSLog(ALLoggerSeverityInfo, @"Contact scrolling ");
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        float reload_distance = 10;
        if (y > (h - reload_distance)) {
            if ([ALApplozicSettings getFilterContactsStatus]) {
                [[self activityIndicator] startAnimating];
                [ALUserDefaultsHandler setContactScrollingIsInProgress:YES];
                [self proccessRegisteredContactsCall:YES];
            }
        }
    }
    
}


- (void)proccessRegisteredContactsCall:(BOOL)isRemoveobject{

    [self.view setUserInteractionEnabled:NO];
    ALUserService *userService = [ALUserService new];
    [userService getListOfRegisteredUsersWithCompletion:^(NSError *error) {
        
        [self.searchBar setUserInteractionEnabled:YES];
        [self.view setUserInteractionEnabled:YES];
        if (error) {
            [self.activityIndicator stopAnimating];
            [self.emptyConversationText setHidden:NO];
            [self.emptyConversationText setText: NSLocalizedStringWithDefaultValue(@"unableToFetachContacts", [ALApplozicSettings getLocalizableName], [NSBundle mainBundle], @"Unable to fetch contacts" , @"")];
            [self onlyGroupFetch];
            return;
        }
        [ALUserDefaultsHandler setContactServerCallIsDone:YES];
        if (self->_stopSearchText != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getSerachResult:self->_stopSearchText];
            });
            [[self activityIndicator] stopAnimating];
        } else {
            if (isRemoveobject) {
                [self.filteredContactList removeAllObjects];
                [self.contactList removeAllObjects];
            }
            [self subProcessContactFetch];
            [[self activityIndicator] stopAnimating];
        }
        
        [ALUserDefaultsHandler setContactScrollingIsInProgress:NO];
        
    }];
}


- (void)proccessContactsGroupCall {
    
    [self.channelService getMembersFromContactGroupOfType:[ALApplozicSettings getContactsGroupId] withGroupType:CONTACT_GROUP withCompletion:^(NSError *error, ALChannel *channel) {
        [self.searchBar setUserInteractionEnabled:YES];
        
        NSMutableArray *contactList = [NSMutableArray new];

        if (!error && channel != nil) {
            for (NSString *userId in channel.membersId) {
                if (![userId isEqualToString:[ALUserDefaultsHandler getUserId]]) {
                    ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
            }
            [self.contactList removeAllObjects];
            self.contactList = [NSMutableArray arrayWithArray:contactList];
            self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
            
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
            
        } else {
            NSMutableArray *membersArray = nil;
            
            membersArray = [self.channelService getListOfAllUsersInChannelByNameForContactsGroup:[ALApplozicSettings getContactsGroupId]];
            
            if (membersArray && membersArray.count >0) {
                for (NSString *userId in membersArray) {
                    ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
                
                [self.contactList removeAllObjects];
                self.contactList = [NSMutableArray arrayWithArray:contactList];
                self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
                
                [[self activityIndicator] stopAnimating];
                [self.contactsTableView reloadData];
            }
        }
        [self onlyGroupFetch];
    }];
}

- (void)proccessContactsGroupList{
    
    [self.channelService getMembersIdsForContactGroups:[ALApplozicSettings getContactGroupIdList] withCompletion:^(NSError *error, NSArray *membersArray) {
        [self.searchBar setUserInteractionEnabled:YES];
        
        NSMutableArray *contactList = [NSMutableArray new];

        if (!error && membersArray != nil) {
            membersArray = [membersArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
            for (NSString *userId in membersArray) {
                if (![userId isEqualToString:[ALUserDefaultsHandler getUserId]]) {
                    ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
                    [contactList addObject:contact];
                }
            }
            [self.contactList removeAllObjects];
            self.contactList = [NSMutableArray arrayWithArray:contactList];
            self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
            
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
            
        } else {
            ALChannelService *channelService = [ALChannelService new];
            NSMutableArray *membersArray = [NSMutableArray new];

            for (NSString *channelId in [ALApplozicSettings getContactGroupIdList]) {
                NSMutableArray *members = [channelService getListOfAllUsersInChannelByNameForContactsGroup:channelId];
                [membersArray addObjectsFromArray: members];

            }
            if (membersArray && membersArray.count >0) {
                membersArray = [membersArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
                for (NSString *userId in membersArray) {
                    if (![userId isEqualToString:[ALUserDefaultsHandler getUserId] ]) {
                        ALContact *contact = [self.contactService loadContactByKey:@"userId" value:userId];
                        [contactList addObject:contact];
                    }
                }

                [self.contactList removeAllObjects];
                self.contactList = [NSMutableArray arrayWithArray:contactList];
                self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];

            }
            [[self activityIndicator] stopAnimating];
            [self.contactsTableView reloadData];
        }
        [self onlyGroupFetch];
        
    }];
}


- (void)sendMessage:(ALMessage *) msgObject {

    ALMessage *alMessage = [ALMessage build:^(ALMessageBuilder *alMessageBuilder) {
        if (msgObject.contactIds) {
            alMessageBuilder.to = msgObject.contactIds;
        } else if (msgObject.groupId != nil) {
            alMessageBuilder.groupId = msgObject.groupId;
        }
        alMessageBuilder.message = msgObject.message;
        alMessageBuilder.imageFilePath = msgObject.imageFilePath;
        alMessageBuilder.contentType = ALMESSAGE_CONTENT_ATTACHMENT;

    }];
    [self.applozicClient sendMessageWithAttachment:alMessage];
}



- (void)onDownloadCompleted:(ALMessage *)alMessage {

}

- (void)onDownloadFailed:(ALMessage *)alMessage {

}

- (void)onUpdateBytesDownloaded:(int64_t)bytesReceived withMessage:(ALMessage *)alMessage {

}

- (void)onUpdateBytesUploaded:(int64_t)bytesSent withMessage:(ALMessage *)alMessage {

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];

    unsigned long long fileSize;

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    } else {
        NSURL *documentDirectory   = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[ALApplozicSettings getShareExtentionGroup]];
        documentDirectory = [documentDirectory  URLByAppendingPathComponent:alMessage.imageFilePath];
        fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:documentDirectory.path error:nil] fileSize];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.uiProgress.progress = ((100.0/fileSize)*bytesSent)/100;
    });

}

- (void)onUploadCompleted:(ALMessage *)alMessage withOldMessageKey:(NSString *)oldMessageKey {

    [self.uiAlertController dismissViewControllerAnimated:YES completion:nil];
    if (self.directContactVCLaunch) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_SHARE_EXTENSION" object:nil];
    }
}

- (void)onUploadFailed:(ALMessage *)alMessage {

    [self.uiAlertController dismissViewControllerAnimated:YES completion:nil];
    if (self.directContactVCLaunch) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_SHARE_EXTENSION" object:nil];
    }
}

@end
