//
//  AppDelegate.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LoginViewController.h"
#import <PgySDK/PgyManager.h>

@interface AppDelegate ()<BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate>

@end

BMKMapManager* _mapManager;
BMKLocationService *_locService;

@implementation AppDelegate

// 注册通知
- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 注册APNS
    [self registerRemoteNotification];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 要使用百度地图，请先启动BaiduMapManager
    self.cityName = @"杭州市";//默认为杭州市
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"CgYEZc4f07w7aZ7AwVD296Ee" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //定位
    [self startLocation];
    
    self.flgAutoLogin = NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //自动登录
    [self autoLogin];
    
    //获取准教车型
    [self getModelList];
    
    //注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getModelList) name:@"getModelList" object:nil];//获取准教车型
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogin:) name:@"needlogin" object:nil];
    
    //蒲公英
    // 设置用户反馈界面激活方式为三指拖动
    //    [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeThreeFingersPan];
    
    // 设置用户反馈界面激活方式为摇一摇
    //    [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeShake];
    
    [[PgyManager sharedPgyManager] startManagerWithAppId:PGY_APPKEY];
    [[PgyManager sharedPgyManager] setEnableFeedback:NO]; //关闭用户反馈功能
    
    [[PgyManager sharedPgyManager] setThemeColor:[UIColor blackColor]];
    
    //    [[PgyManager sharedPgyManager] setShakingThreshold:3.0];//开发者可以自定义摇一摇的灵敏度，默认为2.3，数值越小灵敏度越高。
    //    [[PgyManager sharedPgyManager] showFeedbackView];//直接显示用户反馈画面
    
    [[PgyManager sharedPgyManager] checkUpdate];//检查版本更新
    
    return YES;
}

//在此接收设备号
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //[self addDeviceToken:deviceToken];    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self updateUserAddress];
   // NSLog(@"deviceToken:%@", _deviceToken);
    //上传设备信息
    //[self toUploadDeviceInfo];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveTopMessage" object:nil];
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Regist fail%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //AudioServicesPlaySystemSound(1007); //系统的通知声音
   // AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveTopMessage" object:nil];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
   [alert show];
}

//跳转到MainViewController
- (void) jumpToMainViewController{
    
    self.mainController = [[MainViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:_mainController];
    self.window.rootViewController = navi;
    [navi setNavigationBarHidden:YES];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTaskData" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
    [[PgyManager sharedPgyManager] checkUpdate];//检查版本更新
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//引入支付宝
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      NSLog(@"result = %@",resultDic);
                                                  }]; }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return YES;
}

//自动登录
- (void)autoLogin
{    
    NSString *username = [CommonUtil getObjectFromUD:@"loginusername"];
    NSString *password = [CommonUtil getObjectFromUD:@"loginpassword"];
    
    if ([CommonUtil isEmpty:username] || [CommonUtil isEmpty:password]) {
        [self needLogin:nil];
        return;
    }
    self.flgAutoLogin = YES;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"Login" forKey:@"action"];
    [request setPostValue:username forKey:@"loginid"]; // 手机号码
    [request setPostValue:password forKey:@"password"]; // 密码
//    [request setDidFinishSelector:@selector(requestLoginFinished:)];
//    [request setDidFailSelector:@selector(requestLoginFailed:)];
    [request startSynchronous];
//}
//
//- (void)requestLoginFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        
        // 取出对应的userInfo数据
        NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
        user = [result objectForKey:@"UserInfo"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:user key:@"userInfo"];
        
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.userid = user[@"coachid"];
        [app toUploadDeviceInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTaskData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
        
        [self jumpToMainViewController];
    } else {
        if(![CommonUtil isEmpty:message])
            [self needLogin:message];
        else
            [self needLogin:nil];
    }
}

// 服务器请求失败
- (void)requestLoginFailed:(ASIHTTPRequest *)request {
    [self needLogin:@"自动登录失败, 请检查您的网络"];
}

- (void)needLogin :(NSString*)message {    
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    viewController.errMessage = message;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navi;
    [navi setNavigationBarHidden:YES];
    [self.window makeKeyAndVisible];
}

#pragma mark - 接口
/* 上传设备号 */
- (void)toUploadDeviceInfo {
    //NSLog(@"-----%@",self.deviceToken);
    //NSString *userid = [CommonUtils stringForId:[CommonUtils getLoginInfo:@"userid"]];
    // 取出教练ID
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSystemServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"UpdatePushInfo" forKey:@"action"];
    
     NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *coachId  = [ds objectForKey:@"coachid"];
        if ([CommonUtil isEmpty:coachId] || [CommonUtil isEmpty:self.deviceToken]) {
            return;
        }
    
    [request setPostValue:coachId forKey:@"userid"];   // 教练ID
    [request setPostValue:@"1" forKey:@"usertype"];      // 用户类型 1.教练  2 学员
    [request setPostValue:@"1" forKey:@"devicetype"];           // 设备类型 0安卓  1IOS
    [request setPostValue:self.deviceToken forKey:@"devicetoken"];  // iphone的devicetoken
    [request startAsynchronous];
}



//获取准教车型
- (void)getModelList{
   
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 1;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetCarModel" forKey:@"action"];
    [request startAsynchronous];
}

// 获取投诉原因
- (void)getReason {
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kSorderServlet]];
    request.tag = 2;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetComplaintReason" forKey:@"action"];
    
    [request setPostValue:@"1" forKey:@"type"];        // 获取方 1.教练  2.学员
    
    [request startAsynchronous];
    //[DejalBezelActivityView activityViewForView:self.view];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if(request.tag == 1){
        NSArray *modelList = result[@"modellist"];
        [CommonUtil saveObjectToUD:modelList key:@"modellist"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateModelList" object:nil];
        }else if(request.tag == 2){
           
        }else{
             NSLog(@"上传设备号 OK");
        }
    }
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getModelList" object:nil];
}

#pragma mark - 定位 BMKLocationServiceDelegate
- (void)startLocation {
    if (_locService == nil) {
        //定位 初始化BMKLocationService
        _locService = [[BMKLocationService alloc] init];
        _locService.delegate = self;

    }
    //启动LocationService
    [_locService startUserLocationService];
}

/**
 *用户位置更新后，会调用此函数(无法调用这个方法，可能更新的百度地图.a文件有关)
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
    _userCoordinate = userLocation.location.coordinate;
    if (_userCoordinate.latitude == 0 || _userCoordinate.longitude == 0) {
        NSLog(@"位置不正确");
        return;
    } else  {
        [_locService stopUserLocationService];
    }
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
        NSLog(@"地理编码检索失败");
    }
}

/**
 *用户位置更新后，会调用此函数(调用这个方法，可能更新的百度地图.a文件有关)
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateBMKUserLocation lat %f,long %f, sutitle: %@",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.subtitle);
    _userCoordinate = userLocation.location.coordinate;
    if (_userCoordinate.latitude == 0 || _userCoordinate.longitude == 0) {
        NSLog(@"位置不正确");
        return;
    } else  {
        [_locService stopUserLocationService];
    }
    
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
        NSLog(@"地理编码检索失败");
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    NSLog(@"定位失败%@", error);
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == BMK_SEARCH_NO_ERROR) {
        self.locationResult = result;
        
        [self updateUserAddress];
        self.cityName = result.addressDetail.city;
        self.address = result.address;
        self.area = [NSString stringWithFormat:@"%@%@", result.addressDetail.province, result.addressDetail.city];
    }
}

- (void) updateUserAddress{
    if(![CommonUtil isEmpty:self.deviceToken] && self.locationResult){
        NSString *provience = self.locationResult.addressDetail.province;
        NSString *city = self.locationResult.addressDetail.city;
        NSString *area = self.locationResult.addressDetail.district;
        
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[OpenUDID value] forKey:@"openid"];
        [params setObject:@"1" forKey:@"devicetype"];
        [params setObject:@"1" forKey:@"usertype"];
        [params setObject:[NSString stringWithFormat:@"%@%@",version,buildVersion] forKey:@"appversion"];
        [params setObject:provience forKey:@"province"];
        [params setObject:city forKey:@"city"];
        [params setObject:area forKey:@"area"];
        
        
        NSString *uri = @"/system?action=UpdateUserLocation";
        NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        
    }
}

@end
