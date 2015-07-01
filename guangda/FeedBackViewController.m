//
//  FeedBackViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "FeedBackViewController.h"
#import "LoginViewController.h"

@interface FeedBackViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *submitbutton;       // 提交按钮属性
@property (strong, nonatomic) IBOutlet UITextView *feedBackTextView; // 反馈内容

- (IBAction)submitBtn:(id)sender; // 提交按钮
@property (strong, nonatomic) IBOutlet UITextField *opinionTextField;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitB) name:UITextViewTextDidChangeNotification object:nil];
    //self.feedBackTextView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
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

// 设置提交是否能点击
- (void)submitB
{
    if(self.feedBackTextView.text.length != 0)
    {
        [self.submitbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.submitbutton.enabled = YES;
    }else{
        [self.submitbutton setTitleColor:RGB(211, 211, 211) forState:UIControlStateNormal];
        self.submitbutton.enabled = NO;
    }
}

// 提交按钮操作
- (IBAction)submitBtn:(id)sender {
    NSString *feedbackcontet = self.feedBackTextView.text;
    // 调用接口
    [self submitFeedBack:feedbackcontet feedBackType:1];
    
}


-(void)textViewDidChange:(UITextView *)textView
{
   // NSLog(@"---++");
    if(self.feedBackTextView.text.length == 0)
    {
        self.opinionTextField.hidden = NO;
    }else
    {
        self.opinionTextField.hidden = YES;
    }
}
#pragma mark - 意见反馈接口
- (void)submitFeedBack:(NSString *)feedBackContent feedBackType:(int)feedBackType {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSetServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"Feedback" forKey:@"action"];
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"studentid"];     // 教练ID
    [request setPostValue:dic[@"token"] forKey:@"token"];
    [request setPostValue:feedBackContent forKey:@"content"];     // 反馈内容
    [request setPostValue:[NSString stringWithFormat:@"%i",feedBackType] forKey:@"type"];     // 来自客户端 1.教练  2 学员
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
        [self makeToast:@"提交成功"];
        [self.navigationController popViewControllerAnimated:YES];
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
