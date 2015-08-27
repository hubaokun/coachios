//
//  CoachInfoTextFieldViewController.m
//  guangda
//
//  Created by Ray on 15/8/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachInfoTextFieldViewController.h"
#import "LoginViewController.h"
@interface CoachInfoTextFieldViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputTextfield;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *inputBackView;
@property (strong, nonatomic) IBOutlet UITextView *inputTextView;

@property (strong, nonatomic) NSMutableDictionary *msgDic;//资料
@end

@implementation CoachInfoTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.msgDic = [NSMutableDictionary dictionary];
    
    self.inputTextfield.delegate = self;
    self.inputTextView.delegate = self;
    self.inputBackView.hidden = YES;
    //1：姓名   2：驾培教龄  3：个人评价
    if ([self.viewType intValue] == 1) {
        self.titleLabel.text = @"姓名";
        self.inputTextfield.placeholder = @"请输入真实姓名";
        if (self.textString.length>0) {
            self.inputTextfield.text = self.textString;
        }
        self.inputTextfield.keyboardType = UIKeyboardTypeDefault;
    }else if ([self.viewType intValue] == 2){
        self.titleLabel.text = @"驾培教龄";
        self.inputTextfield.placeholder = @"请输入真实驾培教龄";
        if (self.textString.length>0) {
            self.inputTextfield.text = self.textString;
        }
        self.inputTextfield.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([self.viewType intValue] == 3){
        self.inputBackView.hidden = NO;
        self.titleLabel.text = @"个人评价";
        if (self.textString.length>0) {
            NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
            NSString *selfeval = userInfo[@"selfeval"];
            self.inputTextView.text = selfeval;
        }
        //        self.inputTextfield.placeholder = @"请输入真实姓名";
    }
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self registerForKeyboardNotifications];
}

- (IBAction)clickForCommit:(id)sender {
    if (self.inputTextfield.text > 0) {
        if ([self.viewType intValue]==1) {
            [self updateUserData:@"realname" and:self.inputTextfield.text];
            
        }else{
            [self updateUserData];
        }

    }else{
        [self makeToast:@"不能提交空白资料"];
    }
}

#pragma mark - 接口
//提交个人资料
- (void)updateUserData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = userInfo[@"coachid"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 0;
    request.requestMethod = @"POST";
    [request setPostValue:@"PerfectPersonInfo" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    NSString *text = self.inputTextfield.text;
    NSString *str = @"";//提交的字段
    NSString *userKey = @"";//useInfo中的字段
    if ([self.viewType intValue] == 1){
        //出生年月
        str = @"birthday";
        userKey = @"birthday";
        [request setPostValue:self.inputTextfield.text forKey:str];
    }else if ([self.viewType intValue] == 2){
        //教龄
        str = @"years";
        userKey = @"years";
        [request setPostValue:self.inputTextfield.text forKey:str];
    }else if ([self.viewType intValue] == 3){
        //自我评价
        str = @"selfeval";
        userKey = @"selfeval";
        [request setPostValue:self.inputTextView.text forKey:str];
    }
    if (![CommonUtil isEmpty:text]) {
        [self.msgDic setObject:text forKey:userKey];
    }
    
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

//提交个人资料
- (void)updateUserData:(NSString *)key and:(id)value{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = userInfo[@"coachid"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 1;
    request.requestMethod = @"POST";
    [request setPostValue:@"PerfectAccountInfo" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];
    
    [request setPostValue:value forKey:key];
    [self.msgDic setObject:value forKey:key];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
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
            NSMutableDictionary * ds = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            for (NSString *key in self.msgDic.allKeys) {
                [ds setObject:[self.msgDic objectForKey:key] forKey:key];
            }
            [self.navigationController popViewControllerAnimated:YES];
            [CommonUtil saveObjectToUD:ds key:@"userInfo"];
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
        
        [self makeToast:message];
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}


-(void)backupgroupTap:(id)sender{
    [self.inputTextfield resignFirstResponder];
}


#pragma mark - 键盘遮挡输入框处理
// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    //    if (!self.commitView.superview) {
    //        return;
    //    }
    //    _oldFrame = self.commitView.frame;
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    //    CGFloat keyboardTop = keyboardRect.origin.y;
    
    //    CGFloat offset = CGRectGetMaxY(self.commitView.frame) - keyboardTop + 10;
    
    NSTimeInterval animationDuration = 0.3f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //    self.commitView.frame = CGRectMake(_oldFrame.origin.x, _oldFrame.origin.y - offset, _oldFrame.size.width, _oldFrame.size.height);
    [UIView commitAnimations];
    
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    //    if (!self.commitView.superview) {
    //        return;
    //    }
    //    self.commitView.frame = _oldFrame;
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
