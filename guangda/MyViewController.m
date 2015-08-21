//
//  MyViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyViewController.h"
#import "MyComplainViewController.h"
#import "MyEvaluationViewController.h"
#import "MyMessageViewController.h"
#import "MyInfoViewController.h"
#import "SetAddrViewController.h"
#import "SetAddrViewController.h"
#import "LoginViewController.h"
#import "SetViewController.h"
#import "CoachInfoViewController.h"
#import "CZPhotoPickerController.h"
#import "SetTeachViewController.h"
#import "AmountDetailViewController.h"
#import "MyTicketDetailViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TQStarRatingView.h"
#import "MyStudentViewController.h"
#import "LoginViewController.h"
#import "APAuthV2Info.h"
#import "RecommendPrizeViewController.h"
#import "ConvertCoinViewController.h"
#import "UILabel+StringFrame.h"
@interface MyViewController () <UITextFieldDelegate, UIScrollViewDelegate> {
    CGRect _oldFrame1;
    CGRect _oldFrame2;
    NSString *updatePrice;
    NSString *getPrice;//取现金额
}
@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) IBOutlet UIView *checkView;           // 验证教练资格视图
@property (strong, nonatomic) IBOutlet UIView *getMoneyView;        // 申请金额视图
@property (strong, nonatomic) IBOutlet UIView *commitView;          // 提交申请
@property (strong, nonatomic) IBOutlet UIView *successAlertView;    // 提交成功提示
@property (strong, nonatomic) IBOutlet UIView *priceAndAddrView;    // 选择设置价格&上车地址&教学内容
@property (strong, nonatomic) IBOutlet UIView *priceAndAddrBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceWidthConstraint;//价格宽度约束

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITextField *moneyYuanField; // 取钱

//头像
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;//通过审核页面的头像
@property (strong, nonatomic) IBOutlet UIImageView *checkLogoImageView;//未通过审核的头像
@property (strong, nonatomic) IBOutlet UILabel *checkNameLabel;

//余额
@property (strong, nonatomic) IBOutlet UIButton *moneyBtn;//余额
@property (strong, nonatomic) IBOutlet UILabel *cashLabel;          // 保证金及冻结金额

//小巴券
@property (strong, nonatomic) IBOutlet UILabel *xiaobaTicketLabel;
@property (strong, nonatomic) IBOutlet UIButton *convertButton;
//小巴币
@property (strong, nonatomic) IBOutlet UILabel *xiaobaCoinLabel;
@property (strong, nonatomic) IBOutlet UIButton *coinConvertButton;

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertPhotoView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;

//取钱弹框
@property (strong, nonatomic) IBOutlet UILabel *alertMoneyLabel;//余额
@property (strong, nonatomic) IBOutlet UILabel *moneyDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyTitleLabel;

//充值
@property (strong, nonatomic) IBOutlet UIView *rechargeView;
@property (strong, nonatomic) IBOutlet UITextField *rechargeYuanTextField;
@property (strong, nonatomic) IBOutlet UIButton *rechargeBtn;

//参数
@property (strong, nonatomic) UIImage *changeLogoImage;//修改后的头像

//消息条数
@property (strong, nonatomic) IBOutlet UILabel *complaintLabel;
@property (strong, nonatomic) IBOutlet UILabel *evaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UIView *numView;
@property (strong, nonatomic) TQStarRatingView *starView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *crashLabelWidth;

@property (strong, nonatomic) IBOutlet UIView *coinRuleView;


- (IBAction)clickForRecommendPrize:(id)sender;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    
    // 注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogOut:) name:@"LogOut" object:nil];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self registerForKeyboardNotifications];
    
    //设置圆角
    self.alertDetailView.layer.cornerRadius = 4;
    self.alertDetailView.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMessageCount) name:@"ReceiveTopMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAlert) name:@"openAlert" object:nil];
    
    self.moneyYuanField.delegate = self;
    
    //圆角
    self.rechargeBtn.layer.cornerRadius = 4;
    self.rechargeBtn.layer.masksToBounds = YES;
    self.convertButton.layer.cornerRadius = 2;
    self.convertButton.layer.masksToBounds = YES;
    self.coinConvertButton.layer.cornerRadius = 2;
    self.coinConvertButton.layer.masksToBounds = YES;
}
- (void)changeMessageCount {
    [self getMessageCount];
}
-(void)backupgroupTap:(id)sender{
    [self.moneyYuanField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.mainScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.mainScrollView.contentSize = CGSizeMake(0, [UIScreen mainScreen].bounds.size.height + 80);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getMessageCount];
    [self settingView];
    [self updateMoney];
    
}
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    self.strokeImageView.hidden = NO;
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

- (void)settingView {
    
    self.getMoneyView.frame = [UIScreen mainScreen].bounds;
    
    //判断该用户是否通过审核
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *state = [userInfo[@"state"] description];//2:通过审核
    NSString *logoUrl = userInfo[@"avatarurl"];//头像
    NSString *name = userInfo[@"realname"];
    NSString *phone = userInfo[@"phone"];//手机号
    //培训时长
    NSString *totalTime = [userInfo[@"totaltime"] description];
    totalTime = [CommonUtil isEmpty:totalTime]?@"0":totalTime;
    state = @"2";//全部显示的为已经通过审核的UI
    
    if ([state intValue] == 2) {
        self.dataView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)+80);
        [self.mainScrollView addSubview:self.dataView];
        self.mainScrollView.userInteractionEnabled=YES;
        
        NSString *money = [userInfo[@"money"] description];//余额
//        NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
//        NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
        
        //头像
        self.strokeImageView.hidden = YES;
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image != nil) {
                self.logoImageView.layer.cornerRadius = self.logoImageView.bounds.size.width/2;
                self.logoImageView.layer.masksToBounds = YES;
//                [self updateLogoImage:self.logoImageView];
            }
        }];
        
        //昵称
        if (name.length == 0) {
           self.nameLabel.text = @"未设置";
        }else{
           self.nameLabel.text = name;
        }
        
        self.phoneLabel.text = phone;
        self.trainTimeLabel.text = [NSString stringWithFormat:@"已累计培训%@学时",totalTime];
        
        //余额
        if ([CommonUtil isEmpty:money]) {
            money = @"0";
        }
        NSString *money1 = [NSString stringWithFormat:@"%@元", money];
//        [self.moneyBtn setTitle:money forState:UIControlStateNormal];
        
//        NSInteger moneyf = 0;
//        NSInteger fmoneyf = 0;
//        NSInteger gmoneyf = 0;
//        
//        // 保证金及冻结金额
//        if (![CommonUtil isEmpty:gMoney]){
//            gmoneyf = [gMoney integerValue];
//        }
//        if (![CommonUtil isEmpty:moneyFrozen]) {
//            fmoneyf = [moneyFrozen integerValue];
//        }
//        
//        if (![CommonUtil isEmpty:userInfo[@"money"]]) {
//            moneyf = [userInfo[@"money"] integerValue];
//        }
//        
//        NSInteger temp = moneyf - gmoneyf;
//        if(temp < 0){
//            temp = 0;
//        }
//        
//        
//        gMoney = [NSString stringWithFormat:@"%ld",(long)temp];
//        moneyFrozen = [NSString stringWithFormat:@"%ld",(long)fmoneyf];
//        
//        NSString *moneyStr = [NSString stringWithFormat:@"(%@元可提现 / %@元冻结金额)", gMoney, moneyFrozen];
//        
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:moneyStr];
//        [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(1,gMoney.length)];
//        [str addAttribute:NSForegroundColorAttributeName value:RGB(228, 228, 228) range:NSMakeRange(6 + gMoney.length,1)];
//        [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(moneyStr.length - 6 - moneyFrozen.length,moneyFrozen.length)];
        
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:money1];
        [str1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0, money.length)];
        [str1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(money.length, 1)];
        self.cashLabel.attributedText = str1;
        
        //小巴券时间
        int couponhour = [userInfo[@"couponhour"] intValue];
        
        NSString *xiaobaTicketTime = [NSString stringWithFormat:@"%d张", couponhour];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:xiaobaTicketTime];
        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(0,[NSString stringWithFormat:@"%d",couponhour].length)];
        [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange([NSString stringWithFormat:@"%d",couponhour].length, 1)];
        self.xiaobaTicketLabel.attributedText = string;
        
        //小巴币个数
        NSString *coinnum = [userInfo[@"coinnum"] description];
        NSString *coinnumStr;
        if (coinnum) {
            coinnumStr = [NSString stringWithFormat:@"%@个",coinnum];
        }else{
            coinnum = @"0";
            coinnumStr = [NSString stringWithFormat:@"%@个",coinnum];
        }
        
        NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:coinnumStr];
        [string2 addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(0,coinnum.length)];
        [string2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(coinnum.length, 1)];
        self.xiaobaCoinLabel.attributedText = string2;
        
        //
        float score = [userInfo[@"score"] floatValue];
        if(!self.starView){
            UILabel *label1 = [UILabel new];
            label1.text = self.nameLabel.text;
            label1.font =  [UIFont systemFontOfSize:20];
            label1.numberOfLines = 0;        // 设置无限换行
            CGSize size1 = [label1 boundingRectWithSize:CGSizeMake(0, self.nameLabel.frame.size.height)];
            self.starViewConstraint.constant = -200+size1.width+10;
            CGRect rect = self.priceAndAddrBar.bounds;
            rect.origin.y = 3;
            rect.size.height = 15;
            rect.size.width = 103;
            self.starView = [[TQStarRatingView alloc] initWithFrame:rect numberOfStar:5];
            [self.priceAndAddrBar addSubview:self.starView];
        }
        [self.starView changeStarForegroundViewWithScore:score];
        
    }else{
        //未通过审核
        self.checkView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        [self.view addSubview:self.checkView];//显示未通过审核的页面
        [self.checkLogoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"]];
        [self performSelector:@selector(updateLogoImage:) withObject:self.checkLogoImageView afterDelay:0.1f];
        self.checkNameLabel.text = name;//名称
    }
    
}

//显示设置地址价格的弹框
- (void)openAlert{
    self.priceAndAddrView.frame = self.view.frame;
    [self.view addSubview:self.priceAndAddrView];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (void)dealloc {
    self.mainScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat _y = scrollView.contentOffset.y;
////    NSLog(@"%f", _y);
//    CGFloat scale = (MAX(self.topView.frame.size.height - _y, 64) - 64)/131.0; // 195 - 64 = 131
//    if (_y > 0 && self.topView.frame.size.height > 64.0) {
////        CGRect frame = self.topView.frame;
////        NSLog(@"_y: %f height: %f", _y, frame.size.height);
//        self.topViewHeightCon.constant = MAX(self.topView.frame.size.height - _y, 64);
//        
//        
////        self.portraitView.transform = CGAffineTransformMakeScale(1, 1);
////        self.nameLabel.transform = CGAffineTransformMakeScale(1, 1);
////        self.carAddrView.transform = CGAffineTransformMakeScale(1, 1);
////        self.polygonImageView.transform = CGAffineTransformMakeScale(1, 1);
//        
////        CGRect frame = self.portraitView.frame;
////        frame.origin.y -= _y;
////        self.portraitView.frame = frame;
////        
////        frame = self.nameLabel.frame;
////        frame.origin.y -= _y;
////        self.nameLabel.frame = frame;
////        
////        frame = self.carAddrView.frame;
////        frame.origin.y -= _y;
////        self.carAddrView.frame = frame;
////        
////        frame = self.polygonImageView.frame;
////        frame.origin.y -= _y;
////        self.polygonImageView.frame = frame;
//        
////        self.portraitView.transform = CGAffineTransformMakeScale(scale, scale);
////        self.nameLabel.transform = CGAffineTransformMakeScale(scale, scale);
////        self.carAddrView.transform = CGAffineTransformMakeScale(scale, scale);
////        self.polygonImageView.transform = CGAffineTransformMakeScale(scale * 0.25 + 0.75, scale * 0.25 + 0.75);
//        
//        self.portraitView.alpha = scale;
//        self.nameLabel.alpha = scale;
//        self.carAddrView.alpha = scale;
//        
//        scrollView.contentOffset = CGPointMake(0, 0);
//        
//    } else if (_y < 0  && self.topView.frame.size.height < 326) {
////        CGRect frame = self.topView.frame;
////        NSLog(@"_y: %f height: %f", _y, frame.size.height);
//        self.topViewHeightCon.constant = MIN(self.topView.frame.size.height - _y, 326);
//        
////        self.portraitView.transform = CGAffineTransformMakeScale(1, 1);
////        self.nameLabel.transform = CGAffineTransformMakeScale(1, 1);
////        self.carAddrView.transform = CGAffineTransformMakeScale(1, 1);
////        self.polygonImageView.transform = CGAffineTransformMakeScale(1, 1);
//        
////        CGRect frame = self.portraitView.frame;
////        frame.origin.y -= _y;
////        self.portraitView.frame = frame;
////        
////        frame = self.nameLabel.frame;
////        frame.origin.y -= _y;
////        self.nameLabel.frame = frame;
////        
////        frame = self.carAddrView.frame;
////        frame.origin.y -= _y;
////        self.carAddrView.frame = frame;
////        
////        frame = self.polygonImageView.frame;
////        frame.origin.y -= _y;
////        self.polygonImageView.frame = frame;
//        
//        self.portraitView.alpha = scale;
//        self.nameLabel.alpha = scale;
//        self.carAddrView.alpha = scale;
//        
//        scrollView.contentOffset = CGPointMake(0, 0);
//    }
}

#pragma mark - 键盘遮挡输入框处理
// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    _oldFrame1 = self.commitView.frame;
    
//    UIView *priceCommitView = [self.setPriceView viewWithTag:100];
//    _oldFrame2 = priceCommitView.frame;

    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGFloat offset = CGRectGetMaxY(self.commitView.frame) - keyboardTop + 10;

    NSTimeInterval animationDuration = 0.3f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.commitView.frame = CGRectMake(_oldFrame1.origin.x, _oldFrame1.origin.y - offset, _oldFrame1.size.width, _oldFrame1.size.height);
//    priceCommitView.frame = CGRectMake(_oldFrame2.origin.x, _oldFrame2.origin.y - offset, _oldFrame2.size.width, _oldFrame2.size.height);
    [UIView commitAnimations];

}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    self.commitView.frame = _oldFrame1;
//    UIView *priceCommitView = [self.setPriceView viewWithTag:100];
//    priceCommitView.frame = _oldFrame2;
}

#pragma mark - 拍照
- (CZPhotoPickerController *)photoController
{
    typeof(self) weakSelf = self;
    
    return [[CZPhotoPickerController alloc] initWithPresentingViewController:self withCompletionBlock:^(UIImagePickerController *imagePickerController, NSDictionary *imageInfoDict) {
        
        [weakSelf.pickPhotoController dismissAnimated:YES];
        weakSelf.pickPhotoController = nil;
        
        if (imagePickerController == nil || imageInfoDict == nil) {
            return;
        }
        
        UIImage *image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            image = [CommonUtil fixOrientation:image];
            
            [self uploadLogo:image];
        }
        
        [self.alertPhotoView removeFromSuperview];
    }];
}

#pragma mark - 按钮方法
// 通过审核
- (IBAction)clickForPass:(id)sender {
    self.hasChecked = 1;
    [self.checkView removeFromSuperview];
}



- (IBAction)closeRuleView:(id)sender {
    [self.coinRuleView removeFromSuperview];
}

// 查看小巴币/券规则
- (IBAction)clickForCoinRuleView:(id)sender {
    //    self.photoView.hidden = NO;
    self.coinRuleView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.tabBarController.view addSubview:self.coinRuleView];
}

// 更改头像
- (IBAction)clickForChangePortrait:(id)sender {
//    self.photoView.hidden = NO;
    self.alertPhotoView.frame = self.view.frame;
    [self.view addSubview:self.alertPhotoView];
}

//关闭弹框
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertPhotoView removeFromSuperview];
}

- (IBAction)clickForCamera:(id)sender {
    self.pickPhotoController = [self photoController];
    
    if ([CZPhotoPickerController canTakePhoto]) {
        //拍照
        self.pickPhotoController.allowsEditing = YES;
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        self.pickPhotoController.allowsEditing = YES;
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (IBAction)clickForAlbum:(id)sender {
    self.pickPhotoController = [self photoController];
    //相册
    self.pickPhotoController.allowsEditing = YES;
    [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 申请提现
- (IBAction)clickForMoney:(id)sender {
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去钱包下的账户管理页面设置您的支付宝账户"];
        return;
    }
    
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    
    //设置价格
    
    NSString *money = [userInfo[@"money"] description];//余额
    NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
    NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
    
    // 保证金及冻结金额
    if ([CommonUtil isEmpty:gMoney]){
        gMoney = @"0";
    }
    
    if ([CommonUtil isEmpty:moneyFrozen]) {
        moneyFrozen = @"0";
    }
    
    if ([CommonUtil isEmpty:money]) {
        moneyFrozen = @"0";
    }
    
    double lestMoney = [money doubleValue] - [gMoney doubleValue];
    if(lestMoney < 0){
        lestMoney = 0;
    }
    
    money = [NSString stringWithFormat:@"%.0f", lestMoney];
    self.alertMoneyLabel.text = [NSString stringWithFormat:@"%@元", money];
    [self.alertMoneyLabel.superview  bringSubviewToFront:self.alertMoneyLabel];
}

// 兑换小巴券
- (IBAction)clickForConvertTicket:(id)sender {
    MyTicketDetailViewController *nextController = [[MyTicketDetailViewController alloc] initWithNibName:@"MyTicketDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

//查看小巴币详情
- (IBAction)clickForCoinDetail:(id)sender {
    ConvertCoinViewController *nextController = [[ConvertCoinViewController alloc] initWithNibName:@"ConvertCoinViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

// 取消取钱
- (IBAction)clickForCancel:(id)sender {
    [self.getMoneyView removeFromSuperview];
}

//查看收支详细
- (IBAction)lookDetail:(id)sender {
    AmountDetailViewController *nextController = [[AmountDetailViewController alloc] initWithNibName:@"AmountDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

//查看小巴券明细
- (IBAction)lookTicketDetail:(id)sender {
    
}


// 提交取钱
- (IBAction)clickForCommit:(id)sender {
    
    NSString *yuan = [self.moneyYuanField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:yuan]) {
        [self makeToast:@"请输入您要提现的金额"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    
    if ([yuan intValue] == 0) {
        [self makeToast:@"请输入您要提现的金额"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    [self.moneyYuanField resignFirstResponder];
    
    NSString *price = [NSString stringWithFormat:@"%d", [yuan intValue]];
    
    //设置价格
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *money = [userInfo[@"money"] description];//余额
    NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
    NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
    
    if ([CommonUtil isEmpty:money]) {
        money = @"0";
    }
    
    // 保证金及冻结金额
    if ([CommonUtil isEmpty:gMoney]){
        gMoney = @"0";
    }
    if ([CommonUtil isEmpty:moneyFrozen]) {
        moneyFrozen = @"0";
    }
    
    if ([price doubleValue] <50) {
        //提现金额不得小于50
        [self makeToast:@"请输入大于50元的数额进行提现"];
        return;
    }
    
    //判断是否有这么多金额可以取    moneyFrozen//不用减去冻结金额
    if ([price doubleValue] < [money doubleValue] - [gMoney doubleValue]) {
        //提现金额足够
        [self getMoney:price];
        getPrice = price;
        self.moneyTitleLabel.text = @"提交成功";
        self.moneyDetailLabel.text = [NSString stringWithFormat:@"您申请的%@元金额已提交成功，请等待审核，我们会在3个工作日内联系您！", price];
        
    }else{
        //提现金额不足
        [self makeToast:@"您的可提现金额不足，请重新输入"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
}

// 关闭提交成功提示
- (IBAction)clickForClose:(id)sender {
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.getMoneyView removeFromSuperview];
}

- (IBAction)clickForClosePriceAndAddr:(id)sender {
    [self.priceAndAddrView removeFromSuperview];
}

// 设置价格
- (IBAction)clickForSetPrice:(id)sender {
//    [self.priceAndAddrView removeFromSuperview];
//    self.setPriceView.frame = [UIScreen mainScreen].bounds;
//    [self.view addSubview:self.setPriceView];
//    
//    //设置价格
//    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
//    NSString *price = [userInfo[@"price"] description];
//    
//    if ([CommonUtil isEmpty:price]) {
//        self.priceYuanField.text = @"0";
//        self.priceJiaoField.text = @"0";
//    }else{
//        NSArray *priceArray = [price componentsSeparatedByString:@"."];
//        if (priceArray.count == 1){
//            self.priceYuanField.text = price;
//            self.priceJiaoField.text = @"0";
//            
//        }else if (priceArray.count > 1){
//            self.priceYuanField.text = priceArray[0];
//            self.priceJiaoField.text = priceArray[1];
//            
//        }else{
//            self.priceYuanField.text = @"0";
//            self.priceJiaoField.text = @"0";
//        }
//    }
    
}

- (IBAction)clickForCloseSetPrice:(id)sender {
//    [self.setPriceView removeFromSuperview];
}

//- (IBAction)clickForCommitPrice:(id)sender {
//    
//    [self.setPriceView removeFromSuperview];
//    
//    NSString *price = [self.priceYuanField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *jiaoPrice = [self.priceJiaoField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    if ([CommonUtil isEmpty:price] && [CommonUtil isEmpty:jiaoPrice]) {
//        [self makeToast:@"请输入价格"];
//        [self.priceYuanField becomeFirstResponder];
//        return;
//    }
//    
//    if ([price intValue] == 0 && [jiaoPrice intValue] == 0) {
//        [self makeToast:@"请输入价格"];
//        [self.priceYuanField becomeFirstResponder];
//        return;
//    }
//    
//    [self.priceYuanField resignFirstResponder];
//    [self.priceJiaoField resignFirstResponder];
//    
//    if ([CommonUtil isEmpty:jiaoPrice]) {
//        updatePrice = [NSString stringWithFormat:@"%d", [price intValue]];
//    }else{
//        updatePrice = [NSString stringWithFormat:@"%d.%@", [price intValue], jiaoPrice];
//    }
//    
//    [self changePrice:updatePrice];//修改价格
//}

// 我的投诉
- (IBAction)clickToMyComplainView:(id)sender {
//    MyComplainViewController *targetViewController = [[MyComplainViewController alloc] initWithNibName:@"MyComplainViewController" bundle:nil];
//    [self.navigationController pushViewController:targetViewController animated:YES];
    MyStudentViewController *nextViewController = [[MyStudentViewController alloc] initWithNibName:@"MyStudentViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

// 我的评价
- (IBAction)clickToMyEvaluateView:(id)sender {
    MyEvaluationViewController *targetViewController = [[MyEvaluationViewController alloc] initWithNibName:@"MyEvaluationViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 我的通知
- (IBAction)clickToMyMessageView:(id)sender {
    MyMessageViewController *targetViewController = [[MyMessageViewController alloc] initWithNibName:@"MyMessageViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 我的资料
- (IBAction)clickToMyInfoView:(id)sender {
    MyInfoViewController *targetViewController = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 上车地址设置
- (IBAction)clickToSetAddrView:(id)sender {
//    [self.priceAndAddrView removeFromSuperview];
    SetAddrViewController *targetViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 教学内容设置
- (IBAction)clickToSetTeachView:(id)sender{
//    [self.priceAndAddrView removeFromSuperview];
    SetTeachViewController *targetViewController = [[SetTeachViewController alloc] initWithNibName:@"SetTeachViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
    
}

// 进入设置界面
- (IBAction)clickToSetting:(id)sender {
    SetViewController *targetViewController = [[SetViewController alloc] initWithNibName:@"SetViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

//实现消息通知方法
- (void)LogOut:(NSNotification *)notification

{
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
   
}


- (IBAction)clickForCoachMsg:(id)sender {
    CoachInfoViewController *targetViewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
    targetViewController.superViewNum = @"1";
    [self.navigationController pushViewController:targetViewController animated:YES];
}

//充值
- (IBAction)clickForChongzhi:(id)sender {
    AmountDetailViewController *nextViewController = [[AmountDetailViewController alloc] initWithNibName:@"AmountDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)removeChongzhi:(id)sender {
    [self.rechargeView removeFromSuperview];
}

//提交充值
- (IBAction)clickForChongzhiCommit:(id)sender {
    NSString *price = [self.rechargeYuanTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *jiaoPrice = [self.rechargeJiaoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:price]) {
        [self makeToast:@"请输入价格"];
        [self.rechargeYuanTextField becomeFirstResponder];
        return;
    }
    
    
    [self.rechargeYuanTextField resignFirstResponder];
//    [self.rechargeJiaoTextField resignFirstResponder];
    
//    if ([CommonUtil isEmpty:jiaoPrice]) {
//        updatePrice = [NSString stringWithFormat:@"%d", [price intValue]];
//    }else{
//        updatePrice = [NSString stringWithFormat:@"%d.%@", [price intValue], jiaoPrice];
//    }
    updatePrice = [NSString stringWithFormat:@"%d", [price intValue]];
    [self rechargeMoney:updatePrice];//修改价格
}

- (IBAction)clickForCloseKeyboard:(id)sender {
    [self.rechargeYuanTextField resignFirstResponder];
//    [self.rechargeJiaoTextField resignFirstResponder];
}

#pragma mark - 接口
- (void)changePrice:(NSString *)price{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 0;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"SetPrice" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
     [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:price forKey:@"price"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];

}

//上传头像
- (void)uploadLogo:(UIImage *)image{
    [DejalBezelActivityView activityViewForView:self.view];
    
    self.changeLogoImage = image;//修改的头像
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 1;
    request.delegate = self;
    request.timeOutSeconds = 30;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangeAvatar" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setData:UIImageJPEGRepresentation(image, 0.75) forKey:@"avatar"];
    [request startAsynchronous];

}

//提现
- (void)getMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 2;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"ApplyCash" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:money forKey:@"count"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

//获取消息条数
- (void)getMessageCount{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 3;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetMessageCount" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request startAsynchronous];
}

//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kSystemServlet]];
    request.tag = 4;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"refreshUserMoney" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"userid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:@"1" forKey:@"usertype"];//用户类型 1.教练  2 学员
    [request startAsynchronous];
}

//充值
- (void)rechargeMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 5;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"Recharge" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:money forKey:@"amount"];//充值金额
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if (request.tag == 0) {
            //修改价格
            [self makeToast:@"修改价格成功"];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [dic setObject:updatePrice forKey:@"price"];
            [CommonUtil saveObjectToUD:dic key:@"userInfo"];
            
        }else if (request.tag == 1){
            [self makeToast:@"修改头像成功"];
            
            NSString *url = result[@"avatarurl"];
            url = [CommonUtil isEmpty:url]?@"":url;
            //头像
            self.strokeImageView.hidden = YES;
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image != nil) {
                    self.logoImageView.layer.cornerRadius = self.logoImageView.bounds.size.width/2;
                    self.logoImageView.layer.masksToBounds = YES;
//                    [self updateLogoImage:self.logoImageView];
                }
            }];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [dic setObject:url forKey:@"avatarurl"];
            [CommonUtil saveObjectToUD:dic key:@"userInfo"];
            
        }else if (request.tag == 2){
            //申请提现，增加冻结金额
            self.commitView.hidden = YES;
            self.successAlertView.hidden = NO;
            
//            NSInteger fmoney = [result[@"fmoney"] integerValue];
//            NSInteger money = [result[@"money"] integerValue];
//            NSInteger gmoney = [result[@"gmoney"] integerValue];
//            NSString *moneyStr = [NSString stringWithFormat:@"%ld",(long)money];
//            NSString *fmoneyStr = [NSString stringWithFormat:@"%ld",(long)fmoney];
//            NSInteger temp = money - gmoney;
//            if(temp < 0){
//                 temp = 0;
//            }
//            
//            
//            NSString *canApplyStr = [NSString stringWithFormat:@"%ld",(long)temp];
//            //刷新金额
//            NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
//            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
//            
//            [dic setObject:fmoneyStr forKey:@"money_frozen"];
//            [dic setObject:moneyStr forKey:@"money"];
//            [CommonUtil saveObjectToUD:dic key:@"userInfo"];
//            
//            NSString *str1 = [NSString stringWithFormat:@"(%@元可提现 / %@元冻结金额)", canApplyStr, fmoneyStr];
//            
//            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:str1];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(1,canApplyStr.length)];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(228, 228, 228) range:NSMakeRange(6 + fmoneyStr.length,1)];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(str1.length - 6 - fmoneyStr.length,fmoneyStr.length)];
//            
//            self.cashLabel.attributedText = str;
            NSString *money1 = [result[@"money"] description];
            NSString *money = [NSString stringWithFormat:@"%@元",money1];
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:money];
            [str1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0, money1.length)];
            [str1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(money.length, 1)];
            self.cashLabel.attributedText = str1;
            
//            NSString *moneyStr1 = [NSString stringWithFormat:@"余额：%ld元", (long)money];
//            [self.moneyBtn setTitle:moneyStr1 forState:UIControlStateNormal];
            
            //清空数据
            self.moneyYuanField.text = @"";
            
        }else if (request.tag == 3){
            //获取消息条数
            NSString *noticeCount = [result[@"noticecount"] description];//未读通知数量
            NSString *allnoticeCount = [result[@"allnoticecount"] description];//通知总数量
            NSString *complaint1 = [result[@"complaint1"] description];//投诉我的<未处理数量>
            NSString *evaluation1 = [result[@"evaluation1"] description];//评论我的<累计数量>
            NSString *evaluation2 = [result[@"evaluation2"] description];//我评论的<累计数量>
            NSString *studentcount = [result[@"studentcount"] description];//我的学员数量<累计数量>
            
            
            if ([noticeCount intValue] == 0) {
                //未读条数
                self.numView.hidden = YES;
            }else{
                if ([noticeCount intValue] > 99) {
                    noticeCount = @"99+";
                }
                self.numView.hidden = NO;
                self.numLabel.text = noticeCount;
            }
            
            NSString *complaint = [NSString stringWithFormat:@"%d位", [studentcount intValue]];
            self.complaintLabel.text = complaint;
            
            NSString *evaluation = [NSString stringWithFormat:@"评论%d条 投诉%d条", [evaluation1 intValue] + [evaluation2 intValue],[complaint1 intValue] ];
            self.evaluationLabel.text = evaluation;
            
            NSString *count = [NSString stringWithFormat:@"%d条", [allnoticeCount intValue]];
            self.noticeLabel.text = count;
            
        }else if (request.tag == 4){
            //更新余额
            NSString *money = [CommonUtil isEmpty:[result[@"money"] description]]?@"0":[result[@"money"] description];//用户余额
            NSString *fmoney = [CommonUtil isEmpty:[result[@"fmoney"] description]]?@"0":[result[@"fmoney"] description];//用户冻结金额
            NSString *gmoney = [CommonUtil isEmpty:[result[@"gmoney"] description]]?@"0":[result[@"gmoney"] description];//保证金金额(教练专有)
            NSString *couponhour = [CommonUtil isEmpty:[result[@"couponhour"] description]]?@"0":[result[@"couponhour"] description];//小巴券张数
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [userInfo setObject:money forKey:@"money"];
            [userInfo setObject:fmoney forKey:@"money_frozen"];
            [userInfo setObject:gmoney forKey:@"gmoney"];
            [userInfo setObject:couponhour forKey:@"couponhour"];
            [CommonUtil saveObjectToUD:userInfo key:@"userInfo"];
            
            //余额
            if ([CommonUtil isEmpty:money]) {
                money = @"0";
            }
//            money = [NSString stringWithFormat:@"余额：%@元", money];
//            [self.moneyBtn setTitle:money forState:UIControlStateNormal];
            
            if([CommonUtil isEmpty:couponhour]){
                couponhour = @"0";
            }
            
            NSString *xiaobaTicketTime = [NSString stringWithFormat:@"%@张", couponhour];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:xiaobaTicketTime];
            [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(0,couponhour.length)];
            [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(couponhour.length, 1)];
            self.xiaobaTicketLabel.attributedText = string;
            
            NSString *coinnum = [result[@"coinnum"] description];//小巴币个数
            
            NSString *coinnumStr = [NSString stringWithFormat:@"%@个",coinnum];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:coinnumStr];
            [string2 addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(0,coinnum.length)];
            [string2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(coinnum.length, 1)];
            self.xiaobaCoinLabel.attributedText = string2;
            
//            NSInteger temp = [result[@"money"] integerValue] - [gmoney integerValue];
//            if(temp < 0){
//               temp = 0;
//            }
//            
//            NSString *gMoney = [NSString stringWithFormat:@"%ld",(long)temp];
//            NSString *moneyStr = [NSString stringWithFormat:@"(%@元可提现 / %@元冻结金额)", gMoney, fmoney];
//            
//            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:moneyStr];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(1,gMoney.length)];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(228, 228, 228) range:NSMakeRange(6 + gMoney.length,1)];
//            [str addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(moneyStr.length - 6 - fmoney.length,fmoney.length)];
//            self.cashLabel.attributedText = str;

            NSString *money1 = [NSString stringWithFormat:@"%@元",money];
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:money1];
            [str1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0, money.length)];
            [str1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(money.length, 1)];
            self.cashLabel.attributedText = str1;
            
        }else if (request.tag == 5){
            NSString *partner = [result[@"partner"] description];//合作者身份ID
            NSString *notify_url = [result[@"notify_url"] description];//服务器异步通知页面路径
            NSString *out_trade_no = [result[@"out_trade_no"] description];//商户网站唯一订单号,表t_balance_student生成记录的ID
            NSString *subject = [result[@"subject"] description];//商品名
            NSString *seller_id = [result[@"seller_id"] description];//卖家支付宝账号
            NSString *total_fee = [result[@"total_fee"] description];//总金额
            NSString *body = [result[@"body"] description];//商品详情
            NSString *private_key = [result[@"private_key"] description];//客户私钥
            
            [self alipayForPartner:partner seller:seller_id privateKey:private_key tradeNO:out_trade_no subject:subject body:body price:total_fee notifyURL:notify_url];
        }
        
    } else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
    }else{
        if(request.tag != 4){
            if ([CommonUtil isEmpty:message]) {
                message = ERR_NETWORK;
            }
            [self makeToast:message];
        }
    }
    if (request.tag != 3){
        [DejalBezelActivityView removeViewAnimated:YES];
    }
    
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag != 4) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }
    
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - private
////设置价格
//- (void)changePriceLabel:(NSString *)price{
//    NSString *price2 = [NSString stringWithFormat:@"%@ 元/小时", price];
//    
//    CGSize size = [price2 boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.priceLabel.font} context:nil].size;
//    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 40;//20:边距 16：与箭头的距离
//    if (size.width < width) {
//        width = ceil(size.width);
//    }
//    width += 20;
//    self.priceWidthConstraint.constant = width;
//}

- (void)alipayForPartner:(NSString *)partner seller:(NSString *)seller privateKey:(NSString *)privateKey
                 tradeNO:(NSString *)tradeNO subject:(NSString *)subject body:(NSString *)body
                   price:(NSString *)price notifyURL:(NSString *)notifyURL{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
//    NSString *partner = @"";
//    NSString *seller = @"wjqee2013@163,com";//支付宝收款账号,手机号码或邮箱格式
//    NSString *privateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
    order.productName = subject; //商品标题
    order.productDescription = body; //商品描述
    order.amount = price; //商品价格
    order.notifyURL =  notifyURL; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"guangda";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self.rechargeView removeFromSuperview];
            self.rechargeYuanTextField.text = @"";
            
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            
            if ([resultStatus isEqualToString:@"9000"]) {
                [self makeToast:@"充值成功"];
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
                
                NSString *money = [CommonUtil isEmpty:[userInfo[@"money"] description]]?@"0":[userInfo[@"money"] description];//用户余额
                CGFloat totalPrice = [money floatValue] + [updatePrice floatValue];
                
                [userInfo setObject:[NSString stringWithFormat:@"%f", totalPrice] forKey:@"money"];
                
                [CommonUtil saveObjectToUD:userInfo key:@"userInfo"];
                
                //余额
                money = [NSString stringWithFormat:@"余额：%f元", totalPrice];
                [self.moneyBtn setTitle:money forState:UIControlStateNormal];
                
            }else{
                [self makeToast:@"充值失败"];
            }
        }];
    }
}
- (IBAction)clickForChangeInfo:(id)sender {
    MyInfoViewController *targetViewController = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//分享有礼
- (IBAction)clickForRecommendPrize:(id)sender {
    RecommendPrizeViewController *targetViewController = [[RecommendPrizeViewController alloc] initWithNibName:@"RecommendPrizeViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
    
}
@end
