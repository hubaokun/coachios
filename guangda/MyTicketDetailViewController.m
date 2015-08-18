//
//  MyTicketDetailViewController.m
//  guangda
//
//  Created by Ray on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyTicketDetailViewController.h"
#import "MyTicketDetailTableViewCell.h"
@interface MyTicketDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *noDataButton;

@property (strong, nonatomic) IBOutlet UIView *ruleView;//规则页面

@property (strong, nonatomic) IBOutlet UIView *footBackView;
@property (strong, nonatomic) IBOutlet UILabel *altogetherTime;
@property (strong, nonatomic) IBOutlet UILabel *altogetherMoney;
@property (strong, nonatomic) IBOutlet UIButton *convertButton;
@property (strong, nonatomic) IBOutlet UILabel *headLabel;

//参数
@property (strong, nonatomic) NSMutableArray *ticketArray;
@property (strong, nonatomic) NSMutableArray *arrayList1;
@property (strong, nonatomic) NSMutableArray *arrayList2;

@end

@implementation MyTicketDetailViewController
{
    NSMutableArray *selectArray;
    NSString *requsetTag;
    NSString *recordids;
    UIView *view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = RGB(243, 243, 243);
    // Do any additional setup after loading the view from its nib.
    
    self.convertButton.layer.cornerRadius = 4;
    self.convertButton.layer.masksToBounds = YES;
    
    self.ticketArray = [[NSMutableArray alloc]init];
    self.arrayList1 = [[NSMutableArray alloc]init];
    self.arrayList2 = [[NSMutableArray alloc]init];
    selectArray = [[NSMutableArray alloc]init];
    
    [self.noDataButton setImage:[UIImage imageNamed:@"no_coupon"] forState:UIControlStateDisabled];
    self.noDataButton.enabled = NO;
    
    requsetTag = @"1";
    [self getAmountData];
    //合计金额
    NSString *money = @"0";
    NSString *altogetherMoney = [NSString stringWithFormat:@"合计：%@元", money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:altogetherMoney];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(3,money.length+1)];
    self.altogetherMoney.attributedText = string;
    
    //合计时间
    NSString *ticketNum = @"0";
    NSString *altogetherHours = @"0";
    NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%@张共%@小时",ticketNum,altogetherHours];
    self.altogetherTime.text = altogetherTimeStr;
}

//ticketArray处理
- (void)handleTicketArray
{
    for (int i = 0; i<self.ticketArray.count; i++) {
        NSDictionary *dic = self.ticketArray[i];
        if (i%2 == 0) {
            [self.arrayList1 addObject:dic];
        }else{
            [self.arrayList2 addObject:dic];
        }
    }
}

//立即兑换
- (IBAction)convertClick:(id)sender {
    if (selectArray.count > 0) {
        requsetTag = @"2";
        [self getAmountData];
    }else{
        [self makeToast:@"请至少选择一张小巴券"];
    }
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSNumber *cellCount = [NSNumber numberWithLong:self.ticketArray.count/2];
    if (self.ticketArray.count%2 != 0) {
        cellCount = [NSNumber numberWithLong:self.ticketArray.count/2 + 1];
    }
//    if (cellCount.intValue == 0) {
//        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height)];
//        view.backgroundColor = [UIColor whiteColor];
//        [self.mainTableView addSubview:view];
//    }else{
//        [view removeFromSuperview];
//    }
    return cellCount.intValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"MyTicketDetailTableViewCell";
    MyTicketDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyTicketDetailTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    cell.selectTag1.hidden = YES;
    cell.selectTag2.hidden = YES;
    cell.clickButton1.tag = [NSNumber numberWithInt:((int)indexPath.row*10+0)].intValue;
    cell.clickButton2.tag = [NSNumber numberWithInt:((int)indexPath.row*10+1)].intValue;
    [cell.clickButton1 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    [cell.clickButton2 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row < self.ticketArray.count/2) {
        NSDictionary *dic1 = self.arrayList1[indexPath.row];
        NSString *str1 = [NSString stringWithFormat:@"%@小时小巴券", dic1[@"value"]];
        NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
        cell.ticketFrom1.text = [self getFromString:dic1[@"ownertype"]];
        cell.ticketTime1.text = dic1[@"gettime"];
        NSString *state1 = [dic1[@"state"] description];
        if (state1.intValue == 2) {
            [string1 addAttribute:NSForegroundColorAttributeName value:RGB(222, 222, 222) range:NSMakeRange(0,str1.length)];
            cell.clickButton1.enabled = NO;
            cell.applyLabel1.hidden = NO;
        }else{
            [string1 addAttribute:NSForegroundColorAttributeName value:RGB(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
            cell.clickButton1.enabled = YES;
            cell.applyLabel1.hidden = YES;
        }
        cell.ticketName1.attributedText = string1;
        
        NSDictionary *dic2 = self.arrayList2[indexPath.row];
        NSString *str2 = [NSString stringWithFormat:@"%@小时小巴券", dic2[@"value"]];
        NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:str2];
        cell.ticketFrom2.text = [self getFromString:dic2[@"ownertype"]];
        cell.ticketTime2.text = dic2[@"gettime"];
        NSString *state2 = [dic2[@"state"] description];
        if (state2.intValue == 2) {
            [string2 addAttribute:NSForegroundColorAttributeName value:RGB(222, 222, 222) range:NSMakeRange(0,str2.length)];
            cell.clickButton2.enabled = NO;
            cell.applyLabel2.hidden = NO;
        }else{
            [string2 addAttribute:NSForegroundColorAttributeName value:RGB(37, 37, 37) range:NSMakeRange(str2.length-3,3)];
            cell.clickButton2.enabled = YES;
            cell.applyLabel2.hidden = YES;
        }
        cell.ticketName2.attributedText = string2;
    }else{
        if (self.ticketArray.count%2 != 0) {
            NSDictionary *dic1 = self.arrayList1[indexPath.row];
            NSString *str1 = [NSString stringWithFormat:@"%@小时小巴券", dic1[@"value"]];
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
            cell.ticketFrom1.text = [self getFromString:dic1[@"ownertype"]];
            cell.ticketTime1.text = dic1[@"gettime"];
            NSString *state1 = [dic1[@"state"] description];
            if (state1.intValue == 2) {
                [string1 addAttribute:NSForegroundColorAttributeName value:RGB(222, 222, 222) range:NSMakeRange(0,str1.length)];
                cell.clickButton1.enabled = NO;
                cell.applyLabel1.hidden = NO;
            }else{
                [string1 addAttribute:NSForegroundColorAttributeName value:RGB(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
                cell.clickButton1.enabled = YES;
                cell.applyLabel1.hidden = YES;
            }
            cell.ticketName1.attributedText = string1;
            cell.backView2.hidden = YES;
        }else{
            NSDictionary *dic1 = self.arrayList1[indexPath.row];
            NSString *str1 = [NSString stringWithFormat:@"%@小时小巴券", dic1[@"value"]];
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
            cell.ticketFrom1.text = [self getFromString:dic1[@"ownertype"]];
            cell.ticketTime1.text = dic1[@"gettime"];
            NSString *state1 = [dic1[@"state"] description];
            if (state1.intValue == 2) {
                [string1 addAttribute:NSForegroundColorAttributeName value:RGB(222, 222, 222) range:NSMakeRange(0,str1.length)];
                cell.clickButton1.enabled = NO;
                cell.applyLabel1.hidden = NO;
            }else{
                [string1 addAttribute:NSForegroundColorAttributeName value:RGB(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
                cell.clickButton1.enabled = YES;
                cell.applyLabel1.hidden = YES;
            }
            cell.ticketName1.attributedText = string1;
            
            NSDictionary *dic2 = self.arrayList2[indexPath.row];
            NSString *str2 = [NSString stringWithFormat:@"%@小时小巴券", dic2[@"value"]];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:str2];
            cell.ticketFrom2.text = [self getFromString:dic2[@"ownertype"]];
            cell.ticketTime2.text = dic2[@"gettime"];
            NSString *state2 = [dic2[@"state"] description];
            if (state2.intValue == 2) {
                [string2 addAttribute:NSForegroundColorAttributeName value:RGB(222, 222, 222) range:NSMakeRange(0,str2.length)];
                cell.clickButton2.enabled = NO;
                cell.applyLabel2.hidden = NO;
            }else{
                [string2 addAttribute:NSForegroundColorAttributeName value:RGB(37, 37, 37) range:NSMakeRange(str2.length-3,3)];
                cell.clickButton2.enabled = YES;
                cell.applyLabel2.hidden = YES;
            }
            cell.ticketName2.attributedText = string2;
        }
    }
    
    if ([selectArray containsObject:[NSNumber numberWithInteger:((int)indexPath.row*10+0)]]) {
        cell.selectTag1.hidden = NO;
    }
    if ([selectArray containsObject:[NSNumber numberWithInteger:((int)indexPath.row*10+1)]]){
        cell.selectTag2.hidden = NO;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)getFromString:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"%@",sender];
    if ([str isEqualToString:@"0"]) {
        str = @"由官方平台发行";
    }else if ([str isEqualToString:@"1"]){
        str = @"由驾校发行";
    }else if ([str isEqualToString:@"2"]){
        str = @"由教练发行";
    }
    return str;
}

-(void)selectTicket:(UIButton *) sender{
    if ([selectArray containsObject:[NSNumber numberWithInteger:sender.tag]]) {
        [selectArray removeObject:[NSNumber numberWithInteger:sender.tag]];
    }else{
        [selectArray addObject:[NSNumber numberWithInteger:sender.tag]];
    }
    [self.mainTableView reloadData];
    //小巴券id的String
    NSMutableString *str = [[NSMutableString alloc]init];
    //合计金额
    NSString *money = @"0";
    //合计时间
    NSString *ticketNum = @"0";
    NSString *altogetherHours = @"0";
    for (int i=0; i<selectArray.count; i++) {
        NSNumber *num = selectArray[i];
        NSNumber *buttonTag = [NSNumber numberWithInt:(num.intValue%10)];
        NSNumber *cellRow = [NSNumber numberWithInt:(num.intValue/10)];
        NSDictionary *dic = [[NSDictionary alloc]init];
        if (buttonTag.intValue == 0) {
            dic = self.arrayList1[cellRow.intValue];
        }else{
            dic = self.arrayList2[cellRow.intValue];
        }
        NSNumber *valueNum = dic[@"value"];
        altogetherHours = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:altogetherHours.intValue+valueNum.intValue]];
        
        NSNumber *money_valueNum = dic[@"money_value"];
        money = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:money.intValue+money_valueNum.intValue]];
        
        NSNumber *recordidNum = dic[@"recordid"];
        [str appendString:[NSString stringWithFormat:@"%@,",recordidNum]];
    }
    //小巴券的id string
    if (str.length >0) {
       recordids = [str substringToIndex:str.length-1];
    }else{
       recordids = str;
    }
    //合计数量
    ticketNum = [NSString stringWithFormat:@"%lu",(unsigned long)selectArray.count];
    //合计金额
    NSString *altogetherMoney = [NSString stringWithFormat:@"合计：%@元", money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:altogetherMoney];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(3,money.length+1)];
    self.altogetherMoney.attributedText = string;
    
    //合计时间
    NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%@张共%@小时",ticketNum,altogetherHours];
    self.altogetherTime.text = altogetherTimeStr;
    
}

//兑换规则
- (IBAction)clickForRule:(id)sender {
    self.ruleView.frame = self.view.frame;
    [self.view addSubview:self.ruleView];
}

- (IBAction)removeRuleView:(id)sender {
    [self.ruleView removeFromSuperview];
}

#pragma mark - 接口
- (void)getAmountData{
    // 从本取数据
    NSDictionary *dic = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = [dic objectForKey:@"coachid"];
    if ([requsetTag isEqualToString:@"1"]) {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
        request.delegate = self;
        request.requestMethod = @"POST";
        [request setPostValue:@"getAllCoupon" forKey:@"action"];
        [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
        [request startAsynchronous];
    }else if([requsetTag isEqualToString:@"2"]){
        [DejalBezelActivityView activityViewForView:self.view];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
        request.delegate = self;
        request.requestMethod = @"POST";
        [request setPostValue:@"ApplyCoupon" forKey:@"action"];
        [request setPostValue:coachId forKey:@"coachid"];     // 教练ID
        [request setPostValue:recordids forKey:@"recordids"];     // 教练ID
        [request startAsynchronous];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if ([requsetTag isEqualToString:@"1"]) {
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        // 取得数据成功
        if ([code intValue] == 1) {
            self.ticketArray = result[@"couponlist"];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (int i=0; i<self.ticketArray.count; i++) {
                NSDictionary *dic = self.ticketArray[i];
                NSString *state = [dic[@"state"] description];
                if (state.intValue == 1) {
                    [array addObject:dic];
                }
            }
            NSString *str1 = [NSString stringWithFormat:@"共%lu张小巴券 有%lu张可兑换 \n已兑换的小巴券，请联系发行者结算",(unsigned long)self.ticketArray.count,(unsigned long)array.count];
            self.headLabel.text = str1;
            [self handleTicketArray];
            [self.mainTableView reloadData];
            if (self.ticketArray.count == 0) {
                //没有数据
                self.noDataButton.hidden = NO;
            }else{
                self.noDataButton.hidden = YES;
            }
            
            //合计时间
            NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%@张共%@小时",@"0",@"0"];
            self.altogetherTime.text = altogetherTimeStr;
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
    }else if ([requsetTag isEqualToString:@"2"]){
        //接口
        NSDictionary *result = [[request responseString] JSONValue];
        NSNumber *code = [result objectForKey:@"code"];
        NSString *message = [result objectForKey:@"message"];
        [DejalBezelActivityView removeViewAnimated:YES];
        // 取得数据成功
        if ([code intValue] == 1) {
            [self makeToast:message];
            [self.ticketArray removeAllObjects];
            [selectArray removeAllObjects];
            [self.arrayList1 removeAllObjects];
            [self.arrayList2 removeAllObjects];
            requsetTag = @"1";
            [self getAmountData];
        } else {
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
    }
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    //    [DejalBezelActivityView removeViewAnimated:YES];
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
