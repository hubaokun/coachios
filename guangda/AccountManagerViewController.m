//
//  AccountManagerViewController.m
//  guangda
//
//  Created by guok on 15/6/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "LoginViewController.h"

@interface AccountManagerViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)clickForSubmit:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *inpputViewBg;

@property (strong, nonatomic) IBOutlet UITextField *accountInputView;

@property (strong, nonatomic) IBOutlet UIButton *closeKeyBoard;
- (IBAction)clickForCloseKeyBoard:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *clearAccountButton;
- (IBAction)clickForClearAccount:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *applySwitch;

- (IBAction)switchChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *applyTypeTipLabel;
@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inpputViewBg.layer.cornerRadius = 5;
    self.inpputViewBg.layer.borderWidth = 1;
    self.inpputViewBg.layer.borderColor = [RGB(199, 199, 199) CGColor];
    
    
    //提交按钮默认不可以点击
    self.submitButton.alpha = 0.4;
    self.submitButton.enabled = NO;
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    if(![CommonUtil isEmpty:aliaccount]){
        self.accountInputView.text = aliaccount;
    }
    
    UIImage *image1 = [[UIImage imageNamed:@"btn_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *image2 = [[UIImage imageNamed:@"btn_red_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.clearAccountButton setBackgroundImage:image1 forState:UIControlStateNormal];;
    [self.clearAccountButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    
    //注册监听，防止键盘遮挡视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
    int cashtype = [user_info[@"cashtype"] intValue];
    if(cashtype == 0){
        self.applySwitch.on = NO;
        self.applyTypeTipLabel.text = @"您现在提现的金额将会直接转到您的支付宝账户";
    }else{
        self.applySwitch.on = YES;
        self.applyTypeTipLabel.text = @"您现在提现的金额将会转到您所在的驾校";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.closeKeyBoard.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.closeKeyBoard.hidden = YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *input = [toBeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(![CommonUtil isEmpty:input] && ![input isEqualToString:aliaccount]){
        self.submitButton.alpha = 1;
        self.submitButton.enabled = YES;
    }else{
        self.submitButton.alpha = 0.4;
        self.submitButton.enabled = NO;
    }
    return  YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickForSubmit:(id)sender {
    NSString *aliaccount = [self.accountInputView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    
    NSString *uri = @"/cmy?action=ChangeAliAccount";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"coachid"] forKey:@"userid"];
    [paramDic setObject:@"1" forKey:@"type"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:aliaccount forKey:@"aliaccount"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
            
            //更新用户的支付宝账户设置
            NSString *account = responseObject[@"aliacount"];
            NSMutableDictionary *user_info = [[CommonUtil getObjectFromUD:@"userInfo"] mutableCopy];
            [user_info setObject:account forKey:@"alipay_account"];
            [CommonUtil saveObjectToUD:user_info key:@"userInfo"];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(backLogin)
                                               userInfo:nil
                                                repeats:NO];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (IBAction)clickForClearAccount:(id)sender{
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    
    NSString *uri = @"/cmy?action=DelAliAccount";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"coachid"] forKey:@"userid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:@"1" forKey:@"type"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"清除支付宝账号成功"];
            
            //更新用户的支付宝账户设置
            NSMutableDictionary *user_info = [[CommonUtil getObjectFromUD:@"userInfo"] mutableCopy];
            [user_info setObject:@"" forKey:@"alipay_account"];
            [CommonUtil saveObjectToUD:user_info key:@"userInfo"];
            self.accountInputView.text = @"";
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (IBAction)clickForCloseKeyBoard:(id)sender {
    [self.accountInputView resignFirstResponder];
}

- (IBAction)switchChanged:(id)sender {
    UISwitch *s = (UISwitch*)sender;
    int setvalue = 0;
    if(s.on){
        setvalue = 1;
    }
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    
    NSString *uri = @"/cmy?action=ChangeApplyType";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"coachid"] forKey:@"coachid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:[NSString stringWithFormat:@"%d",setvalue] forKey:@"setvalue"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"修改成功"];
            
            //更新用户的支付宝账户设置
            NSMutableDictionary *user_info = [[CommonUtil getObjectFromUD:@"userInfo"] mutableCopy];
            [user_info setObject:responseObject[@"cashtype"] forKey:@"cashtype"];
            [CommonUtil saveObjectToUD:user_info key:@"userInfo"];
            
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        NSDictionary *user = [CommonUtil getObjectFromUD:@"userInfo"];
        int cashtype = [user[@"cashtype"] intValue];
        if(cashtype == 0){
            self.applySwitch.on = NO;
            self.applyTypeTipLabel.text = @"您现在提现的金额将会直接转到您的支付宝账户";
        }else{
            self.applySwitch.on = YES;
            self.applyTypeTipLabel.text = @"您现在提现的金额将会转到您所在的驾校";
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
        
        NSDictionary *user = [CommonUtil getObjectFromUD:@"userInfo"];
        int cashtype = [user[@"cashtype"] intValue];
        if(cashtype == 0){
            self.applySwitch.on = NO;
            self.applyTypeTipLabel.text = @"您现在提现的金额将会直接转到您的支付宝账户";
        }else{
            self.applySwitch.on = YES;
            self.applyTypeTipLabel.text = @"您现在提现的金额将会转到您所在的驾校";
        }
    }];
    
}
@end
