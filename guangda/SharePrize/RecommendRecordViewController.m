//
//  RecommendRecordViewController.m
//  guangda
//
//  Created by Ray on 15/7/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendRecordViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "RecommendRecordTableViewCell.h"
#import "LoginViewController.h"
#import "ScanningCodeViewController.h"
@interface RecommendRecordViewController ()<UITableViewDataSource,UITableViewDelegate, DSBottomPullToMoreManagerClient, DSPullToRefreshManagerClient>
{
    int pageNum;
    NSMutableArray *recordList;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

//@property (strong, nonatomic) NSMutableArray *recommendRecordList;
@property (strong, nonatomic) IBOutlet UIButton *noDataButton;

- (IBAction)clickForCode:(id)sender;

@end

@implementation RecommendRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    recordList = [[NSMutableArray alloc]init];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
    [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self pullToRefreshTriggered:self.pullToRefresh];
    
    self.noDataButton.enabled = NO;
}

#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return recordList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"RecommendRecordTableViewCell";
    RecommendRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"RecommendRecordTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    //获取数据
    NSDictionary *dic = [recordList objectAtIndex:indexPath.row];
    cell.moneyLabel.text = [dic[@"reward"] description];
    cell.userNameLabel.text = [dic[@"realname"] description];
    cell.registerTimeLabel.text = [dic[@"addtime"] description];
    
    NSString *state = [dic[@"state"] description];
    NSString *isOrder = [dic[@"isOrder"] description];
    cell.stateLabel.text = [NSString stringWithFormat:@"%@/%@",state,isOrder];
    
    return cell;
}

#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    pageNum = 1;
    [recordList removeAllObjects];
    [self.mainTableView reloadData];
    [self getRecommendRecordList];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getRecommendRecordList];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
    if (recordList.count == 0) {
        //        self.noStudentView.hidden = NO;
        self.mainTableView.hidden = YES;
    }else{
        //        self.noStudentView.hidden = YES;
        self.mainTableView.hidden = NO;
    }
}

- (void) getRecommendRecordList{
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kRecommend]];
    
    request.delegate = self;
    request.tag = 0;
    [request setPostValue:@"CGETRECOMMENDLIST" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pagenum"];
    [request startAsynchronous];
}

#pragma mark 回调
- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if (pageNum == 0){
            [recordList removeAllObjects];
        }
        NSMutableArray *array = [NSMutableArray array];
        NSArray *RecommendList = result[@"RecommendList"];
        NSString *rflag = [result[@"rflag"] description];
        if ([rflag isEqualToString:@"0"]) {
            
        }else{
            for (int i=0; i<RecommendList.count; i++) {
                NSMutableDictionary *recordDic = [[NSMutableDictionary alloc]init];
                NSString *addtime = [RecommendList[i][@"addtime"] substringToIndex:10];
                [recordDic setObject:addtime forKey:@"addtime"];//注册时间
                
                NSString *reward = RecommendList[i][@"reward"];
                [recordDic setObject:reward forKey:@"reward"];//单个奖励
                
                NSString *realname = RecommendList[i][@"invitedpeoplename"];
                if (realname) {
                    [recordDic setObject:realname forKey:@"realname"];//真实姓名
                }else{
                    NSString *phone = [RecommendList[i][@"invitedpeopletelphone"] description];
                    NSString *head3 = [phone substringToIndex:3];
                    NSString *foot4 = [phone substringFromIndex:7];
                    [recordDic setObject:[NSString stringWithFormat:@"%@****%@",head3,foot4] forKey:@"realname"];//真实姓名 或 手机号
                }
                NSString *state = [RecommendList[i][@"ischecked"] description];
                NSString *str1;
                if ([state isEqualToString:@"1"]) {
                    str1 = @"已认证";
                }else{
                    str1 = @"未认证";
                }
                [recordDic setObject:str1 forKey:@"state"];//认证状态
                
                NSString *isOrder = [RecommendList[i][@"isorder"] description];
                NSString *str2;
                if ([isOrder isEqualToString:@"1"]) {
                    str2 = @"已开单";
                }else{
                    str2 = @"未开单";
                }
                [recordDic setObject:str2 forKey:@"isOrder"];//是否开单
                [array addObject:recordDic];
            }
        }
        
        
        [recordList addObjectsFromArray:array];
        if (recordList.count == 0) {
            //没有数据
            self.noDataButton.hidden = NO;
        }else{
            self.noDataButton.hidden = YES;
        }
//        NSString *reward = [result[@"totalreward"] description];
        NSString *total = [result[@"total"] description];
        //，获得 %@ 元奖励 ,reward
        NSString *titleStr = [NSString stringWithFormat:@"您已邀请 %@ 位教练",total];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleStr];
        [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(5,total.length)];
//        [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(titleStr.length-reward.length-4,reward.length)];
        self.titleLabel.attributedText = string;
        
        NSString *hasMore = result[@"hasmore"];//是否还有更多数据1：有0：没有
        if ([hasMore intValue] == 1) {
            //还有更多数据
            [_pullToMore setPullToMoreViewVisible:YES];
            [_pullToMore relocatePullToMoreView];
            pageNum++;
        }else{
            [_pullToMore setPullToMoreViewVisible:NO];
            [_pullToMore relocatePullToMoreView];
        }
        [self.mainTableView reloadData];
        
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
        
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:message];
    }
    [self getDataFinish];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self makeToast:ERR_NETWORK];
    [self getDataFinish];
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

- (IBAction)clickForCode:(id)sender {
    ScanningCodeViewController *nextViewController = [[ScanningCodeViewController alloc] initWithNibName:@"ScanningCodeViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
