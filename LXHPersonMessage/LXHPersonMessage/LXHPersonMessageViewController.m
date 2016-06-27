//
//  LXHPersonMessageViewController.m
//  LXHPersonMessage
//
//  Created by moxuyou on 16/6/27.
//  Copyright © 2016年 moxuyou. All rights reserved.
//

#import "LXHPersonMessageViewController.h"
#import "LXHDetailTableViewController.h"
#import "LXHPersonSettingTableViewController.h"
#import "Masonry.h"

@interface LXHPersonMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

/* 装住大imageView的底部View */
@property (weak, nonatomic) IBOutlet UIView *bgView;
/* 个人头像 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
/* 背后大的ImageView */
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
/* 详细按钮 */
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
/* 个人信息按钮 */
@property (weak, nonatomic) IBOutlet UIButton *personButton;
/* 个人设置按钮 */
@property (weak, nonatomic) IBOutlet UIButton *personSettingButton;
/* 装住大imageView的底部View高度的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageViewConstraint;
/** 详细信息tableView */
@property (weak, nonatomic) UITableView *detailTableView;
/** 个人设置tableView */
@property (weak, nonatomic) UITableView *personSettingTableView;
/** 个人信心tableView */
@property (weak, nonatomic) UITableView *personTableView;
/** 装选择三个按钮的父控件View */
@property (weak, nonatomic) UIView *headView;
/** 装住整个tableView的底层scrollView */
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
/** headView下划线 */
@property (nonatomic , weak)UIView *footView;
/** 当前选中显示的tableView */
@property (nonatomic , weak)UITableView *curronTableView;

@end

@implementation LXHPersonMessageViewController

//懒加载创建personTableView
- (UITableView *)personTableView
{
    if (_personTableView == nil) {
        UITableView *personTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [self.bgScrollView addSubview:personTableView];
        personTableView.backgroundColor = [UIColor redColor];
        _personTableView = personTableView;
        NSLog(@"%s",__func__);
    }
    return _personTableView;
}

- (UITableView *)detailTableView
{
    if (_detailTableView == nil) {
        NSLog(@"%s",__func__);
        LXHDetailTableViewController *detailTableViewVC = [[LXHDetailTableViewController alloc] init];
        [self addChildViewController:detailTableViewVC];
        detailTableViewVC.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        detailTableViewVC.view.backgroundColor = [UIColor greenColor];
        [self.bgScrollView addSubview:detailTableViewVC.view];
        _detailTableView = (UITableView *)detailTableViewVC.view;
    }
    return _detailTableView;
}

- (UITableView *)personSettingTableView
{
    if (_personSettingTableView == nil) {
        NSLog(@"%s",__func__);
        LXHPersonSettingTableViewController *personSettingTableViewVC = [[LXHPersonSettingTableViewController alloc] init];
        [self addChildViewController:personSettingTableViewVC];
        personSettingTableViewVC.view.frame = CGRectMake(self.view.bounds.size.width * 2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        personSettingTableViewVC.view.backgroundColor = [UIColor greenColor];
        [self.bgScrollView addSubview:personSettingTableViewVC.view];
        _personSettingTableView = (UITableView *)personSettingTableViewVC.view;
    }
    return _personSettingTableView;
}

- (UIView *)footView
{
    if (_footView == nil) {
        [self.personButton.titleLabel sizeToFit];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.headView.bounds.size.height - 2, self.personButton.titleLabel.bounds.size.width, 2)];
        [self.headView addSubview:view];
        view.backgroundColor = [UIColor redColor];
        
        _footView = view;
    }
    
    return _footView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.curronTableView = self.personTableView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.curronTableView.dataSource = self;
    self.curronTableView.delegate = self;
    
    self.navigationController.navigationBar.alpha = 0;
    [self personButtonClick:self.personButton];
    
    self.curronTableView.contentInset = UIEdgeInsetsMake(self.bgView.bounds.size.height + 44, 0, 0, 0);
    [self.curronTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidScroll:) name:@"messageDidScroll" object:nil];
    
}

- (void)messageDidScroll:(NSNotification *)note
{
    UIScrollView *scrollView = note.userInfo[@"messageDidScroll"];
    [self scrollViewDidScroll:scrollView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"personTableView--%lu", indexPath.row];

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = self.curronTableView.contentInset.top + self.curronTableView.contentOffset.y;
//    NSLog(@"%lf", offset);
    if (offset > (self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64)) {
        offset = self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64;
    }
    //控制拖动
    self.bgImageViewConstraint.constant = 200 - offset;
    //控制导航条颜色
//    NSLog(@"%lf", 1.0 * offset / (self.tableView.contentInset.top - 64 - 44));
    self.navigationController.navigationBar.alpha = 1.0 * offset / (self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64);
    
}

- (IBAction)personButtonClick:(UIButton *)btn {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(0, 0);
    }];
    
    self.curronTableView = self.personTableView;
}
- (IBAction)detailButtonClick:(UIButton *)btn {
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }];
    
    self.curronTableView = self.detailTableView;
    
}
- (IBAction)personSettingButtonClick:(UIButton *)btn {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(self.view.bounds.size.width * 2, 0);
    }];
    
    self.curronTableView = self.personSettingTableView;
}



@end
