//
//  ViewController.m
//  LXHPersonMessage
//
//  Created by moxuyou on 16/6/27.
//  Copyright © 2016年 moxuyou. All rights reserved.
//

#import "LXHPersonMessageViewController.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (IBAction)show {
    LXHPersonMessageViewController *vc = [[LXHPersonMessageViewController alloc] init];
    [self addChildViewController:vc];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
