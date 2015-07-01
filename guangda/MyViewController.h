//
//  MyViewController.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface MyViewController : GreyTopViewController
@property (assign, nonatomic) int hasChecked; // 是否已通过教练资格审核 0:未通过 1:通过

// 顶部视图动画
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightCon;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *portraitView;
@property (strong, nonatomic) IBOutlet UIView *carAddrView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carAddrViewBottomCon;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *polygonImageView;
@property (strong, nonatomic) IBOutlet UIView *dataView;
//点击头像修改个人信息
- (IBAction)clickForChangeInfo:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *strokeImageView;

@end
