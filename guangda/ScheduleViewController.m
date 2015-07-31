//
//  ScheduleViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DateButton.h"
#import "DSPullToRefreshManager.h"
#import "ScheduleSettingViewController.h"
#import "SetAddrViewController.h"
#import "CustomTabBar.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ScheduleDetailViewController.h"
@interface ScheduleViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, CustomTabBarDelegate>{
    BOOL isCloseDate;
    CGRect dateFrame;
    BOOL isShowCalendar;
    BOOL isReload2Section;
    BOOL isUpdateDate;
    BOOL needRefresh;
    int maxdays;
    BOOL needSetDefault;
}

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *leftBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightBtn;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) UIView *dateView;//日历view
@property (strong, nonatomic) UIView *monthDayView;//月份view
@property (strong, nonatomic) IBOutlet UIView *weekView;//日期栏
@property (strong, nonatomic) UIButton *openBtn;

@property (strong, nonatomic) DSPullToRefreshManager *refreshManager;//下拉刷新

//订单是否可以取消
@property (strong, nonatomic) IBOutlet UIView *orderMsgView;
@property (strong, nonatomic) IBOutlet UILabel *orderDescLabel;
@property (strong, nonatomic) IBOutlet UISwitch *orderSwitch;
@property (strong, nonatomic) IBOutlet UILabel *openOrCloseLabel;
@property (strong, nonatomic) IBOutlet UISwitch *openOrCloseSwitch;

//参数
@property (strong, nonatomic) NSMutableArray *calenderArray;
@property (strong, nonatomic) NSDate *nowDate;
@property (strong, nonatomic) NSDate *selectDate;//选中的日期
@property (strong, nonatomic) NSDate *endDate;//结束时间
@property (strong, nonatomic) NSMutableArray *selectTimeArray;//选中的时间 8:00,9:00
@property (strong, nonatomic) NSMutableArray *morningAllTimeArray;//早上
@property (strong, nonatomic) NSMutableArray *afternoonAllTimeArray;//下午
@property (strong, nonatomic) NSMutableArray *eveningAllTimeArray;//晚上
@property (strong, nonatomic) NSString *cancelPermission;
@property (strong, nonatomic) NSString *nowHour;//现在时间点

@property (strong, nonatomic) IBOutlet UIButton *setDefaultButton;
- (IBAction)clickForSetDefaultCheck:(id)sender;

- (IBAction)clickTest:(id)sender;

/*
 calenderDic 格式
 date: 日期
 list: 时间点数组
 
 */
@property (strong, nonatomic) NSMutableDictionary *calenderDic;


@property (strong, nonatomic) NSMutableDictionary *stateDic;//时间状态对象

@property (strong, nonatomic) IBOutlet UIView *defaultAlertView;
@property (strong, nonatomic) IBOutlet UIButton *defaultSetButton;
@property (strong, nonatomic) IBOutlet UIButton *defaultCancelButton;

- (IBAction)clickForDefaultAlert:(id)sender;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cancelPermission = @"1";//默认不可设置
    isUpdateDate = YES;
    maxdays = 30;
    needSetDefault = NO;
    self.calenderDic = [NSMutableDictionary dictionary];
    self.nowDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:[NSDate date] format:@"yyyy-MM-dd"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    self.selectDate = self.nowDate;
    self.endDate = [CommonUtil addDate2:self.nowDate year:0 month:0 day:maxdays];
    self.startTime = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
    self.dateLabel.text = [CommonUtil getStringForDate:self.nowDate format:@"yyyy年M月"];
    isCloseDate = NO;
    isShowCalendar = YES;
    isReload2Section = NO;//显示第二行的sectionHeader
    self.selectTimeArray = [NSMutableArray array];
    self.morningAllTimeArray = [NSMutableArray arrayWithObjects:@"5:00", @"6:00", @"7:00", @"8:00", @"9:00", @"10:00", @"11:00", nil];
    self.afternoonAllTimeArray = [NSMutableArray arrayWithObjects:@"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00",nil];
    self.eveningAllTimeArray = [NSMutableArray arrayWithObjects:@"19:00", @"20:00", @"21:00", @"22:00", @"23:00", nil];
    
    [self initViews];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = RGB(243, 243, 243);
    [self showTableHeaderView];
    [self compareBeforeDate:self.selectDate nowDate:self.nowDate];
    
    //下拉刷新
    self.refreshManager = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.mainTableView withClient:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDaySchedule:) name:@"changeDaySchedule" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedule) name:@"refreshSchedule" object:nil];
    
    self.defaultSetButton.layer.cornerRadius = 5;
    self.defaultSetButton.layer.masksToBounds = YES;
    self.defaultCancelButton.layer.cornerRadius = 5;
    self.defaultCancelButton.layer.masksToBounds = YES;
    
    self.defaultAlertView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    needRefresh = YES;
}

- (IBAction)clickTest:(id)sender {
    ScheduleDetailViewController *nextController = [[ScheduleDetailViewController alloc] initWithNibName:@"ScheduleDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

- (void)changeDaySchedule:(id)dictionary{
    needRefresh = NO;
    NSMutableArray *array = nil;
    if ([dictionary isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)dictionary;
        if ([CommonUtil isEmpty:notification.object]) {
            return;
        }
        array = [NSMutableArray arrayWithArray:notification.object];
    } else {
        array = [NSMutableArray arrayWithArray:dictionary];
    }
    
    if (array != nil && array.count > 0) {
        [self handelDaySchedule:array];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.selectDate != nil) {
        NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        //获取数据
        if(needRefresh){
            [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];//手动下拉
            [self.refreshManager tableViewReloadStart:[NSDate date] Animated:YES];
            [self getScheduleList];
        }
    }
    needRefresh = YES;
}


//刷新数据
- (void)refreshSchedule{
    //获取数据
    if(needRefresh){
        [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];//手动下拉
        [self.refreshManager tableViewReloadStart:[NSDate date] Animated:YES];
        [self getScheduleList];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    needRefresh = NO;
}

- (void)initViews{
    
    //星期几frame
    int weekWidth = SCREEN_WIDTH / 7;
    
    //星期
    for (int i = 0; i < 7; i++) {
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*weekWidth, 0, weekWidth, 25)];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.textColor = RGB(136, 136, 136);
        weekLabel.font = [UIFont systemFontOfSize:12];
        [self.weekView addSubview:weekLabel];
        
        if (i == 0) {
            //日
            weekLabel.text = @"日";
        }else if (i == 1){
            //一
            weekLabel.text = @"一";
        }else if (i == 2){
            //二
            weekLabel.text = @"二";
        }else if (i == 3){
            //三
            weekLabel.text = @"三";
        }else if (i == 4){
            //四
            weekLabel.text = @"四";
        }else if (i == 5){
            //五
            weekLabel.text = @"五";
        }else if (i == 6){
            //六
            weekLabel.text = @"六";
        }
        
    }
    
    self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.openBtn setBackgroundColor:[UIColor blackColor]];
    [self.openBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    [self.openBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateSelected];
    [self.openBtn addTarget:self action:@selector(clickForOpenClose:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - tableView代理
#pragma mark tableSection
//section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//section高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat height = 0;
    
    int weekHeight = ceil(SCREEN_WIDTH / 7);
 
    height = weekHeight;

    if (!isShowCalendar) {
        //不显示日历
        height = 0;
    }
    if (section == 1) {
        if (!isReload2Section) {
            //不显示第二行的section
            height = 0;
        }else{
            height += 16;
        }
        
    }else{
        //
        if (isReload2Section) {
            //不显示第一行的section
            height = 0;
        }
    }
    return height;
}

//sectionHeader的样式
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;{

    /************** 日期栏 ****************/
    self.dateView = [[UIView alloc] init];
    /*****  日历页面  *****/
    
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间

    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    
    NSInteger weekCount = 1;
    long weekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(weekday-1)];//获取选中日期的星期天的日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //星期几frame
    int weekHeight = weekWidth;
    
    /*******  月份view ******/
    self.monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [self.dateView addSubview:self.monthDayView];
    
    CGFloat dayY = 0;

    for (int i = 0; i < weekCount*7; i++) {
        
        int index = -1;
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
            }
        }
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        int month = [CommonUtil getMonthOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        int status = 0;//0:正常工作，1：未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"] intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [self.monthDayView addSubview:view];
        
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    
    if (isReload2Section && section == 1){
        self.openBtn.frame = CGRectMake(0, dayY, SCREEN_WIDTH, 16);
        [self.dateView addSubview:self.openBtn];
    }
    
    //日历view高度
    self.dateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.monthDayView.frame.origin.y + CGRectGetHeight(self.monthDayView.frame) + 16);
    self.dateView.backgroundColor = [UIColor blackColor];
    return self.dateView;
}

#pragma mark sectionFooterView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        if (isReload2Section) {
            //不显示第一行的section
           return 0;
        }
        return 16;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    view.backgroundColor = [UIColor blackColor];
    self.openBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 16);
    [view addSubview:self.openBtn];
    return view;
}

#pragma mark tableHeaderView
//显示日期
- (void)showTableHeaderView{
    //如果选中的日期是第一周，那么就不需要tableHeaderView
    long selectWeek = [CommonUtil getWeekOfDate:self.selectDate];
    if (selectWeek == 1) {//是第一周
        self.mainTableView.tableHeaderView = nil;
        return;
    }
    
    /************** 日期栏 ****************/
    UIView *dateView = [[UIView alloc] init];
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    
    //获取1号所在星期的星期日的日期
    long weekday = [CommonUtil getWeekdayOfDate:firstDate];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:firstDate year:0 month:0 day:0-(weekday-1)];//获取星期天的日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取结束时间，选中日期所在周的前一个星期六
    long selectWeekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *endDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(selectWeekday)];//获取选中日期的星期六的日期
    endDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:endDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    //获取月初到结束日期相差几个礼拜,也就是获取结束日期在这个月第几周
    NSInteger weekCount = [CommonUtil getWeekOfDate:endDate];
    
    //星期几frame
    int weekHeight = weekWidth;
    
    /*******  月份view ******/
    UIView *monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [dateView addSubview:monthDayView];
    
    CGFloat dayY = 0;
    
    for (int i = 0; i < weekCount*7; i++) {
        
        int index = -1;
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
                break;
            }
        }
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        int month = [CommonUtil getMonthOfDate:beginDate];
        int status = 0;//全天状态 0开课  1未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"] intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [monthDayView addSubview:view];
        
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    
    //日历view高度
    dateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, monthDayView.frame.origin.y + CGRectGetHeight(monthDayView.frame));
    dateView.backgroundColor = [UIColor blackColor];
    self.mainTableView.tableHeaderView = dateView;
}

#pragma mark tableFooterView
- (void)showTableFooterView{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic != nil) {
        int state = [[dic objectForKey:@"state"] intValue];//全天状态 0未开课  1开课
        NSString *cancelState = [dic objectForKey:@"cancelstate"];//当天的订单是否可以取消 0.可以取消 1.不可以取消

        if (self.orderMsgView.superview) {
            [self.orderMsgView removeFromSuperview];
        }
        
        CGFloat height = 0;
        
        //判断全天开课或者停课
        if(state == 0){//未开课
            [self.openOrCloseSwitch setOn:NO];
            self.openOrCloseLabel.text = @"已关闭，学员现在不可以预定您今天的课程了";
        }else{//开课
            [self.openOrCloseSwitch setOn:YES];
            self.openOrCloseLabel.text = @"已开启，学员现在可以预定您今天的课程了";
        }
        
//        NSString *permiss = self.cancelPermission;//是否有设置当天订单可否取消的权限 0.可以设置  1.不可以设置
//        if ([permiss intValue] == 0) {
//            //可以设置
//            int cancel = [cancelState intValue];//0.可以取消 1.不可以取消
//            if (cancel == 0) {//可以取消教练的订单
//                [self.orderSwitch setOn:YES];
//                self.orderDescLabel.text = @"已开启，学员预定后可以取消对您下的订单";
//            }else{
//                [self.orderSwitch setOn:NO];
//                self.orderDescLabel.text = @"已关闭，学员预定后不可以取消对您下的订单";
//            }
//            self.orderMsgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80.0);
//            height = 80.0;
//        }else{
//            height = 0.0;
//            self.orderMsgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.0);
//        }
//        
//        
//        [view addSubview:self.orderMsgView];
        
        //显示当天停课按钮
        CGFloat x = ceilf((SCREEN_WIDTH - 140)/2);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, height + 13, 140, 41);
        button.layer.cornerRadius = 3;
        if(state == 0){
            [button setTitle:@"发布课程" forState:UIControlStateNormal];
            [button setBackgroundColor:RGB(33, 180, 120)];
        }else{
            [button setTitle:@"当天停课" forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor redColor]];
            button.backgroundColor = [UIColor redColor];
        }
        button.tag = state;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickForTodayOPenClose:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
//        //设置按钮背景
//        UIImage *image1 = [[UIImage imageNamed:@"background_check_geton"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
//        UIImage *image2 = [[UIImage imageNamed:@"background_check_geton_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
//        [button setBackgroundImage:image1 forState:UIControlStateNormal];
//        [button setBackgroundImage:image2 forState:UIControlStateHighlighted];
        
        view.frame = CGRectMake(0, 100, SCREEN_WIDTH, 41 + 13*2 + height);
        
        self.mainTableView.tableFooterView = view;
    }
}


#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        //剩下的日期
        NSDate *lastDate = [CommonUtil getLastDayOfDate:self.selectDate];
        long lastWeek = [CommonUtil getWeekOfDate:lastDate];
        long selectWeed = [CommonUtil getWeekOfDate:self.selectDate];
        return lastWeek - selectWeed;
    }else{
        return 3;
//        NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
//        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
//        
//        NSArray *array = dic[@"list"];
//        
//        NSDictionary *stateDic = nil;
//        for (NSDictionary *dateDic in array) {
//            int hour = [dateDic[@"hour"] intValue];
//            if (hour >= 25 || hour <= 0) {
//                stateDic = dateDic;
//                break;
//            }
//        }
        
        
        
//        if (stateDic == nil) {
//            //没有全天状态，今天为开课状态
//            return 3;
//        }else{
//            NSString *state = [stateDic[@"state"] description];//全天状态 0开课  1未开课
//            if ([state intValue] == 1) {
//                return 0;
//            }else{
//                return 3;
//            }
//        }
        
//        if (dic != nil) {
//            NSString *state = [dic objectForKey:@"state"];//0：停课 1:开课（未开课）
//            if ([state intValue] == 1) {
//                //没有日程安排
//                return 0;
//            }
//        }
//        //显示当天停课按钮
//        return 3;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        int weekHeight = ceil(SCREEN_WIDTH / 7.0);
        return  weekHeight;
    }
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSString *key = [NSString stringWithFormat:@"row%ld", (long)indexPath.row];
    NSString *state = [dic objectForKey:key];
    
    
    //状态 0:关闭 1：打开
    if ([state intValue] == 0) {
//        //关闭
//        if (indexPath.row == 0) {
//            return 45 + 8;
//        }
        return 45;
    }else{
        if (indexPath.row == 0) {
            //+ 11 + 18  代表标注
            //上午
            return (43 + 7) * 4 + 21 + 45 + 0 + 10 + 35  + 5;//4行时间 第一个21底部注解与时间距离,22:注解的高度 18：注解跟下划线的距离
        }else if (indexPath.row == 1){
            //下午
            return (43 + 7) * 4 + 21 + 45 + 10 + 35  + 5;//4行时间
        }else {
            //晚上
            return (43 + 7) * 3 + 21 + 45 + 10 + 35  + 10;//3行时间
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForDateRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
    
    /************** 日期栏 ****************/
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    //获取这一行的星期天所在日期
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    
    //获取1号所在星期的星期日的日期
    NSDate *date = [CommonUtil addDate2:self.selectDate year:0 month:0 day:7*(indexPath.row+1)];
    long weekday = [CommonUtil getWeekdayOfDate:date];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:date year:0 month:0 day:0-(weekday-1)];//获取这一行的星期天所在日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取结束时间，选中日期所在周的前一个星期六
    long selectWeekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *endDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(selectWeekday-2)];//获取选中日期的星期六的日期
    endDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    //获取月初到结束日期相差几个礼拜,也就是获取结束日期在这个月第几周
    NSInteger weekCount = 1;
    
    //星期几frame
    int weekHeight = weekWidth;

    /*******  月份view ******/
    UIView *monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [cell.contentView addSubview:monthDayView];
    
    CGFloat dayY = 0;
    
    for (int i = 0; i < weekCount*7; i++) {
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [CommonUtil getMonthOfDate:beginDate];
        
        int status = 0;//0:正常工作，1：未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"]intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        int index = -1;
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
                break;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [monthDayView addSubview:view];
   
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //日期
        UITableViewCell *cell = [self tableView:tableView cellForDateRowAtIndexPath:indexPath];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeCell"];
    
    CGFloat y = 0;
    if (indexPath.row == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0)];
        view.backgroundColor = RGB(243, 243, 243);
        [cell.contentView addSubview:view];
        
        y = 0;
    }
    
    /* ----  时间栏  ----- */
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 45)];
    [cell.contentView addSubview:timeView];
    
    UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clickButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(timeView.frame));
    [clickButton addTarget:self action:@selector(clickForChangeSchedule:) forControlEvents:UIControlEventTouchUpInside];
    clickButton.tag = indexPath.row;
    [timeView addSubview:clickButton];
    
    //上划线
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    underline.backgroundColor = RGB(211, 211, 211);
    [timeView addSubview:underline];
    
    //获取数据
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    /* ----  点  ----- */
    CGFloat pointY = ceilf((45 - 8)/2);
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(16, pointY, 8, 8)];
    pointView.layer.cornerRadius = 4;
    pointView.layer.masksToBounds = YES;
    [timeView addSubview:pointView];
    
    NSString *str = @"";
    if (indexPath.row == 0) {
        //上午橙色，未开课显示灰色
        str = dic[@"morning"];
        if ([@"未开课" isEqualToString:str]) {
            pointView.backgroundColor = RGB(193, 193, 193);
        }else{
            pointView.backgroundColor = RGB(247, 148, 29);
        }
        
    }else if (indexPath.row == 1){
        //下午红色，未开课显示灰色
        str = dic[@"afternoon"];
        if ([@"未开课" isEqualToString:str]) {
            pointView.backgroundColor = RGB(193, 193, 193);
        }else{
            pointView.backgroundColor = RGB(213, 49, 47);
        }
        
        
    }else{
        //晚上蓝色，未开课显示灰色
        str = dic[@"evening"];
        if ([@"未开课" isEqualToString:str]) {
            pointView.backgroundColor = RGB(193, 193, 193);
        }else{
            pointView.backgroundColor = RGB(19, 82, 226);
        }
        
    }
    
    //时间
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pointView.frame.origin.x + CGRectGetWidth(pointView.frame) + 8, 0, 30, 45)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = RGB(85, 85, 85);
    [timeView addSubview:label];
    if (indexPath.row == 0) {
        label.text = @"上午";
    }else if (indexPath.row == 1){
        label.text = @"下午";
    }else{
        label.text = @"晚上";
    }
   
    
    NSString *key = [NSString stringWithFormat:@"row%ld", (long)indexPath.row];
    NSString *state = [dic objectForKey:key];
    //状态 0:关闭 1：打开
    if ([state intValue] == 0) {
        //关闭
        
        //箭头
        CGFloat x = SCREEN_WIDTH - 15 - 9;
        pointY = ceilf((45 - 15)/2);
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, pointY, 9, 15)];
        arrowImageView.image = [UIImage imageNamed:@"arrow_complain"];
        [timeView addSubview:arrowImageView];
        
        //文字
        x = x - label.frame.origin.x - CGRectGetWidth(label.frame) - 10 - 8;
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x + CGRectGetWidth(label.frame) + 10, 0, x, 45)];
        descLabel.font = [UIFont boldSystemFontOfSize:17];
        descLabel.textColor = RGB(28, 28, 28);
        descLabel.textAlignment = NSTextAlignmentRight;
        [timeView addSubview:descLabel];
        
        NSString *str = @"";
        if (indexPath.row == 0) {
            //上午
            str = dic[@"morning"];
            if ([CommonUtil isEmpty:str]) {
                str = @"5:00~11:00";
            }
        }else if (indexPath.row == 1){
            //下午
            str = dic[@"afternoon"];
            if ([CommonUtil isEmpty:str]) {
                str = @"13:00~18:00";
            }
        }else{
            //晚上
            str = dic[@"evening"];
            if ([CommonUtil isEmpty:str]) {
                str = @"20:00~23:00";
            }
        }
        descLabel.text = str;
        
        y = 44;
    }else{
        //打开
        //箭头
        CGFloat x = SCREEN_WIDTH - 15 - 14;
        pointY = ceilf((45 - 9)/2);
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, pointY, 14, 9)];
        arrowImageView.image = [UIImage imageNamed:@"arrow_down_black"];
        [timeView addSubview:arrowImageView];
        
        y = 45;
        
        //显示按钮
        UIView *selectView = [[UIView alloc] init];//按钮区域
        [cell.contentView addSubview:selectView];
        
        //获取开始时间
        NSDate *date = [CommonUtil getDateForString:@"5:00" format:@"H:00"];
        if (indexPath.row == 1) {
            date = [CommonUtil getDateForString:@"12:00" format:@"H:00"];
        }else if (indexPath.row == 2){
            //晚上
            date = [CommonUtil getDateForString:@"19:00" format:@"H:00"];
        }
        
        /* ----   显示按钮   ------*/
        int count = 8; //7 个时间点 1个底部
        if (indexPath.row == 1) {
            //下午
            count = 8;
        }else if (indexPath.row == 2){
            //晚上
            count = 6;
        }
        
        CGFloat marginX = ceil((SCREEN_WIDTH - 120*2)/3);
        CGFloat buttonY = 10;
        
        //按钮状态
        NSString *key1 = [NSString stringWithFormat:@"selectState%ld", (long)indexPath.row];
        NSDictionary *selectDic = [dic objectForKey:key1];
        NSString *allSelect = [selectDic objectForKey:@"allSelect"];//0:不是全选 1：全选
        for (int i = 0; i < count; i++) {
            
            if (i == count-1) {
                //显示底部栏
                marginX = ceil((SCREEN_WIDTH - 120*2)/3);
                buttonY += (7 + 21 + 30);
                
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(marginX, buttonY, 120, 11)];
//                imageView.image = [UIImage imageNamed:@"notice_image"];
//                [selectView addSubview:imageView];
//                
//                buttonY += 11 + 18;
                
                UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(marginX, buttonY, ceil((SCREEN_WIDTH - 120*2)/3) + 120*2, 55)];
                bottomView.backgroundColor = [UIColor clearColor];
                [selectView addSubview:bottomView];
                
                //下划线
                UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bottomView.frame), 1)];
                underline.backgroundColor = RGB(211, 211, 211);
                [bottomView addSubview:underline];
                
                //全选按钮
                DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, 120, CGRectGetHeight(bottomView.frame));
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                [button setTitleColor:RGB(28, 28, 28) forState:UIControlStateNormal];
                button.tag = indexPath.row;
                [button setTitle:@"全选" forState:UIControlStateNormal];
                button.date = @"-1";
                [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [button addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
                [bottomView addSubview:button];
                
                [button setImage:[UIImage imageNamed:@"btn_checkbox_unchecked"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"btn_checkbox_checked"] forState:UIControlStateSelected];
                
                //按钮状态//0:全选 1：不是全选
                if ([allSelect integerValue] == 0) {
                    //是全选
                    button.selected = YES;
                }
                if ([CommonUtil isEmpty:allSelect]) {
                    //显示默认值
                    if (indexPath.row == 1){
                        button.selected = NO;//下午
                    }else if(indexPath.row == 2){
                        button.selected = NO;//晚上
                    }
                }
                
                //修改按钮
                x = CGRectGetWidth(bottomView.frame) - 84;
                pointY = ceilf((CGRectGetHeight(bottomView.frame) - 32)/2);
                DateButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                editBtn.frame = CGRectMake(x, pointY, 84, 32);
                editBtn.tag = indexPath.row;
                [editBtn setTitle:@"批量设置" forState:UIControlStateNormal];
                [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [editBtn setBackgroundColor:RGB(247, 148, 29)];
                [editBtn addTarget:self action:@selector(clickForUpdateTime:) forControlEvents:UIControlEventTouchUpInside];
                editBtn.layer.cornerRadius = 3;
                editBtn.layer.masksToBounds = YES;
                [bottomView addSubview:editBtn];
                
                //总高度
                buttonY += CGRectGetHeight(bottomView.frame);
                
            }else{
                if (i > 0 && i%2 == 0) {
                    buttonY += (8 + 43);
                }
                
                if (i > 0 && i%2 == 0) {
                    marginX = ceil((SCREEN_WIDTH - 120*2)/3);
                }
                
                if (i > 0 && (i + 1) %2 == 0) {
                    marginX = ceil((SCREEN_WIDTH - 120*2)/3) *2 + 120;
                }
                
                //时间按
                NSString *time = [CommonUtil getStringForDate:date format:@"H:00"];
                date = [CommonUtil addTime:date hour:1 minute:0 second:0];
                
                /////////////////  时间view  /////////////////
                //时间view
                UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(marginX, buttonY, 120, 43)];
                contentView.backgroundColor = [UIColor clearColor];
                
                [selectView addSubview:contentView];

                //时间
                UIView *timeDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120-33, CGRectGetHeight(contentView.frame))];
                timeDetailView.backgroundColor = [UIColor whiteColor];
                timeDetailView.layer.borderWidth = 1;
                timeDetailView.layer.borderColor = RGB(243, 243, 243).CGColor;
                [contentView addSubview:timeDetailView];
                
                //日期显示
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(timeDetailView.frame) - 26 - 8 - 7, CGRectGetHeight(timeDetailView.frame) - 16)];
                timeLabel.font = [UIFont boldSystemFontOfSize:16];
                //timeLabel.textColor = RGB(28, 28, 28);
                timeLabel.textColor = RGB(32, 180, 120);
                timeLabel.text = time;
                [timeDetailView addSubview:timeLabel];
                
                //选中样式
               /*
                UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x + CGRectGetWidth(timeLabel.frame), ceil((CGRectGetHeight(timeLabel.frame) - 8)/2), 12, 8)];
                selectImageView.image = [UIImage imageNamed:@"icon_ok_black"];
                selectImageView.hidden = YES;
                [timeDetailView addSubview:selectImageView];
                */
                UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x + CGRectGetWidth(timeLabel.frame), ceil((CGRectGetHeight(timeLabel.frame) - 14)/2), 26, 14)];
                selectLabel.backgroundColor = [UIColor blackColor];
                selectLabel.textAlignment = NSTextAlignmentCenter;
                selectLabel.font = [UIFont systemFontOfSize:11];
                selectLabel.textColor = [UIColor whiteColor];
                selectLabel.text = @"选中";
                selectLabel.hidden = YES;
                [timeDetailView addSubview:selectLabel];
                
                //价格显示
                UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(timeLabel.frame), CGRectGetWidth(timeDetailView.frame), 16)];
                //priceView.backgroundColor = RGB(243, 243, 243);
                priceView.backgroundColor = RGB(32, 180, 120);
                [contentView addSubview:priceView];
                
                //获取价格
                
                NSString *price = @"0";
                NSArray *array = dic[@"list"];
                NSString *timeStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:time format:@"H:00"] format:@"H"];
                for (NSDictionary *arrDic in array) {
                    NSString *hour = arrDic[@"hour"];
                    if ([timeStr intValue] == [hour intValue]) {
                        price = [arrDic[@"price"] description];
                        if ([CommonUtil isEmpty:price]) {
                            price = @"0";
                        }else{
                            price = [NSString stringWithFormat:@"%.0f", [price floatValue]];
                        }
                        break;
                    }
                }
                //价格label显示
                UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, CGRectGetWidth(priceView.frame) - 8, 16)];
                //priceLabel.textColor = RGB(247, 148, 29);
                priceLabel.textColor = [UIColor whiteColor];
                priceLabel.font = [UIFont systemFontOfSize:10];
                priceLabel.text = [NSString stringWithFormat:@"单价%@元", price];
                [priceView addSubview:priceLabel];
                
                //点击按钮
                DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, CGRectGetWidth(timeDetailView.frame), CGRectGetHeight(timeDetailView.frame));
                button.tag = indexPath.row;
                button.date = time;
                button.index = [NSString stringWithFormat:@"%d", i];
                [button addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
                [contentView addSubview:button];
                
                
                //------------------设置按钮---------------------
                DateButton *settingBtn = [DateButton buttonWithType:UIButtonTypeCustom];
                settingBtn.date = time;
                settingBtn.tag = indexPath.row;
                settingBtn.index = [NSString stringWithFormat:@"%d", i];
                settingBtn.frame = CGRectMake(CGRectGetWidth(timeDetailView.frame) - 1, 0, 34, CGRectGetHeight(contentView.frame));
                settingBtn.backgroundColor = [UIColor whiteColor];
                [settingBtn setImage:[UIImage imageNamed:@"icon_setting_black"] forState:UIControlStateNormal];
                [settingBtn addTarget:self action:@selector(clickForSetting:) forControlEvents:UIControlEventTouchUpInside];
                settingBtn.layer.borderColor = RGB(243, 243, 243).CGColor;
                settingBtn.layer.borderWidth = 1;
                [contentView addSubview:settingBtn];
                
                
                /*
                DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(marginX, buttonY, 115, 38);
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:26];
                [button setTitleColor:RGB(28, 28, 28) forState:UIControlStateNormal];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                button.tag = indexPath.row;
                [button setTitle:time forState:UIControlStateNormal];
                button.date = time;
                [button addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
                [selectView addSubview:button];
                
                //按钮背景
                UIImage *image1 = [[UIImage imageNamed:@"btn_time_unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 20)];
                UIImage *image2 = [[UIImage imageNamed:@"btn_time_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 20)];
                [button setBackgroundImage:image1 forState:UIControlStateNormal];
                [button setBackgroundImage:image2 forState:UIControlStateSelected];
                */
                
                //按钮状态 0:全选 1：不是全选
                NSArray *selectArray = [selectDic objectForKey:@"selectArray"];
                NSArray *restArray = [selectDic objectForKey:@"restArray"];//未开课的时间
                if ([CommonUtil isEmpty:allSelect] && selectArray.count == 0){
                    //默认时间段， 12，18未开课
                    if ([@"12:00" isEqualToString:time] || [@"18:00" isEqualToString:time]) {
                        button.selected = NO;
                        
                        priceLabel.text = @"未开课";
                        timeLabel.textColor = RGB(210, 210, 210);
                        priceLabel.textColor = RGB(210, 210, 210);
                        priceView.backgroundColor = RGB(243, 243, 243);
                    }else{
                        button.selected = YES;
                        
                        //选中状态
                        timeDetailView.backgroundColor = [UIColor whiteColor];
                        selectLabel.hidden = NO;
                        selectLabel.text = @"选中";
                    }
                }else{
                    for (NSString *selectTime in selectArray) {
                        if ([time isEqualToString:selectTime]) {
                            button.selected = YES;
                            
                            //选中状态
                            timeDetailView.backgroundColor = [UIColor whiteColor];
                            selectLabel.hidden = NO;
                            selectLabel.text = @"选中";
                        }
                    }
                }
                
                //设置未开课的时间
                for (NSString *restTime in restArray) {
                    if ([time isEqualToString:restTime]) {
                        button.selected = NO;
                        
                        //未选中状态
                        priceLabel.text = @"未开课";
                        timeLabel.textColor = RGB(210, 210, 210);
                        priceLabel.textColor = RGB(210, 210, 210);
                        priceView.backgroundColor = RGB(243, 243, 243);
                    }
                }
                
                //设置未开课的时间
                NSMutableArray *bookArray = [selectDic objectForKey:@"bookArray"];//已选时间
                for (NSString *restTime in bookArray) {
                    if ([time isEqualToString:restTime]) {
                        button.selected = YES;
                        selectLabel.hidden = NO;
                        selectLabel.text = @"已约";
                    }
                }
            }
        }
        selectView.frame = CGRectMake(0, y, SCREEN_WIDTH, buttonY);
        
        //下一个控件的Y轴
        y = selectView.frame.origin.y + CGRectGetHeight(selectView.frame);
        
    }
    
    //下划线
    if (indexPath.row == 2){
        underline = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 1)];
        underline.backgroundColor = RGB(211, 211, 211);
        [timeView addSubview:underline];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//没有选中状态
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - scrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.refreshManager tableViewScrolled];
    
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    //CGFloat y = scrollView.contentOffset.y;
    if (scrollView.contentOffset.y >= 0){
        [self getDataFinish];
    }
    
    if (scrollView.contentOffset.y > weekHeight*(weekCount - 1)) {
        if (!isReload2Section) {
            //显示第二个sectionHeader隐藏第一个sectionHeader，造成选中行停留的效果
            isReload2Section = YES;
            [self.mainTableView reloadData];
        }
        
    }else{
        if (isReload2Section) {
            //显示第一个sectionHeader隐藏第二个sectionHeader，造成选中行打开的效果
            isReload2Section = NO;
            [self.mainTableView reloadData];
        }
    }
    
    if (scrollView.contentOffset.y > ceil(weekHeight*weekCount/2)
        && scrollView.contentOffset.y < weekHeight*weekCount+16) {
        //大于一半，收缩
        self.openBtn.selected = YES;//展开
        
    }else if (scrollView.contentOffset.y <= ceil(weekHeight*weekCount/2)){
        //小于一半，打开
        self.openBtn.selected = NO;//收缩
        
    }
    
}

#pragma mark - DSPullToRefreshManagerClient

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshManager tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    [self getScheduleList];
}

- (void)getDataFinish{
    [self.refreshManager tableViewReloadFinishedAnimated:YES];
}

//停止拖拽的时候开始执行
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    
//    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
//    NSMutableDictionary *dic = [self.stateDic objectForKey:chooseTime];
//    if (dic == nil) {
//        dic = [NSMutableDictionary dictionary];
//    }
//    NSString *state0 = [dic objectForKey:@"row0"];
//    NSString *state1 = [dic objectForKey:@"row1"];
//    NSString *state2 = [dic objectForKey:@"row2"];
//    
//    //状态 0:关闭 1：打开
//    if ([state0 intValue] == 0 && [state1 intValue] == 0 && [state2 intValue] == 0 ) {
//        //三个时间段都为关闭状态
//        return;
//    }
//    
//    int weekHeight = ceil(SCREEN_WIDTH / 7);
//    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
//    //获取本月有几周
//    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
//    
//    if (scrollView.contentOffset.y > ceil(weekHeight*weekCount/2)
//        && scrollView.contentOffset.y < weekHeight*weekCount+16) {
//        //大于一半，收缩
//        self.openBtn.selected = YES;//展开
//        [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 1)*weekHeight) animated:YES];
//        
//    }else if (scrollView.contentOffset.y <= ceil(weekHeight*weekCount/2)){
//        //小于一半，打开
//        self.openBtn.selected = NO;//收缩
//        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        
//    }
//    
//}

//减速的时候执行
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
//    NSMutableDictionary *dic = [self.stateDic objectForKey:chooseTime];
//    if (dic == nil) {
//        dic = [NSMutableDictionary dictionary];
//    }
//    NSString *state0 = [dic objectForKey:@"row0"];
//    NSString *state1 = [dic objectForKey:@"row1"];
//    NSString *state2 = [dic objectForKey:@"row2"];
//    
//    //状态 0:关闭 1：打开
//    if ([state0 intValue] == 0 && [state1 intValue] == 0 && [state2 intValue] == 0 ) {
//        //三个时间段都为关闭状态
//        return;
//    }
//    
//    //滑动效果
//    int weekHeight = ceil(SCREEN_WIDTH / 7);
//    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
//    //获取本月有几周
//    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
//    
//    if (scrollView.contentOffset.y > ceil(weekHeight*weekCount/2)
//        && scrollView.contentOffset.y < weekHeight*weekCount+16) {
//        //大于一半，收缩
//        self.openBtn.selected = YES;//展开
//        [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 1)*weekHeight) animated:YES];
//        
//    }else if (scrollView.contentOffset.y <= ceil(weekHeight*weekCount/2)){
//        //小于一半，打开
//        self.openBtn.selected = NO;//收缩
//        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        
//    }
//}

#pragma mark - private
//比较日期查看上一个的按钮是否可以点击， 下一个日期是否可以点击
- (void)compareBeforeDate:(NSDate *)date1 nowDate:(NSDate *)nowDate{
    //判断下一个月是否可以点击
    NSDate *endDate = [CommonUtil addDate2:nowDate year:0 month:1 day:0];
    endDate = [CommonUtil getFirstDayOfDate:endDate];
    NSDate *endDate1 = [CommonUtil getFirstDayOfDate:date1];
    if ([endDate1 compare:endDate] == NSOrderedAscending) {
        //小于，可以点击
        self.rightBtn.selected = NO;
        self.rightBtn.userInteractionEnabled = YES;
    }else{
        self.rightBtn.selected = YES;
        self.rightBtn.userInteractionEnabled = NO;
    }
    
    //判断上一个月是否可以点击
    date1 = [CommonUtil getFirstDayOfDate:date1];
    nowDate = [CommonUtil getFirstDayOfDate:nowDate];
    
    if ([date1 compare:nowDate] == NSOrderedDescending) {
        //大于当前月
        self.leftBtn.selected = NO;
        self.leftBtn.userInteractionEnabled = YES;
        //选中日期默认1号
        self.selectDate = date1;
    }else{
        //当前月
        self.leftBtn.selected = YES;
        self.leftBtn.userInteractionEnabled = NO;
        //选中日期默认今天
        self.selectDate = self.nowDate;
    }
    
}

//更新选中的时间区间描述
- (void)updateSelectTimeDesc{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    for (int i = 0; i < 3; i++) {
        //获取该行的选中状态
        NSString *key = [NSString stringWithFormat:@"selectState%d", i];
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
        
        //获取该行是否是全选
        NSString *allState = [selectDic objectForKey:@"allSelect"];
        if ([allState intValue] == 0) {
            //全选
            if (i == 0) {
                 [dic setObject:@"5:00~11:00" forKey:@"morning"];
                
            }else if (i == 1){
                [dic setObject:@"12:00~18:00" forKey:@"afternoon"];
                
            }else{
                [dic setObject:@"19:00~23:00" forKey:@"evening"];
                
            }
           
        }else{
            //不是全选
            
            //获取该行选中的时间
            NSMutableArray *restArray = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restArray"]];//未开课的日期
            NSMutableArray *array = [NSMutableArray array];
            
            NSDate *date = [CommonUtil getDateForString:@"5:00" format:@"H:00"];
            if (i == 0) {
                array = [NSMutableArray arrayWithArray:self.morningAllTimeArray];
                [array removeObjectsInArray:restArray];//工作的时间
                
            }else if (i == 1) {
                date = [CommonUtil getDateForString:@"12:00" format:@"H:00"];
                
                array = [NSMutableArray arrayWithArray:self.afternoonAllTimeArray];
                [array removeObjectsInArray:restArray];//工作的时间
            }else if (i == 2){
                //晚上
                date = [CommonUtil getDateForString:@"19:00" format:@"H:00"];
                
                array = [NSMutableArray arrayWithArray:self.eveningAllTimeArray];
                [array removeObjectsInArray:restArray];//工作的时间
            }
            
            NSString *descTime = @"";
            NSString *startTime = @"";
            NSString *endTime = @"";
            if (array.count == 0) {
                descTime = @"未开课";
            }else{
                
                for (int i = 0; i < array.count; i++) {
                    NSString *selectTime = array[i];
                    
                    if (i == 0) {
                        descTime = selectTime;
                        startTime = selectTime;
                        
                    } else{
                        //下一个日期
                        NSString *beforeTime = array[i - 1];
                        NSString *beforeH = [CommonUtil getStringForDate:[CommonUtil getDateForString:beforeTime format:@"H:00"] format:@"H"];
                        NSString *selectH = [CommonUtil getStringForDate:[CommonUtil getDateForString:selectTime format:@"H:00"] format:@"H"];
                        
                        if ([selectH intValue] - [beforeH intValue] == 1) {
                            //选中日期比上一个选中日期相差一个小时，表示这个是连续的时间
                            if (i == array.count-1) {
                                //最后一个时间
                                endTime = selectTime;
                                if (![startTime isEqualToString:endTime]) {
                                    //开始时间跟结束时间不一致,表示是一个区间
                                    descTime = [NSString stringWithFormat:@"%@~%@", descTime, endTime];
                                }else{
                                    //开始时间跟结束时间一致，代表要/分割
                                    descTime = [NSString stringWithFormat:@"%@/%@", descTime, selectTime];
                                    
                                }
                            }
                        }else{
                            //选中日期比上一个选中日期相差超过一个小时，表示这个不是连续的时间
                            //结束时间为上一个时间
                            endTime = array[i - 1];
                            if (![startTime isEqualToString:endTime]) {
                                //开始时间跟结束时间不一致,表示是一个区间
                                descTime = [NSString stringWithFormat:@"%@~%@/%@", descTime, endTime, selectTime];
                                
                            }else{
                                //开始时间跟结束时间一致，代表要/分割
                                descTime = [NSString stringWithFormat:@"%@/%@", descTime, selectTime];
                                
                            }
                            startTime = selectTime;
                            
                        }
                    }
                }
            }
            
            NSString *timeKey = @"morning";
            if (i == 1){
                timeKey = @"afternoon";
            }else if (i == 2){
                timeKey = @"evening";
            }
            [dic setObject:descTime forKey:timeKey];
        }
    }
    
    [self.calenderDic setObject:dic forKey:chooseTime];
    
}

#pragma mark - action
//点击查看日期详细   选择日期
- (void)clickForDetail:(DateButton *)button{
    NSString *date = button.date;
    self.selectDate = [CommonUtil getDateForString:date format:@"yyyy-MM-dd"];
    
    //处理选中日期的数据
    [self handelSelectDateDetail];
    
    [self showTableHeaderView];
    [self.mainTableView reloadData];
    [self showTableFooterView];
   
}

//切换月份
- (IBAction)clickForChangeDate:(id)sender {
    isCloseDate = NO;
    self.openBtn.selected = NO;
    UIButton *button = (UIButton *)sender;
    
    NSDate *date = [CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"];
    date = [CommonUtil getFirstDayOfDate:date];

    if (button.tag == 0) {
        //上一个月
        date = [CommonUtil addDate2:date year:0 month:-1 day:0];
        
        self.startTime = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    }else{
        //下一个月
        
        date = [CommonUtil addDate2:date year:0 month:1 day:0];
        
        self.startTime = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    }
    
    self.dateLabel.text = [CommonUtil getStringForDate:date format:@"yyyy年M月"];
    [self compareBeforeDate:date nowDate:self.nowDate];
    
    [self handelSelectDateDetail];//处理数据
    
    [self.mainTableView reloadData];
    [self showTableFooterView];
    [self showTableHeaderView];
    
//    [self checkSlideDown];
}

//打开或者关闭日历
- (void)clickForOpenClose:(id)sender{

    UIButton *button = (UIButton *)sender;
    
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    if (button.selected) {
        //收缩状态,显示一行日期
        //打开日期栏
        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        //打开状态，显示全部日期
        //关闭日期栏
        [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 1)*weekHeight) animated:YES];
    }
    
    button.selected = !button.selected;
    [self showTableFooterView];

}

//停课
- (void)clickForStop:(id)sender{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
//    [dic setObject:@"1" forKey:@"state"];
//    [self.calenderDic setObject:dic forKey:chooseTime];
    
    //修改改天日程状态
    [self updateSchedateState:@"2"];//修改的状态1.全天开课 2.全天未开课
    
}

//开课
- (void)clickForStart:(id)sender{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
   
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
//    
//    [dic setObject:@"0" forKey:@"state"];
//    [self.calenderDic setObject:dic forKey:chooseTime];
    
    //修改改天日程状态
    [self updateSchedateState:@"1"];//修改的状态1.全天开课 2.全天未开课
    
}

//选择时间（）
- (void)clickForChoose:(DateButton *)button{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSString *key1 = [NSString stringWithFormat:@"selectState%ld", (long)button.tag];
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *bookArray = [selectDic objectForKey:@"bookArray"];
    
    NSString *time = button.date;
    if ([@"-1" isEqualToString:time]) {
        //全选
        NSString *allSelect = selectDic[@"allSelect"];
        if ([allSelect intValue] == 0) {
            //全选，变成全不选
            [selectDic setObject:@"1" forKey:@"allSelect"];//0:全选 1：不是全选
            [selectDic setObject:[NSArray array] forKey:@"selectArray"];
        }else{
            //不是全选，变成全选
            [selectDic setObject:@"0" forKey:@"allSelect"];//0:全选 1：不是全选
            
            NSMutableArray *array = nil;
            if (button.tag == 0) {
                //早上
                array = [NSMutableArray arrayWithArray:self.morningAllTimeArray];
                
            }else if (button.tag == 1){
                //下午
                array = [NSMutableArray arrayWithArray:self.afternoonAllTimeArray];
                
            }else{
                //晚上
                array = [NSMutableArray arrayWithArray:self.eveningAllTimeArray];
            }
            if (array == nil) {
                array = [NSMutableArray array];
            }
            
            //移除已经预约的
            [array removeObjectsInArray:bookArray];
            
            //移除当前时间之前的日期
            if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
                //小于当天
                [array removeAllObjects];
                [self makeToast:@"没有可以选择的时间点"];
                return;
                
            }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
                //等于当天
                NSArray *hourArray = [NSArray arrayWithArray:array];
                for (NSString *hour in hourArray) {
                    NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:hour format:@"H:00"] format:@"H"];
                    
                    if ([hourStr intValue] <= [self.nowHour intValue]) {
                        [array removeObject:hour];
                    }
                    
                }

            }
            
            if (array.count == 0) {
                //没有可以选择的日期
                [self makeToast:@"没有可以选择的时间点"];
                return;
            }
            [selectDic setObject:array forKey:@"selectArray"];
        }
        
    }else{
        //不是全选，点击日期
        [selectDic setObject:@"1" forKey:@"allSelect"];//0:不是全选 1：全选
        
        //移除已经预约的
        if ([bookArray containsObject:time]) {
            [self makeToast:@"该时间点已被预约不可选择"];
            return;
        }
        
        //移除当前时间之前的日期
        if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
            //小于当天
            [self makeToast:@"该时间点不可选择"];
            return;
            
        }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
            //等于当天
            NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:time format:@"H:00"] format:@"H"];
            if ([hourStr intValue] <= [self.nowHour intValue]) {
                [self makeToast:@"该时间点不可选择"];
                return;
            }
            
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
        if ([array  containsObject:time]) {
            //包含，就移除
            [array removeObject:time];
        }else{
            //不包含，就添加
            [array addObject:time];
        }
        
        NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *str1 = (NSString *)obj1;
            NSString *str2 = (NSString *)obj2;
            str1 = [CommonUtil getStringForDate:[CommonUtil getDateForString:str1 format:@"H:00"] format:@"H"];
            str2 = [CommonUtil getStringForDate:[CommonUtil getDateForString:str2 format:@"H:00"] format:@"H"];
            
            if ([str1 intValue] > [str2 intValue]) {
                //小于
                return NSOrderedDescending;
            }else if ([str1 intValue] == [str2 intValue]){
                return NSOrderedSame;
            }else{
                return NSOrderedAscending;
            }
            
         }];
        [selectDic setObject:sortArray forKey:@"selectArray"];
        
    }

    
    [dic setObject:selectDic forKey:key1];
    [self.calenderDic setObject:dic forKey:chooseTime];
    
    [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

//打开或者关闭日程
- (void)clickForChangeSchedule:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [NSString stringWithFormat:@"row%ld", (long)button.tag];
    NSString *state = [dic objectForKey:key];
    if ([@"1" isEqualToString:state]) {
        state = @"0";//关闭
        
        //获取该行的选中状态
        NSString *stateKey = [NSString stringWithFormat:@"selectState%ld", (long)button.tag];
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:stateKey]];

//        //获取该行选中的时间
//        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
//        [selectDic setObject:array forKey:@"selectTime"];
        
        //获取该行是否是全选
//        NSString *allState = [selectDic objectForKey:@"realAllSelect"];
//        allState = [CommonUtil isEmpty:allState]?@"":allState;
//        [selectDic setObject:allState forKey:@"allSelect"];//真正的是否全选

        //保存数据
        [dic setObject:selectDic forKey:stateKey];

        [self updateSelectTimeDesc];//更新日期描述
    }else{
        state = @"1";//打开
    }
    [dic setObject:state forKey:key];//时间状态 0:关闭 1：打开
   
    [self.calenderDic setObject:dic forKey:chooseTime];
    
    [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:1]]  withRowAnimation:UITableViewRowAnimationFade];
    
    [self checkSlideDown];
}

- (void)checkSlideDown{
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    //动画效果（遗弃）
//    if (self.mainTableView.contentOffset.y > ceil(weekHeight*weekCount/2)
//        && self.mainTableView.contentOffset.y < weekHeight*weekCount+16) {
//        //大于一半，收缩
//        self.openBtn.selected = YES;//展开
//        [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 1)*weekHeight) animated:YES];
//        
//    }
    if (self.mainTableView.contentOffset.y > weekHeight*(weekCount - 1)) {
        if (!isReload2Section) {
            //显示第二个sectionHeader隐藏第一个sectionHeader，造成选中行停留的效果
            isReload2Section = YES;
            [self.mainTableView reloadData];
        }
        
    }else{
        if (isReload2Section) {
            //显示第一个sectionHeader隐藏第二个sectionHeader，造成选中行打开的效果
            isReload2Section = NO;
            [self.mainTableView reloadData];
        }
    }
    //动画效果（遗弃）
//    if (self.mainTableView.contentOffset.y <= ceil(weekHeight*weekCount/2)){
//        //小于一半，打开
//        self.openBtn.selected = NO;//收缩
//        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        
//    }
}

#pragma mark 批量设置
- (void)clickForUpdateTime:(id)sender{

    UIButton *button = (UIButton *)sender;
    
//    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
//    NSMutableDictionary *dic = [self.stateDic objectForKey:chooseTime];
//    if (dic == nil) {
//        dic = [NSMutableDictionary dictionary];
//    }
//    
////    BOOL hasData = NO;//是否选择日期
//    for (int i = 0; i < 3; i++) {
//        //修改3个日期的时间
//
//        
//        //获取该行的选中状态
//        NSString *key = [NSString stringWithFormat:@"selectState%d", i];
//        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
//        
//        //获取该行选中的时间
//        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
//        [selectDic setObject:array forKey:@"realSelectTime"];
//        
//        //获取该行是否是全选
//        NSString *allState = [selectDic objectForKey:@"allSelect"];
//        allState = [CommonUtil isEmpty:allState]?@"0":allState;
//        [selectDic setObject:allState forKey:@"realAllSelect"];//真正的是否全选
//        
//        //获取该行未开课的时间
//        NSMutableArray *restArray = [NSMutableArray array];
//        if (i == 0) {
//            //早上
//            restArray = [NSMutableArray arrayWithArray:self.morningAllTimeArray];
//            
//        }else if (i == 1){
//            //下午
//            restArray = [NSMutableArray arrayWithArray:self.afternoonAllTimeArray];
//            
//        }else{
//            //晚上
//            restArray = [NSMutableArray arrayWithArray:self.eveningAllTimeArray];
//        }
//        
//        [restArray removeObjectsInArray:array];
//        [selectDic setObject:restArray forKey:@"realRestTime"];
//        [selectDic setObject:restArray forKey:@"restTime"];
//        
//        //保存数据
//        [dic setObject:selectDic forKey:key];
//        [self.stateDic setObject:dic forKey:chooseTime];
//
//    }
//    
//    //上传数据
//    [self uploadTimeChange];
    
//    if (hasData) {
//        //上传数据
//        [self uploadTimeChange];
//    }else{
//        [self updateSelectTimeDesc];//更新日期描述
//        
//        [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:1]]  withRowAnimation:UITableViewRowAnimationFade];
// 
//    }
    
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    //获取选中的日期
    NSString *time = @"";
    NSString *firstTime = @"";
    NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];//获取选中日期的对象
    //获取对应时间段的选中状态
    NSString *key = [NSString stringWithFormat:@"selectState%ld", (long)button.tag];
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
    
    NSMutableArray *selectArray = selectDic[@"selectArray"];//选中的时间点集合
    for (NSString *str in selectArray) {
        if ([CommonUtil isEmpty:time]) {
            time = str;
            firstTime = str;//获取第一个时间点，用来获取该时间点的具体数据
        }else{
            time = [NSString stringWithFormat:@"%@、%@", time, str];
        }
        
    }
    
    if ([CommonUtil isEmpty:time]){
        [self makeToast:@"请选择修改时间点"];
        return;
    }
//    for (int j = 0; j < 3; j++) {
//        //获取对应时间段的选中状态
//        NSString *key = [NSString stringWithFormat:@"selectState%d", j];
//        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
//        
//        NSMutableArray *selectArray = selectDic[@"selectArray"];//选中的时间点集合
//        for (NSString *str in selectArray) {
//            if ([CommonUtil isEmpty:time]) {
//                time = str;
//                firstTime = str;//获取第一个时间点，用来获取该时间点的具体数据
//            }else{
//                time = [NSString stringWithFormat:@"%@、%@", time, str];
//            }
//            
//        }
//    }
    
    //获取第一个时间点的具体数据
    NSDate *strDate = [CommonUtil getDateForString:firstTime format:@"HH:00"];
    NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
    for (NSDictionary *arrDic in array) {
        NSString *timeStr = [arrDic[@"hour"] description];
        if ([hourStr intValue] == [timeStr intValue]) {
            //获取该日期的具体数据
            timeDic = [NSMutableDictionary dictionaryWithDictionary:arrDic];
            break;
        }
    }
    
    
    ScheduleSettingViewController *nextController = [[ScheduleSettingViewController alloc] initWithNibName:@"ScheduleSettingViewController" bundle:nil];
    nextController.time = time;
    nextController.timeDic = timeDic;
    nextController.date = chooseTime;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark 点击单个设置
- (void)clickForSetting:(DateButton *)button{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    //获取时间点的具体数据
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    NSString *key1 = [NSString stringWithFormat:@"selectState%ld", (long)button.tag];
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *bookArray = selectDic[@"bookArray"];
    
    NSDictionary *timeDic = [NSDictionary dictionary];
    
    NSDate *strDate = [CommonUtil getDateForString:button.date format:@"HH:00"];
    NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
    
    //判断已经预约的
    if ([bookArray containsObject:button.date]) {
        [self makeToast:@"该时间点已被预约不可修改"];
        return;
    }
    
    //移除当前时间之前的日期
    if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
        //小于当天
        [self makeToast:@"该时间点不可选择"];
        return;
        
    }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
        //等于当天
        NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:button.date format:@"H:00"] format:@"H"];
        if ([hourStr intValue] <= [self.nowHour intValue]) {
            [self makeToast:@"该时间点不可修改"];
            return;
        }
        
    }
    
    for (NSDictionary *arrDic in array) {
        NSString *hour = [arrDic[@"hour"] description];
        if ([hourStr isEqualToString:hour]) {
            timeDic = arrDic;
            break;
        }
    }
    
    ScheduleSettingViewController *nextController = [[ScheduleSettingViewController alloc] initWithNibName:@"ScheduleSettingViewController" bundle:nil];
    nextController.time = button.date;
    nextController.timeDic = timeDic;
    nextController.date = chooseTime;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark 订单是否取消
- (IBAction)clickForChangeOrder:(id)sender {
    UISwitch *ordSwit = (UISwitch *)sender;
    NSInteger tag = ordSwit.tag;
    
    
    if(tag == 0){//是否开课
        if(self.openOrCloseSwitch.isOn){
            self.openOrCloseLabel.text = @"已开启，学员现在可以预定您今天的课程了";
            [self clickForStart:nil];
        }else{
            self.openOrCloseLabel.text = @"已关闭，学员现在不可以预定您今天的课程了";
            [self clickForStop:nil];
        }
    }else{//是否可以取消
        if (ordSwit.isOn) {
            self.orderDescLabel.text = @"已开启，学员预定后可以取消对您下的订单";
            [self updateOrderState:@"0"];//修改的状态 0.可以取消 1.不可以取消
        }else{
            self.orderDescLabel.text = @"已关闭，学员预定后不可以取消对您下的订单";
            [self updateOrderState:@"1"];//修改的状态 0.可以取消 1.不可以取消
        }
    }
}

- (void) clickForTodayOPenClose:(id)sender{
    UIButton *ordSwit = (UIButton *)sender;
    NSInteger tag = ordSwit.tag;
    
    if(tag == 0){
        if(self.defaultAlertView.superview){
            [self.defaultAlertView removeFromSuperview];
        }
        [self.view addSubview:self.defaultAlertView];
    }else{
        [self clickForStop:nil];
    }
}

#pragma mark - 接口
//获取日程安排
- (void)getScheduleList{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kScheduleServlet]];
    request.tag = 0;
    request.delegate = self;
    request.timeOutSeconds = 60;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetSchedule" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request startAsynchronous];
    needRefresh = NO;
}

//更新该天日程的状态， state：修改的状态1.全天开课 2.全天未开课
- (void)updateSchedateState:(NSString *)state{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kScheduleServlet]];
    request.tag = 2;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangeAllDaySchedule" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"] forKey:@"day"];
    [request setPostValue:state forKey:@"type"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

//修改订单式是否可以取消	 修改的状态 0.可以取消 1.不可以取消
- (void)updateOrderState:(NSString *)state{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kScheduleServlet]];
    request.tag = 3;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangeOrderCancel" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"] forKey:@"day"];
    [request setPostValue:state forKey:@"type"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    if(request.tag == 0){
        needRefresh = YES;
    }
    // 取得数据成功
    if ([code intValue] == 1) {
        if (request.tag == 1) {//修改日程

        }else if (request.tag == 2){//更新日程状态
            NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
            NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
            int type = [result[@"type"] intValue];
            NSMutableArray *array = [dic[@"list"] mutableCopy];
            
            for (int i = 0; i <  array.count; i++) {
                NSMutableDictionary *dicy = array[i];
                NSString *hour = dicy[@"hour"];
                if([@"0" isEqualToString:hour]){
                    [dicy setObject:[NSString stringWithFormat:@"%d",type] forKey:@"state"];
                    [array replaceObjectAtIndex:i withObject:dicy];
                    break;
                }
            }
            
            [self handelDaySchedule:array];
            [self makeToast:@"修改成功"];
            //如果需要设置为默认的话
            if(needSetDefault){
                [self setTodayDefault];
            }else{
                [DejalBezelActivityView removeViewAnimated:YES];
            }
            
            
        }else if (request.tag == 3){//修改是否可以取消
            NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
            NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
            int type = [result[@"type"] intValue];
            NSMutableArray *array = [dic[@"list"] mutableCopy];
            
            for (int i = 0; i <  array.count; i++) {
                NSMutableDictionary *dicy = array[i];
                NSString *hour = dicy[@"hour"];
                if([@"0" isEqualToString:hour]){
                    [dicy setObject:[NSString stringWithFormat:@"%d",type] forKey:@"cancelstate"];
                    [array replaceObjectAtIndex:i withObject:dicy];
                    break;
                }
            }
            
            [self handelDaySchedule:array];
            [self makeToast:@"修改成功"];
            [DejalBezelActivityView removeViewAnimated:YES];
        }else if(request.tag == 5){//设置为默认日期
            //更新数据
            self.cancelPermission = result[@"cancelpermission"];
            self.nowHour = [result[@"hour"] description];
            self.calenderArray = [NSMutableArray arrayWithArray:result[@"datelist"]];
            
            [self handelCalender];//整理数据
            
            [self updateSelectTimeDesc];
            //处理选中日期的数据
            [self handelSelectDateDetail];
            if (self.calenderArray.count > 0){
                [self.mainTableView reloadData];
                [self showTableFooterView];
                [self showTableHeaderView];
            }
            
            [self handelCalender];//整理数据
            [self makeToast:@"设置默认日期成功"];
            needSetDefault = NO;
            [DejalBezelActivityView removeViewAnimated:YES];
        }else{//获取数据
            self.cancelPermission = result[@"cancelpermission"];
            self.nowHour = [result[@"hour"] description];
            self.calenderArray = [NSMutableArray arrayWithArray:result[@"datelist"]];
            
            if (isUpdateDate) {
                self.nowDate = [CommonUtil getDateForString:result[@"today"] format:@"yyyy-MM-dd 00:00:00"];
                self.startTime = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
                self.dateLabel.text = [CommonUtil getStringForDate:self.nowDate format:@"yyyy年M月"];
                if (self.nowDate == nil) {
                    self.nowDate = [NSDate date];
                }
                self.selectDate = self.nowDate;
                maxdays = [result[@"maxdays"] intValue];
                self.endDate = [CommonUtil addDate2:self.nowDate year:0 month:0 day:maxdays];
                
                isUpdateDate = NO;
                [self compareBeforeDate:self.selectDate nowDate:self.nowDate];
            }
            
            [self handelCalender];//整理数据
            
            [self updateSelectTimeDesc];
            //处理选中日期的数据
            [self handelSelectDateDetail];
            if (self.calenderArray.count > 0){
                [self.mainTableView reloadData];
                [self showTableFooterView];
                [self showTableHeaderView];
            }
            
            //滑动TabelView
            if(!self.openBtn.selected){
//                [self clickForOpenClose:self.openBtn];
                int weekHeight = ceil(SCREEN_WIDTH / 7);
                NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
                NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
                [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 2.3)*weekHeight) animated:YES];
            }
            
            [DejalBezelActivityView removeViewAnimated:YES];
        }
        
        
    } else if([code intValue] == 95) {
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
    }else if([code intValue] == 5){
        //没有默认地址
        [DejalBezelActivityView removeViewAnimated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请您先去设置默认学车地址,您必须有一个默认的学车地址,学员才能预定您的课程" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    }else {
        [DejalBezelActivityView removeViewAnimated:YES];
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        
        [self makeToast:message];
    }
    
    [self getDataFinish];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
    [self getDataFinish];
    
    if(request.tag == 0){
        needRefresh = YES;
    }
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //跳转至地址列表画面
    SetAddrViewController *nextViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - private
//整理数据
- (void)handelCalender{
    NSArray *array = [NSArray arrayWithArray:self.calenderArray];
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        NSString *date1 = dic1[@"date"];
        NSString *date2 = dic2[@"date"];
        return [date1 compare:date2];
    }];
    
    
    NSString *date = @"";
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *calenderArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSDictionary *dic = [sortArray objectAtIndex:i];
        NSString *arrayDate = dic[@"date"];
        
        if (i == 0) {
            date = arrayDate;
        }
        
        if ([date isEqualToString:arrayDate]) {
            //相同日期
            [dataArray addObject:dic];
        }else{
            //不同日期
            NSMutableDictionary *dateDic = [self.calenderDic objectForKey:date];
            if (dateDic == nil) {
                dateDic = [NSMutableDictionary dictionary];
            }
            [dateDic setObject:date forKey:@"date"];
            [dateDic setObject:[NSArray arrayWithArray:dataArray] forKey:@"list"];
            
            //设置每一行的状态
            if ([CommonUtil isEmpty:dateDic[@"row0"]]) {
                [dateDic setObject:@"0" forKey:@"row0"];//上午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row1"]]) {
                [dateDic setObject:@"0" forKey:@"row1"];//下午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row2"]]) {
                [dateDic setObject:@"0" forKey:@"row2"];//晚上状态 0:关闭 1：打开
            }
            
            [calenderArray addObject:dateDic];
            [self.calenderDic setObject:dateDic forKey:date];
            
            [dataArray removeAllObjects];
            date = arrayDate;
            [dataArray addObject:dic];
        }
        
        if (i == sortArray.count - 1) {
            NSMutableDictionary *dateDic = [self.calenderDic objectForKey:date];
            if (dateDic == nil) {
                dateDic = [NSMutableDictionary dictionary];
            }
            [dateDic setObject:date forKey:@"date"];
            [dateDic setObject:[NSArray arrayWithArray:dataArray] forKey:@"list"];
            
            //设置每一行的状态
            if ([CommonUtil isEmpty:dateDic[@"row0"]]) {
                [dateDic setObject:@"0" forKey:@"row0"];//上午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row1"]]) {
                [dateDic setObject:@"0" forKey:@"row1"];//下午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row2"]]) {
                [dateDic setObject:@"0" forKey:@"row2"];//晚上状态 0:关闭 1：打开
            }
            
            
            [self.calenderDic setObject:dateDic forKey:date];
            [calenderArray addObject:dateDic];
        }
    }
    
    //判断是否是全选
    NSMutableDictionary *sortDic = [NSMutableDictionary dictionaryWithDictionary:self.calenderDic];
    NSArray *keyArray = self.calenderDic.allKeys;
    for (int i = 0; i < keyArray.count; i++) {
        NSString *date = keyArray[i];
        NSMutableDictionary *keyDic = [NSMutableDictionary dictionaryWithDictionary:[sortDic objectForKey:date]];
        NSArray *dicArray = keyDic[@"list"];
        
        NSString *state = @"0";//全天状态 0开课  1未开课
        NSString *cancelstate = @"0";//当天的订单是否可以取消 0.可以取消 1.不可以取消
        //对三个时间段进行整理
        for (int j = 0; j < 3; j++) {
            //获取对应时间段的选中状态
            NSString *key = [NSString stringWithFormat:@"selectState%d", j];
            NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[keyDic objectForKey:key]];
            
            NSMutableArray *selectArray = [NSMutableArray array];//选中的时间点集合
            NSMutableArray *restArray = [NSMutableArray array];//未开课的时间点集合
            NSMutableArray *bookArray = [NSMutableArray array];//已经预约时间点集合
            for (NSDictionary *timeDic in dicArray) {
                int hour = [timeDic[@"hour"] intValue];
                NSString *isrest = [timeDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
                NSString *hasbooked = [timeDic[@"hasbooked"] description];//时间点是否已经被预约 0未被预约 1已经被预约
                
                if (hour > 0 && hour < 25){
                    if (hour < 12) {
                        if (j != 0) {
                            continue;
                        }
                        NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
                        NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                        
                        if ([isrest intValue] == 1) {
                            //未开课
                            [restArray addObject:str];
                        }else{
//                            [selectArray addObject:str];//工作
                        }
                        
                        if ([hasbooked intValue] == 1) {
                            //已经预约
                            [bookArray addObject:str];
                        }else{
                            NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
                           
                            //移除当前时间之前的日期
                            if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
                                //大于当天
                                [selectArray addObject:str];//工作,默认全选
                            }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
                                //等于当天
                                if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
                                    //现在时间大于改时间点，选中状态
                                    [selectArray addObject:str];//工作,默认全选
                                }
                                
                            }

                        }
                        //continue;//早上整理完毕
                    }else if (hour < 19){
                        if (j != 1) {
                            continue;
                        }
                        NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
                        NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                        
                        if ([isrest intValue] == 1) {
                            //未开课
                            [restArray addObject:str];
                        }else{
//                            [selectArray addObject:str];//工作
                        }
                        if ([hasbooked intValue] == 1) {
                            //已经预约
                            [bookArray addObject:str];
                        }else{
                            NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
                            
                            //移除当前时间之前的日期
                            if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
                                //大于当天
                                [selectArray addObject:str];//工作,默认全选
                            }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
                                //等于当天
                                if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
                                    //现在时间大于改时间点，选中状态
                                    [selectArray addObject:str];//工作,默认全选
                                }
                                
                            }
                        }
                    }else{
                        if (j != 2) {
                            continue;
                        }
                        NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"H"];
                        NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                        
                        if ([isrest intValue] == 1) {
                            //未开课
                            [restArray addObject:str];
                        }else{
//                            [selectArray addObject:str];//工作
                        }
                       // continue;
                        if ([hasbooked intValue] == 1) {
                            //已经预约
                            [bookArray addObject:str];
                        }else{
                            NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
                            
                            //移除当前时间之前的日期
                            if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
                                //大于当天
                                [selectArray addObject:str];//工作,默认全选
                            }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
                                //等于当天
                                if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
                                    //现在时间大于改时间点，选中状态
                                    [selectArray addObject:str];//工作,默认全选
                                }
                                
                            }
                        }
                    }
                }else{
                    //全体状态
                    NSString *str = [timeDic[@"state"] description];
                    NSString *cancelstateStr = [timeDic[@"cancelstate"] description];
//                    if ([str intValue] == 0) {
//                        continue;
//                    }
                    state = [CommonUtil isEmpty:str]?@"":str;
                    cancelstate = [CommonUtil isEmpty:cancelstateStr]?@"":cancelstateStr;
//                    break;
                }
                
            }
            
            //将值保存下来
            [selectDic setObject:selectArray forKey:@"selectArray"];
            [selectDic setObject:restArray forKey:@"restArray"];
            [selectDic setObject:bookArray forKey:@"bookArray"];
            
            //判断是否全选
            NSString *allSelect = @"1";
            
            if ((j == 0 && selectArray.count == 7)
                || (j == 1 && selectArray.count == 7)
                || (j == 2 && selectArray.count == 5)) {
                //全选
                allSelect = @"0";
            }
            [selectDic setObject:allSelect forKey:@"allSelect"];
            
            [keyDic setObject:selectDic forKey:key];//替换选中状态
            
        }
        
        [keyDic setObject:state forKey:@"state"];//全体状态
        [keyDic setObject:cancelstate forKey:@"cancelstate"];//当天的订单是否可以取消 0.可以取消 1.不可以取消
        [self.calenderDic setObject:keyDic forKey:date];//更新数据
        
    }
}

//保存修改后的日程
- (void)saveChangeSchedule{
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    
    int index = -1;
    for (int i = 0; i < self.calenderArray.count; i++) {
        NSDictionary *calenderDic = [self.calenderArray objectAtIndex:i];
        NSString *date = calenderDic[@"date"];//日期
        
        if ([chooseTime isEqualToString:date]) {
            //已经包含了该日程
            index = i;
            break;
        }
        
    }
    
    if(index == -1 || index > self.calenderArray.count){
        //不包含该日程，插入
        NSMutableDictionary *calenderDic = [NSMutableDictionary dictionary];
        [calenderDic setObject:chooseTime forKey:@"date"];
        
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        NSString *time = @"";
        for (int j = 0; j < 3; j++) {
            NSString *key = [NSString stringWithFormat:@"selectState%d", j];
            NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
            
            //获取该行选中的时间
            NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restTime"]];//选择的日期
            
            for (NSString *str in array) {
                //格式转换
                NSDate *date = [CommonUtil getDateForString:str format:@"H:mm"];
                NSString *dateStr = [CommonUtil getStringForDate:date format:@"H"];
                
                if ([CommonUtil isEmpty:time]) {
                    time = dateStr;
                }else{
                    time = [NSString stringWithFormat:@"%@,%@", time, dateStr];
                }
                
            }
            
        }
        
        [calenderDic setObject:time forKey:@"resttimes"];//未开课时间
        [calenderDic setObject:dic[@"state"] forKey:@"state"];
        [self.calenderArray addObject:calenderDic];
    }else{
        //已经包含了该日程，替换
        NSMutableDictionary *calenderDic = [NSMutableDictionary dictionary];
        [calenderDic setObject:chooseTime forKey:@"date"];
        
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        NSString *time = @"";
        for (int j = 0; j < 3; j++) {
            NSString *key = [NSString stringWithFormat:@"selectState%d", j];
            NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
            
            //获取该行选中的时间
            NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restTime"]];//选择的日期
            
            for (NSString *str in array) {
                //格式转换
                NSDate *date = [CommonUtil getDateForString:str format:@"H:mm"];
                NSString *dateStr = [CommonUtil getStringForDate:date format:@"H"];
                
                if ([CommonUtil isEmpty:time]) {
                    time = dateStr;
                }else{
                    time = [NSString stringWithFormat:@"%@,%@", time, dateStr];
                }
                
            }
            
        }
        
        [calenderDic setObject:time forKey:@"resttimes"];//未开课时间
        [calenderDic setObject:dic[@"state"] forKey:@"state"];
        [self.calenderArray insertObject:calenderDic atIndex:index];
    }
    
}

//处理选中日期的数据
- (void)handelSelectDateDetail{
    [self updateSelectTimeDesc];
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }

    
    //设置工作时间
    BOOL hasDate = NO;
    int index = -1;
    for (int i = 0; i < self.calenderArray.count; i++) {
        NSDictionary *calenderDic = [self.calenderArray objectAtIndex:i];
        NSString *date = calenderDic[@"date"];//日期
        
        if ([chooseTime isEqualToString:date]) {
            hasDate = YES;
            index = i;
            break;
        }
    }
}


//更新当天数据
- (void)handelDaySchedule:(NSArray *)dateArray{
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    [dic setObject:dateArray forKey:@"list"];
    
    NSString *state = @"0";//全天状态 0开课  1未开课
    NSString *cancelstate = @"0";//当天的订单是否可以取消 0.可以取消 1.不可以取消
    for (int j = 0; j < 3; j++) {
        //获取对应时间段的选中状态
        NSString *key = [NSString stringWithFormat:@"selectState%d", j];
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
        
        NSMutableArray *selectArray = [NSMutableArray arrayWithArray:selectDic[@"selectArray"]];//选中的时间点集合
        NSMutableArray *restArray = [NSMutableArray array];//未开课的时间点集合
        NSMutableArray *bookArray = [NSMutableArray array];//已经预约时间点集合
        for (NSDictionary *timeDic in dateArray) {
            int hour = [timeDic[@"hour"] intValue];
            NSString *isrest = [timeDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
            NSString *hasbooked = [timeDic[@"hasbooked"] description];//时间点是否已经被预约 0未被预约 1已经被预约
            
            if (hour > 0 && hour < 25){
                if (hour < 12) {
                    if (j != 0) {
                        continue;
                    }
                    NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
                    NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                    
                    if ([isrest intValue] == 1) {
                        //未开课
                        [restArray addObject:str];
                    }else{
                        //                            [selectArray addObject:str];//工作
                    }
                    
                    if ([hasbooked intValue] == 1) {
                        //已经预约
                        [bookArray addObject:str];
                    }else{
//                        NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
//                        
//                        //移除当前时间之前的日期
//                        if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
//                            //大于当天
//                            [selectArray addObject:str];//工作,默认全选
//                        }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
//                            //等于当天
//                            if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
//                                //现在时间大于改时间点，选中状态
//                                [selectArray addObject:str];//工作,默认全选
//                            }
//                            
//                        }
                        
                    }
                    
                }else if (hour < 19){
                    if (j != 1) {
                        continue;
                    }
                    NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
                    NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                    
                    if ([isrest intValue] == 1) {
                        //未开课
                        [restArray addObject:str];
                    }else{
                        //                            [selectArray addObject:str];//工作
                    }
                    
                    if ([hasbooked intValue] == 1) {
                        //已经预约
                        [bookArray addObject:str];
                    }else{
//                        NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
//                        
//                        //移除当前时间之前的日期
//                        if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
//                            //大于当天
//                            [selectArray addObject:str];//工作,默认全选
//                        }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
//                            //等于当天
//                            if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
//                                //现在时间大于改时间点，选中状态
//                                [selectArray addObject:str];//工作,默认全选
//                            }
//                            
//                        }
                        
                    }
                }else{
                    if (j != 2) {
                        continue;
                    }
                    NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"H"];
                    NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                    
                    if ([isrest intValue] == 1) {
                        //未开课
                        [restArray addObject:str];
                    }else{
                        //                            [selectArray addObject:str];//工作
                    }
                    // continue;
                    if ([hasbooked intValue] == 1) {
                        //已经预约
                        [bookArray addObject:str];
                    }else{
//                        NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
//                        
//                        //移除当前时间之前的日期
//                        if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
//                            //大于当天
//                            [selectArray addObject:str];//工作,默认全选
//                        }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
//                            //等于当天
//                            if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
//                                //现在时间大于改时间点，选中状态
//                                [selectArray addObject:str];//工作,默认全选
//                            }
//                            
//                        }
                        
                    }
                }
            }else{
                //全体状态
                NSString *str = [timeDic[@"state"] description];
                NSString *cancelstateStr = [timeDic[@"cancelstate"] description];

                state = [CommonUtil isEmpty:str]?@"":str;
                cancelstate = [CommonUtil isEmpty:cancelstateStr]?@"":cancelstateStr;
            }
            
        }
        
        //将值保存下来
        [selectDic setObject:selectArray forKey:@"selectArray"];
        [selectDic setObject:restArray forKey:@"restArray"];
        
        //判断是否全选
        NSString *allSelect = @"1";
        
        if ((j == 0 && selectArray.count == 7)
            || (j == 1 && selectArray.count == 7)
            || (j == 2 && selectArray.count == 5)) {
            //全选
            allSelect = @"0";
        }
        [selectDic setObject:allSelect forKey:@"allSelect"];
        
        [dic setObject:selectDic forKey:key];//替换选中状态
        
        
    }
    
    [dic setObject:state forKey:@"state"];//全体状态
    [dic setObject:cancelstate forKey:@"cancelstate"];//全体状态
    
    [self.calenderDic setObject:dic forKey:chooseTime];
    [self.mainTableView reloadData];
    [self showTableFooterView];
}

- (NSMutableArray *)getPointNum:(NSString *)day{
    NSMutableArray *pointArray = [NSMutableArray array];
    
    NSDictionary *dic = [self.calenderDic objectForKey:day];
    if (dic == nil) {
        dic = [NSDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    NSString *state = dic[@"state"];//全天状态 0开课  1未开课
    
    if ([state intValue] == 1) {
        //不未开课,判断上课状态
        BOOL hasMorning = NO;
        BOOL hasAfternoon = NO;
        BOOL hasEvening = NO;
        
        //没有数据，默认开课
        if (array == nil) {
            hasMorning = YES;
            hasAfternoon = YES;
            hasEvening = YES;
        }
        
        //有数据，开始判断
        for (NSDictionary *arrDic in array) {
            NSString *hour = [arrDic[@"hour"] description];
            NSString *isRest = [arrDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
            if ([hour integerValue] > 0 && [hour integerValue] < 25) {
                if ([hour intValue] < 12) {
                    //早上有上课时间
                    if ([isRest intValue] == 0) {
                        //上课
                        hasMorning = YES;
                    }
                }else if ([hour intValue] < 19){
                    //中午有上课时间
                    if ([isRest intValue] == 0) {
                        //上课
                        hasAfternoon = YES;
                    }
                }else{
                    //晚上有上课时间
                    if ([isRest intValue] == 0) {
                        //上课
                        hasEvening = YES;
                    }
                }
            }
        }
        
        if (hasMorning) {
            [pointArray addObject:@"morning"];
            
        }
        
        if (hasAfternoon) {
            [pointArray addObject:@"afternoon"];
            
        }
        
        if (hasEvening) {
            [pointArray addObject:@"evening"];
        }
        
    }
    
    return pointArray;
}

/** 显示日期按钮
 * @param weekWidth     一个日期的宽高
 * @param dayStr        日期-天
 * @param beginDate     该按钮的日期（NSDate类型）
 * @param status        该天的状态 0开课  1未开课
 * @param index         该天在calenderList里面的下标位置
 * @param lastDate      月末
 * @param firstDate     月初
 * @param month 当前日期所属的月份
 **/
- (UIView *)showDateButtonView:(NSInteger)weekWidth dayStr:(NSString *)dayStr
                     beginDate:(NSDate *)beginDate status:(NSInteger)status index:(int)index
                      lastDate:(NSDate *)lastDate firstDate:(NSDate *)firstDate month:(NSInteger) month{
    NSMutableArray *pointArray = [self getPointNum:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"]];//点点的数量
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(34, 34, 34);
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 0.5f;
    
    DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, 5, weekWidth - 10, weekWidth - 10);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.date = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
    button.titleLabel.numberOfLines = 2;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
    [view addSubview:button];
    
    //设置该日期在list的位置
    button.index = [NSString stringWithFormat:@"%d", index];
    
    //获取最后一天的日期
    if ([beginDate compare:lastDate] == NSOrderedDescending || [beginDate compare:firstDate] == NSOrderedAscending
        || [beginDate compare:self.nowDate] == NSOrderedAscending || [beginDate compare:self.endDate] == NSOrderedDescending) {
        //不可点击, beginDate大于月末, beginDate小于月初、开始时间,小于今日
        int selectMonth = [CommonUtil getMonthOfDate:self.selectDate];
        if(selectMonth == month){
            [button setTitle:dayStr forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;//不可点击
            [button setTitleColor:RGB(104, 104, 104) forState:UIControlStateNormal];
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 22, weekWidth, 22)];
            label.text = @"不可操作";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = RGB(104, 104, 104);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }else{
            [button setTitle:@"" forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;//不可点击
            [button setTitleColor:RGB(104, 104, 104) forState:UIControlStateNormal];
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 22, weekWidth, 22)];
            label.text = @"";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = RGB(104, 104, 104);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
        
    }else if ([beginDate compare:self.nowDate] == NSOrderedSame){
        //今天
        [button addTarget:self action:@selector(clickForDetail:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:dayStr forState:UIControlStateNormal];
        [button setTitleColor:RGB(34, 192, 100) forState:UIControlStateNormal];
        
        //文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 22, weekWidth, 22)];
        label.text = @"今日";
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = RGB(34, 192, 100);
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        if ([beginDate compare:self.selectDate] == NSOrderedSame ) {
            //该日期是选中的日期
            [button setTitleColor:RGB(28, 28, 28) forState:UIControlStateNormal];
            label.textColor = RGB(28, 28, 28);
            view.backgroundColor = [UIColor whiteColor];
        }
        
    }else{
        //beginDate 在这个月内
        //添加点击
        [button addTarget:self action:@selector(clickForDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        //显示按钮下方点
        if (status == 0 || pointArray.count == 0){
            //未开课
            [button setTitle:dayStr forState:UIControlStateNormal];
            [button setTitleColor:RGB(104, 104, 104) forState:UIControlStateNormal];
            
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 22, weekWidth, 22)];
            label.text = @"未开课";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = RGB(104, 104, 104);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            if ([beginDate compare:self.selectDate] == NSOrderedSame ) {
                //该日期是选中的日期
                label.textColor = RGB(28, 28, 28);
            }
        }else{
            //正常工作
            [button setTitle:dayStr forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
            NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
            if (dic == nil) {
                dic = [NSDictionary dictionary];
            }
            
            CGFloat x = (weekWidth - pointArray.count*4 - (pointArray.count - 1)*3)/2;
            
            for (int i = 0; i < pointArray.count; i++) {
                UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(x + 4*i + 3*i, 34, 4, 4)];
                
                pointView.layer.cornerRadius = 2;
                pointView.layer.masksToBounds = YES;
                [view addSubview:pointView];
                
                NSString *str = pointArray[i];
                
                if ([@"morning" isEqualToString:str]) {
                    pointView.backgroundColor = RGB(247, 148, 29);
                }else if ([@"afternoon" isEqualToString:str]){
                    pointView.backgroundColor = RGB(224, 72, 62);
                }else{
                    pointView.backgroundColor = RGB(19, 82, 226);
                }
            }
        }
        
        if ([beginDate compare:self.selectDate] == NSOrderedSame) {
            //该日期是选中的日期
            [button setTitleColor:RGB(28, 28, 28) forState:UIControlStateNormal];
            view.backgroundColor = [UIColor whiteColor];
            
        }
    }
    return view;
}

- (IBAction)clickForDefaultAlert:(id)sender {
    NSInteger tag = ((UIButton*)sender).tag;
    if(tag == 0){//设置默认
        [self clickForStart:nil];
        if(self.setDefaultButton.selected){
            needSetDefault = YES;
            self.setDefaultButton.selected = NO;
        }
    }
    
    [self.defaultAlertView removeFromSuperview];
}


- (IBAction)clickForSetDefaultCheck:(id)sender {
    UIButton *button = (UIButton*)sender;
    if(button.isSelected){
        button.selected = NO;
    }else{
        button.selected = YES;
    }
}

- (void) setTodayDefault{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kScheduleServlet]];
    request.tag = 5;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"SetDefault" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"] forKey:@"day"];
    [request startAsynchronous];
}
@end

