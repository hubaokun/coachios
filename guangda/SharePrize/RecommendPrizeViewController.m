//
//  RecommendPrizeViewController.m
//  guangda
//
//  Created by Ray on 15/7/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendPrizeViewController.h"
#import "RecommendRecordViewController.h"
#import "UMSocial.h"
#import "QRCodeGenerator.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RecommendPrizeViewController ()<UMSocialUIDelegate,CLLocationManagerDelegate>
{
    NSArray *addressArray;
    NSString *address;
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
}
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIImageView *CodeImage; //二维码图片
@property (strong, nonatomic) IBOutlet UIButton *CodeButton;     //邀请码
@property (strong, nonatomic) IBOutlet UIButton *recommendFriendButton;

@property (strong, nonatomic) IBOutlet UILabel *footLabel1;   //底部label1
@property (strong, nonatomic) IBOutlet UILabel *footLabel;    //底部label2

- (IBAction)clickForRecord:(id)sender;
- (IBAction)clickForRecommendFriend:(id)sender;
@end

@implementation RecommendPrizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    [self.CodeButton setTitle:[NSString stringWithFormat:@"c%@",[[userInfo[@"invitecode"] description] lowercaseString]] forState:UIControlStateNormal];//邀请码

    //圆角
    self.recommendFriendButton.layer.cornerRadius = 4;
    self.recommendFriendButton.layer.masksToBounds = YES;
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    if ([userInfo[@"realname"] isEqualToString:@""]) {
        
    }
    self.CodeImage.image = [QRCodeGenerator qrImageForString:[[NSString stringWithFormat:@"http://www.xiaobaxueche.com/share.jsp?code=%@&user=%@",self.CodeButton.titleLabel.text,userInfo[@"realname"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] imageSize:self.CodeImage.frame.size.height];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *str1 = [NSString stringWithFormat:@"◉ 推荐其他教练加盟小巴，在被推荐教练通过审核并开课后，可获赠%@元，3个工作日内到账户余额。",app.crewardamount];
    NSString *str2 = [NSString stringWithFormat:@"◉ 开课成功后，被推荐教练首次订单完成，3个工作日内您可再获赠%@元到账户余额。",app.orewardamount];
    if ([app.crewardamount intValue] == 0) {
        if ([app.orewardamount intValue] == 0) {
            self.footLabel.hidden = YES;
            self.footLabel1.hidden = YES;
        }else{
            self.footLabel1.hidden = NO;
            self.footLabel1.text = str2;
            self.footLabel.hidden = YES;
        }
    }else{
        if ([app.orewardamount intValue] == 0) {
            self.footLabel.hidden = YES;
        }else{
            self.footLabel.hidden = NO;
            self.footLabel.text = str2;
        }
        self.footLabel1.text = str1;
    }
    
    [self setupLocationManager];
    
}


#pragma mark - private
- (void)showMainView{
    //    scrollFrame = self.view.frame;
    
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footLabel.frame.origin.y + CGRectGetHeight(self.footLabel.frame) + 20);
}



//跳转到分享记录
- (IBAction)clickForRecord:(id)sender {
    RecommendRecordViewController *nextViewController = [[RecommendRecordViewController alloc] initWithNibName:@"RecommendRecordViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
//跳转到分享给好友
- (IBAction)clickForRecommendFriend:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"55aa05f667e58ec7dc005698"
                                      shareText:[NSString stringWithFormat:@"小巴学车，只因改变\n加入小巴，月入过万"]
                                     shareImage:[UIImage imageNamed:@"300-icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil]
                                       delegate:self];
    NSString *getURL = [[NSString stringWithFormat:@"http://www.xiaobaxueche.com/share.jsp?code=%@&user=%@",self.CodeButton.titleLabel.text,userInfo[@"realname"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [UMSocialData defaultData].extConfig.qqData.shareText = @"小巴学车，只因改变\n加入小巴，月入过万";
    [UMSocialData defaultData].extConfig.qqData.title = [NSString stringWithFormat:@"%@邀请您加入小巴学车",userInfo[@"realname"]];
    [UMSocialData defaultData].extConfig.qqData.url = getURL;
    [UMSocialData defaultData].extConfig.qzoneData.title = [NSString stringWithFormat:@"%@邀请您加入小巴学车",userInfo[@"realname"]];
    [UMSocialData defaultData].extConfig.qzoneData.shareText = @"小巴学车，只因改变\n加入小巴，月入过万";
    [UMSocialData defaultData].extConfig.qzoneData.url = getURL;
    [UMSocialData defaultData].extConfig.wechatSessionData.shareText = @"小巴学车，只因改变\n加入小巴，月入过万";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [NSString stringWithFormat:@"%@邀请您加入小巴学车",userInfo[@"realname"]];
    [UMSocialData defaultData].extConfig.wechatSessionData.url = getURL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = [NSString stringWithFormat:@"%@邀请您加入小巴学车",userInfo[@"realname"]];
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = @"小巴学车，只因改变\n加入小巴，月入过万";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = getURL;
    
    [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"快来加入小巴学车，月入过万！  %@",getURL];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.xiaobaxueche.com/images/share.png"]]];
    [UMSocialData defaultData].extConfig.sinaData.shareImage = image;
    
    
}
//定位
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    checkinLocation = newLocation;
    //do something else
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"failed with error: %@", error);
             return;
         }
         if(placemarks.count > 0)
         {
             for(CLPlacemark *placemark in placemarks)
             {
                 NSLog(@"%@",placemark.addressDictionary);
                 NSLog(@"国家：%@",[placemark.addressDictionary valueForKey:@"Country"]);
                 NSLog(@"省：%@",[placemark.addressDictionary valueForKey:@"State"]);
                 NSLog(@"市：%@",[placemark.addressDictionary valueForKey:@"City"]);
                 NSLog(@"区：%@",[placemark.addressDictionary valueForKey:@"SubLocality"]);
                 NSLog(@"街道：%@",[placemark.addressDictionary valueForKey:@"Street"]);
                 
                 //             NSString *State = [NSString stringWithFormat:@"%@",[placemark.addressDictionary valueForKey:@"State"]];
                 NSString *City = [NSString stringWithFormat:@"%@",[placemark.addressDictionary valueForKey:@"City"]];
                 NSString *SubLocality = [NSString stringWithFormat:@"%@-%@",City,[placemark.addressDictionary valueForKey:@"SubLocality"]];
                 NSString *Street = [NSString stringWithFormat:@"%@-%@",SubLocality,[placemark.addressDictionary valueForKey:@"Street"]];
                 
                 addressArray = [[NSArray alloc]initWithObjects:City,SubLocality,Street,nil];
//                 [self makeToast:[NSString stringWithFormat:@"省：%@市：%@区：%@",[placemark.addressDictionary valueForKey:@"State"],[placemark.addressDictionary valueForKey:@"City"],[placemark.addressDictionary valueForKey:@"SubLocality"]]];
             }
         }else{
             [locationManager startUpdatingLocation];
         }
     }];
}


- (void) setupLocationManager {
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        locationManager.delegate = self;
        locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
}
//剪贴板功能
- (IBAction)copyCode:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *stringToCopy = self.CodeButton.titleLabel.text;
    [pasteboard setString:stringToCopy];
    [self makeToast:@"已复制到剪贴板，长按输入框黏贴"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
