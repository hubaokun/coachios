//
//  ConvertCoinViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ConvertCoinViewController.h"
#import "CoinRecordListViewController.h"
#import "CoinRecordListTableViewCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
@interface ConvertCoinViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient,UIAlertViewDelegate>
{
    NSString *buttonTag;
    NSArray *coinaffiliationlist;
    int pageNum;
    BOOL hasTask;//是否有进行中的任务
    BOOL isRefresh;//是否刷新
    NSMutableArray *coinRecordList;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel1;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel2;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel3;

@property (strong, nonatomic) IBOutlet UIButton *nodataView;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) IBOutlet UIView *ruleView;//规则页面

@property (strong, nonatomic) IBOutlet UIView *cheakView;//兑换页面
@property (strong, nonatomic) IBOutlet UILabel *convertID;//兑换订单号
@property (strong, nonatomic) IBOutlet UILabel *convertPeople;//兑换人
@property (strong, nonatomic) IBOutlet UILabel *ownerLabel;//发放人
@property (strong, nonatomic) IBOutlet UILabel *convertCount;//兑换数量
@property (strong, nonatomic) IBOutlet UILabel *moneyCount;//折算金额
@property (strong, nonatomic) IBOutlet UILabel *orderTime;//申请时间


@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *coinNumTextfield;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn1;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn2;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn3;

@property (strong, nonatomic) IBOutlet UIView *alertView;


@property (strong, nonatomic) IBOutlet UIView *ruleBackView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewFromConstraint;
- (IBAction)clickForClose:(id)sender;
@end

@implementation ConvertCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backView.layer.borderColor = RGB(222, 222, 222).CGColor;
    self.backView.layer.borderWidth = 0.5;
    
    self.convertBtn1.layer.cornerRadius = 2;
    self.convertBtn1.layer.masksToBounds = YES;
    self.convertBtn2.layer.cornerRadius = 2;
    self.convertBtn2.layer.masksToBounds = YES;
    self.convertBtn3.layer.cornerRadius = 2;
    self.convertBtn3.layer.masksToBounds = YES;
    
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *realname = [[dic objectForKey:@"realname"] description];
    NSString *coinnum = [[dic objectForKey:@"coinnum"] description];
    
    NSString *titleLabelStr = [NSString stringWithFormat:@"%@教练小巴币：%@个",realname,coinnum];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(realname.length+6,coinnum.length)];
    self.titleLabel1.attributedText = string;
    
    [self.convertBtn1 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn1 setEnabled:NO];
    
    [self.convertBtn2 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn2 setEnabled:NO];
    [self.convertBtn3 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn3 setEnabled:NO];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;

    coinRecordList = [[NSMutableArray alloc]init];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    self.nodataView.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshTaskData" object:nil];
    
    self.ruleBackView.layer.cornerRadius = 3;
    self.ruleBackView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateMoney];
    isRefresh = YES;
    if ([[CommonUtil currentUtil] isLogin:NO]){
        [self refreshData];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isRefresh = NO;
}

- (void)refreshData{
    if(isRefresh){
        [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
        [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self pullToRefreshTriggered:self.pullToRefresh];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return coinRecordList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"CoinRecordListTableViewCell";
    CoinRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CoinRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    NSDictionary *dic = coinRecordList[indexPath.row];
    //receivertype :0平台 1驾校 2教练 3学员
    NSString *receivertype = [dic[@"receivertype"] description];
    NSString *ownername = [dic[@"ownername"] description];
    NSString *payertype = [dic[@"payertype"] description];
    NSString *coinnum = [dic[@"coinnum"] description];
    NSString *addtime = [dic[@"addtime"] description];
    NSString *payername = [dic[@"payername"] description];
    
    NSString *coinFrom = [[NSString alloc]init];//小巴币支付方
    NSString *coinWay = [[NSString alloc]init];//小巴币方式
    NSString *coinTime = [[NSString alloc]init];//小巴币记录时间
    NSString *coinNumStr = [[NSString alloc]init];//小巴币额度
    
    
    NSRange range1 = NSMakeRange(5, 5);
    NSRange range2 = NSMakeRange(11, 5);
    NSString *str1 = [addtime substringWithRange:range1];
    NSString *str2 = [addtime substringWithRange:range2];
    coinTime = [NSString stringWithFormat:@"%@ %@",str1,str2];
    
    if ([receivertype intValue] == 2) {
        if ([payertype intValue] == 0) {
            coinFrom = @"支付方：小巴平台";
        }else if ([payertype intValue] == 1){
            coinFrom = @"支付方：驾校";
        }else if ([payertype intValue] == 2){
            NSDictionary *dic1 = [CommonUtil getObjectFromUD:@"userInfo"];
            coinFrom = [NSString stringWithFormat:@"支付方：%@教练",[dic1[@"realname"] description]];
        }else if ([payertype intValue] == 3){
            if (payername) {
                coinFrom =[NSString stringWithFormat:@"支付方：%@",payername];
            }else{
                coinFrom =@"支付方：学员";
            }
        }
        coinNumStr = [NSString stringWithFormat:@"+%@",coinnum];
        coinWay = @"订单支付";
        cell.cheakBtn.hidden = YES;
    }
    if ([payertype intValue] == 2) {
//        if ([payertype intValue] == 0) {
//            coinFrom = [NSString stringWithFormat:@"发放方：%@",ownername];
//        }else if ([payertype intValue] == 1){
//            coinFrom = @"发放方：驾校";
//        }else if ([payertype intValue] == 2){
//            NSDictionary *dic1 = [CommonUtil getObjectFromUD:@"userInfo"];
//            coinFrom = [NSString stringWithFormat:@"支付方：%@教练",[dic1[@"realname"] description]];
//        }else if ([payertype intValue] == 3){
//            coinFrom = @"发放方：学员";
//        }
        coinFrom = [NSString stringWithFormat:@"发放方：%@",ownername];
        coinNumStr = [NSString stringWithFormat:@"-%@",coinnum];
        coinWay = @"小巴币兑换";
        cell.cheakBtn.hidden = NO;
        [cell.cheakBtn addTarget:self action:@selector(clickForCheak:) forControlEvents:UIControlEventTouchUpInside];
        cell.cheakBtn.tag = indexPath.row;
    }
    cell.coinForm.text = coinFrom;
    cell.coinTime.text = coinTime;
    cell.coinNum.text = coinNumStr;
    cell.coinType.text = coinWay;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)clickForCheak:(UIButton *)button
{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSDictionary *dic = coinRecordList[button.tag];
    NSString *coinrecordid = [dic[@"coinrecordid"] description];
    //将兑换单号补齐到11位
    NSMutableString *string1 = [[NSMutableString alloc]init];
    if (coinrecordid.length <11) {
        for (int i=0; i<11-coinrecordid.length; i++) {
            [string1 appendString:@"0"];
        }
    }
    [string1 appendString:coinrecordid];
    coinrecordid = string1;
    self.convertID.text = [NSString stringWithFormat:@"兑换订单号：%@",coinrecordid];
    self.convertPeople.text = [NSString stringWithFormat:@"兑换人：%@",[userInfo[@"realname"] description]];
    self.ownerLabel.text = [NSString stringWithFormat:@"发放方：%@",[dic[@"ownername"] description]];
    self.convertCount.text = [NSString stringWithFormat:@"兑换数量：%@个",[dic[@"coinnum"] description]];
    self.moneyCount.text = [NSString stringWithFormat:@"折算金额：%@元",[dic[@"coinnum"] description]];
    self.orderTime.text = [NSString stringWithFormat:@"申请时间：%@",[dic[@"addtime"] description]];
    self.cheakView.frame = self.view.frame;
    [self.view addSubview:self.cheakView];
}
- (IBAction)clickForClose:(id)sender {
    [self.alertView removeFromSuperview];
}

#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
    //    NSLog(@"%f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 5) {
        [self getDataFinish];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    pageNum = 0;
    [self getCoinRecord];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getCoinRecord];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    [timer invalidate];
    [self.view endEditing:YES];
}

//- (void) textFieldDidChange:(UITextField *) TextField{
//    if (self.coinNumTextfield.text.length >0) {
//        [self.convertBtn1 setEnabled:YES];
//    }
//    else {
//        [self.convertBtn1 setEnabled:NO];
//    }
//}

- (IBAction)clickForCloseAlertView:(id)sender {
    [self.cheakView removeFromSuperview];
}

//兑换规则
- (IBAction)clickForRule:(id)sender {
    self.ruleView.frame = self.view.frame;
    [self.view addSubview:self.ruleView];
}
- (IBAction)removeRuleView:(id)sender {
    [self.ruleView removeFromSuperview];
}

- (IBAction)clickForConvertCoin:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定兑换所有小巴币吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    UIButton *button = (UIButton *)sender;
    buttonTag = [NSString stringWithFormat:@"%ld",(long)button.tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self getAPPLYCOIN];
    }
}

#pragma mark - 接口
- (void)getAPPLYCOIN  //兑换小巴币
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
    NSString *coinCount;
    for (int i=0; i<coinaffiliationlist.count; i++) {
        NSDictionary *dic = coinaffiliationlist[i];
        NSString *type = [dic[@"type"] description];
        if ([type intValue] == [buttonTag intValue]) {
            coinCount = [dic[@"coin"] description];
        }
    }
    [request setPostValue:coinCount forKey:@"coinnum"];
    [request setPostValue:buttonTag forKey:@"type"];  //小巴币的类型
    [request startAsynchronous];
}

- (void)getCoinRecord  //小巴币获取记录
{
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 2;
    request.requestMethod = @"POST";
    [request setPostValue:@"GETMYCOINRECORD" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pagenum"];
    [request startAsynchronous];
}

//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 0;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GETCOACHCOINAFFILIATION" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
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
            [self getCoinRecord];
            [self updateMoney];
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
    }else if(request.tag == 0){
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        if (result) {
            
        }
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        // 取得数据成功
        if ([code intValue] == 1) {
            coinaffiliationlist = result[@"coinaffiliationlist"];
            //type	  0 平台  ，1 驾校 ， 2 教练
            if (coinaffiliationlist.count == 0) {
                self.viewFromConstraint.constant = 0;
            }else if (coinaffiliationlist.count ==1){
                self.viewFromConstraint.constant = 50;
                NSDictionary *dic1 = [self massageDic:coinaffiliationlist[0]];
                NSMutableAttributedString *string1 = (NSMutableAttributedString *)dic1[@"string"];
                NSString *coinnum1 = [dic1[@"coin"] description];
                self.titleLabel1.attributedText = string1;
                if ([coinnum1 intValue] == 0) {
                    self.convertBtn1.enabled = NO;
                }else{
                    self.convertBtn1.enabled = YES;
                }
                self.convertBtn1.tag = [dic1[@"type"] intValue];
            }else if (coinaffiliationlist.count ==2){
                self.viewFromConstraint.constant = 100;
                NSDictionary *dic1 = [self massageDic:coinaffiliationlist[0]];
                NSMutableAttributedString *string1 = (NSMutableAttributedString *)dic1[@"string"];
                NSString *coinnum1 = [dic1[@"coin"] description];
                self.titleLabel1.attributedText = string1;
                if ([coinnum1 intValue] == 0) {
                    self.convertBtn1.enabled = NO;
                }else{
                    self.convertBtn1.enabled = YES;
                }
                self.convertBtn1.tag = [dic1[@"type"] intValue];
                
                NSDictionary *dic2 = [self massageDic:coinaffiliationlist[1]];
                NSMutableAttributedString *string2 = (NSMutableAttributedString *)dic2[@"string"];
                NSString *coinnum2 = [dic2[@"coin"] description];
                self.titleLabel2.attributedText = string2;
                if ([coinnum2 intValue] == 0) {
                    self.convertBtn2.enabled = NO;
                }else{
                    self.convertBtn2.enabled = YES;
                }
                self.convertBtn2.tag = [dic2[@"type"] intValue];
                
            }else if (coinaffiliationlist.count ==3){
                self.viewFromConstraint.constant = 150;
                NSDictionary *dic1 = [self massageDic:coinaffiliationlist[0]];
                NSMutableAttributedString *string1 = (NSMutableAttributedString *)dic1[@"string"];
                NSString *coinnum1 = [dic1[@"coin"] description];
                self.titleLabel1.attributedText = string1;
                if ([coinnum1 intValue] == 0) {
                    self.convertBtn1.enabled = NO;
                }else{
                    self.convertBtn1.enabled = YES;
                }
                self.convertBtn1.tag = [dic1[@"type"] intValue];
                
                NSDictionary *dic2 = [self massageDic:coinaffiliationlist[1]];
                NSMutableAttributedString *string2 = (NSMutableAttributedString *)dic2[@"string"];
                NSString *coinnum2 = [dic2[@"coin"] description];
                self.titleLabel2.attributedText = string2;
                if ([coinnum2 intValue] == 0) {
                    self.convertBtn2.enabled = NO;
                }else{
                    self.convertBtn2.enabled = YES;
                }
                self.convertBtn2.tag = [dic2[@"type"] intValue];
                
                NSDictionary *dic3 = [self massageDic:coinaffiliationlist[2]];
                NSMutableAttributedString *string3 = (NSMutableAttributedString *)dic3[@"string"];
                NSString *coinnum3 = [dic3[@"coin"] description];
                self.titleLabel3.attributedText = string3;
                if ([coinnum3 intValue] == 0) {
                    self.convertBtn3.enabled = NO;
                }else{
                    self.convertBtn3.enabled = YES;
                }
                self.convertBtn3.tag = [dic3[@"type"] intValue];
            }
            
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
        
    }
    else if (request.tag == 2){
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        // 取得数据成功
        if ([code intValue] == 1) {
            if (pageNum == 0){
                [coinRecordList removeAllObjects];
            }
            [coinRecordList addObjectsFromArray:result[@"recordlist"]];
            if (coinRecordList.count == 0) {
                //没有数据
                self.nodataView.hidden = NO;
            }else{
                self.nodataView.hidden = YES;
            }
            //receivertype :0平台 1驾校 2教练 3学员
            [self.mainTableView reloadData];
            [self getDataFinish];
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
            [self getDataFinish];
        }
    }
}

- (NSDictionary *)massageDic:(NSDictionary *)dic
{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *realname = [[userInfo objectForKey:@"realname"] description];
    if (realname.length == 0) {
        realname = [[userInfo objectForKey:@"phone"] description];
    }
    NSString *type = [dic[@"type"] description];
    NSString *titleLabelStr;
    NSMutableAttributedString *string;
    NSString *coinnum = [dic[@"coin"] description];//小巴币个数
    if ([type intValue] == 0) {
        titleLabelStr = [NSString stringWithFormat:@"平台小巴币：%@个",coinnum];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,coinnum.length)];
    }else if ([type intValue] == 1){
        titleLabelStr = [NSString stringWithFormat:@"所属驾校小巴币：%@个",coinnum];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8,coinnum.length)];
    }else if ([type intValue] == 2){
        titleLabelStr = [NSString stringWithFormat:@"%@教练小巴币：%@个",realname,coinnum];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(realname.length+6,coinnum.length)];
    }
    
    NSDictionary *messageDic = [NSDictionary dictionaryWithObjectsAndKeys:string,@"string",coinnum,@"coin",type,@"type", nil];
    
    return messageDic;
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    //    [DejalBezelActivityView removeViewAnimated:YES];
    [self getDataFinish];
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
