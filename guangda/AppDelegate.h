//
//  AppDelegate.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "BMapKit.h"
#import "OpenUDID.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL flgAutoLogin;
@property (strong, nonatomic) NSString *isregister;
@property (strong, nonatomic) NSString *isInvited;
@property (strong, nonatomic) NSString *crewardamount;//认证奖励
@property (strong, nonatomic) NSString *orewardamount;//开单奖励

@property (strong, nonatomic) NSString *superViewNum;
@property (strong, nonatomic) MainViewController *mainController;

// 登录用户ID
@property (copy, nonatomic) NSString *userid;
- (void)toUploadDeviceInfo;
//用户定位
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) NSString *cityName;//城市
@property (strong, nonatomic) NSString *address;//地址
@property (strong, nonatomic) NSString *area;//省市

@property (strong, nonatomic) NSString *deviceToken;
@property (nonatomic, strong) BMKReverseGeoCodeResult *locationResult;

- (void)startLocation;

- (void) jumpToMainViewController;

@end

