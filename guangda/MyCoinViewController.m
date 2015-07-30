//
//  MyCoinViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyCoinViewController.h"
#import "CoinRecordListViewController.h"
#import "ConvertCoinViewController.h"
@interface MyCoinViewController ()

//主界面
@property (strong, nonatomic) IBOutlet UILabel *coachCoin;
@property (strong, nonatomic) IBOutlet UILabel *schoolCoin;
@property (strong, nonatomic) IBOutlet UILabel *platformCoin;
@property (strong, nonatomic) IBOutlet UILabel *fromCoach;
@property (strong, nonatomic) IBOutlet UILabel *fromSchool;
@property (strong, nonatomic) IBOutlet UILabel *fromPlatform;

//弹出框
@property (strong, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *peopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *circulatePeopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *circulateNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *circulateMoneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *applyTimeLabel;

- (IBAction)clickForClose:(id)sender;
- (IBAction)clickForRecord:(id)sender;
@end

@implementation MyCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.orderNumLabel.text = @"兑换订单号：22222333333";
    self.peopleLabel.text = @"兑换人：程志超";
    self.circulatePeopleLabel.text = @"发放人：杭州广大驾校";
    self.circulateNumLabel.text = @"兑换数量：100个";
    self.circulateMoneyLabel.text = @"折算金额：100元";
    self.applyTimeLabel.text = @"申请时间：2015-07-15 12：21：22";
}

- (IBAction)clickForClose:(id)sender {
    
}
//兑换记录
- (IBAction)clickForRecord:(id)sender {
    CoinRecordListViewController *nextController = [[CoinRecordListViewController alloc] initWithNibName:@"CoinRecordListViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
//教练兑换
- (IBAction)ClickForCoachConvert:(id)sender {
    ConvertCoinViewController *nextController = [[ConvertCoinViewController alloc] initWithNibName:@"ConvertCoinViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
//驾校兑换
- (IBAction)ClickForSchoolConvert:(id)sender {
}
//平台兑换
- (IBAction)ClickForPlatformConvert:(id)sender {
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
