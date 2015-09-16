//
//  SendCouponRecordViewController.m
//  guangda
//
//  Created by Ray on 15/9/15.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SendCouponRecordViewController.h"
#import "SendCouponRecordTableViewCell.h"
@interface SendCouponRecordViewController ()<UITableViewDelegate
,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@end

@implementation SendCouponRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"SendCouponRecordTableViewCell";
    SendCouponRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SendCouponRecordTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    cell.userName.text = @"周伯通";
    cell.phoneNumLabel.text = @"手机号:123333333333";
    cell.timeLabel.text = @"2015-01-03";
    
    
    NSString *count = @"32";
    NSString *Count1 = [NSString stringWithFormat:@"%@张",count];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:Count1];
    [str1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0, count.length)];
    [str1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(count.length, 1)];
    cell.couponCount.attributedText = str1;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
