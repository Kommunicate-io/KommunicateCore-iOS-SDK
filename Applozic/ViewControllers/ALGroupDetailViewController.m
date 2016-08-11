//
//  ALGroupDetailViewController.m
//  Applozic
//
//  Created by Divjyot Singh on 23/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
#import "ALGroupDetailViewController.h"
#import "ALContactCell.h"
#import "ALChatViewController.h"
#import "ALChannel.h"
#import "ALNewContactsViewController.h"
#import "ALApplozicSettings.h"
#import "UIImageView+WebCache.h"
#import "ALMessagesViewController.h"
#import "ALNotificationView.h"
#import "ALDataNetworkConnection.h"
#import "ALMQTTConversationService.h"

@interface ALGroupDetailViewController (){
    NSMutableOrderedSet *memberIds;
    NSMutableArray *memberNames;
    BOOL isAdmin;
    CGFloat screenWidth;
    NSArray * colors;
}
@property (nonatomic,retain) UILabel * memberNameLabel;
@property (nonatomic,retain) UILabel * firstLetterLabel;
@property (nonatomic,retain) UIImageView * memberIconImageView;
@property (nonatomic,retain) NSString * groupName;
@property (nonatomic,retain) UILabel * adminLabel;
@property (nonatomic,retain) UILabel * lastSeenLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) ALMQTTConversationService * mqttObject;

@end

@implementation ALGroupDetailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupDeatilsSyncCall) name:@"GroupDetailTableReload" object:nil];
    self.lastSeenMembersArray = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setupView];
}

-(void)setNavigationColor
{
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
//        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColorForNavigationItem], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:18]}];
        [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
    }
}

-(void)setupView{
    
    [self.tabBarController.tabBar setHidden:YES];
    [self setNavigationColor];
    [self setTitle:@"Group Details"];
    
    ALChannelService * channnelService = [[ALChannelService alloc] init];
    ALChannel *alChannel = [channnelService getChannelByKey:self.channelKeyID];
    self.groupName  = alChannel.name;
    isAdmin         = [channnelService checkAdmin:self.channelKeyID];

    memberNames = [[NSMutableArray alloc] init];
    colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView.backgroundColor = [UIColor lightGrayColor];
    
    [self getChannelMembers];
    [self getDisplayNamesAndLastSeen];
    
}

-(void)getChannelMembers{
    ALChannelDBService * channelDBService = [[ALChannelDBService alloc] init];
    NSArray *memberIdArray= [NSArray arrayWithArray:[channelDBService getListOfAllUsersInChannel:self.channelKeyID]];
    memberIds = [NSMutableOrderedSet orderedSetWithArray:memberIdArray];
}

-(void)getDisplayNamesAndLastSeen{
    
    for(NSString * userID in memberIds){
        
        ALContact * contact = [[ALContact alloc] init];
        ALContactDBService * contactDb=[[ALContactDBService alloc] init];
        contact = [contactDb loadContactByKey:@"userId" value:userID];
        if([contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]){
            contact.displayName = @"You";
        }
        [self.lastSeenMembersArray addObject:[self getLastSeenForMember:userID]];
        [memberNames addObject:[contact getDisplayName]];
    }
    self.memberCount = memberIds.count;
    NSLog(@"Member Count :%ld",(long)self.memberCount);
}

-(void)groupDeatilsSyncCall{
    [self setupView];
    [self.tableView reloadData];
}

//------------------------------------------------------------------------------------------------------------------
#pragma mark - Table View DataSource Methods
//------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:{
            if(isAdmin && ![self isThisChannelLeft:self.channelKeyID] && [ALApplozicSettings getGroupMemberAddOption])
                return 2;
            else
                return 1;
        }break;
        case 1:{
            return memberIds.count;
        }break;
        case 2:{
            if(![self isThisChannelLeft:self.channelKeyID] && [ALApplozicSettings getGroupExitOption]){
                return 1;
            }
            else{
                return 0;
            }
        }break;
        default:{
            return 0;
        }
    }

}

#pragma mark - Table Row Height
//================================
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 3) {
        return 100;
    }
    return 65.5;
}

#pragma mark - Table Row Select
//================================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self noDataNotificationView];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            if(indexPath.row == 1){
                
                [self addNewMember];
            }
        }
            break;
        case 1:
        {
            if(isAdmin
               && ![self isThisChannelLeft:self.channelKeyID]
               &&  [ALApplozicSettings getGroupMemberRemoveOption]){
                [self removeMember:indexPath.row];
            }
        }break;
        case 2:{
            //Exit group
            [self checkAndconfirm:@"Confirm" withMessage:@"Are you sure?" otherButtonTitle:@"Yes"];
            
        }break;
        default:break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Add New Member Methods
//==================================
-(void)addNewMember
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:self.class]];
    UIViewController *contactsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    ((ALNewContactsViewController*)contactsViewController).contactsInGroup =[NSMutableArray arrayWithArray:[memberIds array]];
    ((ALNewContactsViewController*)contactsViewController).forGroup = [NSNumber numberWithInt:GROUP_ADDITION];
    ((ALNewContactsViewController*)contactsViewController).delegate = self;    
    [self.navigationController pushViewController:contactsViewController animated:YES];

   
}

-(void)addNewMembertoGroup:(ALContact *)alcontact withComletion:(void(^)(NSError *error,ALAPIResponse *response))completion
{    
    [[self activityIndicator] startAnimating];
    self.memberIdToAdd = alcontact.userId;
    ALChannelService * channelService = [[ALChannelService alloc] init];
     [channelService addMemberToChannel:self.memberIdToAdd andChannelKey:self.channelKeyID orClientChannelKey:nil
                          withComletion:^(NSError *error, ALAPIResponse *response) {
         
         if(!error)
         {
             [memberIds addObject:self.memberIdToAdd];
             [self.tableView reloadData];
             
         }
         [[self activityIndicator] stopAnimating];
         completion(error,response);
    }];
}

-(NSString *)getLastSeenForMember:(NSString*)userID{
    
    ALContactDBService * contactDBService = [[ALContactDBService alloc] init];
    ALContact * contact = [contactDBService loadContactByKey:@"userId" value:userID];
    
    ALUserDetail * userDetails = [[ALUserDetail alloc] init];
    userDetails.userId = userID;
    userDetails.lastSeenAtTime = contact.lastSeenAt;
    
    double value = contact.lastSeenAt.doubleValue;
    NSString * lastSeen;
    if(contact.lastSeenAt == NULL){
        lastSeen = @" ";
    }
    else{
        lastSeen = [(ALChatViewController*)self.alChatViewController formatDateTime:userDetails andValue:value];
    }
    return lastSeen;
}

#pragma mark - Check and confirm
//================================
-(void)checkAndconfirm:(NSString*)title withMessage:(NSString*)message otherButtonTitle:(NSString*)buttonTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:buttonTitle, nil];
    [alert show];
}

#pragma mark - AlertView Delegate Method (Exit Group)
//====================================================
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
     // Index 0 : Cancel
    
    if(buttonIndex == 1){
        // Index 1 : Yes
        [self turnUserInteractivityForNavigationAndTableView:NO];
        ALChannelService * alchannelService = [[ALChannelService alloc] init];
        [alchannelService leaveChannel:self.channelKeyID andUserId:[ALUserDefaultsHandler getUserId] orClientChannelKey:nil withCompletion:^(NSError *error) {
            
            if(!error)
            {
                //Updating view, popping to MessageList View
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                for (UIViewController *aViewController in allViewControllers)
                {
                    if ([aViewController isKindOfClass:[ALMessagesViewController class]])
                    {
                        [self.navigationController popToViewController:aViewController animated:YES];
                    }
                }
            }
            [self turnUserInteractivityForNavigationAndTableView:YES];
        }];
       
    }
}

-(BOOL)isThisChannelLeft:(NSNumber *)channelKey{

    ALChannelService * alChannelService  = [[ALChannelService alloc] init];
    if([alChannelService isChannelLeft:channelKey]){
        return YES;
    }else{
        return NO;
    }

}
#pragma mark - Remove Memember (for admin)
//=======================================
-(void) removeMember:(NSInteger)row {
    
    NSString* removeMemberID = [NSString stringWithFormat:@"%@",memberIds[row]];
    
    if([removeMemberID isEqualToString:[ALUserDefaultsHandler getUserId]])
    {
        return;
    }
    else
    {
        UIAlertController * theController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [theController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [theController addAction:[UIAlertAction
                                  actionWithTitle:[NSString stringWithFormat:@"Remove %@",memberNames[row]]
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                

            [self turnUserInteractivityForNavigationAndTableView:NO];
            ALChannelService * alchannelService = [[ALChannelService alloc] init];
            [alchannelService removeMemberFromChannel:removeMemberID andChannelKey:self.channelKeyID orClientChannelKey:nil withComletion:^(NSError *error, NSString *response) {
                
                if(!error)
                {
                    [memberIds removeObjectAtIndex:row];
                    [self setupView];
                    [self.tableView reloadData];
                }

                [self turnUserInteractivityForNavigationAndTableView:YES];
            }];
                  
        }]];
        
        [self presentViewController:theController animated:YES completion:nil];
    }
}

-(void)turnUserInteractivityForNavigationAndTableView:(BOOL)option{
    
    [self.view setUserInteractionEnabled:option];
    [[self tableView] setUserInteractionEnabled:option];
    [[[self navigationController] navigationBar] setUserInteractionEnabled:option];
    
    if(option == YES){
        [[self activityIndicator] stopAnimating];
    }
    else{
        [[self activityIndicator] startAnimating];
    }
    
}

-(void)updateTableView{
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source
//========================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ALContactCell * memberCell = (ALContactCell*)[tableView dequeueReusableCellWithIdentifier:@"memberCell"
                                                                                 forIndexPath:indexPath];
    [memberCell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
   
    [self setupCellItems:memberCell];
    [self.firstLetterLabel setHidden:YES];
    [self.memberIconImageView setHidden:YES];
    [self.memberNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.memberNameLabel setTextColor:[UIColor blackColor]];
    [self.memberNameLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:15]];
    [self.adminLabel setHidden:YES];
    [self.lastSeenLabel setHidden:YES];
    
    switch (indexPath.section) {
        case 0:{
            if(indexPath.row == 0){
                [self.memberNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
                self.memberNameLabel.text =[NSString stringWithFormat:@"%@",self.groupName];
            }
            else{
                self.memberNameLabel.textColor = self.view.tintColor;
                self.memberNameLabel.text = @"Add New Member";
            }
        }break;
        case 1:{
            [self setMemberIcon:indexPath.row];
        }break;
        case 2:{
            [self.memberNameLabel setTextColor:[UIColor redColor]];
            self.memberNameLabel.text = [NSString stringWithFormat:@"Exit Group"];
        }break;
        default:break;
    }
    return memberCell;
}

-(void)setMemberIcon:(NSInteger)row {
    
    
    ALChannelDBService * channelDBService = [[ALChannelDBService alloc] init];
    ALChannel *channel = [channelDBService loadChannelByKey:self.channelKeyID];
    
    if([channel.adminKey isEqualToString:memberIds[row]]){
        [self.adminLabel setHidden:NO];
    }
    
    
//    Member Name Label
    [self.memberNameLabel setTextAlignment:NSTextAlignmentLeft];
    self.memberNameLabel.text = [NSString stringWithFormat:@"%@",memberNames[row]];
    
    [self.firstLetterLabel setHidden:YES];
    [self.memberIconImageView setHidden:NO];
    
    
    ALContact * alContact = [[ALContact alloc] init];
    ALContactDBService * alContactDBService = [[ALContactDBService alloc] init];
    alContact = [alContactDBService loadContactByKey:@"userId" value:memberIds[row]];
    
    if (![alContact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]){
        [self.lastSeenLabel setHidden:NO];
        [self.lastSeenLabel setText:self.lastSeenMembersArray[row]];
    }
    
    
    if (alContact.localImageResourceName){
        UIImage *someImage = [ALUtilityClass getImageFromFramworkBundle:alContact.localImageResourceName];
        [self.memberIconImageView  setImage:someImage];
        
    }
    else if(alContact.contactImageUrl){
        NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
        [self.memberIconImageView sd_setImageWithURL:theUrl1];
    }
    else{
        [self.firstLetterLabel setHidden:NO];
        self.firstLetterLabel.text = [[alContact getDisplayName] substringToIndex:1];
        NSUInteger randomIndex = random()% [colors count];
        self.memberIconImageView.image = [ALColorUtility imageWithSize:CGRectMake(0,0,55,55)
                                                         WithHexString:colors[randomIndex] ];
        
    }
    
}

-(void)setupCellItems:(ALContactCell*)memberCell
{
    self.memberNameLabel  = (UILabel*)[memberCell viewWithTag:101];
    
    self.memberIconImageView = (UIImageView*)[memberCell viewWithTag:102];
    self.memberIconImageView.clipsToBounds = YES;
    self.memberIconImageView.layer.cornerRadius = self.memberIconImageView.frame.size.width/2;
    
    self.firstLetterLabel = (UILabel*)[memberCell viewWithTag:103];
    self.firstLetterLabel.textColor = [UIColor whiteColor];
    self.adminLabel = (UILabel*)[memberCell viewWithTag:104];
    self.adminLabel.textColor = self.view.tintColor;
    
    self.lastSeenLabel = (UILabel *)[memberCell viewWithTag:105];
}

#pragma mark Row Height
//===============================

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 45;
}

#pragma mark - Display Header/Footer View
//======================================
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
// For Header's Text View
    
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {

    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor = [UIColor lightGrayColor];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

#pragma mark -  Header View
//===========================
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:
                                  [ALUtilityClass getImageFromFramworkBundle:@"applozic_group_icon.png"]];
        
        ALChannelDBService * channelDBService = [ALChannelDBService new];
        ALChannel *alChannel = [channelDBService loadChannelByKey:self.channelKeyID];
        NSURL * imageUrl = [NSURL URLWithString:alChannel.channelImageURL];
        if(imageUrl)
        {
            [imageView sd_setImageWithURL:imageUrl];
        }
        
        imageView.frame = CGRectMake((screenWidth/2)-30, 20, 60, 60);
        imageView.backgroundColor = [UIColor blackColor];
        imageView.clipsToBounds=YES;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
        view.backgroundColor = [ALApplozicSettings getColorForNavigation];
        [view addSubview:imageView];
        return view;
    }
    else if(section == 1){
        UILabel * memberSectionHeaderTitle = [[UILabel alloc] init];
        memberSectionHeaderTitle.text=@"Group Members";
        CGSize textSize = [memberSectionHeaderTitle.text sizeWithAttributes:@{NSFontAttributeName:memberSectionHeaderTitle.font}];
        
        memberSectionHeaderTitle.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x + 5,
                                                  [UIScreen mainScreen].bounds.origin.y + 35,
                                                  textSize.width, textSize.height);
        
        [memberSectionHeaderTitle setTextAlignment:NSTextAlignmentLeft];
        [memberSectionHeaderTitle setTextColor:[UIColor colorWithWhite:0.3 alpha:0.7]];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(memberSectionHeaderTitle.frame.origin.x,
                                                                memberSectionHeaderTitle.frame.origin.y,
                                                                memberSectionHeaderTitle.frame.size.width,
                                                                memberSectionHeaderTitle.frame.size.height)];
        [view addSubview:memberSectionHeaderTitle];
//        view.backgroundColor=[UIColor colorWithWhite:0.7 alpha:1];
        view.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1];
        return view;
        
    }
    else{
        return nil;
    }
}

-(void)noDataNotificationView
{
    ALNotificationView * notification = [ALNotificationView new];
    [notification noDataConnectionNotificationView];
}

@end
