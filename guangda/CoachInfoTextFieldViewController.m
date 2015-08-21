//
//  CoachInfoTextFieldViewController.m
//  guangda
//
//  Created by Ray on 15/8/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachInfoTextFieldViewController.h"

@interface CoachInfoTextFieldViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputTextfield;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation CoachInfoTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.inputTextfield.delegate = self;
    //1：姓名   2：驾培教龄  3：个人评价
    if ([self.viewType intValue] == 1) {
        self.titleLabel.text = @"姓名";
        self.inputTextfield.placeholder = @"请输入真实姓名";
    }else if ([self.viewType intValue] == 2){
        self.titleLabel.text = @"驾培教龄";
        self.inputTextfield.placeholder = @"请输入真实驾培教龄";
    }else if ([self.viewType intValue] == 3){
        self.titleLabel.text = @"个人评价";
        //        self.inputTextfield.placeholder = @"请输入真实姓名";
    }
    
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
