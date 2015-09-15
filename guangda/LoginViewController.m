//
//  LoginViewController.m
//  guangda
//
//  Created by Dino on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "PhoneTestViewController.h"
#import "CoachInfoViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *loginContentView;

@property (strong, nonatomic) IBOutlet UITextField *userName;   // 账号
@property (strong, nonatomic) IBOutlet UITextField *passWord;   // 密码

@property (strong, nonatomic) IBOutlet UIView *loginDetailsView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtnOutlet;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.loginContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.scrollView addSubview:self.loginContentView];
    [self.userName setValue:RGB(173, 173, 173) forKeyPath:@"_placeholderLabel.textColor"];
    [self.passWord setValue:RGB(173, 173, 173) forKeyPath:@"_placeholderLabel.textColor"];
    self.loginBtnOutlet.layer.cornerRadius = 3;
    self.userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passWord.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.vcodeButton.layer.cornerRadius = 3;
    [self.vcodeButton setTitle:@"  获取\n验证码" forState:UIControlStateNormal];
    
    [self.vcodeButton didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        [self.vcodeButton setBackgroundColor:RGB(210, 210, 210)];
        [self.vcodeButton setTitleColor:RGB(37, 37, 37) forState:UIControlStateNormal];
        NSString *title = @"";
        if(second < 10){
            title = [NSString stringWithFormat:@"    %d\"\n后重获",second];
        }else if(second > 99){
            title = [NSString stringWithFormat:@"  %d\"\n后重获",second];
        }else{
            title = [NSString stringWithFormat:@"   %d\"\n后重获",second];
        }
        return title;
    }];
    [self.vcodeButton didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        [countDownButton setBackgroundColor:RGB(247, 148, 29)];
        [countDownButton setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        return @"  重获\n验证码";
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBtnStatus) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelClick:) name:@"closeSelfView" object:nil];
    
    if(![CommonUtil isEmpty:self.errMessage]){
        [self makeToast:self.errMessage];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.userName) {
        if (range.location==11)
        {
            return  NO;
        }
        else
        {
            return YES;
        }
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 忘记密码
- (IBAction)forgetPwdClick:(id)sender {
    PhoneTestViewController *viewController = [[PhoneTestViewController alloc] initWithNibName:@"PhoneTestViewController" bundle:nil];
    viewController.type = 2;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 登录
- (IBAction)loginClick:(id)sender {
    NSString *password = [self.passWord.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *phone = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
  
    if([CommonUtil isEmpty:password])
    {
        [self makeToast:@"请输入验证码"];
        return ;
    }
    
    // 用户密码都不为空调用接口
    [self login:phone passWord:password];
}

// 取消
- (IBAction)cancelClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// 注册
- (IBAction)registerClick:(id)sender {
    
    PhoneTestViewController *viewController = [[PhoneTestViewController alloc] initWithNibName:@"PhoneTestViewController" bundle:nil];
    viewController.type = 1;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}

// 密码显示明文
- (IBAction)showPwdClick:(id)sender {
    self.passWord.secureTextEntry = !self.passWord.secureTextEntry;
}

#pragma mark - 监听
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    int _height = [UIScreen mainScreen].bounds.size.height;
    
    int chazhi = (_height - self.loginDetailsView.bounds.size.height) / 2;
    
    self.scrollView.contentOffset = CGPointMake(0, height - chazhi+20-10);

}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
- (void)checkBtnStatus
{
    if ((self.userName.text.length != 0)
        && (self.passWord.text.length != 0))
    {
        self.loginBtnOutlet.backgroundColor = RGB(32, 180, 120);
        
    }else{
        self.loginBtnOutlet.backgroundColor = RGB(210, 210, 210);
        
    }
}

#pragma mark - 接口
- (void)login:(NSString *)userName passWord:(NSString *) passWord {
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 1;
    request.requestMethod = @"POST";
    [request setPostValue:@"Login" forKey:@"action"];
    [request setPostValue:userName forKey:@"loginid"]; // 手机号码
    [request setPostValue:passWord forKey:@"password"]; // 密码
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [request setPostValue:app_Version forKey:@"version"];
    //手机型号
    [request setPostValue:@"1" forKey:@"ostype"];
    
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    if(request.tag == 0){
        if ([code intValue] == 1) {
            [self makeToast:@"验证码获取成功"];
            //开始倒计时
            self.vcodeButton.enabled = NO;
            [self.vcodeButton startWithSecond:60];
        }else{
            [self makeToast:ERR_NETWORK];
        }
    }else{
        // 取得数据成功
        if ([code intValue] == 1) {
            
            // 取出对应的userInfo数据
            NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
            user = [[result objectForKey:@"UserInfo"] mutableCopy];
            // 将解析出来的数据保存到本地
            [CommonUtil saveObjectToUD:user key:@"userInfo"];
            
            NSString *username = self.userName.text;
            NSString *password = self.passWord.text;
            
            // 去除用户和密码的左右空格
            username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            password = password;
            // 从本地取登录账号和密码
            [CommonUtil saveObjectToUD:username key:@"loginusername"];
            [CommonUtil saveObjectToUD:password key:@"loginpassword"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.userid = user[@"coachid"];
            [app toUploadDeviceInfo];
            
            int isregister = [[result objectForKey:@"isregister"] intValue];
            app.isregister = [NSString stringWithFormat:@"%d",isregister];
            int isInvited = [[result objectForKey:@"isInvited"] intValue];
            app.isInvited = [NSString stringWithFormat:@"%d",isInvited];
            NSString *crewardamount = [result[@"crewardamount"] description];
            app.crewardamount = crewardamount;
            NSString *orewardamount = [result[@"orewardamount"] description];
            app.orewardamount = orewardamount;
            
            [app jumpToMainViewController];
            
//            if(isregister == 0){
////                [self.navigationController popViewControllerAnimated:YES];
//            }else{
//                CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
//                [app.mainController.navigationController pushViewController:viewController animated:YES];
//            }
            
        } else {
            
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            
            [self makeToast:message];
        }
    }
    
   [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
}
- (IBAction)clickForGetVcode:(id)sender {
    
    NSString *phone = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
    
    if ([phone isEqualToString:@"18888888888"]) {
        [self makeToast:@"测试账号，请使用默认验证码"];
        return;
    }
    
    //请求验证码
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSuserServlet]];
    request.delegate = self;
    request.tag = 0;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetVerCode" forKey:@"action"];
    [request setPostValue:phone forKey:@"phone"]; // 手机号码
    [request setPostValue:@"1" forKey:@"type"]; // 密码
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

@end
