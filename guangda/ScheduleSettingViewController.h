//
//  ScheduleSettingViewController.h
//  guangda
//
//  Created by 吴筠秋 on 15/4/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface ScheduleSettingViewController : GreyTopViewController

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSArray *timeArray;
@property (strong, nonatomic) NSDictionary *timeDic;//对应的日期
@property (strong, nonatomic) NSString *date;//修改的日期<2015-03-01>
@end
