//
//  MyEvaluationViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyEvaluationViewController.h"
#import "MyEvaluationCell.h"
#import "EvaluationMeCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "TQStarRatingView.h"
#import "ComplainMeCell.h"
#import "LoginViewController.h"

@interface MyEvaluationViewController () <UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    NSMutableArray *myDataArr;
    //NSMutableArray *myDataArr;
    TQStarRatingView *ratingView;
    
    NSMutableArray *complainMyDataArr; // 我的投诉容器
    NSMutableDictionary *complainMyDic; // 存放每条投诉我的内容高度
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UIView *selectBarView;
@property (strong, nonatomic) IBOutlet UIImageView *backgoundImageView;
@property (strong, nonatomic) IBOutlet UIButton *myEvaluationBtn;       // 评价我的按钮属性
@property (strong, nonatomic) IBOutlet UIButton *evaluationMeBtn;       // 我的评价按钮属性
@property (strong, nonatomic) IBOutlet UIButton *ComplainMeBtn;         // 投诉我的按钮属性
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *studentInfoView;
@property (strong, nonatomic) IBOutlet UIImageView *nodataImageView;   // 没评论时显示的内容
@property (strong, nonatomic) IBOutlet UIImageView *noComplainImageView;      // 无投诉内容时显示的背景图片

@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;  // 学员名字
@property (strong, nonatomic) IBOutlet UILabel *studentCardIdLabel; // 学员证号
@property (strong, nonatomic) IBOutlet UILabel *studentPhoneLabel;  // 学员号码
@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView; // 学员头像
@property (strong, nonatomic) IBOutlet UILabel *studentScoreLabel;    // 学员评分
@property (strong, nonatomic) IBOutlet UIView *startView; // 星级显示


- (IBAction)clickForMyEvaluation:(id)sender;
- (IBAction)clickForEvaluationMe:(id)sender;
- (IBAction)clickForComplainMe:(id)sender;//点击投诉
- (IBAction)clickForCancelInfoView:(id)sender;
- (IBAction)callPhoneBtn:(id)sender;



@property (assign, nonatomic) int rows; // 数据行数;
@property (assign, nonatomic) int pagenum; //评论页数
@property (copy, nonatomic) NSString *phoneNum;

@end

@implementation MyEvaluationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    complainMyDataArr = [[NSMutableArray alloc] init];
    complainMyDic = [[NSMutableDictionary alloc] init];
    
    // 设置边框
    self.selectBarView.layer.cornerRadius = 4;
    self.selectBarView.layer.borderWidth = 0.6;
    self.selectBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.evaluationMeBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.evaluationMeBtn.layer.borderWidth = 0.6;
    
    [self settingView];
    
    ratingView = [[TQStarRatingView alloc] initWithFrame:self.startView.bounds numberOfStar:5];
    ratingView.couldClick = NO;//不可点击
    [ratingView changeStarForegroundViewWithPoint:CGPointMake(0/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    [self.startView addSubview:ratingView];
    
    self.phoneNum = @"12345678912";
    
   // self.rows = 5;
    myDataArr = [[NSMutableArray alloc] init];
    //myDataArr = [[NSMutableArray alloc] init];
    
    self.evaluationType = 1;
    // 调用评价我的
    [self GetEvaluationToMy:self.pagenum];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingView {
    self.mainTableView.allowsSelection = NO;
    self.studentInfoView.frame = [UIScreen mainScreen].bounds;
    
    // 设置圆角
    UIImage *backgroundImage = [[UIImage imageNamed:@"bar_tousu.png"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(0,13,0,13)];
    [self.backgoundImageView setImage:backgroundImage];
    
    self.selectBarView.layer.cornerRadius = 13;
    
    self.myEvaluationBtn.selected = YES;
    self.evaluationMeBtn.selected = NO;
    self.ComplainMeBtn.selected = NO;
    
    
    [self.myEvaluationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.myEvaluationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.evaluationMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.evaluationMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.ComplainMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.ComplainMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.myEvaluationBtn setBackgroundColor:[UIColor blackColor]];
    [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
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

// 对头像裁剪成六边形
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return self.rows;
        return myDataArr.count;
   
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.evaluationType == 0){
//        if ([cell isKindOfClass:[MyEvaluationCell class]]){
//        MyEvaluationCell *myCCell = (MyEvaluationCell *)cell;
//        [self updateLogoImage:myCCell.studentIocnImageView];
//        }
//    }else{
//        if ([cell isKindOfClass:[EvaluationMeCell class]]){
//            EvaluationMeCell *myCCell = (EvaluationMeCell *)cell;
//            [self updateLogoImage:myCCell.studentIocnImageView];
//        }
//    }
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 我的评价
    if (self.evaluationType == 0) {
        static NSString *ID = @"MyEvaluationCellIdentifier";
        MyEvaluationCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"MyEvaluationCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 加载数据
        NSDictionary *dic = [myDataArr objectAtIndex:indexPath.row];
        cell.evaluationContent = dic[@"content"]; // 评价详情
        cell.studentIcon = dic[@"studentavatar"]; // 学员头像
        cell.studentName = dic[@"name"];          // 学员名字
        cell.score = [dic[@"score"] floatValue];  // 评分
        
        NSString *startTime = dic[@"starttime"];  // 任务开始时间
        NSString *endTime = dic[@"endtime"];      // 任务结束时间
        NSString *dataTime =[NSString stringWithFormat:@"%@~%@",[startTime substringToIndex:16],[endTime substringWithRange:NSMakeRange(11, 5)]];
        cell.evaluationData = dataTime;           // 任务时间
        
        cell.studentInfoBtn.tag = indexPath.row;
        [cell.studentInfoBtn addTarget:self action:@selector(myClickForStudentInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell loadData:nil];
        
        if (indexPath.row == (myDataArr.count -1)) {
            [_pullToMore tableViewReloadFinished];
        }
        return cell;
    }
    
    // 评价我的
    else if (self.evaluationType == 1) {
        static NSString *ID = @"EvaluationMeCellIdentifier";
        EvaluationMeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"EvaluationMeCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 加载数据
        NSDictionary *dic = [myDataArr objectAtIndex:indexPath.row];
        cell.evaluationContent = dic[@"content"]; // 评价详情
        cell.studentIcon = dic[@"studentavatar"]; // 学员头像
        cell.score = [dic[@"score"] floatValue];  // 评分
        
        NSString *startTime = dic[@"starttime"];  // 任务开始时间
        NSString *endTime = dic[@"endtime"];      // 任务结束时间
        NSString *dataTime =[NSString stringWithFormat:@"%@~%@",[startTime substringToIndex:16],[endTime substringWithRange:NSMakeRange(11, 5)]];
        cell.evaluationData = dataTime;           // 任务时间

        //cell.evaluationContent = @"教的很专业教的很专业教的很专业教的很专业教的很专业教的很专业教的很专业教的很专业教的很专业教的很专业";
        
        cell.studentInfoBtn.tag = indexPath.row;
        [cell.studentInfoBtn addTarget:self action:@selector(clickForStudentMyInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell loadData:nil];
        
        if (indexPath.row == (myDataArr.count -1)) {
            [_pullToMore tableViewReloadFinished];
        }
        return cell;
    }
    // 投诉我的
    else{
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
                    NSArray * chArr = [complainMyDic objectForKey:[NSString stringWithFormat:@"%li",(long)indexPath.row]];
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
    if (self.evaluationType == 0) {
        NSDictionary *dict = [myDataArr objectAtIndex:indexPath.row];
        NSString *EvaluationContent = [dict objectForKey:@"content"];
        CGSize textSize;
        if([CommonUtil isEmpty:EvaluationContent]){
            textSize.height = 0;
        }else{
            textSize = [self sizeWithString:EvaluationContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:0];
        }
        return 229 - 35 + textSize.height;
    } else if (self.evaluationType == 1) {
         NSDictionary *dict = [myDataArr objectAtIndex:indexPath.row];
        NSString *EvaluationContent = [dict objectForKey:@"content"];
        CGSize textSize;
        if([CommonUtil isEmpty:EvaluationContent]){
            textSize.height = 0;
        }else{
            textSize = [self sizeWithString:EvaluationContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:0];
        }
        return 152 - 35 + textSize.height;
    } else {
        // NSString *complainContent = @"#服务态度差#教练教的一般般，脾气却很大，2小时有1.5小时在煲电话粥，都没怎么教，收费还很
        return [self computeContentMyHeight:indexPath.row];
    }
}

// 计算投诉我的每个内容高度
- (int)computeContentMyHeight:(NSInteger)index{
    // 从字典中获取我的投诉数据
    if(complainMyDataArr == nil){
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
    [complainMyDic setObject:cArr forKey:[NSString stringWithFormat:@"%li",(long)index]];
    return 128 - 35 + contentHeight;
}


#pragma mark - 请求接口
- (void)getFreshData {
   // self.rows = 5;
    //[self.mainTableView reloadData];
    self.pagenum = 0;
    if(self.evaluationType == 0)
    {
        [self GetMyEvaluation:self.pagenum];
    }else if(self.evaluationType == 1){
        [self GetEvaluationToMy:self.pagenum];
    }else{
        [self getComplaintToMy:self.pagenum];
    }
    [_pullToRefresh tableViewReloadFinishedAnimated:YES];
}

// 加载更多数据
- (void)getMoreData {
    //self.rows = self.rows + 5;
    //[self.mainTableView reloadData];
    
    if(self.evaluationType == 0){
        self.pagenum = (int)(myDataArr.count / 10);
        [self GetMyEvaluation:self.pagenum];
    }else if(self.evaluationType == 1){
        self.pagenum = (int)(myDataArr.count / 10);
        [self GetEvaluationToMy:self.pagenum];
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
// 评价我的
- (IBAction)clickForMyEvaluation:(id)sender {
    self.evaluationType = 1;
    self.pagenum = 0;
    if (self.myEvaluationBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = YES;
        self.evaluationMeBtn.selected = NO;
        self.ComplainMeBtn.selected = NO;
        [self.myEvaluationBtn setBackgroundColor:[UIColor blackColor]];
        [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    }
    [myDataArr removeAllObjects];
    [self GetEvaluationToMy:self.pagenum];
    
}

// 我的评价
- (IBAction)clickForEvaluationMe:(id)sender {
    self.evaluationType = 0;
    self.pagenum = 0;
    if (self.evaluationMeBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = NO;
        self.evaluationMeBtn.selected = YES;
        self.ComplainMeBtn.selected = NO;
        [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
        [self.myEvaluationBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor blackColor]];
        
    }
    [myDataArr removeAllObjects];
    [self GetMyEvaluation:self.pagenum];
    //[self.mainTableView reloadData];
}

#pragma mark - 按钮方法
// 投诉我的
- (IBAction)clickForComplainMe:(id)sender {
    //self.mainTableView.scrollsToTop = YES;
    //[self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.pagenum = 0;
    self.evaluationType = 2;
    if (self.ComplainMeBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = NO;
        self.evaluationMeBtn.selected = NO;
        self.ComplainMeBtn.selected = YES;
        [self.ComplainMeBtn setBackgroundColor:[UIColor blackColor]];
        [self.myEvaluationBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    }
    [myDataArr removeAllObjects];
    [self getComplaintToMy:self.pagenum];
    // [self.mainTableView reloadData];
}

// 显示我的评价学员信息
- (void)myClickForStudentInfo:(UIButton *)sender {
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.studentScoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description]];
    self.studentPhoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentCardIdLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    self.phoneNum = self.studentPhoneLabel.text;
    
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

// 显示评价我的学员信息
- (void)clickForStudentMyInfo:(UIButton *)sender {
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.studentScoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description] ];
    self.studentPhoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentCardIdLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    self.phoneNum = self.studentPhoneLabel.text;
    
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


// 关闭学员信息
- (IBAction)clickForCancelInfoView:(id)sender {
    [self.studentInfoView removeFromSuperview];
}

// 电话联系
- (IBAction)callPhoneBtn:(id)sender {
    NSLog(@"%@",self.phoneNum);
    NSString *phoneNum = [NSString stringWithFormat:@"telprompt://%@",self.phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}

#pragma mark - 我的评价接口
- (void)GetMyEvaluation:(int) pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetMyEvaluation" forKey:@"action"];
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

#pragma mark - 评价我的接口
- (void)GetEvaluationToMy:(int)pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetEvaluationToMy" forKey:@"action"];
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

#pragma mark - 投诉我的接口
- (void)getComplaintToMy:(int)pageNum{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetComplaintToMy" forKey:@"action"];
    request.tag = 2;
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];    // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%i",pageNum] forKey:@"pagenum"]; // 当前获取的页数，从零开始
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    NSInteger hasmore = [[result objectForKey:@"hasmore"] integerValue];
    // 取得数据成功
    if ([code intValue] == 1) {
        // 判断是投诉我的接口还是我的投诉接口
        if(request.tag == 0){
            // 取出成长档案动态List
            NSArray *arr = [result objectForKey:@"evaluationlist"];
            
            // 判断数组内容个数是否为零
            if(arr.count == 0){
                self.nodataImageView.hidden = NO;
                self.noComplainImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:NO];
                [self.mainTableView reloadData];
            }else{
                self.nodataImageView.hidden = YES;
                self.noComplainImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:YES];
                // 判断是否要显示上拉加载
                if(self.pagenum == 0)
                {
                    [myDataArr removeAllObjects];
                    [myDataArr addObjectsFromArray:arr];
                    // [self getContent];
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
                    if(hasmore == 0)
                    {
                        [self.pullToMore setPullToMoreViewVisible:NO ];
                    }else{
                        [self.pullToMore setPullToMoreViewVisible:YES];
                    }
                }
            }
        }else if(request.tag == 1){
            // 取出成长档案动态List
            NSArray *arr = [result objectForKey:@"evaluationlist"];
            // 判断数组内容个数是否为零
            if(arr.count == 0){
                [self.mainTableView reloadData];
                self.nodataImageView.hidden = NO;
                self.noComplainImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:NO];
            }else{
                self.nodataImageView.hidden = YES;
                self.noComplainImageView.hidden = YES;
                [self.pullToMore setPullToMoreViewVisible:YES];
                // 判断是否要显示上拉加载
                if(self.pagenum == 0)
                {
                    [myDataArr removeAllObjects];
                    [myDataArr addObjectsFromArray:arr];
                    // [self getContent];
                    [self.mainTableView reloadData];
                    [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:NO];
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
                self.nodataImageView.hidden = YES;
                self.noComplainImageView.hidden = NO;
                [self.pullToMore setPullToMoreViewVisible:NO ];
            }else{
                self.nodataImageView.hidden = YES;
                self.noComplainImageView.hidden = YES;
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

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end
