//
//  MyComplainCell.h
//  guangda
//
//  Created by 冯彦 on 15/3/18.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyComplainCell : UITableViewCell

@property (assign, nonatomic) int hasDealedWith; // 是否已处理 0:未处理 1:已处理
- (void)loadData:(NSArray *)arrayData;
@property (copy, nonatomic) NSString *complainContent; // 我的投诉内容
@property (copy, nonatomic) NSString *complainData;    // 任务时间
@property (copy, nonatomic) NSString *studentIcon;     // 学员头像
@property (copy, nonatomic) NSString *studentName;     // 学员名字
@property (assign, nonatomic) CGFloat messageheight;   // 投诉内容高度
@property (assign, nonatomic) NSInteger complainBecauseLenght;  // 投诉原因长度
@property (assign, nonatomic) int clheight; // 投诉内容到下划线的距离

@property (strong, nonatomic) NSMutableArray *contentHgtArr; // 内容高度数组
@property (strong, nonatomic) NSMutableArray *becauseLenArr; // 原因长度数组
@property (strong, nonatomic) NSMutableDictionary *contentHgtDic; // 内容高度字典
@property (assign, nonatomic) NSInteger type2;

@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView;   // 学员头像
@property (strong, nonatomic) IBOutlet UIButton *studentInfoBtn;
@property (strong, nonatomic) IBOutlet UIView *depositView; // 存放label

@end
