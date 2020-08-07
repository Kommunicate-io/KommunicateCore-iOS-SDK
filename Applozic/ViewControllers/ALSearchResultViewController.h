//
//  SearchViewController.h
//  Applozic
//
//  Created by Sunil on 16/07/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALSearchResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@property (strong, nonatomic) IBOutlet UITableView *mTableView;

-(void)clearAndShowEmptyView;
-(void)searchWithKey:(NSString*)key;

@end
