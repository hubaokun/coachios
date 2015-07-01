//
//  BigPhotoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "BigPhotoViewController.h"

@interface BigPhotoViewController ()
- (IBAction)clickForDelete:(id)sender;

@end

@implementation BigPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingView {
    if (self.type == 0) {
        self.titleLabel.text = @"身份证正面";
    }
}

- (IBAction)clickForDelete:(id)sender {
    NSLog(@"删除照片");
}
@end
