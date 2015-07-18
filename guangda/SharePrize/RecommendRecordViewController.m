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
@interface RecommendRecordViewController ()<UITableViewDataSource,UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    int pageNum;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) NSMutableArray *recommendRecordList;

- (IBAction)clickForCode:(id)sender;
@end

@implementation RecommendRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    pageNum = 0;
    
    NSString *conuts = @"12";
    NSString *money = @"1211";
    NSString *titleStr = [NSString stringWithFormat:@"您已推荐 %@ 位教练，获得 %@ 元奖励",conuts,money];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(5,conuts.length)];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(titleStr.length-money.length-4,money.length)];
    self.titleLabel.attributedText = string;
    
//    //刷新加载
//    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
//    //隐藏加载更多
//    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
//    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
//    [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
//    [self pullToRefreshTriggered:self.pullToRefresh];
    
}

#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.recommendRecordList.count;
    return 6;
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
    
    cell.moneyLabel.text = @"1111";
    
//   //获取数据
//    NSDictionary *dic = [self.recommendRecordList objectAtIndex:indexPath.row];
    
    
    return cell;
}

//#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [_pullToRefresh tableViewScrolled];
//    
//    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
//    [_pullToMore tableViewScrolled];
//    //    NSLog(@"%f",scrollView.contentOffset.y);
//    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 5) {
//        [self getDataFinish];
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [_pullToRefresh tableViewReleased];
//    [_pullToMore tableViewReleased];
//}
//
///* 刷新处理 */
//- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
//    pageNum = 0;
//    [self.recommendRecordList removeAllObjects];
//    [self getRecommendRecordList];
//}
//
///* 加载更多 */
//- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
//    [self getRecommendRecordList];
//}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
    if (self.recommendRecordList.count == 0) {
//        self.noStudentView.hidden = NO;
        self.mainTableView.hidden = YES;
    }else{
//        self.noStudentView.hidden = YES;
        self.mainTableView.hidden = NO;
    }
}

- (void) getRecommendRecordList{
    
//    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
//    
//    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
//    
//    request.delegate = self;
//    request.tag = 0;
//    [request setPostValue:@"GetMyAllStudent" forKey:@"action"];
//    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
//    [request setPostValue:userInfo[@"token"] forKey:@"token"];
//    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pageNum"];
//    [request startAsynchronous];
}

#pragma mark 回调
- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    
    // 取得数据成功
    if ([code intValue] == 1) {
//        //获取未处理任务单
//        NSArray *array = result[@"studentList"];
//        
//        if (pageNum == 0) {
//            //首页
//            [self.studentList removeAllObjects];
//        }
//        
//        [self.studentList addObjectsFromArray:array];
//        
//        NSString *hasMore = result[@"hasmore"];//是否还有更多数据1：有0：没有
//        if ([hasMore intValue] == 1) {
//            //还有更多数据
//            [_pullToMore setPullToMoreViewVisible:YES];
//            [_pullToMore relocatePullToMoreView];
//            
//            pageNum++;
//        }else{
//            [_pullToMore setPullToMoreViewVisible:NO];
//            [_pullToMore relocatePullToMoreView];
//        }
//        
//        [self.studentTableView reloadData];
        [DejalBezelActivityView removeViewAnimated:YES];
        
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
