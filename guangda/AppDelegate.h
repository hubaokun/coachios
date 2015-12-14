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
@property (strong, nonatomic) NSString *schoolName;//驾校名
@property (strong, nonatomic) NSString *driveschoolid;//驾校ID
@property (strong, nonatomic) NSString *carModel;
@property (strong, nonatomic) NSString *modelid;
@property (strong, nonatomic) NSString *crewardamount;//认证奖励
@property (strong, nonatomic) NSString *orewardamount;//开单奖励
@property (strong, nonatomic) NSString *needOpenSchedule;//需要开课
@property (strong, nonatomic) NSString *fromSerAddrive;//从设置地址来

@property (strong, nonatomic) NSString *advertisementUrl;//广告地址
@property (strong, nonatomic) NSString *advertisementopentype;//广告类型  0=无跳转，1=打开URL，2=内部action
@property (strong, nonatomic) NSString *openaction;//跳转ACTION数值
// 1=学员端学车地图首页，2= 学员端陪驾地图首页 ，3=学员端小巴商城，4=学员端题库页，5=教练端邀请朋友加入页 ，6=教练端教练开课页

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

