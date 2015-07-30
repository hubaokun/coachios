//
//  ConvertCoinViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ConvertCoinViewController.h"

@interface ConvertCoinViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *coinNumTextfield;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn;

@property (strong, nonatomic) IBOutlet UIView *alertView;

- (IBAction)clickForClose:(id)sender;
@end

@implementation ConvertCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backView.layer.borderColor = RGB(222, 222, 222).CGColor;
    self.backView.layer.borderWidth = 0.5;
    
    self.convertBtn.layer.cornerRadius = 4;
    self.convertBtn.layer.masksToBounds = YES;
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

- (IBAction)clickForClose:(id)sender {
}
@end
