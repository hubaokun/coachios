//
//  RelatedDataViewController.m
//  guangda
//
//  Created by Dino on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RelatedDataViewController.h"
#import "RelatedDataTableViewCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MainViewController.h"
#import "TaskListViewController.h"
#import "CZPhotoPickerController.h"
#import "MyViewController.h"
#import "LoginViewController.h"

@interface RelatedDataViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *relatedContentView;
@property (strong, nonatomic) IBOutlet UITextField *IdentityNumber;     // 身份证号
@property (strong, nonatomic) IBOutlet UITextField *coachNumber;        // 教练证号
@property (strong, nonatomic) IBOutlet UITextField *carType;            // 车型
@property (strong, nonatomic) IBOutlet UITextField *time;               // 制证时间

@property (strong, nonatomic) IBOutlet UIButton *submitBtn;             // 提交

// 相关证件按钮
// 身份证
@property (strong, nonatomic) IBOutlet UIImageView *idCardImageView;  // 正面
@property (strong, nonatomic) IBOutlet UIImageView *idCardBackImageView;  // 反面
@property (strong, nonatomic) IBOutlet UIButton *idCardBtn;
@property (strong, nonatomic) IBOutlet UIButton *idCardBackBtn;

// 教练证件
@property (strong, nonatomic) IBOutlet UIImageView *cardImageView; // 正面
@property (strong, nonatomic) IBOutlet UIImageView *cardBackImageView; // 反面
@property (strong, nonatomic) IBOutlet UIButton *cardBackBtn;
@property (strong, nonatomic) IBOutlet UIButton *cardBtn;

//点击的按钮
@property (strong, nonatomic) UIButton *clickButton;

// 弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertMsgView;

//拍照，相册
@property (nonatomic, strong) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) UIImageView *clickImageView;//需要显示图片的imageview

@end

@implementation RelatedDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    
    self.relatedContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 660);
    [self.scrollView addSubview:self.relatedContentView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.scrollView.contentSize = CGSizeMake(0, 660+64);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
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
        if (self.clickImageView != nil) {
            self.clickImageView.image = image;
            if (self.clickButton != nil) {
                [self.clickButton setTitle:@"" forState:UIControlStateNormal];
                self.clickButton.adjustsImageWhenDisabled = NO;
            }
        }
        [self.alertView removeFromSuperview];
    }];
}

// 跳过
- (IBAction)ignoreClick:(id)sender {
   [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSelfView" object:nil];
}

//弹框
- (IBAction)clickForAlert:(id)sender {
    //[self.numTextField resignFirstResponder];
    
    UIButton *button = (UIButton *)sender;
    self.clickButton = button;
    if (button.tag == 0){
        //教练证正面
        self.clickImageView = self.cardImageView;
    }else if (button.tag == 1){
        //身份证正面
        self.clickImageView = self.idCardImageView;
    }else if (button.tag == 2){
        //身份证反面
        self.clickImageView = self.idCardBackImageView;
    }else if (button.tag == 3){
        //教练证反面
        self.clickImageView = self.cardBackImageView;
    }else{
        self.clickImageView = nil;
        self.clickButton = nil;
    }
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
}

//关闭弹框
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertView removeFromSuperview];
}

// 上传图片
- (IBAction)clickForImage:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.tag = 0;
    
    if (button.tag == 0 && [CZPhotoPickerController canTakePhoto]) {
        //拍照
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ((self.IdentityNumber.text.length != 0)
        && (self.coachNumber.text.length != 0)
        && (self.carType.text.length != 0)
        && (self.time.text.length != 0))
    {
        [self.submitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.submitBtn.enabled = YES;
    }else{
        [self.submitBtn setTitleColor:RGB(211, 211, 211) forState:UIControlStateNormal];
        self.submitBtn.enabled = NO;
    }
}

- (IBAction)submitClick:(id)sender {

    // 获取输入框字符串
    NSString *identitynumber = self.IdentityNumber.text;
    NSString *coachnumber = self.coachNumber.text;
    NSString *cartype = self.carType.text;
    NSString *ztime = self.time.text;
    UIImage *idcardimageview = self.idCardImageView.image;
    UIImage *idcardbackimageview = self.idCardBackImageView.image;
    UIImage *cardimageview = self.cardImageView.image;
    UIImage *cardbackimageview = self.cardBackImageView.image;
    
    // 去除左右空格
    identitynumber = [identitynumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    coachnumber = [coachnumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cartype = [cartype stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    ztime = [ztime stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 判断身份证号码是否为空
    if([CommonUtil isEmpty:identitynumber])
    {
        [self makeToast:@"身份证号码不能为空"];
        return ;
    }
    // 判断教练证号是否为空
    if([CommonUtil isEmpty:coachnumber])
    {
        [self makeToast:@"教练证号不能为空"];
        return ;
    }
    // 判断准驾车型是否为空
    if([CommonUtil isEmpty:cartype])
    {
        [self makeToast:@"准驾车型不能为空"];
        return ;
    }
    // 判断制证时间是否为空
    if([CommonUtil isEmpty:ztime])
    {
        [self makeToast:@"制证时间不能为空"];
        return ;
    }
    
    // 调用接口方法
    [self relatedData:identitynumber coachNumber:coachnumber carType:cartype time:ztime idCardImageView:idcardimageview idCardBackImageView:idcardbackimageview cardImageView:cardimageview cardBackImageView:cardbackimageview];
    
  
}

#pragma mark - 接口
- (void)relatedData:(NSString *)IdentityNumber coachNumber:(NSString *)coachNumber carType:(NSString *)carType time:(NSString *)time idCardImageView:(UIImage *)idCardImageView idCardBackImageView:(UIImage *)idCardBackImageView cardImageView:(UIImage *)cardImageView cardBackImageView:(UIImage *)cardBackImageView{
    //    NSString *userid = [CommonUtils getLoginInfo:@"userid"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"PerfectCoachInfo" forKey:@"action"];
    
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];             // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    [request setPostValue:IdentityNumber forKey:@"idnum"];        // 身份证号码
    [request setPostValue:coachNumber forKey:@"coachcardnum"];    // 教练证号
    [request setPostValue:carType forKey:@"modelid"];             // 准教车型ID
    [request setPostValue:time forKey:@"ccardyear"];              // 教练证发放时间<2015-03-01>
    [request setData:UIImageJPEGRepresentation(idCardImageView, 0.75) forKey:@"cardpic1"];//身份证正面照
    [request setData:UIImageJPEGRepresentation(idCardBackImageView, 0.75) forKey:@"cardpic2"];//身份证反面照
    [request setData:UIImageJPEGRepresentation(cardImageView, 0.75) forKey:@"cardpic3"];//教练证正面照
    [request setData:UIImageJPEGRepresentation(cardBackImageView, 0.75) forKey:@"cardpic4"];//教练证反面照
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
        //        NSLog(@"list: %@", result[@"datalist"]);
        
        // 取出对应的userInfo数据
        NSDictionary *user = [[NSDictionary alloc] init];
        user = [result objectForKey:@"UserInfo"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:user key:@"userInfo"];
        [self makeToast:@"提交成功"];

        TaskListViewController *nextViewController = [[TaskListViewController alloc] initWithNibName:@"TaskListViewController" bundle:nil];
        [self.navigationController popToViewController:nextViewController animated:YES];
        
    } else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
    }else{
        
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        
        [self makeToast:message];
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
