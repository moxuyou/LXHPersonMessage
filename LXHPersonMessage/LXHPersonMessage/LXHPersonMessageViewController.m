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

/** 用于记录当前背景scrollView的滚动清空 */
@property (nonatomic , assign)CGFloat curronY;
/** 用于记录三个scrollView的偏移量 */
@property (nonatomic , strong)NSMutableDictionary *contentOffsets;

@end

@implementation LXHPersonMessageViewController

NSString *const personOffsetKey = @"personOffsetKey";
NSString *const detailOffsetKey = @"detailOffsetKey";
NSString *const personSettingOffsetKey = @"personSettingOffsetKey";

- (NSMutableDictionary *)contentOffsets {
    if (!_contentOffsets) {
        _contentOffsets = [NSMutableDictionary dictionary];
//        _contentOffsets[personOffsetKey] = @(-244);
//        _contentOffsets[detailOffsetKey] = @(-244);
//        _contentOffsets[personSettingOffsetKey] = @(-244);
    }
    return _contentOffsets;
}

//懒加载创建personTableView（个人信息）
- (UITableView *)personTableView
{
    if (_personTableView == nil) {
        UITableView *personTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [self.bgScrollView addSubview:personTableView];
        personTableView.backgroundColor = [UIColor redColor];
        _personTableView = personTableView;
    }
    return _personTableView;
}
//懒加载创建detailTableView（详细信息）
- (UITableView *)detailTableView
{
    if (_detailTableView == nil) {
        LXHDetailTableViewController *detailTableViewVC = [[LXHDetailTableViewController alloc] init];
        [self addChildViewController:detailTableViewVC];
        detailTableViewVC.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        detailTableViewVC.view.backgroundColor = [UIColor greenColor];
        [self.bgScrollView addSubview:detailTableViewVC.view];
        _detailTableView = (UITableView *)detailTableViewVC.view;
    }
    return _detailTableView;
}
//懒加载创建personSettingTableView（个人设置）
- (UITableView *)personSettingTableView
{
    if (_personSettingTableView == nil) {
        LXHPersonSettingTableViewController *personSettingTableViewVC = [[LXHPersonSettingTableViewController alloc] init];
        [self addChildViewController:personSettingTableViewVC];
        personSettingTableViewVC.view.frame = CGRectMake(self.view.bounds.size.width * 2, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        personSettingTableViewVC.view.backgroundColor = [UIColor greenColor];
        [self.bgScrollView addSubview:personSettingTableViewVC.view];
        _personSettingTableView = (UITableView *)personSettingTableViewVC.view;
    }
    return _personSettingTableView;
}
//创建界面切换的导航栏（三个按钮那个父View）
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
    //设置当前tableView为个人信息
    self.curronTableView = self.personTableView;
    //初始化当前整个bgScrollView的偏移量
    self.curronY = self.curronTableView.contentOffset.y;
    self.contentOffsets[personOffsetKey] = @(self.curronTableView.contentOffset.y);
    //禁止默认偏移
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.personTableView.dataSource = self;
    self.personTableView.delegate = self;
    //设置导航栏透明
    self.navigationController.navigationBar.alpha = 0;
    //默认点击个人信息按钮初始化
    [self personButtonClick:self.personButton];
    
    self.personTableView.contentInset = UIEdgeInsetsMake(self.bgView.bounds.size.height + 44, 0, 0, 0);
    [self.personTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    //监听详情信息和个人信息页面的滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidScroll:) name:@"messageDidScroll" object:nil];
    //监听详情信息和个人信息页面的惯性滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidScrolling:) name:@"messageDidScrolling" object:nil];
    //详情信息和个人信息页面的一下子停止滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidScrolled:) name:@"messageDidScrolled" object:nil];
    
}
//监听详情信息和个人信息页面的惯性滚动
- (void)messageDidScrolling:(NSNotification *)note
{
    UIScrollView *scrollView = note.userInfo[@"messageDidScrolling"];
    //decelerate
    BOOL decelerate = [note.userInfo[@"decelerate"] boolValue];
    [self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
}
//详情信息和个人信息页面的一下子停止滚动
- (void)messageDidScrolled:(NSNotification *)note
{
    UIScrollView *scrollView = note.userInfo[@"messageDidScrolled"];
    [self scrollViewDidEndDecelerating:scrollView];
    
}
//监听详情信息和个人信息页面的滚动
- (void)messageDidScroll:(NSNotification *)note
{
    UIScrollView *scrollView = note.userInfo[@"messageDidScroll"];
    [self scrollViewDidScroll:scrollView];
    
}
//对象销毁前做的事情
- (void)dealloc
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
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

//监听当前显示控制器的惯性滚动停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"惯性导致的滚动停止了");
    self.headView.userInteractionEnabled = YES;
}
//监听当前显示控制器的惯性滚动和一下子停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        NSLog(@"惯性滚动~~~~~~");
        self.headView.userInteractionEnabled = NO;
    }else{
        NSLog(@"一下子滚动停止了");
        self.headView.userInteractionEnabled = YES;
    }
    
}
//监听当前控制器的滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //获取当前偏移量
    CGFloat offset = self.curronTableView.contentInset.top +self.curronTableView.contentOffset.y;
    //控制偏移量的最小值不能小于导航栏的高度+headView的高度
    if (offset > (self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64)) {
        offset = self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64;
    }
    //控制拖动
    self.curronY = self.curronTableView.contentOffset.y;
    self.bgImageViewConstraint.constant = 200 - offset;

    //控制导航条颜色
    self.navigationController.navigationBar.alpha = 1.0 * offset / (self.curronTableView.contentInset.top - self.headView.bounds.size.height - 64);
    //判断设置当前显示控制器的偏移量
    if (scrollView.frame.origin.x == 0) {
        self.contentOffsets[personOffsetKey] = @(self.curronTableView.contentOffset.y);
    
    } else if (scrollView.frame.origin.x == self.view.bounds.size.width) {
        
        self.contentOffsets[detailOffsetKey] = @(self.curronTableView.contentOffset.y);
    } else {
        self.contentOffsets[personSettingOffsetKey] = @(self.curronTableView.contentOffset.y);
    }
    
}
//个人信息按钮点击
- (IBAction)personButtonClick:(UIButton *)btn {
//    [self setUpCurronTableView:self.personTableView contentOffsets:personOffsetKey clickBtn:btn];
//    headView底部线的滑动
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(0, 0);
    }];

    //切换控制器的View
    self.curronTableView = self.personTableView;
    //获取自己的tableView偏移量
    CGFloat offsetY = [self.contentOffsets[personOffsetKey] doubleValue];
    //根据当前整个偏移量设置每个tableView的偏移量
    if (self.curronY >= -108) {
        //判断每个子控制器tableView的偏移量，如果大于-108则使用自己的（上面），小于-108（下面）
        if (offsetY >= -108) {
            
            [self.curronTableView setContentOffset:CGPointMake(0, offsetY)];
        } else {
            
            [self.curronTableView setContentOffset:CGPointMake(0, -108)];
        }
        
    } else {
        [self.curronTableView setContentOffset:CGPointMake(0, self.curronY)];
    }
//    保存备份，用于控制scrollView停止滚动的方法
    CGPoint offset = self.curronTableView.contentOffset;
//    (self.curronTableView.contentOffset.y > 0) ? offset.y-- : offset.y++;
    [self.curronTableView setContentOffset:offset animated:YES];
}
- (IBAction)detailButtonClick:(UIButton *)btn {
//    [self setUpCurronTableView:self.detailTableView contentOffsets:detailOffsetKey clickBtn:btn];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }];
    
    self.curronTableView = self.detailTableView;
    CGFloat offsetY = [self.contentOffsets[detailOffsetKey] doubleValue];
    
    if (self.curronY >= -108) {
        
        if (offsetY >= -108) {
            
            [self.curronTableView setContentOffset:CGPointMake(0, offsetY)];
        } else {
            
            [self.curronTableView setContentOffset:CGPointMake(0, -108)];
        }
        
    } else {
        [self.curronTableView setContentOffset:CGPointMake(0, self.curronY)];
    }
    
}
- (IBAction)personSettingButtonClick:(UIButton *)btn {
//    [self setUpCurronTableView:self.personSettingTableView contentOffsets:personSettingOffsetKey clickBtn:btn];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.footView.frame;
        frame.size.width = btn.titleLabel.frame.size.width;
        self.footView.frame = frame;
        self.footView.center = CGPointMake(btn.center.x, self.footView.center.y);
        self.bgScrollView.contentOffset = CGPointMake(self.view.bounds.size.width * 2, 0);
    }];
    
    self.curronTableView = self.personSettingTableView;
    CGFloat offsetY = [self.contentOffsets[personSettingOffsetKey] doubleValue];
    
    if (self.curronY >= -108) {
        
        if (offsetY >= -108) {
            
            [self.curronTableView setContentOffset:CGPointMake(0, offsetY)];
        } else {
            
            [self.curronTableView setContentOffset:CGPointMake(0, -108)];
        }
        
    } else {
        [self.curronTableView setContentOffset:CGPointMake(0, self.curronY)];
    }
}

- (void)setUpCurronTableView:(UITableView *)curronTableView contentOffsets:(NSString *)contentOffsetskey clickBtn:(UIButton *)clickBtn
{
    //headView底部线的滑动
//    [UIView animateWithDuration:0.25 animations:^{
//        CGRect frame = self.footView.frame;
//        frame.size.width = clickBtn.titleLabel.frame.size.width;
//        self.footView.frame = frame;
//        self.footView.center = CGPointMake(clickBtn.center.x, self.footView.center.y);
//        self.bgScrollView.contentOffset = CGPointMake(0, 0);
//    }];
//    
//    //切换控制器的View
//    self.curronTableView = curronTableView;
//    //获取自己的tableView偏移量
//    CGFloat offsetY = [self.contentOffsets[contentOffsetskey] doubleValue];
//    //根据当前整个偏移量设置每个tableView的偏移量
//    if (self.curronY >= -108) {
//        //判断每个子控制器tableView的偏移量，如果大于-108则使用自己的（上面），小于-108（下面）
//        if (offsetY >= -108) {
//            
//            [self.curronTableView setContentOffset:CGPointMake(0, offsetY)];
//        } else {
//            
//            [self.curronTableView setContentOffset:CGPointMake(0, -108)];
//        }
//        
//    } else {
//        [self.curronTableView setContentOffset:CGPointMake(0, self.curronY)];
//    }
    
//    保存备份，用于控制scrollView停止滚动的方法
//        CGPoint offset = self.curronTableView.contentOffset;
//        (self.curronTableView.contentOffset.y > 0) ? offset.y-- : offset.y++;
//        [self.curronTableView setContentOffset:offset animated:YES];
}

@end
