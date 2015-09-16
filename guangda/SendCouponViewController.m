//
//  SendCouponViewController.m
//  guangda
//
//  Created by Ray on 15/9/15.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SendCouponViewController.h"
#import "SendCouponRecordViewController.h"
@interface SendCouponViewController ()

@property (strong, nonatomic) IBOutlet UIView *phoneView;
@property (strong, nonatomic) IBOutlet UIView *couponNumView;
@property (strong, nonatomic) IBOutlet UILabel *signLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *couponNumberTextField;

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
    
    self.signLabel.hidden = YES;
}
- (IBAction)clickForSendCoupon:(id)sender {
    
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
