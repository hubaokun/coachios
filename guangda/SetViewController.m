//
//  SetViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SetViewController.h"
#import "FeedBackViewController.h"
#import "AboutUsViewController.h"
#import "LoginViewController.h"

@interface SetViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *taskChangedSwitch;

- (IBAction)newTaskChanged:(id)sender;

- (IBAction)clickFeedBack:(id)sender;
- (IBAction)clickAboutUs:(id)sender;
- (IBAction)clickLogOff:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.logoutButton.layer.cornerRadius = 4.0;
    self.logoutButton.layer.masksToBounds = YES;
    
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

// 设置是否接受新任务通知
- (IBAction)newTaskChanged:(id)sender {
    if(_taskChangedSwitch.on == YES)
    {
        // 将数据存到字典
        NSDictionary *taskChangedDict = [NSDictionary dictionaryWithObject:@"0" forKey:@"boolkey"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:taskChangedDict key:@"boolChanged"];
        // 调用接口
        [self taskChanged:0];
    }else{
        NSDictionary *taskChangedDict = [NSDictionary dictionaryWithObject:@"1" forKey:@"boolkey"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:taskChangedDict key:@"boolChanged"];
        [self taskChanged:1];
    }
}

// 进入意见反馈界面
- (IBAction)clickFeedBack:(id)sender {
    FeedBackViewController *targetViewController = [[FeedBackViewController alloc] initWithNibName:@"FeedBackViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 进入关于我们界面
- (IBAction)clickAboutUs:(id)sender {
    AboutUsViewController *targetViewController = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 响应方法
- (void)sendNotification{
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 退出登录
- (IBAction)clickLogOff:(id)sender {
    
    [CommonUtil logout];
    
    [self sendNotification];
    
}

#pragma mark - 接受新任务通知接口
- (void)taskChanged:(int)newTaskNoTi {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangeSet" forKey:@"action"];
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
    [request setPostValue:[NSString stringWithFormat:@"%i",newTaskNoTi]forKey:@"newtasknoti"];  // 接收到新任务是否提醒 0.提醒 1.不提醒
    [request startAsynchronous];
    //[DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        
    } else {
        
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        
        [self makeToast:message];
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
}

@end
