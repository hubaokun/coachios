//
//  SendCouponViewController.m
//  guangda
//
//  Created by Ray on 15/9/15.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SendCouponViewController.h"
#import "SendCouponRecordViewController.h"
#import "SendCouponTableViewCell.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
@interface SendCouponViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
     NSMutableArray *studentArray;
     NSArray *allArray;
     NSString *selectStudentId;
}
@property (strong, nonatomic) IBOutlet UIView *phoneView;
@property (strong, nonatomic) IBOutlet UIView *couponNumView;
@property (strong, nonatomic) IBOutlet UILabel *signLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *couponNumberTextField;



@property (strong, nonatomic) IBOutlet UIView *testView;
@property (strong, nonatomic) IBOutlet UITableView *userListTableView;
@end

@implementation SendCouponViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     // Do any additional setup after loading the view from its nib.
     //圆角
     self.sendButton.layer.cornerRadius = 4;
     self.sendButton.layer.masksToBounds = YES;
     
     self.phoneView.layer.borderColor = RGB(210, 210, 210).CGColor;
     self.phoneView.layer.borderWidth = 0.8;
     self.couponNumView.layer.borderColor = RGB(210, 210, 210).CGColor;
     self.couponNumView.layer.borderWidth = 0.8;
     
     self.userListTableView.delegate = self;
     self.userListTableView.dataSource = self;
     self.userListTableView.layer.borderColor = RGB(210, 210, 210).CGColor;
     self.userListTableView.layer.borderWidth = 0.8;
     self.userListTableView.hidden = YES;
     
     [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
     self.phoneNumberTextField.delegate = self;
     self.signLabel.hidden = YES;
     
     studentArray = [NSMutableArray array];
     allArray = [NSMutableArray array];
     [self getCoachStudent];
     
     self.image.image = [YLGIFImage imageNamed:@"未标题-4.gif"];
     
     self.testView.hidden = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     if (textField == self.phoneNumberTextField) {
          self.userListTableView.hidden = NO;
          
     }
}
//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField
{
     if (textField == self.phoneNumberTextField) {
          self.userListTableView.hidden = YES;
     }
}
- (void) textFieldDidChange:(UITextField *) TextField{
     if (TextField == self.phoneNumberTextField) {
          self.userListTableView.hidden = NO;
          [studentArray removeAllObjects];
          // 用NSPredicate来过滤数组。
          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains  %@",TextField.text];
          NSMutableArray *mutableAry = [[NSMutableArray alloc]init];
          for (int i=0; i<allArray.count; i++) {
               NSDictionary *dic = allArray[i];
               NSString *cellStr = [NSString stringWithFormat:@"%@  %@",[dic[@"phone"] description],[dic[@"realname"] description]];
               [mutableAry addObject:cellStr];
          }
          NSMutableArray *array = [NSMutableArray arrayWithArray:[mutableAry filteredArrayUsingPredicate:predicate]];
          for (int i=0; i<allArray.count; i++) {
               NSDictionary *dic = [allArray objectAtIndex:i];
               NSString *phone = [[dic objectForKey:@"phone"] description];
               for (int m=0; m<array.count; m++) {
                    NSString *searchstr = [[[array objectAtIndex:m] description] substringToIndex:11];
                    if ([searchstr isEqualToString:phone]) {
                         [studentArray addObject:dic];
                         break;
                    }
               }
          }
          if (TextField.text.length == 0) {
               studentArray = [NSMutableArray arrayWithArray:allArray];
          }
          [self.userListTableView reloadData];
     }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     [self.phoneNumberTextField resignFirstResponder];
     [self.couponNumberTextField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return studentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     
     return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString *cellident = @"SendCouponTableViewCell";
     SendCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
     if (!cell) {
          [tableView registerNib:[UINib nibWithNibName:@"SendCouponTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
          cell = [tableView dequeueReusableCellWithIdentifier:cellident];
     }
     
     NSDictionary *dic = studentArray[indexPath.row];
     NSString *cellStr = [NSString stringWithFormat:@"%@  %@",[dic[@"phone"] description],[dic[@"realname"] description]];
     cell.textLabel.text = cellStr;
     
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     tableView.separatorStyle = UITableViewCellSelectionStyleNone;
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSDictionary *dic = studentArray[indexPath.row];
     selectStudentId = [dic[@"studentid"] description];
     NSString *cellStr = [NSString stringWithFormat:@"%@  %@",[dic[@"phone"] description],[dic[@"realname"] description]];
     self.phoneNumberTextField.text = cellStr;
     self.userListTableView.hidden = YES;
     [self getStudentCoupon];
}

- (IBAction)clickForSendCoupon:(id)sender {
    if ( self.phoneNumberTextField.text.length >=11 && self.couponNumberTextField.text.length >0 && [self.couponNumberTextField.text intValue] <=32) {
        [self grantCoupon];
    }else{
        [self makeToast:@"请选择正确的用户和正确数量的小巴券"];
    }
}

//查看发放记录
- (IBAction)clickForSendRecord:(id)sender {
     SendCouponRecordViewController *nextController = [[SendCouponRecordViewController alloc] initWithNibName:@"SendCouponRecordViewController" bundle:nil];
     [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark - 接口
//获取教练有关联的学员
- (void)getCoachStudent{
     NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
     ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
     request.delegate = self;
     request.tag = 0;
     request.requestMethod = @"POST";
     [request setPostValue:@"GETCOACHSTUDENT" forKey:@"action"];
     [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
     [request setPostValue:userInfo[@"token"] forKey:@"token"];
     [request startAsynchronous];
     [DejalBezelActivityView activityViewForView:self.view];
}

//获取学员可用小巴券数
- (void)getStudentCoupon{
     NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
     ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
     request.delegate = self;
     request.tag = 1;
     request.requestMethod = @"POST";
     [request setPostValue:@"GETSTUDENTCOUPON" forKey:@"action"];
     [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
     [request setPostValue:selectStudentId forKey:@"studentid"];
     [request setPostValue:userInfo[@"token"] forKey:@"token"];
     [request startAsynchronous];
     [DejalBezelActivityView activityViewForView:self.view];
}

//获取教练有关联的学员
- (void)grantCoupon{
     NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
     ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
     request.delegate = self;
     request.tag = 2;
     request.requestMethod = @"POST";
     [request setPostValue:@"GRANTCOUPON" forKey:@"action"];
     [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
     [request setPostValue:[self.phoneNumberTextField.text substringToIndex:11] forKey:@"phone"];
     [request setPostValue:self.couponNumberTextField.text forKey:@"pubnum"];
     [request setPostValue:userInfo[@"token"] forKey:@"token"];
     [request startAsynchronous];
     [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
     //接口
     NSDictionary *result = [[request responseString] JSONValue];
     NSNumber *code = [result objectForKey:@"code"];
     NSString *message = [result objectForKey:@"message"];
     // 取得数据成功
     if ([code intValue] == 1) {
          if (request.tag == 0) {
               NSArray *studentlist = result[@"studentlist"];
               studentArray = [NSMutableArray arrayWithArray:studentlist];
               allArray = [NSArray arrayWithArray:studentlist];
               [self.userListTableView reloadData];
               [DejalBezelActivityView removeViewAnimated:YES];
          }else if (request.tag == 1){
               NSString *studentStr = [NSString stringWithFormat:@"该学员已用小巴券%@张，剩余%@张",[result[@"total"] description],[result[@"rest"] description]];
               self.signLabel.text = studentStr;
               self.signLabel.hidden = NO;
               [DejalBezelActivityView removeViewAnimated:YES];
          }else if (request.tag == 2){
               [self makeToast:@"发放成功"];
               selectStudentId = @"";
               self.couponNumberTextField.text = @"";
               
               [DejalBezelActivityView removeViewAnimated:YES];
          }
          
     } else {
          if ([CommonUtil isEmpty:message]) {
               message = ERR_NETWORK;
          }
          [self makeToast:message];
          [DejalBezelActivityView removeViewAnimated:YES];
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
