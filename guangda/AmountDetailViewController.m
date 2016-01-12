//
//  AmountDetailViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AmountDetailViewController.h"
#import "DSPullToRefreshManager.h"
#import "AmountTableViewCell.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AccountManagerViewController.h"
#import "APAuthV2Info.h"
#import "LoginViewController.h"

@interface AmountDetailViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient,UITextFieldDelegate>{
    CGRect _oldFrame1;
    CGRect _oldFrame2;
}


@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新

//参数
@property (strong, nonatomic) NSMutableArray *amountArray;
@property (strong, nonatomic) NSString *totalPrice;//总金额
@property (strong, nonatomic) NSString *fMoney;//冻结金额
@property (strong, nonatomic) NSString *gmoney;//保证金额

@property (strong, nonatomic) IBOutlet UIButton *rechargButton;
@property (strong, nonatomic) IBOutlet UIButton *applyButton;

- (IBAction)clickForRecharge:(id)sender;
- (IBAction)clickForApply:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *rechargeView;
- (IBAction)clickForCloseAlert:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *rechargeCommitBtn;
@property (strong, nonatomic) IBOutlet UITextField *rechargeYuanTextField;

@property (strong, nonatomic) IBOutlet UILabel *headAlertMoneyLabel;  //总金额
@property (strong, nonatomic) IBOutlet UILabel *canBeCashLabel;    //可提现金额
@property (strong, nonatomic) IBOutlet UILabel *frozenMoneyLabel;  //冻结金额

@property (strong, nonatomic) IBOutlet UIView *getMoneyView;        // 申请金额视图
@property (strong, nonatomic) IBOutlet UIView *commitView;          // 提交申请
@property (strong, nonatomic) IBOutlet UIView *successAlertView;    // 提交成功提示
@property (strong, nonatomic) IBOutlet UIView *rechargeBackView;//充值底部白view

@property (strong, nonatomic) IBOutlet UITextField *moneyYuanField; // 取钱

//取钱弹框
@property (strong, nonatomic) IBOutlet UILabel *alertMoneyLabel;//余额
@property (strong, nonatomic) IBOutlet UILabel *moneyDetailLabel;  //申请是否成功的提示
@property (strong, nonatomic) IBOutlet UILabel *moneyTitleLabel;  //是否提交成功的字段

- (IBAction)clickForAccountManager:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *commitBackView;   //返回按钮
@property (strong, nonatomic) IBOutlet UIButton *commitButton;   //提现按钮
@property (strong, nonatomic) IBOutlet UIImageView *noMoneyImage;  //余额不足的图片
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel;  //警告
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel2;

@property (strong, nonatomic) IBOutlet UIView *addMoneyBackView;
@property (strong, nonatomic) IBOutlet UIView *apply_rechargeView;
@end

@implementation AmountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.amountArray = [NSMutableArray array];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
    [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self pullToRefreshTriggered:self.pullToRefresh];
    
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    
    self.rechargButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.rechargButton.layer.borderWidth = 0.5;
    self.apply_rechargeView.layer.cornerRadius = CGRectGetHeight(self.apply_rechargeView.frame)/2;
    self.apply_rechargeView.layer.masksToBounds = YES;
    self.apply_rechargeView.layer.borderWidth = 0.5;
    self.apply_rechargeView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _rechargeCommitBtn.layer.cornerRadius = 3;
    _rechargeCommitBtn.layer.masksToBounds = YES;
    self.rechargeCommitBtn.layer.borderWidth = 1;
    self.rechargeCommitBtn.layer.borderColor = RGB(188, 188, 188).CGColor;
    [self.rechargeCommitBtn setTitleColor:RGB(188, 188, 188) forState:UIControlStateDisabled];
    [self.rechargeCommitBtn setBackgroundImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateDisabled];
    [self.rechargeYuanTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.rechargeCommitBtn.enabled = NO;
    self.rechargeBackView.layer.cornerRadius = 3;
    self.rechargeBackView.layer.masksToBounds = YES;
    
    self.commitBackView.layer.borderColor = RGB(188, 188, 188).CGColor;
    self.commitBackView.layer.borderWidth = 1;
    self.addMoneyBackView.layer.borderColor = RGB(188, 188, 188).CGColor;
    self.addMoneyBackView.layer.borderWidth = 1;
    
    self.commitView.layer.cornerRadius = 3;
    self.commitView.layer.masksToBounds = YES;
    self.successAlertView.layer.cornerRadius = 3;
    self.successAlertView.layer.masksToBounds = YES;
    
    self.commitButton.layer.borderWidth = 1;
    self.commitButton.layer.borderColor = RGB(188, 188, 188).CGColor;
    self.commitButton.layer.cornerRadius = 3;
    self.commitButton.layer.masksToBounds = YES;
    [self.commitButton setTitleColor:RGB(188, 188, 188) forState:UIControlStateDisabled];
    [self.commitButton setBackgroundImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateDisabled];
    self.commitButton.enabled = NO;
    self.noMoneyImage.hidden = YES;
    self.moneyYuanField.delegate = self;
    [self.moneyYuanField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.attentionLabel2.hidden = YES;
    [self registerForKeyboardNotifications];
    
    //缺少一句话
    self.getMoneyView.frame = [UIScreen mainScreen].bounds;

}

- (void) textFieldDidChange:(UITextField *) TextField{
    if (TextField == self.moneyYuanField) {
        if (self.moneyYuanField.text.length > 0) {
            self.commitButton.enabled = YES;
            self.commitButton.layer.borderWidth = 0;
        }else{
            self.commitButton.enabled = NO;
            self.commitButton.layer.borderWidth = 1;
        }
    }else if (TextField == self.rechargeYuanTextField){
        if (self.rechargeYuanTextField.text.length > 0) {
            self.rechargeCommitBtn.enabled = YES;
            self.rechargeCommitBtn.layer.borderWidth = 0;
        }else{
            self.rechargeCommitBtn.enabled = NO;
            self.rechargeCommitBtn.layer.borderWidth = 1;
        }
    }
    
}


// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    if(self.rechargeView.superview){
        _oldFrame1 = self.rechargeView.frame;
        CGFloat offset = keyboardTop - (SCREEN_HEIGHT - 193) / 2;
        
        if(offset > 0){
            NSTimeInterval animationDuration = 0.3f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            self.rechargeView.frame = CGRectMake(_oldFrame1.origin.x, _oldFrame1.origin.y - offset / 2, _oldFrame1.size.width, _oldFrame1.size.height);
            [UIView commitAnimations];
        }
    }
    
    if(self.getMoneyView.superview){
        _oldFrame2 = self.getMoneyView.frame;
        CGFloat offset = keyboardTop - (SCREEN_HEIGHT - 238) / 2;
        
        if(offset > 0){
            NSTimeInterval animationDuration = 0.3f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            self.getMoneyView.frame = CGRectMake(_oldFrame2.origin.x, _oldFrame2.origin.y - offset / 2, _oldFrame2.size.width, _oldFrame2.size.height);
            [UIView commitAnimations];
        }
    }
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    if(self.rechargeView.superview)
        self.rechargeView.frame = _oldFrame1;
     if(self.getMoneyView.superview)
        self.getMoneyView.frame = _oldFrame2;
}


#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    [self getAmountData];
}


- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.amountArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [self.amountArray objectAtIndex:indexPath.row];
    NSString *amount = [dic[@"amount"] description];//数量
    NSString *type = [dic[@"type"] description];//数量
    NSString *amount_out1 = [dic[@"amount_out1"] description];//平台抽成
    NSString *amount_out2 = [dic[@"amount_out2"] description];//驾校抽成
    
    NSString *str = @"";
    if ([type intValue] == 1) {
        if (![CommonUtil isEmpty:amount]) {
            str = [NSString stringWithFormat:@"(课程总额%@元", amount];
            
            if (![CommonUtil isEmpty:amount_out1] && [amount_out1 doubleValue] > 0) {
                str = [NSString stringWithFormat:@"%@，其中%@元小巴平台抽成", str, amount_out1];
            }
            
            if (![CommonUtil isEmpty:amount_out2] && [amount_out2 doubleValue] > 0) {
                str = [NSString stringWithFormat:@"%@，其中%@元驾校抽成", str, amount_out2];
            }
            
            str = [NSString stringWithFormat:@"%@)", str];
        }
    }
    
    
    CGFloat height = 60;
    if (![CommonUtil isEmpty:str]) {
        CGSize size = [CommonUtil sizeWithString:str fontSize:12 sizewidth:CGRectGetWidth([UIScreen mainScreen].bounds) - 23 sizeheight:MAXFLOAT];
        
        height += ceilf(size.height) + 15;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"AmountTableViewCell";
    AmountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AmountTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    NSDictionary *dic = [self.amountArray objectAtIndex:indexPath.row];
    NSString *time = dic[@"addtime"];
    NSString *type = dic[@"type"];
    NSString *amount = dic[@"amount"];
    cell.width = [NSString stringWithFormat:@"%f", CGRectGetWidth([UIScreen mainScreen].bounds)];
    
    [cell setType:type time:time amount:amount];
    [cell setDesDic:dic];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//显示tableHeaderView
- (void)showTableHeaderView{

    //金额
    NSString *money = [NSString stringWithFormat:@"%@元", self.totalPrice];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:money];
    [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0,self.totalPrice.length)];
    self.headAlertMoneyLabel.attributedText = str1;
    
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float fMoney =[self.fMoney floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    self.canBeCashLabel.text = [NSString stringWithFormat:@"%.0f",v];;
    self.frozenMoneyLabel.text = [NSString stringWithFormat:@"%.0f" ,fMoney];;
    
}


#pragma mark - 接口
- (void)getAmountData{
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 1;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetMyBalanceInfo" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
    [request setPostValue:dic[@"token"] forKey:@"token"];
    [request startAsynchronous];
}

//充值
- (void)getMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 2;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ApplyCash" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:money forKey:@"count"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

//提现
- (void)rechargeMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 5;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"Recharge" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:money forKey:@"amount"];//充值金额
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
        if(request.tag == 1){
            self.totalPrice = [result[@"balance"] description];//账户余额
            self.fMoney = [result[@"fmoney"] description];//冻结金额
            self.gmoney = [result[@"gmoney"] description];//保证金额
            
            self.amountArray = [NSMutableArray arrayWithArray:result[@"recordlist"]];
            
            [self showTableHeaderView];
            [self.mainTableView reloadData];
        }else if(request.tag == 5){
            [DejalBezelActivityView removeViewAnimated:YES];
            //充值
            NSString *partner = [result[@"partner"] description];//合作者身份ID
            NSString *notify_url = [result[@"notify_url"] description];//服务器异步通知页面路径
            NSString *out_trade_no = [result[@"out_trade_no"] description];//商户网站唯一订单号,表t_balance_student生成记录的ID
            NSString *subject = [result[@"subject"] description];//商品名
            NSString *seller_id = [result[@"seller_id"] description];//卖家支付宝账号
            NSString *total_fee = [result[@"total_fee"] description];//总金额
            NSString *body = [result[@"body"] description];//商品详情
            NSString *private_key = [result[@"private_key"] description];//客户私钥
            
            [self alipayForPartner:partner seller:seller_id privateKey:private_key tradeNO:out_trade_no subject:subject body:body price:total_fee notifyURL:notify_url];
        }else if(request.tag == 2){
            [DejalBezelActivityView removeViewAnimated:YES];
            //申请提现，增加冻结金额
            self.commitView.hidden = YES;
            self.successAlertView.hidden = NO;
            
            [self getAmountData];
            
            //清空数据
            self.moneyYuanField.text = @"";
        }
    } else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
        [DejalBezelActivityView removeViewAnimated:YES];
    }else{
        
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:message];
    }
    [self getDataFinish];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self makeToast:ERR_NETWORK];
    [self getDataFinish];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (IBAction)clickForRecharge:(id)sender {
    if(self.rechargeView.superview){
        [self.rechargeView removeFromSuperview];
    }
    
    self.rechargeView.frame = self.view.frame;
    [self.view addSubview:self.rechargeView];
    
}

- (IBAction)clickForApply:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去账户管理页面设置您的支付宝账户"];
        return;
    }
    
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    NSString *titleString = [NSString stringWithFormat:@"账户余额 %.0f 元",v];
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:titleString];
    [str1 addAttribute:NSForegroundColorAttributeName value:RGB(247, 61, 68) range:NSMakeRange(5, [NSString stringWithFormat:@"%.0f",v ].length)];
    [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28] range:NSMakeRange(5,[NSString stringWithFormat:@"%.0f",v ].length)];
    self.alertMoneyLabel.attributedText = str1;
    [self.alertMoneyLabel.superview  bringSubviewToFront:self.alertMoneyLabel];
    
    if ([self.totalPrice intValue]<50) {
        self.attentionLabel.hidden = YES;
        self.attentionLabel2.hidden = NO;
        self.commitBackView.hidden = YES;
        self.commitButton.hidden = YES;
        self.noMoneyImage.hidden = NO;
    }else{
        self.attentionLabel.hidden = NO;
        self.attentionLabel2.hidden = YES;
        self.commitBackView.hidden = NO;
        self.commitButton.hidden = NO;
        self.noMoneyImage.hidden = YES;
    }
    
}

- (IBAction)clickForCloseAlert:(id)sender {
    self.rechargeYuanTextField.text = @"";
    if(self.rechargeView.superview){
        [self.rechargeView removeFromSuperview];
    }
    
    self.moneyYuanField.text = @"";
    if(self.getMoneyView.superview){
        [self.getMoneyView removeFromSuperview];
    }
}

- (IBAction)clickForCloseKeybord:(id)sender {
    [self.rechargeYuanTextField resignFirstResponder];
    [self.moneyYuanField resignFirstResponder];
}

//提交充值
- (IBAction)clickForChongzhiCommit:(id)sender {
    NSString *price = [self.rechargeYuanTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:price]) {
        [self makeToast:@"请输入价格"];
        [self.rechargeYuanTextField becomeFirstResponder];
        return;
    }
    
    
    [self.rechargeYuanTextField resignFirstResponder];
    
    [self rechargeMoney:price];//修改价格
}

// 提交取钱
- (IBAction)clickForApplyCommit:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去账户管理页面设置您的支付宝账户"];
        return;
    }
    
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    self.moneyYuanField.text = [NSString stringWithFormat:@"%f",v];
    
    //    self.commitView.hidden = YES;
    //    self.successAlertView.hidden = NO;
    
    NSString *yuan = [self.moneyYuanField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    if ([CommonUtil isEmpty:yuan]) {
//        [self makeToast:@"请输入您要提现的金额"];
//        [self.moneyYuanField becomeFirstResponder];
//        return;
//    }
//    
//    if ([yuan intValue] == 0) {
//        [self makeToast:@"请输入您要提现的金额"];
//        [self.moneyYuanField becomeFirstResponder];
//        return;
//    }
//    [self.moneyYuanField resignFirstResponder];
    
    NSString *price = [NSString stringWithFormat:@"%d", [yuan intValue]];
    
    //设置价格
    NSString *money = [userInfo[@"money"] description];//余额
    NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
    NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
    
    if ([CommonUtil isEmpty:money]) {
        money = @"0";
    }
    
    // 保证金及冻结金额
    if ([CommonUtil isEmpty:gMoney]){
        gMoney = @"0";
    }
    if ([CommonUtil isEmpty:moneyFrozen]) {
        moneyFrozen = @"0";
    }
    
    if ([price doubleValue] <50) {
        //提现金额不得小于50
        [self makeToast:@"可提现金额大于50元才可以提现哦"];
        return;
    }
    
    //判断是否有这么多金额可以取
    if ([price doubleValue] <= [money doubleValue] - [gMoney doubleValue]) {
        //提现金额足够
        [self getMoney:price];
        self.moneyTitleLabel.text = @"提交成功";
        self.moneyDetailLabel.text = [NSString stringWithFormat:@"您申请的%@元金额已提交成功，请等待审核，我们会在3个工作日内联系您！", price];
        
    }else{
        //提现金额不足
        [self makeToast:@"您的可提现金额不足，请重新输入"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    
    self.commitView.hidden = YES;
    //    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    
}





- (void)alipayForPartner:(NSString *)partner seller:(NSString *)seller privateKey:(NSString *)privateKey
                 tradeNO:(NSString *)tradeNO subject:(NSString *)subject body:(NSString *)body
                   price:(NSString *)price notifyURL:(NSString *)notifyURL{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    //    NSString *partner = @"";
    //    NSString *seller = @"wjqee2013@163,com";//支付宝收款账号,手机号码或邮箱格式
    //    NSString *privateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
    order.productName = subject; //商品标题
    order.productDescription = body; //商品描述
    order.amount = price; //商品价格
    order.notifyURL =  notifyURL; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"guangda";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self.rechargeView removeFromSuperview];
            self.rechargeYuanTextField.text = @"";
            
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            
            if ([resultStatus isEqualToString:@"9000"]) {
                [self makeToast:@"充值成功"];
                [self getAmountData];
            }else{
                [self makeToast:@"充值失败"];
            }
        }];
        
    }
}

- (IBAction)clickForAccountManager:(id)sender {
    AccountManagerViewController *nextViewController = [[AccountManagerViewController alloc] initWithNibName:@"AccountManagerViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
