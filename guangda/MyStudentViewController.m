//
//  MyStudentViewController.m
//  guangda
//
//  Created by guok on 15/6/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyStudentViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "MyStudentTableViewCell.h"
#import "LoginViewController.h"

@interface MyStudentViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
@property (strong, nonatomic) IBOutlet UITableView *studentTableView;

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) NSMutableArray *studentList;
@property (strong, nonatomic) NSString *openStudentID;//打开的订单id
@property (strong, nonatomic) NSIndexPath *openIndexPath;//打开的indexPath
@property (strong, nonatomic) NSIndexPath *closeIndexPath;//关闭的indexPath


@end

@implementation MyStudentViewController{
    int pageNum;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageNum = 0;
    _openStudentID = @"0";
    self.studentList = [NSMutableArray array];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.studentTableView withClient:self];
    
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.studentTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    
    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
    [self.studentTableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self pullToRefreshTriggered:self.pullToRefresh];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.studentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.studentList objectAtIndex:indexPath.row];
    NSString *studentid = [dic[@"studentid"] description];
    
    if ([_openStudentID isEqualToString:studentid]) {
        //打开
        return 303;
    }else{
        //关闭
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"MyStudentTableViewCell";
    MyStudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyStudentTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    //获取数据
    NSDictionary *dic = [self.studentList objectAtIndex:indexPath.row];
    NSString *avatar = dic[@"avatar"];
    NSString *coachstate = dic[@"coachstate"];
    NSString *learnmytime = dic[@"learnmytime"];
    NSString *learntime = dic[@"learntime"];
    NSString *money = dic[@"money"];
    NSString *realname = dic[@"realname"];
    NSString *studentid = [dic[@"studentid"] description];
    NSString *phone = dic[@"phone"];
    NSString *student_cardnum = dic[@"student_cardnum"];
    
    //头像
    NSString *logo = [CommonUtil isEmpty:avatar]?@"":avatar;
    
    
    if ([coachstate intValue] == 1) {
        //已认证
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image != nil) {
                
                [self updateUserLogo:cell.logoImageView];
                
            }
        }];
        
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
        
    }else{
        cell.logoImageView.image = [UIImage imageNamed:@"logo_default_nopass"];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }
    
    if(![CommonUtil isEmpty:realname]){
        cell.timeLabel.text = realname;
    }else{
        cell.timeLabel.text = @"";
    }
    
    if([CommonUtil isEmpty:learnmytime]){
        learnmytime = @"0";
    }
    
    if([CommonUtil isEmpty:learntime]){
        learntime = @"0";
    }
    
    cell.addressLabel.text = [NSString stringWithFormat:@"历史学时:%d/%d",[learnmytime intValue],[learntime intValue]];
    
    //订单总价
    cell.priceLabel.textColor = RGB(32, 180, 120);
    cell.priceLabel.text = [NSString stringWithFormat:@"历史消费:%@元",money];
    
    // 投诉
    NSString *phone1 = [CommonUtil isEmpty:phone]?@"暂无":phone;
    cell.complaintBtn.phone = phone1;
    [cell.complaintBtn addTarget:self action:@selector(complaintClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 联系
    cell.contactBtn.phone = phone1;
    [cell.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //姓名
    NSString *name = [CommonUtil isEmpty:realname]?@"暂无":realname;
    name = [NSString stringWithFormat:@"学员姓名 %@", name];
    cell.nameLabel.text = name;
    
    //联系电话
    NSString *phoneString = [NSString stringWithFormat:@"联系电话 %@", phone1];
    cell.phoneLabel.text = phoneString;
    
    //学员证号
    NSString *num = [CommonUtil isEmpty:student_cardnum]?@"暂无":student_cardnum;
    num = [NSString stringWithFormat:@"学员证号 %@", num];
    cell.studentNumLabel.text = num;
    
    if([self.openStudentID isEqualToString:studentid]){
        [self showDetailsCell:cell];
    }else{
        [self hideDetailsCell:cell];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取数据
    NSDictionary *dic = [self.studentList objectAtIndex:indexPath.row];
    
    NSString *studentid = [dic[@"studentid"] description];
    
    if ([_openStudentID isEqualToString:studentid]) {
        _openStudentID = @"0";
    }else{
        self.openStudentID = studentid;
    }
    
    if (self.openIndexPath == nil || [self.openIndexPath isEqual:indexPath]) {
        //本来这一行就是打开状态或者所有行都处于关闭状态
        //        self.closeIndexPath = indexPath;//关闭这一行
        self.openIndexPath = indexPath;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        //这一行不是打开状态,打开这一行
        self.closeIndexPath = self.openIndexPath;
        self.openIndexPath = indexPath;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.closeIndexPath, self.openIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

// details收起
- (void)hideDetailsCell:(MyStudentTableViewCell *)cell
{
    cell.studentDetailsView.hidden = YES;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_right"];
    cell.iconTop.constant = 32;
    cell.iconRight.constant = 11;
    cell.iconWidth.constant = 9;
    cell.iconHeight.constant = 15;
}

// details展开
- (void)showDetailsCell:(MyStudentTableViewCell *)cell
{
    cell.studentDetailsView.hidden = NO;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_down"];
    cell.iconTop.constant = 35;
    cell.iconRight.constant = 8;
    cell.iconWidth.constant = 14;
    cell.iconHeight.constant = 9;
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
    [self.studentList removeAllObjects];
    [self getStudentList];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getStudentList];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
    if (self.studentList.count == 0) {
        self.noStudentView.hidden = NO;
        self.studentTableView.hidden = YES;
    }else{
        self.noStudentView.hidden = YES;
        self.studentTableView.hidden = NO;
    }
}

- (void) getStudentList{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    
    request.delegate = self;
    request.tag = 0;
    [request setPostValue:@"GetMyAllStudent" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pageNum"];
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
        //获取未处理任务单
        NSArray *array = result[@"studentList"];
        
        if (pageNum == 0) {
            //首页
            [self.studentList removeAllObjects];
        }
        
        [self.studentList addObjectsFromArray:array];
        
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
        
        [self.studentTableView reloadData];
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

//更新用户头像，显示六边形
- (void)updateUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

#pragma mark - button action
#pragma mark 联系
- (void)contactClick:(DSButton *)sender
{
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
    
}

#pragma mark 投诉
- (void)complaintClick:(DSButton *)sender
{
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
}

@end
