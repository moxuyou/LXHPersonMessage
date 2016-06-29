//
//  LXHPersonSettingTableViewController.m
//  LXHPersonMessage
//
//  Created by moxuyou on 16/6/27.
//  Copyright © 2016年 moxuyou. All rights reserved.
//

#import "LXHPersonSettingTableViewController.h"

@interface LXHPersonSettingTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LXHPersonSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(200 + 44, 0, 0, 0);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"personSettingCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personSettingCell"];

    cell.textLabel.text = [NSString stringWithFormat:@"personSettingTableView--%lu", indexPath.row];    
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageDidScroll" object:self userInfo:@{@"messageDidScroll" : scrollView}];
}

@end
