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
@interface RecommendPrizeViewController ()<UMSocialUIDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIImageView *CodeImage; //二维码图片
@property (strong, nonatomic) IBOutlet UILabel *CodeLabel;     //邀请码
@property (strong, nonatomic) IBOutlet UIButton *recommendFriendButton;
@property (strong, nonatomic) IBOutlet UILabel *footLabel;    //底部label

- (IBAction)clickForRecord:(id)sender;
- (IBAction)clickForRecommendFriend:(id)sender;
@end

@implementation RecommendPrizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    self.CodeLabel.text = [NSString stringWithFormat:@"c%@",[[userInfo[@"invitecode"] description] lowercaseString]];
    //圆角
    self.recommendFriendButton.layer.cornerRadius = 4;
    self.recommendFriendButton.layer.masksToBounds = YES;
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    if ([userInfo[@"realname"] isEqualToString:@""]) {
        
    }
    self.CodeImage.image = [QRCodeGenerator qrImageForString:[[NSString stringWithFormat:@"http://www.xiaobaxueche.com/share.jsp?code=%@&user=%@",self.CodeLabel.text,userInfo[@"realname"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] imageSize:self.CodeImage.frame.size.height];
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




- (IBAction)clickForRecord:(id)sender {
    RecommendRecordViewController *nextViewController = [[RecommendRecordViewController alloc] initWithNibName:@"RecommendRecordViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)clickForRecommendFriend:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"55aa05f667e58ec7dc005698"
                                      shareText:[NSString stringWithFormat:@"小巴学车，只因改变\n加入小巴，月入过万"]
                                     shareImage:[UIImage imageNamed:@"300-icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatTimeline,UMShareToWechatSession,nil]
                                       delegate:self];
    NSString *getURL = [[NSString stringWithFormat:@"http://www.xiaobaxueche.com/share.jsp?code=%@&user=%@",self.CodeLabel.text,userInfo[@"realname"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
