//
//  RegisterViewController.m
//  guangda
//
//  Created by Dino on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//


#import "RegisterViewController.h"
#import "RelatedDataViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AppDelegate.h"
#import "CoachInfoViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    CGFloat _keyboardHeight;
}

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *registerContentView;

@property (strong, nonatomic) IBOutlet UITextField *userName;       // 用户名
@property (strong, nonatomic) IBOutlet UITextField *cardId;       // 身份证
@property (strong, nonatomic) IBOutlet UITextField *passWord;       // 设置密码


@property (strong, nonatomic) IBOutlet UIButton *registerBtnOutlet;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.registerContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    self.scrollView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    [self.scrollView addSubview:self.registerContentView];   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBtnStatus) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 0) {
        
    }else if (textField.tag == 1)
    {
        self.scrollView.contentOffset = CGPointMake(0, 75);
        
    }else if (textField.tag == 2)
    {
        self.scrollView.contentOffset = CGPointMake(0, 150);
    }
    return YES;
}

// 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    
    self.scrollView.contentSize = CGSizeMake(0, 450 + _keyboardHeight);
}

- (void)keyboardWillHidden
{
    self.scrollView.contentSize = CGSizeMake(0, 0);
//    self.scrollView.contentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height - 64);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1){
        if (self.cardId.text.length != 18) {
        [self makeToast:@"请输入正确格式的身份证"];
       // return;
        }
    }else if(textField.tag == 2){
        if(self.passWord.text.length < 6 || self.passWord.text.length > 20)
        {
         [self makeToast:@"密码长度要大于等于6位"];
       // return ;
        }
    }
    
    

}

- (void)checkBtnStatus
{
   
    if ((self.userName.text.length != 0)
        && (self.cardId.text.length != 0)
        && (self.passWord.text.length != 0))
    {
        [self.registerBtnOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.registerBtnOutlet.enabled = YES;
    }else{
        [self.registerBtnOutlet setTitleColor:RGB(211, 211, 211) forState:UIControlStateNormal];
        self.registerBtnOutlet.enabled = NO;
    }
}

//- (IBAction)hideKeyboardClick:(id)sender {
//    [self.userName resignFirstResponder];
//    [self.trueName resignFirstResponder];
//    [self.passWord resignFirstResponder];
//    [self.checkPwd resignFirstResponder];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.userName resignFirstResponder];
    [self.cardId resignFirstResponder];
    [self.passWord resignFirstResponder];
   // [self.checkPwd resignFirstResponder];
    return YES;
}

// 点击注册按钮
- (IBAction)registerClick:(id)sender {
    
    // 获取输入框字符串
    NSString *username = self.userName.text;
    NSString *cardid = self.cardId.text;
    NSString *password = self.passWord.text;
    //NSString *checkpwd = self.checkPwd.text;
    
    // 去除左右空格
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cardid = [cardid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // checkpwd = [checkpwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 判断姓名是否为空
    if([CommonUtil isEmpty:username])
    {
        [self makeToast:@"真实姓名不能为空"];
        return ;
    }
    // 判断身份证不能为空
    if([CommonUtil isEmpty:cardid])
    {
        [self makeToast:@"身份证不能为空"];
        return ;
    }
    // 判断密码不能为空
    if([CommonUtil isEmpty:password])
    {
        [self makeToast:@"密码不能为空"];
        return ;
    }
    
    if (self.cardId.text.length != 18) {
        [self makeToast:@"请输入正确格式的身份证"];
        return;
    }
    
    if(password.length < 6 || password.length > 20)
    {
        [self makeToast:@"密码长度要大于等于6位"];
        return ;
    }
   
    // 判断2次密码输入是否一致
//    if(![password isEqualToString:checkpwd])
//    {
//        [self makeToast:@"两次密码输入不一致"];
//        return ;
//    }
    [self register:username cardId:cardid passWord:password];
    
//    CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 接口
- (void)register:(NSString *)userName cardId:(NSString *)cardId passWord:(NSString *)passWord {
    passWord = [CommonUtil md5:passWord];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"Register" forKey:@"action"];
    
    NSLog(@"%@---%@",self.userPhone,self.testNum);
    
    [request setPostValue:self.userPhone forKey:@"phone"];   // 手机号码 唯一
    [request setPostValue:userName forKey:@"realname"];      // 真实姓名
    //[request setPostValue:self.testNum forKey:@"vcode"];     // 验证码
    [request setPostValue:cardId forKey:@"idnum"];           // 身份证
    [request setPostValue:[passWord lowercaseString] forKey:@"password"];  // 密码
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
        //        NSLog(@"list: %@", result[@"datalist"]);
        
        // 取出对应的userInfo数据
        NSDictionary *user = [[NSDictionary alloc] init];
        user = [result objectForKey:@"UserInfo"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:user key:@"userInfo"];
        [self makeToast:@"注册成功"];
        
        // 取出教练ID
        NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *coachId  = [ds objectForKey:@"coachid"];
        NSLog(@"%@",coachId);
        
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.userid = user[@"coachid"];
        [app toUploadDeviceInfo];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
        
        CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
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
