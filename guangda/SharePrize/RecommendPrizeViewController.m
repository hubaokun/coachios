//
//  RecommendPrizeViewController.m
//  guangda
//
//  Created by Ray on 15/7/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendPrizeViewController.h"
#import "RecommendRecordViewController.h"
@interface RecommendPrizeViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIImageView *CodeImage; //二维码图片
@property (strong, nonatomic) IBOutlet UILabel *CodeLabel;     //邀请码
@property (strong, nonatomic) IBOutlet UIButton *recommendFriendButton;
@property (strong, nonatomic) IBOutlet UILabel *footLabel;    //底部label

- (IBAction)clickForRecord:(id)sender;
- (IBAction)clickForRecommendFriend:(id)sender;
@end

@implementation RecommendPrizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //圆角
    self.recommendFriendButton.layer.cornerRadius = 4;
    self.recommendFriendButton.layer.masksToBounds = YES;
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    
}


#pragma mark - private
- (void)showMainView{
    //    scrollFrame = self.view.frame;
    
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footLabel.frame.origin.y + CGRectGetHeight(self.footLabel.frame) + 20);
}




- (IBAction)clickForRecord:(id)sender {
    RecommendRecordViewController *nextViewController = [[RecommendRecordViewController alloc] initWithNibName:@"RecommendRecordViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)clickForRecommendFriend:(id)sender {
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
