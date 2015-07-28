//
//  MyComplainViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/18.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyComplainViewController.h"
#import "MyComplainCell.h"
#import "ComplainMeCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "TQStarRatingView.h"
#import "LoginViewController.h"

@interface MyComplainViewController () <UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    NSMutableArray *myDataArr; // 我的投诉容器
    //NSMutableArray *myDataArr; // 投诉我的容器
    NSMutableDictionary *myComplainDic; // 存放每条我的投诉内容高度
    NSMutableDictionary *complainMyDic; // 存放每条投诉我的内容高度
    TQStarRatingView *ratingView;
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UIView *selectBarView;
@property (strong, nonatomic) IBOutlet UIButton *myComplainBtn;         // 我的投诉按钮属性
@property (strong, nonatomic) IBOutlet UIButton *ComplainMeBtn;         // 投诉我的按钮属性
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *studentInfoView;
@property (strong, nonatomic) IBOutlet UIImageView *nodataImageView;      // 无内容时显示的背景图片

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;               // 评分显示
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;               // 学员联系电话
@property (strong, nonatomic) IBOutlet UILabel *studentidLabel;           // 学员证号
@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView; // 学员头像
@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel; // 学员名字
@property (strong, nonatomic) IBOutlet UIView *starView; //显示星级
@property (strong, nonatomic) IBOutlet UIButton *callPhoneBtnOutlet;

- (IBAction)clickForMyComplain:(id)sender;
- (IBAction)clickForComplainMe:(id)sender;
- (IBAction)clickForCancelInfoView:(id)sender;
- (IBAction)callPhoneBtn:(id)sender;

@property (assign, nonatomic) int rows;    // 数据行数;
@property (assign, nonatomic) int pagenum; // 数据页数
@property (copy, nonatomic) NSString *phoneNum;

@end

@implementation MyComplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    myDataArr = [[NSMutableArray alloc] init];
    myDataArr = [[NSMutableArray alloc] init];
    myComplainDic = [[NSMutableDictionary alloc] init];
    complainMyDic = [[NSMutableDictionary alloc] init];
    
    ratingView = [[TQStarRatingView alloc] initWithFrame:self.starView.bounds numberOfStar:5];
    ratingView.couldClick = NO;//不可点击
    [ratingView changeStarForegroundViewWithPoint:CGPointMake(0/5*CGRectGetWidth(self.starView.frame), 0)];//设置星级
    [self.starView addSubview:ratingView];
    
    self.phoneNum = @"12345678912";
    
    // 初始化
    //self.rows = 5;
    [self settingView];
    // 调用我的投诉接口
    //[self getMyComplaint:self.pagenum];
    // 调用投诉我的
    self.complainType = 1;
    [self getComplaintToMy:self.pagenum];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
//    [self.pullToMore setPullToMoreViewVisible:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingView {
    self.mainTableView.allowsSelection = NO;
    self.studentInfoView.frame = [UIScreen mainScreen].bounds;
    
    // 设置圆角
    self.selectBarView.layer.cornerRadius = 13;
    
    self.myComplainBtn.selected = YES;
    self.ComplainMeBtn.selected = NO;
    
    [self.myComplainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.myComplainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.ComplainMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.ComplainMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.myComplainBtn setBackgroundColor:[UIColor blackColor]];
    [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
}

// 对头像裁剪成六边形
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

#pragma mark - tableView
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.complainType == 0){
//        if ([cell isKindOfClass:[MyComplainCell class]]){
//        MyComplainCell *myCCell = (MyComplainCell *)cell;
//        [self updateLogoImage:myCCell.studentIconImageView];
//        }
//    }else{
//        if ([cell isKindOfClass:[ComplainMeCell class]]){
//            ComplainMeCell *myCCell = (ComplainMeCell *)cell;
//            [self updateLogoImage:myCCell.studentIconImageView];
//        }
//    }
//    
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // return self.rows;
//    if(self.complainType == 0){
//        return myDataArr.count;
//    }else{
//        return myDataArr.count;
//    }
    return myDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 我的投诉
    if (self.complainType == 0) {
        static NSString *ID = @"MyComplainCellIdentifier";
        MyComplainCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"MyComplainCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 动态清除子控件
        while (cell.depositView.subviews.count) {
            UIView* child = cell.depositView.subviews.lastObject;
            [child removeFromSuperview];
        }
        if(myDataArr == nil){
            return 0;
        }
        NSDictionary *dict = [myDataArr objectAtIndex:indexPath.row];
        //int indexp = indexPath.row;
        NSArray *contentArr = [dict objectForKey:@"contentlist"];
        if(contentArr.count == 0)
        {
            cell.hasDealedWith = 0;
            cell.complainContent = @"--";
            cell.complainBecauseLenght = 0;
            cell.clheight = 0;
        }else{
            cell.contentHgtDic = myComplainDic;
            int cHeight = 0;
            cell.hasDealedWith = 1;
            for(int i = 0; i<contentArr.count; i++)
            {
                for(int a = 0; a<contentArr.count; a++){
                    NSDictionary *dic = [contentArr objectAtIndex:a];
                    NSString *type1 = [[dic objectForKey:@"state"] description];  // 投诉状态是否处理 0未处理  1处理
                    NSString *type2 = @"0";
                    if([type1 isEqualToString:type2]){
                        cell.hasDealedWith = 0;
                    }
                    
                }
                if(i == 0){
                    NSDictionary *dic = [contentArr objectAtIndex:i];
                    cell.type2 = [[dic objectForKey:@"state"] intValue];  // 投诉状态是否处理 0未处理  1处理
                    NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
                    NSString *strt;
                    if(![CommonUtil isEmpty:strBecause])
                    {
                        strt  = [NSString stringWithFormat:@"#%@#",strBecause];
                    }else{
                        strt = @"";
                    }
                    cell.complainBecauseLenght = strt.length;
                    NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
                    cell.complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent] ;
                }
                else{
                    
                    NSArray * chArr = [myComplainDic objectForKey:[NSString stringWithFormat:@"%i",indexPath.row]];
                    cHeight += [chArr[i] intValue];
                    UILabel *contentLabel = [[UILabel alloc] init];
                    //contentLabel.frame = CGRectMake(62, 38 + [chArr[i-1] intValue], 235, [chArr[i] intValue]);
                    contentLabel.frame = CGRectMake(0, cHeight - [chArr[i] intValue], 235, [chArr[i] intValue]);
                    
                    NSDictionary *dic = [contentArr objectAtIndex:i];
                    NSInteger ty  = [[dic objectForKey:@"state"] intValue];
                    
                    NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
                    NSString *strt;
                    if(![CommonUtil isEmpty:strBecause])
                    {
                        strt  = [NSString stringWithFormat:@"#%@#",strBecause];
                    }else{
                        strt = @"";
                    }
                    NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
                    NSString *complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent];
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:complainContent];
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(33, 180, 120) range:NSMakeRange(0,strt.length)];
                    contentLabel.attributedText = str;
                    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;//实现文字多行显示
                    contentLabel.numberOfLines = 0;
                    if(ty == 1 || ty == 2)
                    {
                        contentLabel.textColor = RGB(210, 210, 210);
                    }
                    //[cell.contentView addSubview:contentLabel];
                    [cell.depositView addSubview:contentLabel];
                }
                cell.clheight = cHeight;
            }

        }
        NSString *str = [dict objectForKey:@"starttime"];
        NSString *str1 = [dict objectForKey:@"endtime"];
        NSString *dataTime =[NSString stringWithFormat:@"%@~%@",[str substringToIndex:16],[str1 substringWithRange:NSMakeRange(11, 5)]];
        cell.complainData = dataTime;                                 // 任务时间段
        cell.studentName = [dict objectForKey:@"name"];               // 学员名字
        cell.studentIcon = [dict objectForKey:@"studentavatar"];      // 学员头像
        //cell.complainContent = @"#迟到#该学员迟到很多次了，今天迟到了近1个小时...";
        cell.studentInfoBtn.tag = indexPath.row;
        [cell.studentInfoBtn addTarget:self action:@selector(myClickForStudentInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell loadData:nil];
        
        if (indexPath.row == (myDataArr.count -1)) {
            [_pullToMore tableViewReloadFinished];
        }
        return cell;
    }
    
    // 投诉我的
    else {
        static NSString *ID = @"ComplainMeCellIdentifier";
        ComplainMeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"ComplainMeCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 动态清除子控件
        while (cell.depositView.subviews.count) {
            UIView* child = cell.depositView.subviews.lastObject;
            [child removeFromSuperview];
        }
        if(myDataArr == nil){
            return 0;
        }
        NSDictionary *dict = [myDataArr objectAtIndex:indexPath.row];
        NSArray *contentArr = [dict objectForKey:@"contentlist"];
        if(contentArr.count == 0)
        {
            cell.hasDealedWith = 0;
            cell.complainContent = @"--";
            cell.complainBecauseLenght = 0;
            cell.clheight = 0;
        }else{
            int cHeight = 0;
            cell.hasDealedWith = 1;
            for(int i = 0; i<contentArr.count; i++)
            {
                for(int a = 0; a<contentArr.count; a++){
                    NSDictionary *dic = [contentArr objectAtIndex:a];
                    NSString *type1 = [[dic objectForKey:@"state"] description];  // 投诉状态是否处理 0未处理  1处理
                    NSString *type2 = @"0";
                    if([type1 isEqualToString:type2]){
                        cell.hasDealedWith = 0;
                    }
                }
                if(i == 0){
                    NSDictionary *dic = [contentArr objectAtIndex:i];
                    cell.type2 = [[dic objectForKey:@"state"] intValue];  // 投诉状态是否处理 0未处理  1处理
                    NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
                    NSString *strt;
                    if(![CommonUtil isEmpty:strBecause])
                    {
                        strt  = [NSString stringWithFormat:@"#%@#",strBecause];
                    }else{
                        strt = @"";
                    }
                    cell.complainBecauseLenght = strt.length;
                    NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
                    cell.complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent] ;
                }
                else{
                    NSArray * chArr = [complainMyDic objectForKey:[NSString stringWithFormat:@"%i",indexPath.row]];
                    cHeight += [chArr[i] intValue];
                    UILabel *contentLabel = [[UILabel alloc] init];
                    //contentLabel.frame = CGRectMake(62, 38 + [chArr[i - 1] intValue], 235, [chArr[i] intValue]);
                    contentLabel.frame = CGRectMake(0, cHeight - [chArr[i] intValue], 235, [chArr[i] intValue]);
                    NSDictionary *dic = [contentArr objectAtIndex:i];
                    
                    NSInteger ty = [[dic objectForKey:@"state"] intValue];
                    NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
                    NSString *strt;
                    if(![CommonUtil isEmpty:strBecause])
                    {
                        strt  = [NSString stringWithFormat:@"#%@#",strBecause];
                    }else{
                        strt = @"";
                    }
                    NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
                    NSString *complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent];
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:complainContent];
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(33, 180, 120) range:NSMakeRange(0,strt.length)];
                    contentLabel.attributedText = str;
                    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;//实现文字多行显示
                    contentLabel.numberOfLines = 0;
                    if(ty == 1 || ty == 2)
                    {
                        contentLabel.textColor = RGB(210, 210, 210);
                    }
                    //[cell.contentView addSubview:contentLabel];
                    [cell.depositView addSubview:contentLabel];
                }
                cell.clheight = cHeight;
            }
            
        }
        NSString *str = [dict objectForKey:@"starttime"];
        NSString *str1 = [dict objectForKey:@"endtime"];
        NSString *dataTime =[NSString stringWithFormat:@"%@~%@",[str substringToIndex:16],[str1 substringWithRange:NSMakeRange(11, 5)]];
        cell.complainData = dataTime;                                 // 任务时间段
        cell.studentIcon = [dict objectForKey:@"studentavatar"];      // 学员头像
        
        //cell.complainContent = @"#服务态度差#教练教的一般般，脾气却很大，2小时有1.5小时在煲电话粥，都没怎么教，收费还很高...";
        cell.studentInfoBtn.tag = indexPath.row;
        [cell.studentInfoBtn addTarget:self action:@selector(clickForStudentMyInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell loadData:nil];
        
        if (indexPath.row == (myDataArr.count - 1)) {
            [_pullToMore tableViewReloadFinished];
        }
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.complainType == 0) {
      //  NSString *complainContent = @"#迟到#该学员迟到很多次了，今天迟到了近1个小时...";
        return [self computeContenHeight:indexPath.row];
    } else {
      // NSString *complainContent = @"#服务态度差#教练教的一般般，脾气却很大，2小时有1.5小时在煲电话粥，都没怎么教，收费还很
        return [self computeContentMyHeight:indexPath.row];
    }
}

// 计算我的投诉每个内容高度
- (int)computeContenHeight:(NSInteger)index{
    // 从字典中获取我的投诉数据
    if(myDataArr == nil){
        return 0;
    }
    NSDictionary *dict = [myDataArr objectAtIndex:index];
    NSArray *arr = [dict objectForKey:@"contentlist"];
    NSMutableArray *cArr = [[NSMutableArray alloc] init];
    int contentHeight = 0;
    for(int n = 0;n < arr.count;n++)
    {
        NSDictionary *dic = [arr objectAtIndex:n];
        NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
        NSString *strt;
        if(![CommonUtil isEmpty:strBecause])
        {
            strt  = [NSString stringWithFormat:@"#%@#",strBecause];
        }else{
            strt = @"";
        }
        NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
        NSString *complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent];
        CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:MAXFLOAT];
        int height = textSize.height;
        [cArr addObject:[NSString stringWithFormat:@"%i",height]];
        contentHeight += height;
    }
    if (contentHeight > 0) {
        contentHeight -= 24;
    }
    [myComplainDic setObject:cArr forKey:[NSString stringWithFormat:@"%li",(long)index]];
    return 240 + contentHeight;
}

// 计算投诉我的每个内容高度
- (int)computeContentMyHeight:(NSInteger)index{
    // 从字典中获取我的投诉数据
    if(myDataArr == nil){
        return 0;
    }
    NSDictionary *dict = [myDataArr objectAtIndex:index];
    NSArray *arr = [dict objectForKey:@"contentlist"];
    NSMutableArray *cArr = [[NSMutableArray alloc] init];
    int contentHeight = 0;
    for(int n = 0;n < arr.count;n++)
    {
        NSDictionary *dic = [arr objectAtIndex:n];
        NSString *strBecause = [dic objectForKey:@"set"];     // 投诉原因
        NSString *strt;
        if(![CommonUtil isEmpty:strBecause])
        {
            strt  = [NSString stringWithFormat:@"#%@#",strBecause];
        }else{
            strt = @"";
        }
        NSString *strContent = [dic objectForKey:@"content"]; // 投诉内容
        NSString *complainContent = [NSString stringWithFormat:@"%@%@",strt,strContent];
        CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:0];
        int height = textSize.height;
        [cArr addObject:[NSString stringWithFormat:@"%i",height]];
        contentHeight += height;
    }
    [complainMyDic setObject:cArr forKey:[NSString stringWithFormat:@"%i",index]];
    return 128 + contentHeight;
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
    
    // 计算出显示完内容的最小尺寸
    
    return expectedLabelSize;
}

#pragma mark - 刷新数据
- (void)getFreshData {
//    self.rows = 5;
//    [self.mainTableView reloadData];
    self.pagenum = 0;
    if(self.complainType == 0)
    {
        [self getMyComplaint:self.pagenum];
    }else{
        [self getComplaintToMy:self.pagenum];
    }
    
    [_pullToRefresh tableViewReloadFinishedAnimated:YES];
}

// 加载数据
- (void)getMoreData {
//    self.rows = self.rows + 5;
//    [self.mainTableView reloadData];
    if(self.complainType == 0){
        self.pagenum = (int)(myDataArr.count / 10);
        [self getMyComplaint:self.pagenum];
    }else{
        self.pagenum = (int)(myDataArr.count / 10);
        [self getComplaintToMy:self.pagenum];
    }
        
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

#pragma mark - 按钮方法
// 投诉我的
- (IBAction)clickForMyComplain:(id)sender {
    //self.mainTableView.scrollsToTop = YES;
    //[self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.pagenum = 0;
    self.complainType = 1;
    if (self.myComplainBtn.selected == YES) {
        return;
    } else {
        self.myComplainBtn.selected = YES;
        self.ComplainMeBtn.selected = NO;
        [self.myComplainBtn setBackgroundColor:[UIColor blackColor]];
        [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
    }
    [myDataArr removeAllObjects];
    [self getComplaintToMy:self.pagenum];
   // [self.mainTableView reloadData];
}

// 我的投诉
- (IBAction)clickForComplainMe:(id)sender {
    
    self.pagenum = 0;
    self.complainType = 0;
    if (self.ComplainMeBtn.selected == YES) {
        return;
    } else {
        self.myComplainBtn.selected = NO;
        self.ComplainMeBtn.selected = YES;
        [self.myComplainBtn setBackgroundColor:[UIColor clearColor]];
        [self.ComplainMeBtn setBackgroundColor:[UIColor blackColor]];
    }
    [myDataArr removeAllObjects];
    [self getMyComplaint:self.pagenum];
   // [self.mainTableView reloadData];
}



// 我的投诉显示学员信息
- (void)myClickForStudentInfo:(UIButton *)sender {
    //int i = sender.tag;
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description] ];
    self.phoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentidLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    
    self.phoneNum = self.phoneLabel.text;
    
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.starView.frame), 0)];//设置星级
    NSString * strIcon = [[dict objectForKey:@"studentavatar"] description];
    if([CommonUtil isEmpty:strIcon])         // 设置学员头像
    {
        strIcon = @"";
    }
    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:strIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
//            [self updateLogoImage:self.studentIconImageView];//裁切
        }
    }];
    [self.view addSubview:self.studentInfoView];
}

// 投诉我的显示学员信息
- (void)clickForStudentMyInfo:(UIButton *)sender {
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description] ];
    self.phoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentidLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.starView.frame), 0)];//设置星级
    self.phoneNum = self.phoneLabel.text;
    
    NSString * strIcon = [[dict objectForKey:@"studentavatar"] description];
    if([CommonUtil isEmpty:strIcon])         // 设置学员头像
    {
        strIcon = @"";
    }
    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:strIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
//            [self updateLogoImage:self.studentIconImageView];//裁切头像
        }
    }];
    [self.view addSubview:self.studentInfoView];
}

// 关闭学员信息
- (IBAction)clickForCancelInfoView:(id)sender {
    [self.studentInfoView removeFromSuperview];
}

// 电话联系
- (IBAction) callPhoneBtn:(id)sender {
    NSString *phoneNum = [NSString stringWithFormat:@"telprompt://%@",self.phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}

#pragma mark - 我的投诉接口
- (void)getMyComplaint:(int) pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetMyComplaint" forKey:@"action"];
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

#pragma mark - 投诉我的接口
- (void)getComplaintToMy:(int)pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetComplaintToMy" forKey:@"action"];
    request.tag = 1;
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];    // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%i",pageNum] forKey:@"pagenum"]; // 当前获取的页数，从零开始
    
    [request startAsynchronous];
    //[DejalBezelActivityView activityViewForView:self.view];
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
        // 判断是投诉我的接口还是我的投诉接口
        if(request.tag == 0){
            // 取出成长档案动态List
            NSArray *arr = [result objectForKey:@"complaintlist"];
     
            // 判断数组内容个数是否为零
            if(arr.count == 0){
                [self.mainTableView reloadData];
                self.nodataImageView.hidden = NO;
                [self.pullToMore setPullToMoreViewVisible:NO ];
            }else{
                self.nodataImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:YES ];
                // 判断是否要显示上拉加载
                if(self.pagenum == 0)
                {
                    [myDataArr removeAllObjects];
                    [myDataArr addObjectsFromArray:arr];
                   // [self getContent];
                   // NSLog(@"my%@",myDataArr);
                    [self.mainTableView reloadData];
                    [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:NO];
                    //if(myDataArr.count < 10)
                    if(hasmore == 0)
                    {
                        [self.pullToMore setPullToMoreViewVisible:NO];
                    }else{
                        [self.pullToMore setPullToMoreViewVisible:YES];
                    }
                    
                }else
                {
                    [myDataArr addObjectsFromArray:arr];
                 //   [self getContent];
                    [self.mainTableView reloadData];
                     //if(myDataArr.count < (self.pagenum * 10 + 10))
                    if(hasmore == 0)
                    {
                        [self.pullToMore setPullToMoreViewVisible:NO ];
                    }else{
                        [self.pullToMore setPullToMoreViewVisible:YES];
                    }
                }
            }
        }else{
            // 取出成长档案动态List
            NSArray *arr = [result objectForKey:@"complaintlist"];
            // 判断数组内容个数是否为零
            if(arr.count == 0){
                [self.mainTableView reloadData];
                self.nodataImageView.hidden = NO;
                [self.pullToMore setPullToMoreViewVisible:NO ];
            }else{
                self.nodataImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:YES ];
                // 判断是否要显示上拉加载
                if(self.pagenum == 0)
                {
                    [myDataArr removeAllObjects];
                    [myDataArr addObjectsFromArray:arr];
                    // [self getContent];
                    //NSLog(@"datamy%@",myDataArr);
                    [self.mainTableView reloadData];
                    [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:NO];
                    //if(myDataArr.count < 10)
                    if(hasmore == 0)
                    {
                        [self.pullToMore setPullToMoreViewVisible:NO];
                    }else{
                        [self.pullToMore setPullToMoreViewVisible:YES];
                    }
                    
                }else
                {
                    [myDataArr addObjectsFromArray:arr];
                    //   [self getContent];
                    [self.mainTableView reloadData];
                    //if(myDataArr.count < (self.pagenum * 10 + 10))
                    if(hasmore == 0)
                    {
                        [self.pullToMore setPullToMoreViewVisible:NO ];
                    }else{
                        [self.pullToMore setPullToMoreViewVisible:YES];
                    }
                }
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
