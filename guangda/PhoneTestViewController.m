//
//  PhoneTestViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "JKCountDownButton.h"
#import "RegisterViewController.h"
#import "SetNewPassViewController.h"
#import "PhoneTestViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AppDelegate.h"

@interface PhoneTestViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *phonTestContentView;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;  // 手机号码
@property (strong, nonatomic) IBOutlet UITextField *testTextField;   // 验证号码
//@property (strong, nonatomic) IBOutlet UIButton *getTestBtnOutlet;  // 获取验证码
@property (strong, nonatomic) IBOutlet UILabel *phoneTestLabel;   // 显示类型
@property (strong, nonatomic) IBOutlet JKCountDownButton *getTestBtnOutlet;


@property (strong, nonatomic) IBOutlet UIButton *nextStepOutlet;  // 下一步按钮属性
- (IBAction)nextStepBtn:(id)sender;
//- (IBAction)cancelBtn:(id)sender;
//- (IBAction)getTestCardBtn:(id)sender; // 获取验证码
@property(assign, nonatomic) int isType;

@end

@implementation PhoneTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.phonTestContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    self.scrollView.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    if(self.type == 1){
        self.phoneTestLabel.text = @"手机验证";
    }else{
        self.phoneTestLabel.text = @"密码找回";
    }
    // Do any additional setup after loading the view from its nib.
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBtnStatus) name:UITextFieldTextDidChangeNotification object:nil];
    [self.scrollView addSubview:self.phonTestContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkBtnStatus
{
    if (self.phoneTextField.text.length != 0)
    {
        self.getTestBtnOutlet.backgroundColor = RGB(32, 180, 120);
    }else{
        self.getTestBtnOutlet.backgroundColor = RGB(210, 210, 210);
    }
    
    if ((self.phoneTextField.text.length != 0)
        && (self.testTextField.text.length != 0))
    {
        [self.nextStepOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.nextStepOutlet.enabled = YES;
    }else{
        [self.nextStepOutlet setTitleColor:RGB(211, 211, 211) forState:UIControlStateNormal];
        self.nextStepOutlet.enabled = NO;
    }
    
}

// 获取验证码
- (IBAction)countDownXibTouched:(JKCountDownButton*)sender {
    NSString *phoneNum = self.phoneTextField.text;
    NSString *str = [phoneNum substringToIndex:1];
    NSString *str1 = @"1";
    if ([str isEqualToString:str1] == 0) {
        [self makeToast:@"请输入正确格式的手机号"];
        return;
    }
    if (phoneNum.length != 11) {
        [self makeToast:@"请输入正确格式的手机号"];
        return;
    }
    if(self.type == 1){
        [self getVerCode:phoneNum type:@"1"];
        NSLog(@"1111---");
    }else{
        [self getVerCode:phoneNum type:@"2"];
        NSLog(@"22222---");
    }
    sender.enabled = NO;
    //button type要 设置成custom 否则会闪动
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
// 下一步
- (IBAction)nextStepBtn:(id)sender {
    // 调用验证验证码接口
  [self checkVerCode:self.phoneTextField.text code:self.testTextField.text];
//    RegisterViewController *viewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
//    viewController.userPhone = self.phoneTextField.text;
//    [self.navigationController pushViewController:viewController animated:YES];
   
}





#pragma mark - 获取验证码接口
- (void)getVerCode:(NSString *)phoneNum type:(NSString *)type {
    //passWord = [[CommonUtil md5:passWord] lowercaseString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSuserServlet]];
    request.delegate = self;
    request.tag = 0;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetVerCode" forKey:@"action"];
    [request setPostValue:phoneNum forKey:@"phone"]; // 手机号码
    [request setPostValue:type forKey:@"type"]; // 密码
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

// 验证验证码的有效性
- (void)checkVerCode:(NSString *)phoneNum code:(NSString *)code {
    //passWord = [[CommonUtil md5:passWord] lowercaseString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSuserServlet]];
    request.delegate = self;
    request.tag = 1;
    request.requestMethod = @"POST";
    [request setPostValue:@"VerificationCode" forKey:@"action"];
    //NSLog(@"%@-----%@",phoneNum,code);
    [request setPostValue:phoneNum forKey:@"phone"]; // 手机号码
    [request setPostValue:code forKey:@"code"]; // 验证码
    [request setPostValue:@"1" forKey:@"type"]; // 类型  1.教练  2.学员
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
        //NSDictionary *dic = [[NSDictionary alloc] init];
        if(request.tag == 0){
            //self.testTextField.text = [result objectForKey:@"vercode"];
            [self makeToast:@"获取验证码成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextFieldTextDidChangeNotification" object:nil];
            
            self.getTestBtnOutlet.enabled = NO;
            // 设置多少秒后可以重新获取
            [self.getTestBtnOutlet startWithSecond:60];
            
            [self.getTestBtnOutlet didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
                NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
                return title;
            }];
            [self.getTestBtnOutlet didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
                countDownButton.enabled = YES;
                return @"    点击重新获取";
            }];
        }else{
            
            if(self.type == 1){
                RegisterViewController *viewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
                viewController.userPhone = self.phoneTextField.text;
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                SetNewPassViewController *viewController =  [[SetNewPassViewController alloc] initWithNibName:@"SetNewPassViewController" bundle:nil];
                viewController.userPhone = self.phoneTextField.text;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
        //[self.navigationController popToRootViewControllerAnimated:YES];
    } else {
//        if([code intValue] == 2){
//            [self makeToast:@"号码已被注册"];
//        }else{
         // if(request.tag == 0){
        if(request.tag == 0){
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
//            [self makeToast:@"获取失败请重试"];
            self.getTestBtnOutlet.enabled = YES;
        }else{
             if ([CommonUtil isEmpty:message]) {
                 message = ERR_NETWORK;
                }
              
           // }
            [self makeToast:message];
         //}
        }
    }
    
    [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    
    if(request.tag == 0){
        [self makeToast:@"获取失败请重试"];
        self.getTestBtnOutlet.enabled = YES;
    }else{
        [self makeToast:ERR_NETWORK];
    }
}

@end
