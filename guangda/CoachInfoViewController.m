//
//  CoachInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachInfoViewController.h"
#import "MyInfoCell.h"
#import "BigPhotoViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CZPhotoPickerController.h"
#import "DatePickerViewController.h"
#import "LoginViewController.h"
#import "SchoolSelectViewController.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import "XBProvince.h"
#import "CarModelViewController.h"
@interface CoachInfoViewController ()<UITextFieldDelegate, DatePickerViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,LocationViewControllerDelegate> {
    CGFloat _y;
    NSInteger selectRow;
    NSString *isChangeCity;
//    NSString *cityid;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UIView *idPhototView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) UIImageView *clickImageView;//需要显示图片的imageview
@property (strong, nonatomic) UILabel *clickLabel;//显示图片的文字
@property (strong, nonatomic) UIButton *clickDelBtn;
@property (strong, nonatomic) IBOutlet UIView *keepLabelView; // 动态存放label
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keepViewConstraint; // 动态存放label高度
@property (strong, nonatomic) IBOutlet UIButton *keepBtnOutlet;

@property (strong, nonatomic) IBOutlet UILabel *warmingLabel;//提示语

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;

// 身份证号码
@property (strong, nonatomic) IBOutlet UITextField *idCardField;
@property (strong, nonatomic) IBOutlet UIImageView *idCardPencilImage;

// 教练证号
@property (strong, nonatomic) IBOutlet UITextField *coachCardField;
@property (strong, nonatomic) IBOutlet UIImageView *coachCardPencilImage;

// 驾驶证号
@property (strong, nonatomic) IBOutlet UITextField *driveCardField;
@property (strong, nonatomic) IBOutlet UIImageView *driveCardPencilImage;

// 汽车年检证号
@property (strong, nonatomic) IBOutlet UITextField *carCheckField;
@property (strong, nonatomic) IBOutlet UIImageView *carCheckPencilImage;

// 教学用车牌照
@property (strong, nonatomic) IBOutlet UITextField *teachCarField;
@property (strong, nonatomic) IBOutlet UIImageView *teachCarPencilImage;

// 教学用车型号
@property (strong, nonatomic) IBOutlet UITextField *teachCarCardField;

// 准教车型
@property (strong, nonatomic) IBOutlet UIButton *C1Button;
@property (strong, nonatomic) IBOutlet UIButton *C2Button;
@property (strong, nonatomic) IBOutlet UILabel *coachCarLabel;

@property (strong, nonatomic) IBOutlet UIView *carModelView;
@property (strong, nonatomic) IBOutlet UITextField *carModelField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carModelViewHeight;
@property (strong, nonatomic) IBOutlet UIView *selectView; // 选择器
@property (nonatomic, strong) IBOutlet UIPickerView *carModelPicker;
@property (strong, nonatomic) NSMutableArray *carModelArray;      // 准教车型
@property (strong, nonatomic) NSMutableArray *myCarModelArray;
@property (strong, nonatomic) IBOutlet UIButton *teachCarBtnOutlet;
@property (strong, nonatomic) NSMutableArray *TeachCarModeArray;  // 教学用车型号
@property (strong, nonatomic) NSMutableArray *carSchoolArray;

@property (strong, nonatomic) IBOutlet UIButton *idCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *idCardBackDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachCarCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *carCheckDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *carCheckBackDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachTureIconDelBtn;

// 身份证到期时间
@property (strong, nonatomic) IBOutlet UIView *cardMadeTimeView;
@property (strong, nonatomic) IBOutlet UITextField *cardMadeTimeField;

// 教练证到期时间
@property (strong, nonatomic) IBOutlet UITextField *coachMadeTimeField;

// 驾驶证到期时间
@property (strong, nonatomic) IBOutlet UITextField *driveMadeTimeField;

// 汽车年检证到期时间
@property (strong, nonatomic) IBOutlet UITextField *carCheckMadeTimeField;

/*  以下4个view内部各有5个子控件，其tag为:
 image:  100 200 300 400
 label:  101 201 301 401
 editBtn:102 202 302 402
 bigPhotoBtn:103 203 303 403
 deleteBtn:104 204 304 404
 */
@property (strong, nonatomic) IBOutlet UIView *idCardFrontView;     // 身份证正面
@property (strong, nonatomic) IBOutlet UIView *idCardBackView;      // 身份证反面
@property (strong, nonatomic) IBOutlet UIView *coachCardView;       // 教练证
@property (strong, nonatomic) IBOutlet UIView *coachCarCardView;    // 教练车驾驶证
@property (strong, nonatomic) IBOutlet UIView *carCheckView;      // 车辆行驶证正面
@property (strong, nonatomic) IBOutlet UIView *carCheckBackView;       // 车辆行驶证反面
@property (strong, nonatomic) IBOutlet UIView *coachTureIconView;    // 教练真实头像

@property (strong, nonatomic) IBOutlet UILabel *idCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *idCardBackLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachCarCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *carCheckLabel;
@property (strong, nonatomic) IBOutlet UILabel *carCheckBackLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachTureIconLabel;

//证件图片
@property (strong, nonatomic) IBOutlet UIImageView *idCardImageView; // 身份证正面
@property (strong, nonatomic) IBOutlet UIImageView *idCardBackImageView;  // 身份证反面
@property (strong, nonatomic) IBOutlet UIImageView *coachCardImageView; // 教练证
@property (strong, nonatomic) IBOutlet UIImageView *coachCarCardImageView; // 教练车驾驶证
@property (strong, nonatomic) IBOutlet UIImageView *carCheckImageView; // 车辆年检证&车辆行驶证正面
@property (strong, nonatomic) IBOutlet UIImageView *carCheckBackImageView; // 车辆行驶证反面
@property (strong, nonatomic) IBOutlet UIImageView *coachTureIconImageView; // 教练真实照片

//参数
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (strong, nonatomic) NSArray *testInfo;
@property (strong, nonatomic) NSMutableDictionary *msgDic;//参数
@property (strong, nonatomic) NSString *userState;//2：通过审核（不可修改数据）

// 省市区
@property (strong, nonatomic) XBProvince *selectProvince;
@property (strong, nonatomic) XBCity *selectCity;
@property (strong, nonatomic) XBArea *selectArea;
@property (strong, nonatomic) NSString *selectProvinceid;
@property (strong, nonatomic) NSString *selectCityid;
@property (strong, nonatomic) NSString *selectAreaid; //地区id
@property (strong, nonatomic) IBOutlet UILabel *cityNameLabel;


// 返回按钮
@property (strong, nonatomic) IBOutlet UIButton *backBtn;

// 时间
@property (strong, nonatomic) UITextField *dateTimeTextField;
@property (assign, nonatomic) NSInteger dataTag;
@property (assign, nonatomic) NSInteger teachCarTag;

// 选择教学车型ID
@property (copy, nonatomic) NSString *teachCarID;
@property (copy, nonatomic) NSString *carSchoolID;

- (IBAction)clickForCommit:(id)sender;
//- (IBAction)clickForCarModel:(id)sender;
//- (IBAction)clickForCardMadeTime:(id)sender;


- (IBAction)clickForPhoto:(UIButton *)sender;
//驾校
@property (strong, nonatomic) IBOutlet UILabel *schoolTextFiled;
- (IBAction)clickForSelectSchool:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *selectSchoolButton;

@property (copy, nonatomic) NSString *schoolid;

@end

@implementation CoachInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mainScrollView contentSizeToFit];
    [self getCoachDetail];
//    [self getCarMode];
    // _mainViewHeight.constant = 1360;
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    self.userState = [userInfo[@"state"] description];
    self.warmingLabel.text = @"正在查询您的审核状态...";
    _myCarModelArray = [[NSMutableArray alloc] init];
    self.msgDic = [NSMutableDictionary dictionary];
    _TeachCarModeArray = [[NSMutableArray alloc] init];
    _carModelArray = [[NSMutableArray alloc] init];
    _teachCarID = @"";
    _carSchoolArray = [NSMutableArray array];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    //设置弹框圆角
    self.alertDetailView.layer.cornerRadius = 5;
    self.alertDetailView.layer.masksToBounds = YES;
    
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCarModelData) name:@"updateModelList" object:nil];
    
    [self.C1Button setImage:[UIImage imageNamed:@"coupon_unselected"] forState:UIControlStateNormal];
    [self.C1Button setImage:[UIImage imageNamed:@"coupon_selected"] forState:UIControlStateSelected];
    [self.C2Button setImage:[UIImage imageNamed:@"coupon_unselected"] forState:UIControlStateNormal];
    [self.C2Button setImage:[UIImage imageNamed:@"coupon_selected"] forState:UIControlStateSelected];
    
    // 判断哪个界面推出此界面 修改相应的样式
    if ([_superViewNum intValue] == 0) {
        // 登录注册界面过来的
        [self.backBtn setImage:nil forState:UIControlStateNormal];
        [self.backBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:RGB(32, 120, 180) forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.backBtn addTarget:self action:@selector(ignoreClick) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *idNum = [userInfo[@"id_cardnum"] description]; // 身份证
        //身份证
        self.idCardField.text = idNum;
        
    }else{
        // 修改账号资料
        [self.backBtn setImage:[UIImage imageNamed:@"icon_arrow_back"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [self updateUserMsg];//给信息赋值
    }
}

// 跳过
- (void)ignoreClick {
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSelfView" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backupgroupTap:(id)sender{
    [self.idCardField resignFirstResponder];
    [self.coachCardField resignFirstResponder];
    [self.carModelField resignFirstResponder];
    [self.cardMadeTimeField resignFirstResponder];
    [self.driveCardField resignFirstResponder];
    [self.carCheckField resignFirstResponder];
    [self.teachCarField resignFirstResponder];
    [self.coachMadeTimeField resignFirstResponder];
    [self.driveMadeTimeField resignFirstResponder];
    [self.carCheckMadeTimeField resignFirstResponder];
    [self.teachCarCardField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.schoolName.length != 0) {
        self.schoolTextFiled.text = app.schoolName;
        self.schoolid = app.driveschoolid;
    }
    if (app.carModel) {
        //教学用车型号
        self.teachCarCardField.text = app.carModel;
    }
    
    if (app.modelid.length >0) {
        //准教车型
        if ([app.modelid isEqualToString:@"17"]) {
            self.coachCarLabel.text = @"C1手动挡";
        }
        if ([app.modelid isEqualToString:@"18"]) {
            self.coachCarLabel.text = @"C2自动挡";
        }
        if ([app.modelid isEqualToString:@"17,18"]) {
            self.coachCarLabel.text = @"C1手动挡,C2自动挡";
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.schoolName = @"";
}

#pragma mark - 加载驾照信息
- (void)updateUserMsg{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *idNum = [userInfo[@"id_cardnum"] description]; // 身份证
    NSString *creatTime = [userInfo[@"id_cardexptime"] description]; // 身份证到期时间
    
    NSString *coachNum = [userInfo[@"coach_cardnum"] description]; // 教练证
    NSString *coachNumPt = [userInfo[@"coach_cardexptime"] description]; // 教练证到期时间
    
    NSString *driveNum = [userInfo[@"drive_cardnum"] description]; // 驾驶证
    NSString *driveNumPt = [userInfo[@"drive_cardexptime"] description]; // 驾驶证到期时间
    
    NSString *carNum = [userInfo[@"car_cardnum"] description]; // 车辆年检证
    NSString *carNumPt = [userInfo[@"car_cardexptime"] description]; // 车辆年检证到期时间
    
    NSString *carLicense = [userInfo[@"carlicense"] description]; // 教学用车牌照
    NSString *carModel = [userInfo[@"teachcarmodel"] description]; // 教学用车型号
    NSString *driveschool = [userInfo[@"driveschool"]description];
    
    NSString *modelid = [userInfo[@"modelid"]description];//准教车型id
    NSString *cityid1 = [userInfo[@"cityid"] description]; //城市id
    NSString *provinceid = [userInfo[@"provinceid"] description];
    NSString *areaid = [userInfo[@"areaid"] description];
    NSString *locationname = [userInfo[@"locationname"] description];//城市名
    NSString *idCardImage = [CommonUtil stringForID:userInfo[@"id_cardpicfurl"]]; // 身份证正面照片地址
    NSString *idCardBackImage = [CommonUtil stringForID:userInfo[@"id_cardpicburl"]]; // 身份证反面照片地址
    NSString *coachImage = [CommonUtil stringForID:userInfo[@"coach_cardpicurl"]]; // 教练证正面照片地址
    NSString *coachBackImage = [CommonUtil stringForID:userInfo[@"drive_cardpicurl"]]; // 驾驶证照片地址
    NSString *carCheckImage = [CommonUtil stringForID:userInfo[@"car_cardpicfurl"]]; // 车辆年检证照片地址&车辆行驶证正面
    NSString *carCheckBackImage = [CommonUtil stringForID:userInfo[@"car_cardpicburl"]]; // 车辆行驶证反面
    NSString *coachTureIconImage = [CommonUtil stringForID:userInfo[@"realpicurl"]]; // 教练真实头像
    
    self.selectProvinceid = provinceid;
    self.selectCityid = cityid1;
    self.selectAreaid = areaid;
    
    //身份证
    self.idCardField.text = idNum;
    
    //身份证到期时间时间
    self.cardMadeTimeField.text = creatTime;
    
    //教练证
    self.coachCardField.text = coachNum;
    
    //教练证到期时间时间
    self.coachMadeTimeField.text = coachNumPt;
    
    //驾驶证
    self.driveCardField.text = driveNum;
    //驾驶证到期时间时间
    self.driveMadeTimeField.text = driveNumPt;
    
    //车辆年检证
    self.carCheckField.text = carNum;
    
    //车辆年检证到期时间时间
    self.carCheckMadeTimeField.text = carNumPt;
    
    //教学用车牌照
    self.teachCarField.text = carLicense;
    
    if(![CommonUtil isEmpty:driveschool]){
        self.schoolTextFiled.text = driveschool;
    }
    
    //所在城市
    self.cityNameLabel.text = locationname;
    
    //教学用车型号
    self.teachCarCardField.text = carModel;
    
    //准教车型
    self.myCarModelArray = [NSMutableArray arrayWithArray:userInfo[@"modellist"]];
//    NSArray *array = [modelid componentsSeparatedByString:@","];
    if ([modelid isEqualToString:@"17"]) {
       self.coachCarLabel.text = @"C1手动挡";
    }
    if ([modelid isEqualToString:@"18"]) {
        self.coachCarLabel.text = @"C2自动挡";
    }
    if ([modelid isEqualToString:@"17,18"]) {
        self.coachCarLabel.text = @"C1手动挡,C2自动挡";
    }
    
    [self loadTestInfo];

    /******相关证件*******/
    
    //身份证正面
    self.idCardImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (![CommonUtil isEmpty:idCardImage]){
        [self.idCardImageView sd_setImageWithURL:[NSURL URLWithString:idCardImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.idCardDelBtn.hidden = YES;
        self.idCardLabel.hidden = NO;
        
    }
    
    //身份证反面
    self.idCardBackImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (![CommonUtil isEmpty:idCardBackImage]) {
        [self.idCardBackImageView sd_setImageWithURL:[NSURL URLWithString:idCardBackImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.idCardBackDelBtn.hidden = YES;
        self.idCardBackLabel.hidden = NO;
    }
    
    
    //教练证
    if (![CommonUtil isEmpty:coachImage]){
        [self.coachCardImageView sd_setImageWithURL:[NSURL URLWithString:coachImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.coachCardDelBtn.hidden = YES;
        self.coachCardLabel.hidden = NO;
    }
    
    
    //教练驾驶证
    if (![CommonUtil isEmpty:coachBackImage]) {
        [self.coachCarCardImageView sd_setImageWithURL:[NSURL URLWithString:coachBackImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.coachCarCardDelBtn.hidden = YES;
        self.coachCarCardLabel.hidden = NO;
    }
    
    //车辆年检证&车辆行驶证正面
    if (![CommonUtil isEmpty:carCheckImage]) {
        [self.carCheckImageView sd_setImageWithURL:[NSURL URLWithString:carCheckImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.carCheckDelBtn.hidden = YES;
        self.carCheckLabel.hidden = NO;
    }
    
    //车辆行驶证反面
    if (![CommonUtil isEmpty:carCheckBackImage]) {
        [self.carCheckBackImageView sd_setImageWithURL:[NSURL URLWithString:carCheckBackImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.carCheckBackDelBtn.hidden = YES;
        self.carCheckBackLabel.hidden = NO;
    }
    
    //教练真实头像
    if (![CommonUtil isEmpty:coachTureIconImage]) {
        [self.coachTureIconImageView sd_setImageWithURL:[NSURL URLWithString:coachTureIconImage] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
        self.coachTureIconDelBtn.hidden = YES;
        self.coachTureIconLabel.hidden = NO;
    }
    
}

#pragma mark - 加载数据
// 加载测试数据
- (void)loadTestInfo {
    
    for (int i = 0; i < _myCarModelArray.count; i++) {
        NSDictionary *dic = _myCarModelArray[i];
        NSString *name = dic[@"modelname"];
        
        UIView *view = [self.carModelView viewWithTag:100 + i];
        if (view == nil) {
            continue;
        }
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if ([name isEqualToString:label.text]) {
                continue;
            }
        }
    }
    
    
    CGFloat addHeight = 0;
    if (_myCarModelArray.count == 0) {
    }
    else if (_myCarModelArray.count == 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
    }
    else if (_myCarModelArray.count > 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
        
        for (int i = 1; i < _myCarModelArray.count; i++) {
            dic = _myCarModelArray[i];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 39 * (i - 1), 150, 18)];
            label.font = [UIFont systemFontOfSize:18];
            label.text = dic[@"modelname"];
            label.tag = 100 + i;
            [self.keepLabelView addSubview:label];
            addHeight += 39;
        }
        _keepViewConstraint.constant = addHeight;
        _carModelViewHeight.constant = 85 + addHeight;
        _mainViewHeight.constant = 1485 + addHeight;
    }
}



#pragma mark - 加载数据
// 加载服务器数据
- (void)loadDataInfo {
    
    // 加载准教车型
    CGFloat addHeight = 0;
    if (_myCarModelArray.count == 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
    }
    if(_myCarModelArray.count > 1){
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
        dic = _myCarModelArray[_myCarModelArray.count - 1];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 39 * (_myCarModelArray.count - 2), 150, 18)];
        label.font = [UIFont systemFontOfSize:18];
        label.text = dic[@"modelname"];
        [self.keepLabelView addSubview:label];
        addHeight += 39 * (_myCarModelArray.count - 1);
    }
    _keepViewConstraint.constant = addHeight;
    _carModelViewHeight.constant = 85 + addHeight;
    _mainViewHeight.constant = 1485 + addHeight;
}

#pragma mark - PickerVIew
// 准教车型数据
- (void)initCarModelData {
    
    _carModelArray = [CommonUtil getObjectFromUD:@"modellist"];
    if (_carModelArray.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getModelList" object:nil];//重新获取
    }
}

// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.carModelPicker]) {
        return 1;
    } else {
        return 0;
    }
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.carModelPicker]) {
        if(self.teachCarTag == 0){
            if(_carModelArray.count == 0){
                return 0;
            }else{
                return _carModelArray.count;
            }
        }else if(self.teachCarTag == 1){
            return _TeachCarModeArray.count;
        }else{
            return _carSchoolArray.count;
        }
    }else {
        return 0;//如果不是就返回0
    }
}
// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    
    // 性别选择器
    if ([pickerView isEqual:self.carModelPicker]) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
        myView.textAlignment = NSTextAlignmentCenter;
        if(_teachCarTag == 0){
            NSDictionary *dic = [_carModelArray objectAtIndex:row];
            myView.text = dic[@"modelname"];
        }else if(_teachCarTag == 1){
            NSDictionary *dict = [_TeachCarModeArray objectAtIndex:row];
            myView.text = dict[@"modelname"];
        }else{
            NSDictionary *dict = [_carSchoolArray objectAtIndex:row];
            myView.text = dict[@"name"];
        }
        myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
        
        myView.textColor = RGB(161, 161, 161);
        
        myView.backgroundColor = [UIColor clearColor];
        if (selectRow == row){
            myView.textColor = RGB(34, 192, 100);
        }
    }
    
    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectRow = row;
    [pickerView reloadComponent:0];
}

#pragma mark - 页面特性
// 开始编辑，铅笔变蓝
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    
    if ([textField isEqual:self.idCardField]) {
        [self.idCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.coachCardField]) {
        [self.coachCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.driveCardField]) {
        [self.driveCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.carCheckField]) {
        [self.carCheckPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.teachCarField]) {
        [self.teachCarPencilImage setImage:image];
    }
}

// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_black"];
    
    if ([textField isEqual:self.idCardField]) {
        [self.idCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.coachCardField]) {
        [self.coachCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.driveCardField]) {
        [self.driveCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.carCheckField]) {
        [self.carCheckPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.teachCarField]) {
        [self.teachCarPencilImage setImage:image];
    }
}

#pragma mark - 按钮方法
//弹出驾校选择框
- (IBAction)clickForSelectSchool:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        if ([self.cityNameLabel.text isEqualToString:@"未设置"]) {
            [self makeToast:@"请先设置您的所在城市"];
        }else{
            NSString *cityID;
            if (self.selectCity) {
                cityID = self.selectCity.cityID;
            }else{
                NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
                cityID = [userInfo[@"cityid"] description];
            }
            SchoolSelectViewController *nextViewController = [[SchoolSelectViewController alloc] initWithNibName:@"SchoolSelectViewController" bundle:nil];
            nextViewController.selectCityID = cityID;
            [self.navigationController pushViewController:nextViewController animated:YES];
        }
    }
}

- (IBAction)clickForCommit:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交后将会进入审核状态，在未通过审核前学员无法预约您的课程" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

//C1或C2的选择
- (IBAction)clickForC1:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        if (self.C1Button.selected) {
            self.C1Button.selected = NO;
        }else{
            self.C1Button.selected = YES;
        }
    }
    
}

- (IBAction)clickForC2:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        if (self.C2Button.selected) {
            self.C2Button.selected = NO;
        }else{
            self.C2Button.selected = YES;
        }
    }
}
- (IBAction)clickForCarModel:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        CarModelViewController *nextViewController = [[CarModelViewController alloc] initWithNibName:@"CarModelViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}

// 监听弹话框点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *coachImage = [CommonUtil stringForID:userInfo[@"coach_cardpicurl"]]; // 教练证正面照片地址
        NSString *coachBackImage = [CommonUtil stringForID:userInfo[@"drive_cardpicurl"]]; // 驾驶证照片地址
        NSString *carCheckImage = [CommonUtil stringForID:userInfo[@"car_cardpicfurl"]]; // 车辆年检证照片地址&车辆行驶证正面
        NSString *carCheckBackImage = [CommonUtil stringForID:userInfo[@"car_cardpicburl"]]; // 车辆行驶证反面
        
        NSNumber *isNotEmpty = [NSNumber numberWithBool:YES];
        
        if ([CommonUtil isEmpty:coachImage] && self.coachCardDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:coachBackImage] && self.coachCarCardDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:carCheckImage] && self.carCheckDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:carCheckBackImage] && self.carCheckBackDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if (self.schoolTextFiled.text.length == 0 || [self.schoolTextFiled.text isEqualToString:@"请输入您的驾校名称"] || !isNotEmpty) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请正确填写完所有信息后再提交" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            NSString *cardNum = [self.idCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *cardNumPt = [self.cardMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *coachNum = [self.coachCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *coachNumPt = [self.coachMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *driveNum = [self.driveCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *driveNumPt = [self.driveMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *carCNum = [self.carCheckField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carCNumPt = [self.carCheckMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *carModel = [self.teachCarCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carLicense = [self.teachCarField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //驾校
            NSString *carSchoolName = [self.schoolTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [self uploadCardNum:cardNum cardNumPt:cardNumPt coachNum:coachNum coachNumPt:coachNumPt driveNum:driveNum driveNumPt:driveNumPt carCNum:carCNum carCNumPt:carCNumPt carModel:carModel carLicense:carLicense carArray:self.myCarModelArray carSchoolName:carSchoolName cityModel:self.selectCity.cityID];
        }
        
    }
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

// 重新进行选择车型
- (IBAction)clickagainCarModelDone:(id)sender {
    //    [_myCarModelArray removeAllObjects];
    //    while (self.keepLabelView.subviews.count) {
    //        UIView* child = self.keepLabelView.subviews.lastObject;
    //        [child removeFromSuperview];
    //    }
    //    self.carModelField.text = @"";
    //    _keepViewConstraint.constant = 1;
    //    _carModelViewHeight.constant = 85;
    //    _mainViewHeight.constant = 1485;
    //    [self.selectView removeFromSuperview];
}

// 完成准教车型选择
- (IBAction)clickForCarModelDone:(id)sender {
    
    
    NSInteger row = [self.carModelPicker selectedRowInComponent:0];
    if(_teachCarTag == 0){
        if(_carModelArray == 0){
            [self makeToast:@"数据有误"];
            return;
        }
        NSDictionary *dic = _carModelArray[row];
        [_myCarModelArray removeAllObjects];
        [_myCarModelArray addObject:dic];
        [self loadDataInfo];
    }else if(_teachCarTag == 1){
        if(row == (_TeachCarModeArray.count - 1)){
            self.teachCarBtnOutlet.hidden = YES;
            _teachCarCardField.text = @"";
            _teachCarCardField.placeholder = @"请输入您的教学车型";
            _teachCarID = @"";
            [self.teachCarCardField becomeFirstResponder];
        }else{
            self.teachCarBtnOutlet.hidden = NO;
            _teachCarCardField.placeholder = @"";
            NSDictionary *dic = _TeachCarModeArray[row];
            _teachCarCardField.text = dic[@"modelname"];
            _teachCarID = dic[@"modelid"];
        }
    }else{
        if(row == (_carSchoolArray.count - 1)){
            self.selectSchoolButton.hidden = YES;
            _schoolTextFiled.text = @"";
            _schoolTextFiled.text = @"未设置";
            _carSchoolID = @"";
            [self.schoolTextFiled becomeFirstResponder];
        }else{
            self.selectSchoolButton.hidden = NO;
            _schoolTextFiled.text = @"";
            NSDictionary *dic = _carSchoolArray[row];
            _schoolTextFiled.text = dic[@"name"];
            _carSchoolID = dic[@"schoolid"];
        }
    }
    [self.selectView removeFromSuperview];
}

//// 选择准教车型
//- (IBAction)clickForCarModel:(id)sender {
//    if([sender tag] == 0){
//        self.teachCarTag = 0;
//        self.keepBtnOutlet.hidden = YES;
//        [self getCarMode];
//
//    }else{
//        self.teachCarTag = 1;
//        self.keepBtnOutlet.hidden = YES;
//        [self getTeachCarMode]; // 获取教练教学用车型号
//    }
//}

//// 选择时间
//- (IBAction)clickForCardMadeTime:(id)sender {
//    self.dataTag = [sender tag];
//    //日期
//    DatePickerViewController *viewController = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
//    viewController.delegate = self;
//    UIViewController* controller = self.view.window.rootViewController;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
//        viewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
//    }else{
//        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
//    }
//
//    [controller presentViewController:viewController animated:YES completion:^{
//        viewController.view.superview.backgroundColor = [UIColor clearColor];
//    }];
//   // self.cardMadeTimeField.text = self.dateTimeTextField.text;
//}
- (IBAction)backClick:(id)sender {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isregister = @"0";
    app.isInvited = @"0";
    if ([app.superViewNum intValue] == 1) {
        // 登录注册界面过来的
        app.isInvited = @"0";
        app.superViewNum = @"0";
        app.isInvited = @"0";
//        MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 拍证件照片
- (IBAction)clickForPhoto:(UIButton *)sender {
    //    if ([self.userState intValue] == 2) {
    //        //通过审核不可修改
    //        return;
    //    }
    
    // 身份证正面
    if (sender.tag == 102) {
        NSLog(@"身份证正面");
    }
    
    // 身份证反面
    if (sender.tag == 202) {
        NSLog(@"身份证反面");
    }
    
    // 教练证
    if (sender.tag == 302) {
        NSLog(@"教练证");
    }
    
    // 教练车行驶证
    if (sender.tag == 402) {
        NSLog(@"教练车行驶证");
    }
}

//// 删除身份证正面照
//- (void)clickForDeleteCardFront:(id)sender {
//    UIImageView *imageView = (UIImageView *)[self.idCardFrontView viewWithTag:100];
//    [imageView setImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
//
//    // 显示文字
//    UILabel *label = (UILabel *)[self.idCardFrontView viewWithTag:101];
//    label.hidden = NO;
//
//    // 显示编辑按钮
//    UIButton *button = (UIButton *)[self.idCardFrontView viewWithTag:102];
//    button.hidden = NO;
//
//    // 隐藏查看大图按钮
//    button = (UIButton *)[self.idCardFrontView viewWithTag:103];
//    button.hidden = YES;
//
//    // 隐藏删除按钮
//    button = (UIButton *)[self.idCardFrontView viewWithTag:104];
//    button.hidden = YES;
//}
//
////查看大图
//- (void)clickToBigPhotoView:(UIButton *)sender {
//    BigPhotoViewController *targetViewController = [[BigPhotoViewController alloc] initWithNibName:@"BigPhotoViewController" bundle:nil];
//    if (sender.tag == 103) {
//        targetViewController.type = 0;
//    }
//    [self.navigationController pushViewController:targetViewController animated:YES];
//}

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
        }
        
        if (self.clickImageView != nil) {
            self.clickImageView.image = image;
            self.clickImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.clickLabel.hidden = YES;
            self.clickDelBtn.hidden = NO;//显示删除按钮
            
        }
        [self.alertView removeFromSuperview];
    }];
}

#pragma mark - LocationViewControllerDelegate
- (void)location:(LocationViewController *)viewController selectDic:(NSDictionary *)selectDic{
    
    isChangeCity = @"1";
    
    self.selectProvince = selectDic[@"province"];
    self.selectCity = selectDic[@"city"];
    self.selectArea = selectDic[@"area"];
    
    self.selectProvinceid = self.selectProvince.provinceID;
    self.selectCityid = self.selectCity.cityID;
    self.selectAreaid = self.selectArea.areaID;

    NSString *addrStr = nil;
    NSString *areaStr = [self.selectArea.areaName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (self.selectProvince.isZxs) { // 直辖市
        addrStr = [NSString stringWithFormat:@"%@ - %@", self.selectProvince.provinceName, areaStr];
    } else {
        addrStr =  [NSString stringWithFormat:@"%@ - %@ - %@", self.selectProvince.provinceName, self.selectCity.cityName, areaStr];
    }

    self.cityNameLabel.text = addrStr;
}
//选择城市
- (IBAction)clickForSelectCity:(UIButton *)sender{
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        LocationViewController *viewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
        viewController.delegate = self;
        UIViewController* controller = self.view.window.rootViewController;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            viewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }else{
            controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
        
        [controller presentViewController:viewController animated:YES completion:^{
            viewController.view.superview.backgroundColor = [UIColor clearColor];
        }];
    }
    
}


#pragma mark - DatePickerViewControllerDelegate
- (void)datePicker:(DatePickerViewController *)viewController selectedDate:(NSDate *)selectedDate{
    NSString *time = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
    //self.cardMadeTimeField.text = time;
    //self.dateTimeTextField.text = time;
    if(self.dataTag == 0){
        self.cardMadeTimeField.text = time;
    }else if(self.dataTag == 1){
        self.coachMadeTimeField.text = time;
    }else if(self.dataTag == 2){
        self.driveMadeTimeField.text = time;
    }else{
        self.carCheckMadeTimeField.text = time;
    }
    
}

#pragma mark - 弹框方法
//弹框
- (IBAction)clickForAlert:(id)sender {
    //    if ([self.userState intValue] == 2) {
    //        //通过审核不可修改
    //        return;
    //    }
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        UIButton *button = (UIButton *)sender;
        if (button.tag == 0){
            //身份证正面
            self.clickImageView = self.idCardImageView;
            self.clickLabel = self.idCardLabel;
            self.clickDelBtn = self.idCardDelBtn;
        }else if (button.tag == 1){
            //身份证反面
            self.clickImageView = self.idCardBackImageView;
            self.clickLabel = self.idCardBackLabel;
            self.clickDelBtn = self.idCardBackDelBtn;
        }else if (button.tag == 2){
            //教练证
            self.clickImageView = self.coachCardImageView;
            self.clickLabel = self.coachCardLabel;
            self.clickDelBtn = self.coachCardDelBtn;
        }else if (button.tag == 3){
            //教练驾驶证
            self.clickImageView = self.coachCarCardImageView;
            self.clickLabel = self.coachCarCardLabel;
            self.clickDelBtn = self.coachCarCardDelBtn;
        }else if (button.tag == 4){
            //车辆年检证&教练行驶证正面
            self.clickImageView = self.carCheckImageView;
            self.clickLabel = self.carCheckLabel;
            self.clickDelBtn = self.carCheckDelBtn;
        }else if (button.tag == 5){
            //教练行驶证反面
            self.clickImageView = self.carCheckBackImageView;
            self.clickLabel = self.carCheckBackLabel;
            self.clickDelBtn = self.carCheckBackDelBtn;
        }else if (button.tag == 6){
            //教练真实头像
            self.clickImageView = self.coachTureIconImageView;
            self.clickLabel = self.coachTureIconLabel;
            self.clickDelBtn = self.coachTureIconDelBtn;
        }else{
            self.clickImageView = nil;
        }
        
        self.alertView.frame = self.view.frame;
        [self.view addSubview:self.alertView];
    }
    
}

- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertView removeFromSuperview];
}

// 上传图片
- (IBAction)clickForImage:(id)sender {
    //    if ([self.userState intValue] == 2) {
    //        //通过审核不可修改
    //        return;
    //    }
    
    UIButton *button = (UIButton *)sender;
    
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.allowsEditing = NO;
    if (button.tag == 0 && [CZPhotoPickerController canTakePhoto]) {
        //拍照
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
}

- (IBAction)clickForDelImage:(id)sender {
    //    if ([self.userState intValue] == 2) {
    //        //通过审核不可修改
    //        return;
    //    }
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0){
        //身份证正面
        self.idCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.idCardLabel.hidden = NO;
        self.idCardDelBtn.hidden = YES;
    }else if (button.tag == 1){
        //身份证反面
        self.idCardBackImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.idCardBackLabel.hidden = NO;
        self.idCardBackDelBtn.hidden = YES;
        
    }else if (button.tag == 2){
        //教练证
        self.coachCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachCardLabel.hidden = NO;
        self.coachCardDelBtn.hidden = YES;
        
    }else if (button.tag == 3){
        //教练驾驶证
        self.coachCarCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachCarCardLabel.hidden = NO;
        self.coachCarCardDelBtn.hidden = YES;
        
    }else if (button.tag == 4){
        //车辆年检证&车辆行驶证正面
        self.carCheckImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.carCheckLabel.hidden = NO;
        self.carCheckDelBtn.hidden = YES;
        
    }else if (button.tag == 5){
        //车辆行驶证反面
        self.carCheckBackImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.carCheckBackLabel.hidden = NO;
        self.carCheckBackDelBtn.hidden = YES;
        
    }else if (button.tag == 6){
        //教练真实头像
        self.coachTureIconImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachTureIconLabel.hidden = NO;
        self.coachTureIconDelBtn.hidden = YES;
        
    }else{
        self.clickImageView = nil;
    }
}

#pragma mark - 接口
// 获取教学用车型号
- (void)getTeachCarMode{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 0;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetAllTeachCarModel" forKey:@"action"];
    [request startAsynchronous];
}


// 获取所有驾校信息
- (void)getCarSchool{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 5;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetAllSchool" forKey:@"action"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

#pragma mark - 接口
- (void)getCarMode{
//    NSArray *ds = [CommonUtil getObjectFromUD:@"modellist"];
//    if (ds.count > 0) {
//        [self.carModelArray removeAllObjects];
//        [self.carModelArray addObjectsFromArray:ds];
//        [self.carModelPicker reloadAllComponents];
//        self.selectView.frame = [UIScreen mainScreen].bounds;
//        [self.view addSubview:self.selectView];
//        return;
//    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 2;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetCarModel" forKey:@"action"];
    [request startAsynchronous];
}

#pragma mark - 接口
- (void)uploadCardNum:(NSString *)cardNum cardNumPt:(NSString *)cardNumPt coachNum:(NSString *)coachNum coachNumPt:(NSString *)coachNumPt driveNum:(NSString *)driveNum driveNumPt:(NSString *)driveNumPt carCNum:(NSString *)carCNum carCNumPt:(NSString *)carCNumPt  carModel:(NSString *)carModel carLicense:(NSString *)carLicense carArray:(NSArray *)carArray carSchoolName:(NSString*)carSchoolName cityModel:(NSString *)cityid{
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    
    request.tag = 1;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"PerfectCoachInfo" forKey:@"action"];
    
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];             // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
    
    //    if(![CommonUtil isEmpty:cardNum])
    //    {
    //        [request setPostValue:cardNum forKey:@"idnum"];              // 身份证号码
    //    }
    //    if(![CommonUtil isEmpty:cardNumPt])
    //    {
    //        [request setPostValue:cardNumPt forKey:@"idcardextime"];      // 身份证到期时间
    //    }
    //    if(![CommonUtil isEmpty:coachNum])
    //    {
    //        [request setPostValue:coachNum forKey:@"coachcardnum"];       // 教练证号
    //    }
    //    if(![CommonUtil isEmpty:cardNumPt])
    //    {
    //        [request setPostValue:coachNumPt forKey:@"coachcardextime"];      // 教练证到期时间
    //    }
    //    if(![CommonUtil isEmpty:driveNum])
    //    {
    //         [request setPostValue:driveNum forKey:@"drivecardnum"];              // 驾驶证号码
    //    }
    //    if(![CommonUtil isEmpty:driveNumPt])
    //    {
    //        [request setPostValue:driveNumPt forKey:@"drivecardextime"];      // 驾驶证到期时间
    //    }
    //    if(![CommonUtil isEmpty:carCNum])
    //    {
    //        [request setPostValue:carCNum forKey:@"carcardnum"];              // 车辆年检证号码
    //    }
    //    if(![CommonUtil isEmpty:carCNumPt])
    //    {
    //        [request setPostValue:carCNumPt forKey:@"carcardextime"];      // 车辆年检证到期时间
    //    }
    //
        if(![CommonUtil isEmpty:_teachCarID]){
            [request setPostValue:_teachCarID forKey:@"carmodelid"];
        }else{
            if(![CommonUtil isEmpty:carModel])
            {
                [request setPostValue:carModel forKey:@"carmodel"];// 教学用车型号
            }
        }
    //
    if(![CommonUtil isEmpty:_carSchoolID]){
        [request setPostValue:_carSchoolID forKey:@"driveschoolid"];
    }else{
        if(![CommonUtil isEmpty:carSchoolName])
        {
            [request setPostValue:carSchoolName forKey:@"driveschool"];// 教学用车型号
        }
    }
    if (!self.coachCardDelBtn.hidden) {
        //教练证正面照
        [request setData:UIImageJPEGRepresentation(self.coachCardImageView.image, 0.75) forKey:@"cardpic3"];//教练证正面照
    }
    
    if (!self.coachCarCardDelBtn.hidden) {
        //驾驶证照
        [request setData:UIImageJPEGRepresentation(self.coachCarCardImageView.image, 0.75) forKey:@"cardpic4"];//驾驶证照
    }
    
    if (!self.carCheckDelBtn.hidden) {
        //车辆年检照&车辆行驶证正面
        [request setData:UIImageJPEGRepresentation(self.carCheckImageView.image, 0.75) forKey:@"cardpic5"];//车辆年检照
    }
    
    if (!self.carCheckBackDelBtn.hidden) {
        //车辆行驶证反面
        [request setData:UIImageJPEGRepresentation(self.carCheckBackImageView.image, 0.75) forKey:@"cardpic6"];//车辆行驶证反面
    }
    
    //准教车型
    NSString *modelIds;
    if (self.C1Button.selected) {
        if (self.C2Button.selected) {
            modelIds = @"17,18"; //17:C1 18:C2
        }else{
            modelIds = @"17";
        }
    }else{
        if (self.C2Button.selected) {
            modelIds = @"18";
        }else{
            modelIds = @"";
        }
    }
    [request setPostValue:modelIds forKey:@"modelid"];             // 准教车型ID
//    if(carArray.count !=0){
//        NSDictionary *dic = carArray[0];
//        NSString *modelIds = dic[@"modelid"];
//        //    for (NSDictionary *dict in carArray) {
//        //        NSString *idStr = dict[@"modelid"];
//        //        modelIds = [NSString stringWithFormat:@"%@,%@", modelIds, idStr];
//        //    }
//        for(int i = 1;i<carArray.count;i++)
//        {
//            NSDictionary *dict = [carArray objectAtIndex:i];
//            NSString *idStr = dict[@"modelid"];
//            modelIds = [NSString stringWithFormat:@"%@,%@", modelIds, idStr];
//        }
//        //NSLog(@"%@",modelIds);
//        [request setPostValue:modelIds forKey:@"modelid"];             // 准教车型ID
//    }
    
    [request setPostValue:self.selectProvinceid forKey:@"provinceid"];
    [request setPostValue:self.selectCityid forKey:@"cityid"];
    [request setPostValue:self.selectAreaid forKey:@"areaid"];
    [request setPostValue:self.cityNameLabel.text forKey:@"locationname"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
    
    //赋值
    //    [self.msgDic setObject:cardNum forKey:@"id_cardnum"];
    //    [self.msgDic setObject:cardNumPt forKey:@"id_cardexptime"];
    //    [self.msgDic setObject:coachNum forKey:@"coach_cardnum"];
    //    [self.msgDic setObject:coachNumPt forKey:@"coach_cardexptime"];
    //    [self.msgDic setObject:driveNum forKey:@"drive_cardnum"];
    //    [self.msgDic setObject:driveNumPt forKey:@"drive_cardexptime"];
    //    [self.msgDic setObject:carCNum forKey:@"car_cardnum"];
    //    [self.msgDic setObject:carCNumPt forKey:@"car_cardexptime"];
    //    [self.msgDic setObject:carLicense forKey:@"carlicense"];
//    [self.msgDic setObject:carModel forKey:@"carmodel"];
    //    [self.msgDic setObject:carArray forKey:@"modellist"];
    [self.msgDic setObject:self.selectProvinceid forKey:@"provinceid"];
    [self.msgDic setObject:self.selectCityid forKey:@"cityid"];
    [self.msgDic setObject:self.selectAreaid forKey:@"areaid"];
    [self.msgDic setObject:carSchoolName forKey:@"driveschool"];
    [self.msgDic setObject:self.cityNameLabel.text forKey:@"locationname"];
    if (self.schoolid.length != 0) {
        [self.msgDic setObject:self.schoolid forKey:@"driveschoolid"];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //接口
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if(request.tag == 0){
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [result objectForKey:@"teachcarlist"];
            NSDictionary *di = [NSDictionary dictionaryWithObject:@"其它" forKey:@"modelname"];
            [arr addObject:di];
            [self.TeachCarModeArray removeAllObjects];
            [self.TeachCarModeArray addObjectsFromArray:arr];
            [self.carModelPicker reloadAllComponents];
            self.selectView.frame = [UIScreen mainScreen].bounds;
            [self.view addSubview:self.selectView];
            
        }else if(request.tag == 1){
            NSMutableDictionary * ds = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            
            for (NSString *key in self.msgDic.allKeys) {
                [ds setObject:[self.msgDic objectForKey:key] forKey:key];
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic1url"] ]) {
                [ds setObject:result[@"cradpic1url"] forKey:@"id_cardpicfurl"];
                
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic2url"] ]) {
                [ds setObject:result[@"cradpic2url"] forKey:@"id_cardpicburl"];
                
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic3url"] ]) {
                [ds setObject:result[@"cradpic3url"] forKey:@"coach_cardpicurl"];
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic4url"] ]) {
                [ds setObject:result[@"cradpic4url"] forKey:@"drive_cardpicurl"];
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic5url"] ]) {
                [ds setObject:result[@"cradpic5url"] forKey:@"car_cardpicfurl"];
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic6url"] ]) {
                [ds setObject:result[@"cradpic6url"] forKey:@"car_cardpicburl"];
            }
            
            if (![CommonUtil isEmpty:result[@"cradpic7url"] ]) {
                [ds setObject:result[@"cradpic7url"] forKey:@"realpicurl"];
            }
            
            [ds setObject:@"1" forKey:@"state"];
            
            [CommonUtil saveObjectToUD:ds key:@"userInfo"];
            [self makeToast:@"提交成功，请等待审核"];
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.isregister = @"0";
            app.isInvited = @"0";
            if ([app.superViewNum intValue] == 1) {
                // 登录注册界面过来的
                app.isInvited = @"0";
                app.superViewNum = @"0";
                app.isInvited = @"0";
                //        MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else if(request.tag == 5){
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [result objectForKey:@"schoollist"];
            NSDictionary *di = [NSDictionary dictionaryWithObject:@"其它" forKey:@"name"];
            [arr addObject:di];
            [self.carSchoolArray removeAllObjects];
            [self.carSchoolArray addObjectsFromArray:arr];
            [self.carModelPicker reloadAllComponents];
            self.selectView.frame = [UIScreen mainScreen].bounds;
            [self.view addSubview:self.selectView];
        }else{
            NSArray *arr = [result objectForKey:@"modellist"];
            [self.carModelArray removeAllObjects];
            [self.carModelArray addObjectsFromArray:arr];
//            [self.carModelPicker reloadAllComponents];
//            self.selectView.frame = [UIScreen mainScreen].bounds;
//            [self.view addSubview:self.selectView];
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
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        [self makeToast:message];
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)getCoachDetail
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    [paramDic setObject:coachId forKey:@"coachid"];
    
    NSString *uri = @"/sbook?action=GetCoachDetail";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            NSDictionary *coachInfo = responseObject[@"coachinfo"];
            self.userState = [coachInfo[@"state"] description];
            NSString *state = [coachInfo[@"state"] description];
            if (state.intValue == 1) {        //正在审核
                self.commitBtn.hidden = YES;
                self.warmingLabel.text = @"【资格审核已提交】您的教练资料提交成功，正在审核中...";
            }else if (state.intValue == 2){   //审核通过
                self.commitBtn.hidden = YES;
                self.warmingLabel.text = @"【资格审核通过】您已经通过教练资格审核";
            }else if (state.intValue == 3){   //审核未通过
                self.commitBtn.hidden = NO;
                self.warmingLabel.text = @"【未通过资格审核】教练资格审核未通过，请完善以下内容，重新提交认证";
            }else{                            //未设置
                self.commitBtn.hidden = NO;
                self.warmingLabel.text = @"【未提交资格审核】通过教练资格审核后，学员才能预约您的课程";
            }
            NSMutableDictionary * ds = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [ds setObject:state forKey:@"state"];
            [CommonUtil saveObjectToUD:ds key:@"userInfo"];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}


// 服务器请求失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [DejalBezelActivityView removeViewAnimated:YES];
    [self makeToast:ERR_NETWORK];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}


@end
