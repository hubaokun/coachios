//
//  SetNewPassViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "LoginViewController.h"
#import "SetNewPassViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AppDelegate.h"

@interface SetNewPassViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *setNewPassWordContentView;
@property (strong, nonatomic) IBOutlet UIButton *sureBtnOutlet;  // 确定按钮属性
@property (strong, nonatomic) IBOutlet UITextField *setNewPassWordTextField;  // 输入新密码

- (IBAction)sureBtn:(id)sender;  // 确定按钮

@end

@implementation SetNewPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.setNewPassWordContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    self.scrollView.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBtnStatus) name:UITextFieldTextDidChangeNotification object:nil];
    [self.scrollView addSubview:self.setNewPassWordContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkBtnStatus
{
    if (self.setNewPassWordTextField.text.length != 0)
    {
        [self.sureBtnOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.sureBtnOutlet.enabled = YES;
    }else{
        [self.sureBtnOutlet setTitleColor:RGB(211, 211, 211) forState:UIControlStateNormal];
        self.sureBtnOutlet.enabled = NO;
    }
}

// 确定按钮
- (IBAction)sureBtn:(id)sender {
    NSString *newPass = self.setNewPassWordTextField.text;
    [self findPsw:newPass];

}

#pragma mark - 接口
- (void)findPsw:(NSString *) newPassWord {
    newPassWord = [[CommonUtil md5:newPassWord] lowercaseString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"FindPsw" forKey:@"action"];
    
    [request setPostValue:self.userPhone forKey:@"phone"];  // 手机号码
    [request setPostValue:newPassWord forKey:@"newpassword"];  // 新密码
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        [self makeToast:@"修改成功"];
        if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
            LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [self.navigationController pushViewController:nextViewController animated:YES];
        }
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
