//
//  CouponNavigateViewController.m
//  guangda
//
//  Created by Ray on 15/9/16.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CouponNavigateViewController.h"
#import "MyTicketDetailViewController.h"
#import "SendCouponViewController.h"
@interface CouponNavigateViewController ()
@property (strong, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UIView *sendCouponBackView;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UILabel *noAbilityLabel;

@end

@implementation CouponNavigateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendButton.enabled= NO;
    self.noAbilityLabel.hidden = NO;
    [self updateLimit];
    [self updateMoney];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)clickForCouponDetail:(id)sender {
    MyTicketDetailViewController *nextController = [[MyTicketDetailViewController alloc] initWithNibName:@"MyTicketDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
- (IBAction)clickForSendCoupon:(id)sender {
    SendCouponViewController *nextController = [[SendCouponViewController alloc] initWithNibName:@"SendCouponViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kSystemServlet]];
    request.delegate = self;
    request.tag = 0;
    request.requestMethod = @"POST";
    [request setPostValue:@"refreshUserMoney" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"userid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:@"1" forKey:@"usertype"];//用户类型 1.教练  2 学员
    [request startAsynchronous];
}

//更新用户状态
- (void)updateLimit{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 1;
    request.requestMethod = @"POST";
    [request setPostValue:@"GETCOACHCOUPONLIMIT" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
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
        if (request.tag == 0) {
            //更新余额
            NSString *money = [CommonUtil isEmpty:[result[@"money"] description]]?@"0":[result[@"money"] description];//用户余额
            NSString *fmoney = [CommonUtil isEmpty:[result[@"fmoney"] description]]?@"0":[result[@"fmoney"] description];//用户冻结金额
            NSString *gmoney = [CommonUtil isEmpty:[result[@"gmoney"] description]]?@"0":[result[@"gmoney"] description];//保证金金额(教练专有)
            NSString *couponhour = [CommonUtil isEmpty:[result[@"couponhour"] description]]?@"0":[result[@"couponhour"] description];//小巴券张数
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [userInfo setObject:money forKey:@"money"];
            [userInfo setObject:fmoney forKey:@"money_frozen"];
            [userInfo setObject:gmoney forKey:@"gmoney"];
            [userInfo setObject:couponhour forKey:@"couponhour"];
            [CommonUtil saveObjectToUD:userInfo key:@"userInfo"];
            
            //余额
            if ([CommonUtil isEmpty:money]) {
                money = @"0";
            }
            //            money = [NSString stringWithFormat:@"余额：%@元", money];
            //            [self.moneyBtn setTitle:money forState:UIControlStateNormal];
            
            if([CommonUtil isEmpty:couponhour]){
                couponhour = @"0";
            }
            
            NSString *xiaobaTicketTime = [NSString stringWithFormat:@"%@张", couponhour];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:xiaobaTicketTime];
            [string addAttribute:NSForegroundColorAttributeName value:RGB(255, 150, 0) range:NSMakeRange(0,couponhour.length)];
            [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, couponhour.length)];
            self.couponLabel.attributedText = string;
        }else if (request.tag == 1){
            if ([[result[@"grantlimit"] description] boolValue]) {
                    self.sendButton.enabled = YES;
                    self.noAbilityLabel.hidden = YES;
            }else{
                self.sendButton.enabled= NO;
                self.noAbilityLabel.hidden = NO;
            }
            [DejalBezelActivityView removeViewAnimated:YES];
        }
    } else {
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:message];
    }
}
// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    //    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
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
