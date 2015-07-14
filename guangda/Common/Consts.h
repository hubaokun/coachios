//
//  Consts.h
//  HunBoHuiReqeust_demo
//
//  Created by HapN on 14-10-24.
//  Copyright (c) 2014年 HapN. All rights reserved.
//

#ifndef HunBoHuiReqeust_demo_Consts_h
#define HunBoHuiReqeust_demo_Consts_h

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(1.0)]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define _screenWidth [UIScreen mainScreen].bounds.size.width


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

//#define REQUEST_HOST   @"http://192.168.1.123:8080/guangda/"        // 郭凯服务
#define REQUEST_HOST   @"http://www.xiaobakaiche.com/dadmin/"        // 正式服务器
//#define REQUEST_HOST   @"http://120.25.236.228:8080/dadmin/"          //测试服务器

#define kUserServlet        [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"cuser"]
#define kMyServlet          [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"cmy"]
#define kScheduleServlet    [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"cschedule"]
#define kTaskServlet        [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"ctask"]
#define kSystemServlet      [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"system"]
#define kSorderServlet      [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"sorder"]
#define kSuserServlet       [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"suser"]
#define kSetServlet         [NSString stringWithFormat:@"%@/%@",REQUEST_HOST,@"sset"]


#define APP_VERSION    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//新浪微博AppKey
#define kAppKey_Weibo           @"3519030991"
#define kRedirectURI_Weibo      @"http://www.jiehun.com.cn/api/weibo/_grant"

//QQ AppKey
#define kAppID_QQ               @"1103761561"


#define ERR_NETWORK             @"当前网络不稳定，请重试！"
#define NO_NETWORK              @"没有连接网络"

#define PGY_APPKEY              @"ad52d7777114fb5a1e47006123d11484"
//正式蒲公英的app id             f353cb3b650dc32604ddc957ee914ddc
//饶宏的蒲公英app id             ad52d7777114fb5a1e47006123d11484

#endif
