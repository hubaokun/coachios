//
//  MyMessageViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyMessageViewController.h"
#import "MyMessageCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "LoginViewController.h"

@interface MyMessageViewController () <UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    NSMutableArray *dataArr; //容器
    NSMutableArray *contentArr; //存放内容
    NSInteger currentCell; //当前cell行数
    NSInteger currentPage; //当前页数
    NSInteger currentIndexPage; //检索页数
}

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *officialView;
@property (strong, nonatomic) IBOutlet UILabel *officialLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *officialHeight;

@property (copy, nonatomic) UIImage *bgbImage;     // 显示背景图片
@property (copy, nonatomic) NSString *testMessage; // 显示内容
@property (copy, nonatomic) NSString *ttime;       // 显示时间

@property (assign, nonatomic) CGFloat messageHeight;
@property (strong, nonatomic) IBOutlet UIImageView *nodataImageView;

- (IBAction)clickForCancelOfficialView:(id)sender;
@property (assign, nonatomic) int rows; // 数据行数;
@property (assign, nonatomic) int pagenum; // 数据行数;

@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArr = [[NSMutableArray alloc] init];
    contentArr = [[NSMutableArray alloc] init];
    
    // UIImageView *myimageview=[[UIImageView alloc]  initWithFrame:CGRectMake(100,100,150,150)];
    //myimageview.image=[UIImage imageNamed:@"Snow Leopard Prowl.jpg"];
    
    self.officialView.frame = [UIScreen mainScreen].bounds;
//    [self settingView];
    //self.rows = 5;
    [self getMyMessage:self.pagenum]; // 调用接口
//    [self allMessageHeight]; //获取文字高度

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)settingView {
    self.mainTableView.allowsSelection = NO;
    
    self.officialLabel.text = self.testMessage;
    CGSize textSize = [self sizeWithString:self.testMessage fontSize:26 sizewidth:(_screenWidth - 90) sizeheight:0];
    self.officialHeight.constant = textSize.height;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return self.rows;
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"MyMessageCellIdentifier";
    MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyMessageCell" bundle:nil] forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    
    
   NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
   
    // 加载数据
    cell.messageContent = [dic objectForKey:@"content"];
    cell.messageDate = [dic objectForKey:@"addtime"];
    cell.messageHeight = [contentArr[indexPath.row] floatValue];
    cell.officialBtn.tag = indexPath.row; //获取当前cell的行数
    [cell.officialBtn addTarget:self action:@selector(clickForOfficialView:) forControlEvents:UIControlEventTouchUpInside];
    [cell loadData:Nil];
    
    // 加手势
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [cell addGestureRecognizer:longPressGr];
    

    if (indexPath.row == (dataArr.count -1)) {
        [_pullToMore tableViewReloadFinished];
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73 + [contentArr[indexPath.row] floatValue];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
      if (gesture.state == UIGestureRecognizerStateBegan) {
       //if (gesture.state == UIGestureRecognizerStateEnded) {
           NSLog(@"1-------");
           CGPoint point = [gesture locationInView:self.mainTableView];
           NSIndexPath * indexPath = [self.mainTableView indexPathForRowAtPoint:point];
           if(indexPath == nil) return ;
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除此消息？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
           currentCell = indexPath.row;
           
           [alertView show];
       }
}

// 监听弹话框点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //NSLog(@"view-----%li",currentCell);
        NSDictionary *dict = [dataArr objectAtIndex:currentCell];
        NSString *noticeid = [dict objectForKey:@"noticeid"];
         //[dataArr removeObjectAtIndex:currentCell];
        [self DeleteNotification:noticeid];
//        if(dataArr.count == 0)
//        {
//            [self.mainTableView reloadData];
//            [self getMyMessage:0];
//        }else{
//            [self getContent];
//            [self.mainTableView reloadData];
//        }
//
    }
}


// 获取输入文本
- (void)getContent{
    [contentArr removeAllObjects];
    for(int n=0;n<dataArr.count;n++)
    {
        NSDictionary *dict = [dataArr objectAtIndex:n];
        NSString *content = [dict objectForKey:@"content"];
        CGSize textSize = [self sizeWithString:content fontSize:17 sizewidth:(_screenWidth - 112) sizeheight:0];
        [contentArr addObject:[NSString stringWithFormat:@"%f",textSize.height]];
    }
}

// 计算文本高度
- (void)allMessageHeight {
    NSString *messageContent = self.testMessage;
    CGSize textSize = [self sizeWithString:messageContent fontSize:17 sizewidth:(_screenWidth - 112) sizeheight:0];
    self.messageHeight = textSize.height;
    //int a = textSize.height;
}



#pragma mark - 请求接口
// 刷新数据
- (void)getFreshData {
    self.pagenum = 0;
    [self getMyMessage:self.pagenum]; // 调用接口
    [_pullToRefresh tableViewReloadFinishedAnimated:YES];
    currentPage = 0;
}

// 加载数据
- (void)getMoreData {
   // self.pagenum += 1;
    currentIndexPage = currentPage + 1;
    self.pagenum = (int)currentIndexPage;
    
    [self getMyMessage:self.pagenum]; // 调用接口
    //    [_pullToMore tableViewReloadFinished];
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
    [self getFreshData];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    
    [self getMoreData];
}

// 根据文字，字号及固定宽(固定高)来计算高(宽)

- (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height
{
    
    
    // 用何种字体显示
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    
    CGSize expectedLabelSize = CGSizeZero;
    if(![CommonUtil isEmpty:text]){
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            paragraphStyle.alignment=NSTextAlignmentLeft;
            
            NSAttributedString *attributeText=[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
            CGSize labelsize = [attributeText boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            expectedLabelSize = CGSizeMake(ceilf(labelsize.width),ceilf(labelsize.height));
        } else {
            expectedLabelSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByCharWrapping];
        }
    }
    
    // 计算出显示完内容的最小尺寸
    
    return expectedLabelSize;
}

#pragma mark - 按钮方法

// 显示内容信息
- (void)clickForOfficialView:(UIButton *)sender {
    NSDictionary *dict = [dataArr objectAtIndex:sender.tag];
    self.officialLabel.text = [dict objectForKey:@"content"];
    [self.view addSubview:self.officialView];
    [self readNotification:dict];
}

// 关闭显示内容信息
- (IBAction)clickForCancelOfficialView:(id)sender {
    [self.officialView removeFromSuperview];
}

#pragma mark - 获取通知消息接口
- (void)getMyMessage:(int) pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetNotices" forKey:@"action"];
    request.tag = 0;
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];  // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%i", pageNum] forKey:@"pagenum"];  // 当前获取的页数,从零开始
    [request startAsynchronous];
    //[DejalBezelActivityView activityViewForView:self.view];
}

#pragma mark - 删除通知接口
- (void)DeleteNotification:(NSString *)noticeId{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"DelNotice" forKey:@"action"];
    request.tag = 1;
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];  // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:noticeId forKey:@"noticeid"];  // 删除通知ID
    
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

#pragma mark - 已读通知接口
- (void)readNotification:(NSDictionary *)dic{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ReadNotice" forKey:@"action"];
    request.tag = 2;
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];  // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:dic[@"noticeid"] forKey:@"noticeid"];  // 删除通知ID
    
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    NSInteger hasmore = [[result objectForKey:@"hasmore"] integerValue];
    // NSLog(@"a------");
    // 取得数据成功
    if ([code intValue] == 1) {
        // 判断是删除通知接口还是接收通知接口
        if(request.tag == 0){
                // 取出成长档案动态List
           NSArray *arr = [result objectForKey:@"datalist"];
        
           // 判断数组内容个数是否为零
           if(arr.count == 0){
              self.nodataImageView.hidden = NO;
               [self.pullToMore setPullToMoreViewVisible:NO];
           }else{
             self.nodataImageView.hidden = YES;
               [self.pullToMore setPullToMoreViewVisible:YES];
               // 判断是否要显示上拉加载
              if(self.pagenum == 0)
              {
                [dataArr removeAllObjects];
                [dataArr addObjectsFromArray:arr];
                [self getContent];
                [self.mainTableView reloadData];
                //if(dataArr.count < 10)
                if(hasmore == 0)
                {
                    [self.pullToMore setPullToMoreViewVisible:NO];
                }else{
                    [self.pullToMore setPullToMoreViewVisible:YES];
                }
                
            }else
              {
                [dataArr addObjectsFromArray:arr];
                [self getContent];
                [self.mainTableView reloadData];
                  if(dataArr.count % 10 == 0){
                      currentPage = (dataArr.count - 1) / 10;
                  }else{
                      currentPage = dataArr.count / 10;
                  }
               if(hasmore == 0)
                {
                    [self.pullToMore setPullToMoreViewVisible:NO ];
                }else{
                    [self.pullToMore setPullToMoreViewVisible:YES];
                }
            }
           }
        }else if(request.tag == 1){
            [dataArr removeObjectAtIndex:currentCell];
            //NSLog(@"+++---");
            // 判断消息为空时显示其他
            if(dataArr.count == 0)
            {
                [self.mainTableView reloadData];
                [self getMyMessage:0];
            }else{
                [self getContent];
                [self.mainTableView reloadData];
            }
        }
    
        
    }else if([code intValue] == 95){
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
        self.nodataImageView.hidden = NO;
        [self makeToast:message];
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
    self.nodataImageView.hidden = NO;
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end

