//
//  RecommendCodeViewController.m
//  guangda
//
//  Created by Ray on 15/7/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendCodeViewController.h"
#import "CoachInfoViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
@interface RecommendCodeViewController ()

@property (strong, nonatomic) IBOutlet UITextField *inviteCode;
@property (strong, nonatomic) IBOutlet UIView *inviteCodeView;
@property (strong, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation RecommendCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //圆角
    self.sureButton.layer.cornerRadius = 4;
    self.sureButton.layer.masksToBounds = YES;
    
    self.inviteCodeView.layer.borderWidth = 1;
    self.inviteCodeView.layer.borderColor = RGB(222, 222, 222).CGColor;
    
}

- (void) getRecommendRecordList{
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kRecommend]];
    
    request.delegate = self;
    request.tag = 0;
    [request setPostValue:@"CHEAKINVITECODE" forKey:@"action"];
    [request setPostValue:self.inviteCode.text forKey:@"InviteCode"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"InvitedCoachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    
    [request startAsynchronous];
}

#pragma mark 回调
- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    NSString *isRecommended = [result[@"isRecommended"] description];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if ([isRecommended intValue] == 1) {
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([app.isregister isEqualToString:@"1"]) {
                CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
                app.isregister = @"0";
                app.isInvited = @"0";
                app.superViewNum = @"1";
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                app.isInvited = @"0";
                app.isregister = @"0";
                MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            [self makeToast:@"推荐成功"];
        }else{
            [self makeToast:@"请输入正确的推荐码"];
        }
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
    } else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
        
    }else{
        
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:message];
    }
    
}
// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self makeToast:ERR_NETWORK];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

//发送邀请码
- (IBAction)clickForSure:(id)sender {
    if (self.inviteCode.text.length == 0 || [self.inviteCode.text isEqualToString:@"请输入推荐码"]) {
        [self makeToast:@"请输入正确的推荐码"];
    }else{
        [self getRecommendRecordList];
    }
}

- (IBAction)clickForPop:(id)sender {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.isregister isEqualToString:@"1"]) {
        CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
        app.isregister = @"0";
        app.isInvited = @"0";
        app.superViewNum = @"1";
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        app.isInvited = @"0";
        app.isregister = @"0";
        MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
