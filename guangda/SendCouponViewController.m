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
@interface SendCouponViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *phoneView;
@property (strong, nonatomic) IBOutlet UIView *couponNumView;
@property (strong, nonatomic) IBOutlet UILabel *signLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *couponNumberTextField;

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
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.phoneNumberTextField resignFirstResponder];
    [self.couponNumberTextField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
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
    cell.textLabel.text = @"12333333333  李敏镐";
    
//    NSString *count = @"32";
//    NSString *Count1 = [NSString stringWithFormat:@"%@张",count];
//    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:Count1];
//    [str1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0, count.length)];
//    [str1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(count.length, 1)];
//    cell.couponCount.attributedText = str1;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)clickForSendCoupon:(id)sender {
    [self.userListTableView reloadData];
}

//查看发放记录
- (IBAction)clickForSendRecord:(id)sender {
    SendCouponRecordViewController *nextController = [[SendCouponRecordViewController alloc] initWithNibName:@"SendCouponRecordViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
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
