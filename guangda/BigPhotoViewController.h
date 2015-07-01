//
//  BigPhotoViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "BaseViewController.h"

@interface BigPhotoViewController : BaseViewController
@property (assign, nonatomic) int type; // 0:身份证正面 1:身份证反面 2:教练证 3:教练车行驶证
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
