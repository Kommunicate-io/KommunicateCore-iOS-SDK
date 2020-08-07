//
//  SearchViewController.m
//  Applozic
//
//  Created by Sunil on 16/07/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import "ALSearchResultViewController.h"
#import "ALMessageService.h"
#import <Applozic/Applozic-Swift.h>
#import "ALContactCell.h"
#import "ALUtilityClass.h"
#import "ALMessage.h"
#import "ALChatViewController.h"
#import <Applozic/ALPushAssist.h>

@interface ALSearchResultViewController()

@property (strong, nonatomic) ALSearchViewModel *searchViewModel;
@property (strong, nonatomic) NSString * searchInfoText;
@property (strong, nonatomic) NSString * noSearchResultFoundText;
@property (strong, nonatomic) UILabel * emptyLabel;
@property (strong, nonatomic)  NSMutableDictionary *colourDictionary;


@end

@implementation ALSearchResultViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.searchViewModel = [[ALSearchViewModel alloc] init];
    self.colourDictionary = [ALApplozicSettings getUserIconFirstNameColorCodes];

    self.searchInfoText = NSLocalizedStringWithDefaultValue(@"SearchInfoText", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"Press search button to start searching...", @"");

    self.noSearchResultFoundText = NSLocalizedStringWithDefaultValue(@"noSearchResultFound", [ALApplozicSettings getLocalizableName],[NSBundle mainBundle], @"No results found", @"");

    [self setupView];
}

-(void)setupView {
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.estimatedRowHeight = 81.5;
    self.mTableView.rowHeight = 81.5;
    self.mTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor blackColor];
    self.emptyLabel.numberOfLines = 1;
    CGRect frame = CGRectMake(0, 0,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height);

    self.emptyLabel.frame = frame;
    [self showEmptyViewInfo:self.searchInfoText];
}
-(void)searchWithKey:(NSString*)key {
    [self removeEmpty];
    [self.mActivityIndicator startAnimating];
    [self clear];
    [self.searchViewModel searchMessageWith:key :^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mActivityIndicator stopAnimating];
            if (success) {
                [self removeEmpty];
                [self.mTableView reloadData];
            } else {
                [self showEmptyViewInfo:self.noSearchResultFoundText];
            }
        });
    }];
}

-(void)removeEmpty {
    self.mTableView.backgroundView = nil;
}

-(void)clear {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchViewModel clear];
        [self.mTableView reloadData];
    });
}

-(void)clearAndShowEmptyView {
    [self showEmptyViewInfo:self.searchInfoText];
    [self clear];
}

-(void)showEmptyViewInfo:(NSString *)infoText {
    self.emptyLabel.text = infoText;
    self.mTableView.backgroundView = self.emptyLabel;
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ALContactCell *contactCell = (ALContactCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    ALMessage *message = [self.searchViewModel messageAtIndexPathWithIndexPath:indexPath];
    [contactCell updateWithMessage:message withColourDictionary:self.colourDictionary];
    return contactCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchViewModel numberOfRowsInSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.searchViewModel numberOfSections];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALMessage *message = [self.searchViewModel messageAtIndexPathWithIndexPath:indexPath];
    if (message) {
        [self launchChatWithMessage: message];
    }
}
-(void)launchChatWithMessage:(ALMessage *)message {

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALChatViewController *chatVC = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    chatVC.individualLaunch = YES;
    chatVC.displayName = nil;
    chatVC.isSearch = YES;
    ALPushAssist *pushAssist = [[ALPushAssist alloc]init];

    if (message.groupId != nil) {
        chatVC.channelKey = message.groupId;
        ALChannelService * channelService  =  [ALChannelService new];
        [channelService getChannelInformation:message.groupId orClientChannelKey:nil withCompletion:^(ALChannel *alChannel) {

            if (alChannel && ![pushAssist.topViewController isKindOfClass:ALChatViewController.class]) {
                [self.presentingViewController.navigationController pushViewController:chatVC animated:YES];
            }
        }];
    } else {
        chatVC.contactIds = message.to;
    }

    if (![pushAssist.topViewController isKindOfClass:ALChatViewController.class]) {
        [self.presentingViewController.navigationController pushViewController:chatVC animated:YES];
    }
}

@end
