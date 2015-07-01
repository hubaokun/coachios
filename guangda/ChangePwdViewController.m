//
//  ChangePwdViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "MyInfoCell.h"
#import "LoginViewController.h"

@interface ChangePwdViewController ()<UITextFieldDelegate> {
    CGFloat _y;
    int _rows;
}
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;

- (IBAction)clickForCommit:(id)sender;

@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rows = 2;
    [self.commitBtn setEnabled:NO];
    self.commitBtn.alpha = 0.4;
    self.cells = [[NSMutableArray alloc] init];
    [self settingInfo];
    [self addInfoCell];
    [self loadInfo];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];

}

-(void)backupgroupTap:(id)sender{
    for (int i =0; i < _rows; i++) {
        MyInfoCell *cell = _cells[i];
        [cell.contentField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 页面数据
- (void)settingInfo {
    _titles = [NSArray arrayWithObjects:@"新密码", @"确认密码", nil];
    _hints = [NSArray arrayWithObjects:@"请输入新密码", @"请再次输入新密码", nil];
}

// 添加cell
- (void)addInfoCell {
    for (int i = 0; i < _rows; i++) {
        MyInfoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoCell" owner:self options:nil] lastObject];
        _y = 85 * i;
        cell.frame = CGRectMake(0, _y, _screenWidth, 85);
        cell.contentField.delegate = self;
        cell.contentField.tag = 100 + i;
        [cell.contentField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.editBtn.tag = 200 + i;
        cell.contentField.secureTextEntry = YES;
        [self.mainScrollView addSubview:cell];
        [_cells addObject:cell];
    }
}

- (void)loadInfo {
    for (int i = 0; i < _rows; i++) {
        MyInfoCell *curCell = _cells[i];
        curCell.titleLabel.text = _titles[i];
        curCell.contentField.placeholder = _hints[i];
        [curCell.editBtn addTarget:self action:@selector(clickForEditting:) forControlEvents:UIControlEventTouchUpInside];
    }
}

// 信息被改变
- (void)textFieldDidChange:(UITextField *)sender {
    long index = sender.tag - 100;
    MyInfoCell *cell = _cells[index];
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    [cell.editImageView setImage:image];
    
    if (self.commitBtn.enabled == NO) {
        self.commitBtn.enabled = YES;
        self.commitBtn.alpha = 1;
    }
}

#pragma mark - 点击方法
- (IBAction)clickForCommit:(id)sender {
    if (self.cells.count <= 1) {
        return;
    }
    MyInfoCell *curCell = _cells[0];
    NSString *pwd = curCell.contentField.text;
    
    if([CommonUtil isEmpty:pwd]){
        [self makeToast:@"请输入新密码"];
        [curCell.contentField becomeFirstResponder];
        return;
    }
    
    
    MyInfoCell *curCell1 = _cells[1];
    NSString *pwd2 = curCell1.contentField.text;
    
    if([CommonUtil isEmpty:pwd2]){
        [self makeToast:@"请再次输入新密码"];
        return;
    }
    
    if (![pwd isEqualToString:pwd2]){
        [self makeToast:@"两次密码输入不一致"];
        [curCell1.contentField becomeFirstResponder];
        return;
    }
    
    [curCell.contentField becomeFirstResponder];
    [curCell1.contentField becomeFirstResponder];
    
    [self changePwd:pwd];
    
}

- (void)clickForEditting:(UIButton *)sender {
    long index = sender.tag - 200;
    MyInfoCell *cell = _cells[index];
    [cell.contentField becomeFirstResponder];
}

#pragma mark - 接口
//验证密码
- (void)changePwd:(NSString *)pwd{
    if (self.cells.count <= 0) {
        return;
    }
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    pwd = [[CommonUtil md5:pwd] lowercaseString];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangePsw" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"]; // 用户id
    [request setPostValue:userInfo[@"token"] forKey:@"token"]; // token
    [request setPostValue:pwd forKey:@"password"]; // 密码
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
        //修改密码成功
        [self makeToast:@"密码修改成功"];
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
