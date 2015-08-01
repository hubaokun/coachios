//
//  CoinRecordListViewController.m
//  guangda
//
//  Created by Ray on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinRecordListViewController.h"
#import "CoinRecordListTableViewCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
@interface CoinRecordListViewController ()<UITableViewDataSource,UITableViewDelegate,DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    int pageNum;
    BOOL hasTask;//是否有进行中的任务
    BOOL isRefresh;//是否刷新
    NSMutableArray *coinRecordList;
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@end

@implementation CoinRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    coinRecordList = [[NSMutableArray alloc]init];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshTaskData" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            coinFrom = [NSString stringWithFormat:@"支付方:%@教练",[dic1[@"realname"] description]];
        }else if ([payertype intValue] == 3){
            if (payername) {
                coinFrom =[NSString stringWithFormat:@"支付方：%@",payername];
            }else{
                coinFrom =@"支付方：学员";
            }
        }
        coinNumStr = [NSString stringWithFormat:@"+%@",coinnum];
        coinWay = @"订单支付";
        cell.coinNum.textColor = [UIColor redColor];
    }else if ([receivertype intValue] == 3){
        if ([payertype intValue] == 0) {
            coinFrom = @"支付方：小巴平台";
        }else if ([payertype intValue] == 1){
            coinFrom = @"支付方：驾校";
        }else if ([payertype intValue] == 2){
            NSDictionary *dic1 = [CommonUtil getObjectFromUD:@"userInfo"];
            coinFrom = [NSString stringWithFormat:@"支付方:%@教练",[dic1[@"realname"] description]];
        }else if ([payertype intValue] == 3){
            coinFrom = @"支付方：学员";
        }
        coinNumStr = [NSString stringWithFormat:@"-%@",coinnum];
        coinWay = @"订单取消";
        cell.coinNum.textColor = [UIColor greenColor];
    }else{
        if ([payertype intValue] == 0) {
            coinFrom = @"支付方：小巴平台";
        }else if ([payertype intValue] == 1){
            coinFrom = @"支付方：驾校";
        }else if ([payertype intValue] == 2){
            NSDictionary *dic1 = [CommonUtil getObjectFromUD:@"userInfo"];
            coinFrom = [NSString stringWithFormat:@"支付方:%@教练",[dic1[@"realname"] description]];
        }else if ([payertype intValue] == 3){
            coinFrom = @"支付方：学员";
        }
        coinNumStr = [NSString stringWithFormat:@"-%@",coinnum];
        coinWay = @"小巴币兑换";
        cell.coinNum.textColor = [UIColor greenColor];
    }
    cell.coinForm.text = coinFrom;
    cell.coinTime.text = coinTime;
    cell.coinNum.text = coinNumStr;
    cell.coinType.text = coinWay;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
    [coinRecordList removeAllObjects];
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


#pragma mark - 接口
- (void)getCoinRecord
{
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GETMYCOINRECORD" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pagenum"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
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
