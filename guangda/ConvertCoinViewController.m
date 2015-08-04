//
//  ConvertCoinViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ConvertCoinViewController.h"
#import "CoinRecordListViewController.h"
@interface ConvertCoinViewController ()<UITextFieldDelegate>
{
    NSString *coinCount;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *coinNumTextfield;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn;

@property (strong, nonatomic) IBOutlet UIView *alertView;

- (IBAction)clickForClose:(id)sender;
@end

@implementation ConvertCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backView.layer.borderColor = RGB(222, 222, 222).CGColor;
    self.backView.layer.borderWidth = 0.5;
    
    self.convertBtn.layer.cornerRadius = 4;
    self.convertBtn.layer.masksToBounds = YES;
    
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *realname = [[dic objectForKey:@"realname"] description];
    NSString *coinnum = [[dic objectForKey:@"coinnum"] description];
    
    NSString *titleLabelStr = [NSString stringWithFormat:@"可兑换%@教练小巴币：%@个",realname,coinnum];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3,realname.length+2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3+realname.length+6,coinnum.length)];
    self.titleLabel.attributedText = string;
    
    self.coinNumTextfield.delegate = self;
    [self.coinNumTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.convertBtn setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateMoney];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    [timer invalidate];
    [self.view endEditing:YES];
}

- (void) textFieldDidChange:(UITextField *) TextField{
    if (self.coinNumTextfield.text.length >0) {
        [self.convertBtn setEnabled:YES];
    }
    else {
        [self.convertBtn setEnabled:NO];
    }
}

- (IBAction)clickForClose:(id)sender {
    [self.alertView removeFromSuperview];
}

//兑换记录
- (IBAction)clickForRecord:(id)sender {
    CoinRecordListViewController *nextController = [[CoinRecordListViewController alloc] initWithNibName:@"CoinRecordListViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

- (IBAction)clickForConvertCoin:(id)sender {
//    if (self.coinNumTextfield.text.length>0) {
        [self getCoinRecord];
//    }else{
//        [self makeToast:@"请输入正确的兑换数量"];
//    }
}

#pragma mark - 接口
- (void)getCoinRecord
{
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.tag = 1;
    request.requestMethod = @"POST";
    [request setPostValue:@"APPLYCOIN" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
    [request setPostValue:coinCount forKey:@"coinnum"];
    [request startAsynchronous];
}

//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kSystemServlet]];
    request.tag = 0;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"refreshUserMoney" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"userid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:@"1" forKey:@"usertype"];//用户类型 1.教练  2 学员
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 1) {
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        // 取得数据成功
        if ([code intValue] == 1) {
            [self.coinNumTextfield resignFirstResponder];
            self.coinNumTextfield.text = @"";
            self.alertView.frame = self.view.frame;
            [self.view addSubview:self.alertView];
            
            [self updateMoney];
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
    }else{
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        if (result) {
            
        }
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        // 取得数据成功
        if ([code intValue] == 1) {
            NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
            NSString *realname = [[dic objectForKey:@"realname"] description];
            if (realname.length == 0) {
                realname = [[dic objectForKey:@"phone"] description];
            }
            NSString *coinnum = [result[@"coinnum"] description];//小巴币个数
            NSString *titleLabelStr = [NSString stringWithFormat:@"可兑换%@教练小巴币：%@个",realname,coinnum];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3,realname.length+2)];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3+realname.length+6,coinnum.length)];
            self.titleLabel.attributedText = string;
            coinCount = coinnum;
            if ([coinCount intValue] == 0) {
                self.convertBtn.enabled = NO;
            }else{
                self.convertBtn.enabled = YES;
            }
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
        
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
