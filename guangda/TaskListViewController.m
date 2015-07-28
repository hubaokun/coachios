//
//  TaskListViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "TaskListViewController.h"
#import "HistoryViewController.h"
#import "TaskListTableViewCell.h"
#import "UIPlaceHolderTextView.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "UploadPhotoViewController.h"
#import "TQStarRatingView.h"

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GoComplaintViewController.h"

@interface TaskListViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, UIAlertViewDelegate, StarRatingViewDelegate, UITextViewDelegate>{
    int pageNum;
    BOOL hasTask;//是否有进行中的任务
    BOOL isRefresh;//是否刷新
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *commentView;             // 评价弹窗
@property (strong, nonatomic) IBOutlet UIView *commentBottomView;       // 评价弹窗下半部分
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *commentTextView;      
@property (strong, nonatomic) IBOutlet DSButton *gouBtn;        // 勾
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewAndStarView;     // textView距离上部分的约束
@property (strong, nonatomic) IBOutlet UIView *commentContentView;      // 评价的内部内容View
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentContentViewTopJuli; // 评价的内部内容View距离顶部的距离约束

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UIButton *noDataViewBtn;

//评分星星
@property (strong, nonatomic) IBOutlet UIView *scoreStarView3;
@property (strong, nonatomic) IBOutlet UIView *scoreStarView2;
@property (strong, nonatomic) IBOutlet UIView *scoreStarView1;
@property (strong, nonatomic) TQStarRatingView *starRatingView1;
@property (strong, nonatomic) TQStarRatingView *starRatingView2;
@property (strong, nonatomic) TQStarRatingView *starRatingView3;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel1;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel2;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel3;

//参数
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (strong, nonatomic) NSMutableDictionary *scoreDic;//分数
@property (strong, nonatomic) NSMutableArray *taskList;                 //任务信息
@property (strong, nonatomic) NSMutableArray *noSortArray;                 //没有整理过的任务信息
@property (strong, nonatomic) NSMutableDictionary *rowDic;                 // 每一行的状态list
@property (strong, nonatomic) NSString *commentOrderId; //评论的订单id
@property (strong, nonatomic) NSString *openOrderId;//打开的订单id
@property (strong, nonatomic) NSIndexPath *closeIndexPath;//关闭的indexPath
@property (strong, nonatomic) NSIndexPath *openIndexPath;//打开的indexPath

@end

@implementation TaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isRefresh = YES;
    self.openOrderId = @"0";
    self.commentOrderId = @"0";
    self.scoreDic = [NSMutableDictionary dictionary];
    self.noSortArray = [NSMutableArray array];
    hasTask = NO;
    self.rowDic = [NSMutableDictionary dictionary];
    self.taskList = [NSMutableArray array];

    self.commentTextView.delegate = self;
    self.commentTextView.placeholder = @"来说点什么吧";
    self.commentTextView.placeholderColor = RGB(163, 171, 188);
    self.gouBtn.data = [NSMutableDictionary dictionary];
    pageNum = 0;
    self.commentContentViewTopJuli.constant = ([UIScreen mainScreen].bounds.size.height - 319) / 2;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    
    [self addStartEvaluate];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshTaskData" object:nil];
    
    //设置默认分数
    [self.scoreDic setObject:@"5" forKey:@"score1"];
    [self.scoreDic setObject:@"5" forKey:@"score2"];
    [self.scoreDic setObject:@"5" forKey:@"score3"];
}

- (void)addStartEvaluate{
    
    self.starRatingView1 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView1.bounds numberOfStar:5];
    self.starRatingView1.couldClick = YES;//可点击
    self.starRatingView1.delegate = self;
    self.starRatingView1.isFill = YES;//整数显示
    //[self.starRatingView1 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView1 addSubview:self.starRatingView1];

    
    self.starRatingView2 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView2.bounds numberOfStar:5];
    self.starRatingView2.couldClick = YES;//可点击
    self.starRatingView2.delegate = self;
    self.starRatingView2.isFill = YES;//整数显示
    //[self.starRatingView2 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView2 addSubview:self.starRatingView2];
    
    self.starRatingView3 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView3.bounds numberOfStar:5];
    self.starRatingView3.couldClick = YES;//可点击
    self.starRatingView3.isFill = YES;//整数显示
    self.starRatingView3.delegate = self;
    //[self.starRatingView3 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView3 addSubview:self.starRatingView3];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self pullToRefreshTriggered:self.pullToRefresh];
    }
}

#pragma mark - UITableView
#pragma mark tableViewSection
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.taskList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 34)];
    view.backgroundColor = RGB(243, 243, 243);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width, 34)];
    label.textColor = [UIColor blackColor];
    
    NSDictionary *dic = [self.taskList objectAtIndex:section];
    NSString *date = dic[@"date"];
    NSString *weekDay = [CommonUtil getChineseWeekday:[CommonUtil getDateForString:date format:@"yyyy-MM-dd"]];
    
    NSDate *nowDate = [NSDate date];
    NSString *nowDateStr = [CommonUtil getStringForDate:nowDate format:@"yyyy-MM-dd"];
    if ([nowDateStr isEqualToString:date]) {
        //今天
        label.text = [NSString stringWithFormat:@"今日任务 %@ %@", date,  weekDay];
        view.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
       
    }else{
        
        long time = [CommonUtil getTimeDiff:[CommonUtil getDateForString:date format:@"yyyy-MM-dd 00:00:00"] type:@"DD"];
        
        NSString *timeText = @"";
        if (time > 0){
            //明天
            timeText = [NSString stringWithFormat:@"%ld日前任务 %@ %@", time, date, weekDay];
        }else if (time == 1) {
            //明天
            timeText = [NSString stringWithFormat:@"明日任务 %@ %@", date, weekDay];
        }else{
            //后天
            timeText = [NSString stringWithFormat:@"%ld日后任务 %@ %@", -time, date, weekDay];
        }
        
        label.text = timeText;
    }

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
    line.backgroundColor = RGB(211, 211, 211);
    [view addSubview:line];
    [view addSubview:label];
    
    return view;
}

#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    NSDictionary *dic = self.taskList[section];
    NSArray *array = dic[@"list"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.taskList objectAtIndex:indexPath.section];
    NSArray *array = dic[@"list"];
    dic = [array objectAtIndex:indexPath.row];
    
    if ([_openOrderId isEqualToString:[dic[@"orderid"] description]]) {
        //打开
        return 303;
    }else{
        //关闭
        return 80;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"taskCell";
    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"TaskListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    //获取数据
    NSDictionary *dic = [self.taskList objectAtIndex:indexPath.section];
    NSArray *array = dic[@"list"];
    dic = [array objectAtIndex:indexPath.row];
    
    NSDictionary *studentInfo = [NSDictionary dictionaryWithDictionary:dic[@"studentinfo"]];//学员信息
    NSString *startTime = dic[@"start_time"];//开始时间
    NSString *endTime = dic[@"end_time"];//结束时间
    NSString *address = [CommonUtil isEmpty:dic[@"detail"]]?@"地址暂无":dic[@"detail"];//地址
    NSString *total = dic[@"total"]; //订单总价
    /**
     state =
     0：
     接口相关:coachstate为0,且距离开始时间超过一个小时.
     前端处理:无
     1:
     接口相关:coachstate为0,且距离开始时间少于一个小时.且教练当前没有其它的进行中任务.
     前端处理:任务的时间显示为红色.可以确认上车.
     2:
     接口相关:coachstate为0,且距离开始时间少于一个小时.但教练当前还有其它的进行中任务.
     前端处理:任务的时间显示为红色.不可以确认上车.
     3:
     接口相关:coachstate为1
     前端处理:显示练车中,且可以确认下车."
     */
    NSString *state = [dic[@"state"] description];
    //格式化日期
    if ([CommonUtil isEmpty:startTime]) {
        startTime = @"00:00";
    }else{
        startTime = [CommonUtil getStringForDate:[CommonUtil getDateForString:startTime format:@"yyyy-MM-dd HH:mm:ss"] format:@"HH:mm"];
    }
    if ([CommonUtil isEmpty:endTime]) {
        endTime = @"00:00";
    }else{
        endTime = [CommonUtil getStringForDate:[CommonUtil getDateForString:endTime format:@"yyyy-MM-dd HH:mm:ss"] format:@"HH:mm"];
    }
    
    if ([state intValue] != 0) {
        //红色日期 （开始时间1小时内到结束时间为止）
        cell.timeLabel.textColor = RGB(224, 72, 62);
    }else{
        cell.timeLabel.textColor = RGB(28, 28, 28);
    }
    
    //头像
    NSString *logo = [CommonUtil isEmpty:[studentInfo[@"avatarurl"] description]]?@"":[studentInfo[@"avatarurl"] description];
    
    NSString *studentState = [studentInfo[@"coachstate"] description];//0.未认证 1.认证.studentState

    if ([studentState intValue] == 1) {
        //已认证
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image != nil) {
                cell.logoImageView.layer.cornerRadius = cell.logoImageView.bounds.size.width/2;
                cell.logoImageView.layer.masksToBounds = YES;
//                [self updateUserLogo:cell.logoImageView];
                
            }
        }];
        
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
        
    }else{
        cell.logoImageView.image = [UIImage imageNamed:@"logo_default_nopass"];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }
    
    //任务时间
    NSString *time = [NSString stringWithFormat:@"%@ ~ %@", startTime, endTime];
    NSMutableAttributedString *timeStr = [[NSMutableAttributedString alloc] initWithString:time];
    [timeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, startTime.length - 3)];
    [timeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(time.length - endTime.length, endTime.length - 3)];
    [timeStr addAttribute:NSForegroundColorAttributeName value:RGB(210, 210, 210) range:NSMakeRange(startTime.length + 1, 1)];
    cell.timeLabel.attributedText = timeStr;
    
    cell.getCarClick.indexPath = indexPath;
    cell.finishView.hidden = YES;
    
    //订单总价
    cell.priceLabel.textColor = RGB(32, 180, 120);
    cell.priceLabel.text = [NSString stringWithFormat:@"%@元",total];
    
    //地址
    cell.addressLabel.text = address;
    
    // 投诉
    NSString *phone = [CommonUtil isEmpty:studentInfo[@"phone"]]?@"暂无":studentInfo[@"phone"];
    cell.complaintBtn.phone = phone;
    [cell.complaintBtn addTarget:self action:@selector(complaintClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 联系
    cell.contactBtn.phone = phone;
    [cell.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //姓名
    NSString *name = [CommonUtil isEmpty:studentInfo[@"realname"]]?@"暂无":studentInfo[@"realname"];
    name = [NSString stringWithFormat:@"学员姓名 %@", name];
    cell.nameLabel.text = name;
    
    //联系电话
    phone = [NSString stringWithFormat:@"联系电话 %@", phone];
    cell.phoneLabel.text = phone;
    
    //学员证号
    NSString *num = [CommonUtil isEmpty:studentInfo[@"student_cardnum"]]?@"暂无":studentInfo[@"student_cardnum"];
    num = [NSString stringWithFormat:@"学员证号 %@", num];
    cell.studentNumLabel.text = num;
   
    // 判断按钮状态
    /**
     state =
     0:
     接口相关:coachstate为0,且距离开始时间超过一个小时.
     前端处理:无
     1:
     接口相关:coachstate为0,且距离开始时间少于一个小时.且教练当前没有其它的进行中任务.
     前端处理:任务的时间显示为红色.可以确认上车.
     2:
     接口相关:coachstate为0,且距离开始时间少于一个小时.但教练当前还有其它的进行中任务.
     前端处理:任务的时间显示为红色.不可以确认上车.
     3:
     接口相关:coachstate为1
     前端处理:显示练车中,且可以确认下车."
     */
    
    NSString *key = [NSString stringWithFormat:@"row%@", [dic[@"orderid"] description]];
    NSString *rowState = [self.rowDic objectForKey:key];
    if ([rowState intValue] == 2) {
        //完成状态
        cell.finishView.hidden = NO;
        [self hideDetailsCell:cell];
    }else {
        if ([_openOrderId isEqualToString:[dic[@"orderid"] description]]) {
            //打开
            cell.finishView.hidden = YES;
            [self showDetailsCell:cell];
        }else{
            //关闭
            cell.finishView.hidden = YES;
            [self hideDetailsCell:cell];
        }
    }
    
    if ([state intValue] == 0 || [state intValue] == 1) {
        //可以确认上车
//        cell.getCarClick.userInteractionEnabled = YES;
        [self checkUpCarBtn:cell.getCarClick];//确认上车
    }else if ([state intValue] == 3){
        //可以确认下车
//        cell.getCarClick.userInteractionEnabled = YES;
        [self checkDownCarBtn:cell.getCarClick];//确认下车
    }else{
//        cell.getCarClick.userInteractionEnabled = YES;
        [self checkUpCarBtn:cell.getCarClick];//确认上车
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取数据
    NSDictionary *dic = [self.taskList objectAtIndex:indexPath.section];
    NSArray *array = dic[@"list"];
    dic = [array objectAtIndex:indexPath.row];
    
    if ([_openOrderId isEqualToString:[dic[@"orderid"] description]]) {
        _openOrderId = @"0";
    }else{
        self.openOrderId = [dic[@"orderid"] description];
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
    
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionMiddle];
}

//更新用户头像，显示六边形
- (void)updateUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

//更新未通过验证用户头像，显示六边形
- (void)updateNoPassUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [UIImage imageNamed:@"logo_default_nopass"];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.gouBtn.enabled = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
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

#pragma mark 确认上车
- (void)checkUpCarBtn:(DSButton *)button
{
    UIImage *image1 = [UIImage imageNamed:@"background_check_geton"];
    UIImage *image1_h = [UIImage imageNamed:@"background_check_geton_h"];
    [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image1_h resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [button setBackgroundImage:image1 forState:UIControlStateNormal];
    [button setBackgroundImage:image1_h forState:UIControlStateHighlighted];
    [button setTitle:@"确认上车" forState:UIControlStateNormal];
    button.enabled = YES;
    
    [button removeTarget:self action:@selector(getOffCarClick:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(getUpCarClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 练车中
- (void)practicingCarBtn:(DSButton *)button
{
    UIImage *image = [UIImage imageNamed:@"background_practice"];
    [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:@"练车中" forState:UIControlStateNormal];
    button.enabled = NO;
}

#pragma mark 确认下车 background_check_getoff
- (void)checkDownCarBtn:(DSButton *)button
{
    
    UIImage *image1 = [UIImage imageNamed:@"background_check_getoff"];
    UIImage *image1_h = [UIImage imageNamed:@"background_check_getoff_h"];
    [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image1_h resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [button setBackgroundImage:image1 forState:UIControlStateNormal];
    [button setBackgroundImage:image1_h forState:UIControlStateHighlighted];
    [button setTitle:@"确认下车" forState:UIControlStateNormal];
    button.enabled = YES;
    
    [button removeTarget:self action:@selector(getUpCarClick:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(getOffCarClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 点击确认上车弹框
- (void)getUpCarClick:(id)sender
{
    DSButton *button = (DSButton *)sender;
    
    if (button.indexPath.row + button.indexPath.section != 0){
        //只有第一行才能确认上传
        [self makeToast:@"还有未完成的任务，请先完成前面的任务"];
        return;
    }
    

    //获取数据
    NSDictionary *dic = [self.taskList objectAtIndex:button.indexPath.section];
    NSArray *array = dic[@"list"];
    dic = [array objectAtIndex:button.indexPath.row];
    
    /**
     state =
     0：
     接口相关:coachstate为0,且距离开始时间超过一个小时.
     前端处理:无
     1:
     接口相关:coachstate为0,且距离开始时间少于一个小时.且教练当前没有其它的进行中任务.
     前端处理:任务的时间显示为红色.可以确认上车.
     2:
     接口相关:coachstate为0,且距离开始时间少于一个小时.但教练当前还有其它的进行中任务.
     前端处理:任务的时间显示为红色.不可以确认上车.
     3:
     接口相关:coachstate为1
     前端处理:显示练车中,且可以确认下车."
     */
    NSString *state = [dic[@"state"] description];
    
    if ([state intValue] == 0) {
        //不可以上车
        [self makeToast:@"时间还没有到，现在还不能上车"];
        return;
    }else if ([state intValue] == 2){
        //不可以上车
        [self makeToast:@"已经有在进行中的任务"];
        return;
    }
    
    NSDictionary *studentInfo = [NSDictionary dictionaryWithDictionary:dic[@"studentinfo"]];//学员信息
    NSString *studentState = [studentInfo[@"coachstate"] description];//0.未认证 1.认证.

    self.selectIndexPath = button.indexPath;
    if ([studentState intValue] == 1) {
        //已认证,直接确认上车
        //可以上车
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认上车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
//        alertView.tag = 2;
//        [alertView show];
        if (self.selectIndexPath.section >= self.taskList.count) {
            return;//数组越界判断
        }
        //判断该学员是否填写过资料
        NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
        NSArray *array = dic[@"list"];
        
        if (self.selectIndexPath.row >= array.count) {
            return;//数组越界判断
        }
        
        dic = [array objectAtIndex:self.selectIndexPath.row];
        
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app startLocation];//开始定位
        
        [DejalBezelActivityView activityViewForView:self.view];
        [self performSelector:@selector(ComfirmTask:) withObject:[dic[@"orderid"] description] afterDelay:5];
        
        
    }else{
        //未认证过的话,弹出提示
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"学员还未认证资料,是否去认证?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"先去认证", @"直接上车", nil];
        alertView.tag = 0;
        [alertView show];
    }
}

#pragma mark 点击确认下车弹框确认
- (void)getOffCarClick:(id)sender
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认下车吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
//    alertView.tag = 1;
//    [alertView show];
    
    DSButton *button = (DSButton *)sender;
    self.selectIndexPath = button.indexPath;
    
    //确认下车
    if (self.selectIndexPath.section >= self.taskList.count) {
        return;//数组越界判断
    }
    NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
    NSArray *array = dic[@"list"];
    
    if (self.selectIndexPath.row >= array.count) {
        return;//数组越界判断
    }
    
    dic = [array objectAtIndex:self.selectIndexPath.row];
    [self getOffCarTask:[dic[@"orderid"] description]];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.selectIndexPath.section >= self.taskList.count) {
        return;//数组越界判断
    }
    //判断该学员是否填写过资料
    NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
    NSArray *array = dic[@"list"];
    
    if (self.selectIndexPath.row >= array.count) {
        return;//数组越界判断
    }
    
    dic = [array objectAtIndex:self.selectIndexPath.row];
    
    if (alertView.tag == 0 || alertView.tag == 2) {
        //确认上车
        if (alertView.tag == 0 && buttonIndex == 1) {
            NSDictionary *studentInfo = [NSDictionary dictionaryWithDictionary:dic[@"studentinfo"]];//学员信息
            
            //该学员未填写过资料，跳转到资料页面
            UploadPhotoViewController *nextController = [[UploadPhotoViewController alloc] initWithNibName:@"UploadPhotoViewController" bundle:nil];
            nextController.studentId = [studentInfo[@"studentid"] description];
            [self.navigationController pushViewController:nextController animated:YES];
            
//            NSDictionary *studentInfo = [NSDictionary dictionaryWithDictionary:dic[@"studentinfo"]];//学员信息
//            NSString *studentState = [studentInfo[@"coachstate"] description];//0.未认证 1.认证.
//            if([studentState intValue] == 1){
//                [self ComfirmTask:[dic[@"orderid"] description]];
//                
//            }else{
//               //该学员未填写过资料，跳转到资料页面
//                UploadPhotoViewController *nextController = [[UploadPhotoViewController alloc] initWithNibName:@"UploadPhotoViewController" bundle:nil];
//                [self.navigationController pushViewController:nextController animated:YES];
//            }
            
        }else if ((alertView.tag == 0 && buttonIndex == 2) || (alertView.tag == 2 && buttonIndex == 1)){
            //上车
//            NSDictionary *studentInfo = [NSDictionary dictionaryWithDictionary:dic[@"studentinfo"]];//学员信息
//            [self ComfirmTask:[dic[@"orderid"] description]];
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app startLocation];//开始定位
            
            [DejalBezelActivityView activityViewForView:self.view];
            [self performSelector:@selector(ComfirmTask:) withObject:[dic[@"orderid"] description] afterDelay:5];
        }
    }else if (alertView.tag == 1){
        if (buttonIndex == 1) {
            
//            //修改行的打开关闭状态
//            NSString *key = [NSString stringWithFormat:@"row%@", [dic[@"orderid"] description]];
//            [self.rowDic setObject:@"2" forKey:key];//设置为完成状态
//            [self.tableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
//            // 延时后删除cell
//            [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.7f];
            
            [self getOffCarTask:[dic[@"orderid"] description]];
            
        }
    }

}

#pragma mark details收起
- (void)hideDetailsCell:(TaskListTableViewCell *)cell
{
    cell.studentDetailsView.hidden = YES;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_right"];
    cell.iconTop.constant = 32;
    cell.iconRight.constant = 11;
    cell.iconWidth.constant = 9;
    cell.iconHeight.constant = 15;
}

#pragma mark details展开
- (void)showDetailsCell:(TaskListTableViewCell *)cell
{
    cell.studentDetailsView.hidden = NO;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_down"];
    cell.iconTop.constant = 35;
    cell.iconRight.constant = 8;
    cell.iconWidth.constant = 14;
    cell.iconHeight.constant = 9;
}

#pragma mark 完成任务删除cell
- (void)deleteCell
{

    // 删除数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self.taskList objectAtIndex:self.selectIndexPath.section]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:dic[@"list"]];
    NSDictionary *rowDic = [array objectAtIndex:self.selectIndexPath.row];
    [array removeObject:rowDic];
    [dic setObject:array forKey:@"list"];
    
    if (array.count == 0) {
        //该日期下已经没有数据，移除
        [self.taskList replaceObjectAtIndex:self.selectIndexPath.section withObject:dic];
        [self.tableView deleteRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self.rowDic removeAllObjects];
        [self.taskList removeObject:dic];
        [self.tableView reloadData];
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:self.selectIndexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    }else{
        //该日期下还有数据，替换
        [self.taskList replaceObjectAtIndex:self.selectIndexPath.section withObject:dic];
        [self.tableView deleteRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    }
    
    //行状态重置
    self.closeIndexPath = nil;
    self.openIndexPath = nil;
    
//    [self getTaskList];//刷新数据
    
    [self performSelector:@selector(addCommentView) withObject:nil afterDelay:0.3f];
}

#pragma mark 添加评论
- (void)addCommentView
{
    
    
    self.commentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.commentView];

    if (self.taskList.count == 0) {
        //没有数据
        self.noDataViewBtn.hidden = NO;
    }else{
        self.noDataViewBtn.hidden = YES;
    }
    
    pageNum = 0;
    [self performSelector:@selector(getTaskList) withObject:nil afterDelay:0.3f];
    
}


#pragma mark 取消评论
- (IBAction)cancelComment:(id)sender {
    [self.commentView removeFromSuperview];
}

#pragma mark 提交评论
- (IBAction)sureComment:(id)sender {
    NSString *str = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (str.length == 0) {
//        [self makeToast:@"请说点什么吧。。"];
//        return;
//    }
    
    
//    if (self.selectIndexPath.section >= self.taskList.count) {
//        return;//数组越界判断
//    }
//    //判断该学员是否填写过资料
//    NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
//    NSArray *array = dic[@"list"];
//    
//    if (self.selectIndexPath.row >= array.count) {
//        return;//数组越界判断
//    }
//    
//    dic = [array objectAtIndex:self.selectIndexPath.row];
    
    if ([self.commentOrderId intValue] !=0) {
        [self ComfirmComment:str orderId:self.commentOrderId];
    }
    
    
    
}

#pragma mark - StarRatingViewDelegate
-(void)starRatingView:(TQStarRatingView *)view score:(float)score{
    NSString *scoreStr = [NSString stringWithFormat:@"%.f", score*5];
    if ([view isEqual:self.starRatingView1]) {
        
        self.scoreLabel1.text = [NSString stringWithFormat:@"学习态度%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score1"];
        
    }else if ([view isEqual:self.starRatingView2]){
        
        self.scoreLabel2.text = [NSString stringWithFormat:@"技能掌握%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score2"];
    }else if ([view isEqual:self.starRatingView3]){
        
        self.scoreLabel3.text = [NSString stringWithFormat:@"遵章守时%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score3"];
    }
    
//    self.gouBtn.enabled = YES;
}

#pragma mark - 键盘监听
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)notification {
    //    scrollFrame = self.view.frame;
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.frame;
    
   
    //获取这个textField在self.view中的位置， fromView为textField的父view
    CGRect textFrame = self.commentTextView.superview.frame;
    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame) + self.commentContentView.frame.origin.y + 10;
    
    if(textFieldY < keyboardTop){
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    newTextViewFrame.origin.y = keyboardTop - textFieldY;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.commentView.frame = newTextViewFrame;
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.commentView.frame = self.view.frame;
    [UIView commitAnimations];
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.commentTextView resignFirstResponder];
}

#pragma mark 查看历史订单
- (IBAction)historyClick:(id)sender
{
    HistoryViewController *viewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
    viewController.userId = self.userId;
    [self.navigationController pushViewController:viewController animated:YES];
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
    [self.rowDic removeAllObjects];
    [self getTaskList];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getTaskList];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
    if (self.taskList.count == 0) {
        self.noDataViewBtn.hidden = NO;
    }else{
        self.noDataViewBtn.hidden = YES;
    }
    
}

#pragma mark - 接口
- (void)getTaskList{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kTaskServlet]];
    
    request.delegate = self;
    request.tag = 0;
    [request setPostValue:@"GetNowTask" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%d", pageNum] forKey:@"pagenum"];
    [request startAsynchronous];
}

#pragma mark 确认上车接口
- (void)ComfirmTask:(NSString *)orderId{
    
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    double lat = app.userCoordinate.latitude;
    double log = app.userCoordinate.longitude;
    NSString *address = [CommonUtil isEmpty:app.address]?@"":app.address;
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kTaskServlet]];
    
    request.delegate = self;
    request.tag = 1;
    
    [request setPostValue:@"ConfirmOn" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:orderId forKey:@"orderid"];
    [request setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
    [request setPostValue:[NSString stringWithFormat:@"%f", log] forKey:@"lon"];
    [request setPostValue:address forKey:@"detail"];
    [request startAsynchronous];
    
}

#pragma mark 确认下车接口
- (void)getOffCarTask:(NSString *)orderId{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    double lat = app.userCoordinate.latitude;
    double log = app.userCoordinate.longitude;
    NSString *address = [CommonUtil isEmpty:app.address]?@"":app.address;
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kTaskServlet]];
    
    request.delegate = self;
    request.tag = 2;
    [request setPostValue:@"ConfirmDown" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:orderId forKey:@"orderid"];
    [request setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
    [request setPostValue:[NSString stringWithFormat:@"%f", log] forKey:@"lon"];
    [request setPostValue:address forKey:@"detail"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

#pragma mark 提交评论
- (void)ComfirmComment:(NSString *)comment orderId:(NSString *)orderId{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kTaskServlet]];
    
    request.delegate = self;
    request.tag = 3;
    [request setPostValue:@"EvaluationTask" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"userid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:@"1" forKey:@"type"];//1.教练评价学员  2.学员评价教练
    [request setPostValue:orderId forKey:@"orderid"];
    [request setPostValue:self.scoreDic[@"score1"] forKey:@"score1"];
    [request setPostValue:self.scoreDic[@"score2"] forKey:@"score2"];
    [request setPostValue:self.scoreDic[@"score3"] forKey:@"score3"];
    [request setPostValue:comment forKey:@"content"];
    
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

#pragma mark 回调
- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if (request.tag == 0) {
            //获取未处理任务单
            NSArray *array = result[@"tasklist"];
            
            if (pageNum == 0) {
                //首页
                [self.noSortArray removeAllObjects];
                
            }
            
            [self.noSortArray addObjectsFromArray:array];
            
            //整理数据
            self.taskList = [self handelTaskList:self.noSortArray];
            
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
            
            
            [self.tableView reloadData];
            [DejalBezelActivityView removeViewAnimated:YES];
        }else if (request.tag == 1){
            //确认上车
            [self makeToast:@"确认上车成功"];
            [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
            pageNum = 0;
            [self getTaskList];
//            [self performSelector:@selector(getTaskList) withObject:nil afterDelay:0.3f];
            //[self.tableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        }else if (request.tag == 2){
            [DejalBezelActivityView removeViewAnimated:YES];
            //确认下车
            [self makeToast:@"确认下车成功"];
            
            if (self.selectIndexPath.section >= self.taskList.count) {
                return;//数组越界判断
            }
            //判断该学员是否填写过资料
            NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
            NSArray *array = dic[@"list"];
            
            if (self.selectIndexPath.row >= array.count) {
                return;//数组越界判断
            }
            
            dic = [array objectAtIndex:self.selectIndexPath.row];
            self.commentOrderId = [dic[@"orderid"] description];
            _openOrderId = @"0";//关闭
            //修改行的打开关闭状态
            NSString *key = [NSString stringWithFormat:@"row%@", [dic[@"orderid"] description]];
            [self.rowDic setObject:@"2" forKey:key];//设置为完成状态
            [self.tableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            
            // 延时后删除cell
            [self performSelector:@selector(deleteCell) withObject:nil afterDelay:0.7f];
        }else if (request.tag == 3){
            //提交评论
            [self makeToast:@"评价成功"];
            [self.commentView removeFromSuperview];
            
            [self clearEvaluate];
            
            [self getTaskList];
            
        }
        
        
    } else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
        
    }else{
        if (request.tag == 3){
            //提交评论
            
            /*
             "返回值：
             2.您已经对该任务评价过了.
             3.任务未完成,无法评价."
             */
            if ([code intValue] == 2) {
                [self makeToast:@"您已经对该任务评价过了"];
                
            }else if ([code intValue] == 3){
                [self makeToast:@"任务未完成,无法评价"];
            }else{
                if ([CommonUtil isEmpty:message]) {
                    message = ERR_NETWORK;
                }
            }
            
            
        }else{
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
        }
        
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:message];
    }
    [self getDataFinish];
    
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag != 0) {
        [DejalBezelActivityView removeViewAnimated:YES];
    }
    [self makeToast:ERR_NETWORK];
    [self getDataFinish];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - private
/** 整理数据， 根据日期存放list
 *格式 [{date: "yyyy-MM-dd", list:[....]}，{date: "yyyy-MM-dd", list:[....]},...]
 */
- (NSMutableArray *)handelTaskList:(NSArray *)array{
    //1.整理数据，根据日期排序,倒序排列
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        NSString *str1 = dic1[@"date"];
        NSString *str2 = dic2[@"date"];
        return [str1 compare:str2];
        
    }];
    
    NSMutableArray *taskArray = [NSMutableArray array];
    NSString *date = @"";
    NSMutableArray *sortList = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSDictionary *dic = sortArray[i];
        if (i == 0) {
            date = dic[@"date"];
        }
        
        if ([CommonUtil isEmpty:date]) {
            date = @"";
        }
        
        if ([date isEqualToString:dic[@"date"]]) {
            //同一个日期
            [sortList addObject:dic];
        }else{
            //下一个日期
            NSMutableDictionary *sortDic = [NSMutableDictionary dictionary];
            [sortDic setObject:date forKey:@"date"];//日期
            [sortDic setObject:[NSArray arrayWithArray:sortList] forKey:@"list"];
            [taskArray addObject:sortDic];
            
            //清空list
            [sortList removeAllObjects];
            date = dic[@"date"];
            [sortList addObject:dic];
        }
        
        if (i == sortArray.count - 1){
            NSMutableDictionary *sortDic = [NSMutableDictionary dictionary];
            [sortDic setObject:date forKey:@"date"];//日期
            [sortDic setObject:[NSArray arrayWithArray:sortList] forKey:@"list"];
            [taskArray addObject:sortDic];
        }
    }
    
    return taskArray;
}

//清空评价信息
- (void)clearEvaluate{
    [self.starRatingView1 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView1.frame), 0)];
    [self.starRatingView2 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView2.frame), 0)];
    [self.starRatingView3 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView3.frame), 0)];
    
    self.scoreLabel1.text = @"学习态度5分";
    self.scoreLabel2.text = @"技能掌握5分";
    self.scoreLabel3.text = @"遵章守时5分";
    
    self.commentTextView.text = @"";
    self.commentOrderId = @"0";
}
@end
