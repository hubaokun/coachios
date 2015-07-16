//
//  MainViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "CustomTabBar.h"
#import "CoachInfoViewController.h"
#import "TaskListViewController.h"
#import "ScheduleViewController.h"
#import "MyViewController.h"
#import "LoginViewController.h"

@interface MainViewController ()<CustomTabBarDelegate>

@property (nonatomic, strong) TaskListViewController *tasklistVC;
@property (nonatomic, strong) ScheduleViewController *scheduleVC;
@property (nonatomic, strong) MyViewController *myVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomTabBar" owner:self options:nil];
    self.customTabBar = [nib objectAtIndex:0];
    self.customTabBar.delegate = self;
    
    self.tasklistVC = [[TaskListViewController alloc] initWithNibName:@"TaskListViewController" bundle:nil];
    self.scheduleVC = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
    self.myVC = [[MyViewController alloc] initWithNibName:@"MyViewController" bundle:nil];
    
    _tasklistVC.hidesBottomBarWhenPushed = true;
    _scheduleVC.hidesBottomBarWhenPushed = true;
    _myVC.hidesBottomBarWhenPushed = true;
    
    self.viewControllers = @[_tasklistVC, _scheduleVC, _myVC];
    [self.tabBar setClipsToBounds:YES];
//    self.tabBar.hidden = YES;
    
    self.customTabBar.tag = 100;
    self.customTabBar.frame = CGRectMake(0, self.view.frame.size.height - 49, SCREEN_WIDTH, 49);
    [self.view addSubview:self.customTabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断教练是否登陆过
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.isregister isEqualToString:@"1"]) {
        CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
        [app.mainController.navigationController pushViewController:viewController animated:YES];
        app.isregister = @"0";
    }
}

#pragma mark - CustomTabBarDelegate
- (void)customTabBar:(CustomTabBar *)tabBar didSelectItem:(UIControl *)item {
    self.selectedIndex = item.tag;
}

- (void)checkLogin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autologincomplete" object:nil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    if (![[CommonUtil currentUtil] isLogin]) {
        if (appDelegate.flgAutoLogin) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin) name:@"autologincomplete" object:nil];
            return;
        }
        
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

//-(void) viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////    [self.selectedViewController endAppearanceTransition];
//}
//
//-(void) viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
////    [self.selectedViewController beginAppearanceTransition: NO animated: NO];
//}
//
//-(void) viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
////    [self.selectedViewController endAppearanceTransition];
//}

@end
