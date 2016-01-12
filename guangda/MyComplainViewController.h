//
//  MyComplainViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/18.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface MyComplainViewController : GreyTopViewController  //我的投诉
@property (assign, nonatomic) int complainType; // 0:我的投诉 1:投诉我的
@property (assign, nonatomic) int hasData; // 0:无数据 1:有数据
@end
