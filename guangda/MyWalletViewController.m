//
//  MyWalletViewController.m
//  guangda
//
//  Created by 胡保坤 on 15/5/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyWalletViewController.h"

@interface MyWalletViewController ()
//充值
@property (strong, nonatomic) IBOutlet UIView *rechargeView;
- (IBAction)backButtonClick:(id)sender;
@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rechargeView removeFromSuperview];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake(15, 5, 38, 38);
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
//    [btn setBackgroundImage:[UIImageimageNamed:@"按钮-返回1.png"] forState:UIControlStateNormal];
    UIBarButtonItem*back=[[UIBarButtonItem alloc]initWithCustomView:btn];
    [btn addTarget: self action: @selector(goBackAction) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem=back;
    
}
     
     

-(void)viewWillDisappear:(BOOL)animated
{
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

     
-(void)goBackAction{
    
         [self.navigationController popViewControllerAnimated:YES];
         
     }

- (IBAction)pop:(id)sender {
         [self.rechargeView removeFromSuperview];
     }
     
- (IBAction)removeChongzhi:(id)sender {
    [self.rechargeView removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)rechargeButtonTouch:(id)sender {
        self.rechargeView.frame = self.view.frame;
        [self.view addSubview:self.rechargeView];
}

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
