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
#import "RecommendCodeViewController.h"
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
    // ios7中，本视图有状态栏、下面为scrollView，这句让进入下一个视图后，再回来，不会出现scrollview下移20(offSet:-20)的情况；添加在viewDidLoad中
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //判断教练是否能被邀请
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *addtimeStr = [userInfo[@"addtime"] description];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *addtime = [formatter dateFromString:addtimeStr];
    NSTimeInterval time = [addtime timeIntervalSince1970];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    long long int date = time -nowTime + 6*60*60;
    if([app.isInvited isEqualToString:@"1"] && date > 0){
        RecommendCodeViewController *viewController = [[RecommendCodeViewController alloc] initWithNibName:@"RecommendCodeViewController" bundle:nil];
        [app.mainController.navigationController pushViewController:viewController animated:YES];
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
