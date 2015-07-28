//
//  MyInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyInfoViewController.h"
#import "UserInfoViewController.h"
#import "CoachInfoViewController.h"
#import "MyDetailInfoViewController.h"
#import "ChangePwdViewController.h"
#import "TQStarRatingView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MyInfoCell.h"
#import "SetTeachViewController.h"
#import "SetAddrViewController.h"
#import "SetPriceViewController.h"
#import "CZPhotoPickerController.h"
#import "LoginViewController.h"

@interface MyInfoViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    CGRect _oldFrame;
    CGFloat _y;
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
    NSInteger selectRow;
    NSString* pricestr;
}

@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) IBOutlet UIView *pwdProveView;
@property (strong, nonatomic) IBOutlet UITextField *pwdField;
@property (strong, nonatomic) IBOutlet UIView *commitView;
@property (strong, nonatomic) IBOutlet UIView *starView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//累计时长
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;//综合评分
@property (strong, nonatomic) IBOutlet UIView *msgView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgHeightContraint;

//选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView; // 选择器
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) UIImage *changeLogoImage;//修改后的头像

//参数
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (nonatomic, strong) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableArray *selectArray;
@property (copy, nonatomic) NSString *schoolCarID;
@property (strong, nonatomic) NSMutableDictionary *msgDic;//资料

- (IBAction)clickToUserInfoView:(id)sender;     // 账号信息
- (IBAction)clickToCoachInfoView:(id)sender;    // 教练资格信息
- (IBAction)clickToMyDetailInfoView:(id)sender; // 个人资料
- (IBAction)clickToChangePwdView:(id)sender;    // 修改密码
- (IBAction)clickForCancel:(id)sender;
- (IBAction)clickForProvePwd:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;


//
////修改默认价格
//- (IBAction)clickForChangePrice:(id)sender;
//
////修改默认教学内容
//- (IBAction)clickForChangeSubject:(id)sender;

//
//修改上车地址
- (IBAction)clickForChangeAddress:(id)sender;

//修改头像
- (IBAction)clickForChangeAvatar:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *defaultPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *defaultSubjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *defaultAddressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *portraitImage;

@property (strong, nonatomic) IBOutlet UIView *alertPhotoView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;


@end

@implementation MyInfoViewController

//self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width/2;
//self.userLogo.layer.masksToBounds = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cells = [NSMutableArray array];
    self.selectArray = [NSMutableArray array];
    self.msgDic = [NSMutableDictionary dictionary];
    
    self.pickerView.showsSelectionIndicator = NO;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    self.portraitImage.layer.cornerRadius = self.portraitImage.bounds.size.width/2;
    self.portraitImage.layer.masksToBounds = YES;

    self.alertDetailView.layer.cornerRadius = 4;
    self.alertDetailView.layer.masksToBounds = YES;
    
    //显示,时长和评分
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *score = [userInfo[@"score"] description];//教练综合评分
    TQStarRatingView *ratingView = [[TQStarRatingView alloc] initWithFrame:self.starView.bounds numberOfStar:5];
    ratingView.couldClick = NO;//不可点击
    ratingView.isFill = NO;
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([score doubleValue]/5*CGRectGetWidth(self.starView.frame), 0)];//设置星级
    [self.starView addSubview:ratingView];
//    self.commitBtn.hidden = YES;
    self.scoreLabel.text = [NSString stringWithFormat:@"综合评分%@分", score];//综合评分
    
    //培训时长
    NSString *totalTime = [userInfo[@"totaltime"] description];
    totalTime = [CommonUtil isEmpty:totalTime]?@"0":totalTime;
    self.timeLabel.text = [NSString stringWithFormat:@"累计培训学时 %@小时", totalTime];
    //当时长为0时不显示该label
    if ([totalTime isEqualToString:@"0"]) {
        self.timeLabel.hidden = YES;
    }else{
        self.timeLabel.hidden = NO;
    }
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self registerForKeyboardNotifications];
    
    //添加姓名，手机号码，所属驾校，性别
    [self addOtherView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //重新设置默认价格 默认教学科目  默认地址
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *price = [userInfo[@"price"] description];
    NSString *subjectname = [userInfo[@"subjectname"] description];
    NSString *defauleAddress = [userInfo[@"defaultAddress"] description];
    
    if(![CommonUtil isEmpty:price] && [price doubleValue] != 0){
        self.defaultPriceLabel.text = [NSString stringWithFormat:@"%@ 元/小时", price];
    }else{
        self.defaultPriceLabel.text = @"未设置";
    }
    
    if(![CommonUtil isEmpty:subjectname]){
        self.defaultSubjectLabel.text = subjectname;
    }else{
        self.defaultSubjectLabel.text = @"未设置";
    }
    
    if(![CommonUtil isEmpty:defauleAddress]){
        self.defaultAddressLabel.text = defauleAddress;
    }else{
        self.defaultAddressLabel.text = @"未设置";
    }
    
    //头像
    NSString *url = userInfo[@"avatarurl"];
    url = [CommonUtil isEmpty:url]?@"":url;

    //头像
    [self.portraitImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
//            [self updateLogoImage:self.portraitImage];
            self.portraitImage.layer.cornerRadius = self.portraitImage.bounds.size.width/2;
            self.portraitImage.layer.masksToBounds = YES;
        }
    }];
    
    //电话号码
    self.phoneLabel.text = [NSString stringWithFormat:@"手机号码:%@",userInfo[@"phone"]];
}

- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backupgroupTap:(id)sender{
    [self.pwdField resignFirstResponder];
    
    for (int i =0; i < _titles.count; i++) {
        MyInfoCell *cell = _cells[i];
        [cell.contentField resignFirstResponder];
        
    }
}

- (void)addOtherView{
    //赋值
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    _titles = [NSArray arrayWithObjects:@"姓名", @"性别",nil];
    
    _hints = [NSArray arrayWithObjects:@"请输入姓名", @"请选择性别", nil];
    
    self.contentHeightConstraint.constant = _titles.count * 82;
    
    for (int i = 0; i < _titles.count; i++) {
        
        MyInfoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoCell" owner:self options:nil] lastObject];
        
        _y = 82 * i;
        
        cell.frame = CGRectMake(0, _y, _screenWidth, 82);
        
        cell.contentField.delegate = self;
        
        cell.contentField.tag = 100 + i;
        
        [cell.contentField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        cell.editBtn.tag = 200 + i;
        cell.editImageView.hidden = YES;
        cell.necessaryLabel.hidden = NO;
        [self.contentView addSubview:cell];
        
        [_cells addObject:cell];
        
        cell.titleLabel.text = _titles[i];
        cell.contentField.placeholder = _hints[i];
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
        
//        if (i == 1) { // 所属驾校
//            
//            cell.selectBtn.tag = 300 + i;
//
//            cell.selectBtn.hidden = NO;
//
//            cell.hiddenBtn.hidden = NO;
//
//            [cell.selectBtn addTarget:self action:@selector(clickForSelectSchool:) forControlEvents:UIControlEventTouchUpInside];
//
//            [cell.hiddenBtn addTarget:self action:@selector(clickForSelectSchool:) forControlEvents:UIControlEventTouchUpInside];
//        }

        if (i == 1) { // 性别

            cell.selectBtn.tag = 300 + i;
            
            cell.selectBtn.hidden = NO;

            [cell.selectBtn addTarget:self action:@selector(clickForSelect:) forControlEvents:UIControlEventTouchUpInside];
            [cell.hiddenBtn addTarget:self action:@selector(clickForSelect:) forControlEvents:UIControlEventTouchUpInside];

        }
        
        NSString *str = @"";
        if (i == 0) {
            //姓名
            NSString *name = userInfo[@"realname"];
            if ([CommonUtil isEmpty:name]) {
                name = @"";
                cell.editImageView.hidden = NO;
            }
            cell.contentField.text = name;
        }else if (i == 1){
            //性别1.男2.女
            str = [userInfo[@"gender"] description];
            if ([str intValue] == 1) {
                str = @"男";
            }else if ([str intValue] == 2){
                str = @"女";
            }else{
                str = @"";
                cell.editImageView.hidden = NO;
            }
            cell.contentField.text = str;
        }
    }
    self.msgHeightContraint.constant = 147 + 82 * (_titles.count + 3) + 10;
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
    if (!self.commitView.superview) {
        return;
    }
    _oldFrame = self.commitView.frame;
    
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
    self.commitView.frame = CGRectMake(_oldFrame.origin.x, _oldFrame.origin.y - offset, _oldFrame.size.width, _oldFrame.size.height);
    [UIView commitAnimations];
    
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    if (!self.commitView.superview) {
        return;
    }
    self.commitView.frame = _oldFrame;
}

// 信息被改变
- (void)textFieldDidChange:(UITextField *)sender {
    long index = sender.tag - 100;
    MyInfoCell *cell = _cells[index];
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    [cell.editImageView setImage:image];
    
    //    if (self.saveBtn.enabled == NO) {
    //        self.saveBtn.enabled = YES;
    //        self.saveBtn.alpha = 1;
    //    }
}

// 手机号码3-4-4格式
- (void)formatPhoneNumber:(UITextField*)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    //    NSLog(@"targetCursorPosition:%li", (long)targetCursorPosition);
    // nStr表示不带空格的号码
    NSString* nStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* preTxt = [previousTextFieldContent stringByReplacingOccurrencesOfString:@" "
                                                                           withString:@""];
    
    char editFlag = 0;// 正在执行删除操作时为0，否则为1
    
    if (nStr.length <= preTxt.length) {
        editFlag = 0;
    }
    else {
        editFlag = 1;
    }
    
    // textField设置text
    if (nStr.length > 11)
    {
        textField.text = previousTextFieldContent;
        textField.selectedTextRange = previousSelection;
        return;
    }
    
    // 空格
    NSString* spaceStr = @" ";
    
    NSMutableString* mStrTemp = [NSMutableString new];
    int spaceCount = 0;
    if (nStr.length < 3 && nStr.length > -1)
    {
        spaceCount = 0;
    }else if (nStr.length < 7 && nStr.length >2)
    {
        spaceCount = 1;
        
    }else if (nStr.length < 12 && nStr.length > 6)
    {
        spaceCount = 2;
    }
    
    for (int i = 0; i < spaceCount; i++)
    {
        if (i == 0) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(0, 3)], spaceStr];
        }else if (i == 1)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(3, 4)], spaceStr];
        }else if (i == 2)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
        }
    }
    
    if (nStr.length == 11)
    {
        [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
    }
    
    if (nStr.length < 4)
    {
        [mStrTemp appendString:[nStr substringWithRange:NSMakeRange(nStr.length-nStr.length % 3,
                                                                    nStr.length % 3)]];
    }else if(nStr.length > 3)
    {
        NSString *str = [nStr substringFromIndex:3];
        [mStrTemp appendString:[str substringWithRange:NSMakeRange(str.length-str.length % 4,
                                                                   str.length % 4)]];
        if (nStr.length == 11)
        {
            [mStrTemp deleteCharactersInRange:NSMakeRange(13, 1)];
        }
    }
    //    NSLog(@"=======mstrTemp=%@",mStrTemp);
    
    textField.text = mStrTemp;
    // textField设置selectedTextRange
    NSUInteger curTargetCursorPosition = targetCursorPosition;// 当前光标的偏移位置
    if (editFlag == 0)
    {
        //删除
        if (targetCursorPosition == 9 || targetCursorPosition == 4)
        {
            curTargetCursorPosition = targetCursorPosition - 1;
        }
    }
    else {
        //添加
        if (nStr.length == 8 || nStr.length == 3)
        {
            curTargetCursorPosition = targetCursorPosition + 1;
        }
    }
    
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                              offset:curTargetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition
                                                         toPosition :targetPosition]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    return YES;
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    
    return 45.0;
    
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.selectArray.count;
}

// 数据
- (void)initSexData {
    self.pickerView.tag = 1;
    self.selectArray = [NSMutableArray arrayWithObjects:@"男", @"女", nil];
//    _sexViewArray = [[NSMutableArray alloc] init];
    
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    
    // 性别选择器
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 45)];
    myView.textAlignment = NSTextAlignmentCenter;
    
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    
    myView.textColor = RGB(161, 161, 161);
    
    myView.backgroundColor = [UIColor clearColor];
    
    if (selectRow == row){
        myView.textColor = RGB(34, 192, 100);
    }
    
    if(self.pickerView.tag == 1){
        myView.text = [self.selectArray objectAtIndex:row];
    }else{
        NSDictionary *dic = [self.selectArray objectAtIndex:row];
        myView.text = dic[@"name"];
    }
    
    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //    if (component == 0) {
    //        //省
    ////        NSString *pro = [self.provinceArray objectAtIndex:row];
    ////        self.selectPro = [pro substringFromIndex:2];
    ////
    ////        //获取对应的市
    ////        NSString *selectedState = [_provinceArray objectAtIndex:row];
    ////        NSArray *array = [self.stateZips objectForKey:selectedState];
    ////
    ////        self.cityArray = array;
    ////
    ////        [self.pickerView selectRow:0 inComponent:1 animated:YES];
    ////        if (array.count > 0){
    ////            NSString *city = [_cityArray objectAtIndex:0];
    ////            self.selectCity = city;
    ////        }
    //
    //    }else{
    //        //市
    //        NSString *city = [_cityArray objectAtIndex:row];
    //        self.selectCity = city;
    //    }
    selectRow = row;
    [pickerView reloadComponent:0];
    
}

#pragma mark - 按钮方法
- (IBAction)clickToUserInfoView:(id)sender {
    NSLog(@"账号信息");
    UserInfoViewController *targetViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToCoachInfoView:(id)sender {
    NSLog(@"教练资格信息");
    CoachInfoViewController *targetViewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
    targetViewController.superViewNum = @"1";
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToMyDetailInfoView:(id)sender {
    NSLog(@"个人资料");
    MyDetailInfoViewController *targetViewController = [[MyDetailInfoViewController alloc] initWithNibName:@"MyDetailInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToChangePwdView:(id)sender {
    NSLog(@"修改密码");
    
    NSString *pwd = self.pwdField.text;
    if ([CommonUtil isEmpty:pwd]) {
        [self makeToast:@"请输入原密码"];
        [self.pwdField becomeFirstResponder];
        return;
    }
    
    [self.pwdField resignFirstResponder];
    //1.验证原密码是否正确
    
    [self checkPwd];

}

// 取消
- (IBAction)clickForCancel:(id)sender {
    [self.pwdProveView removeFromSuperview];
}

// 验证原密码
- (IBAction)clickForProvePwd:(id)sender {
    self.pwdProveView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.pwdProveView];
}

// 开启驾校选择器
- (void)clickForSelectSchool:(UIButton *)sender {
    [self backupgroupTap:nil];
    //long index = sender.tag - 299;
    self.pickerView.tag = 0;
    [self getCarSchool]; // 获取所有驾校
    
}

// 开启选择器
- (void)clickForSelect:(UIButton *)sender {
    [self backupgroupTap:nil];
    long index = sender.tag - 300;
    // 选择性别
    if (index == 1) {
        [self selectSex:index];
    }
}

// 性别
- (void)selectSex:(long)index {
    [self initSexData];
    [self.pickerView reloadAllComponents];
    self.selectView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.selectView];
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

// 完成性别选择
- (IBAction)clickForSexDone:(id)sender {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    if(self.pickerView.tag == 1){
        MyInfoCell *sexCell = _cells[1];
        sexCell.contentField.text = self.selectArray[row];
        
    }else{
        MyInfoCell *carSchoolCell = _cells[1];
        if(row == (self.selectArray.count - 1)){
            carSchoolCell.selectBtn.hidden = YES;
            carSchoolCell.contentField.text = @"";
            carSchoolCell.contentField.placeholder = @"请输入您的所属驾校";
            _schoolCarID = @"";
            [carSchoolCell.contentField becomeFirstResponder];
        }else{
            carSchoolCell.selectBtn.hidden = NO;
            carSchoolCell.contentField.placeholder = @"";
            NSDictionary *dic = self.selectArray[row];
            carSchoolCell.contentField.text = dic[@"name"];
            _schoolCarID = [dic[@"schoolid"] description];
        }
        
    }
    [self.selectView removeFromSuperview];
    
    //可以提交
    if (self.commitBtn.enabled == NO) {
        self.commitBtn.enabled = YES;
        self.commitBtn.alpha = 1;
    }
}

//提交
- (IBAction)clickForCommit:(id)sender {
    MyInfoCell *cell = _cells[1];
    NSString *str1 = cell.contentField.text;
    if([CommonUtil isEmpty:str1]){
        [self makeToast:@"必须选择性别"];
        return;
    }
    [self updateUserData];
}

#pragma mark - 接口
//验证密码
- (void)checkPwd{
    NSString *pwd = self.pwdField.text;
    pwd = [CommonUtil md5:pwd];
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];

    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 3;
    request.requestMethod = @"POST";
    [request setPostValue:@"VerifyPsw" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"]; // 用户id
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[pwd lowercaseString] forKey:@"password"]; // 密码
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

// 获取所有驾校信息
- (void)getCarSchool{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 1;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"GetAllSchool" forKey:@"action"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

//提交个人资料
- (void)updateUserData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = userInfo[@"coachid"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.tag = 2;
    request.requestMethod = @"POST";
    [request setPostValue:@"PerfectAccountInfo" forKey:@"action"];
    [request setPostValue:coachId forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    
    //判断数据
    for (int i = 0; i < _cells.count; i++) {
        NSString *text = @"";
        MyInfoCell *cell = _cells[i];
        text = [cell.contentField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *str = @"";//提交的字段
        NSString *userKey = @"";//useInfo中的字段
        if (i == 0) {
            //姓名
            str = @"realname";
            userKey = @"realname";
        }else if (i == 1){
            //性别1.男2.女
            str = @"gender";
            userKey = @"gender";
            
            if ([@"男" isEqualToString:text]) {
                text = @"1";
            }else if ([@"女" isEqualToString:text]){
                text = @"2";
            }
        }
        
        
        if (![CommonUtil isEmpty:text]) {
            [request setPostValue:text forKey:str];
            [self.msgDic setObject:text forKey:userKey];
            
        }
    }
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
        
        if (request.tag == 1){
            NSMutableArray *arr = [result objectForKey:@"schoollist"];
            NSDictionary *di = [NSDictionary dictionaryWithObject:@"其它" forKey:@"name"];
            [arr addObject:di];
            [self.selectArray removeAllObjects];
            [self.selectArray addObjectsFromArray:arr];
            [self.pickerView reloadAllComponents];
            self.selectView.frame = [UIScreen mainScreen].bounds;
            [self.view addSubview:self.selectView];
            
        }else if(request.tag == 2){
            [self makeToast:@"修改成功"];
            
            NSMutableDictionary * ds = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            NSString *driveschool = ds[@"driveschool"];
            NSLog(@"%@",driveschool);
            for (NSString *key in self.msgDic.allKeys) {
                [ds setObject:[self.msgDic objectForKey:key] forKey:key];
            }
            [CommonUtil saveObjectToUD:ds key:@"userInfo"];
        }else if(request.tag == 3){
            //密码正确
            //2.正确的情况下修改密码
            ChangePwdViewController *targetViewController = [[ChangePwdViewController alloc] initWithNibName:@"ChangePwdViewController" bundle:nil];
            [self.pwdProveView removeFromSuperview];
            [self.navigationController pushViewController:targetViewController animated:YES];
        }else if(request.tag == 4){
            [self makeToast:@"修改头像成功"];
            
            NSString *url = result[@"avatarurl"];
            url = [CommonUtil isEmpty:url]?@"":url;

            //头像
            [self.portraitImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image != nil) {
                    self.portraitImage.layer.cornerRadius = self.portraitImage.bounds.size.width/2;
                    self.portraitImage.layer.masksToBounds = YES;
//                    [self updateLogoImage:self.portraitImage];
                }
            }];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
            [dic setObject:url forKey:@"avatarurl"];
            [CommonUtil saveObjectToUD:dic key:@"userInfo"];
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

- (IBAction)clickForChangeAddress:(id)sender {
    SetAddrViewController *targetViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}


- (IBAction)clickForChangeAvatar:(id)sender {
    self.alertPhotoView.frame = self.view.frame;
    [self.view addSubview:self.alertPhotoView];
}

//关闭弹框
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertPhotoView removeFromSuperview];
}

- (IBAction)clickForCamera:(id)sender {
    NSInteger tag = ((UIButton*)sender).tag;
    self.pickPhotoController = [self photoController];
    
    if(tag == 1){
        if ([CZPhotoPickerController canTakePhoto]) {
            //拍照

            self.pickPhotoController.allowsEditing = YES;
            [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else {
            //相册
            self.pickPhotoController.allowsEditing = YES;
            [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }else{
        //相册
        self.pickPhotoController.allowsEditing = YES;
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
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
        
        UIImage *image = imageInfoDict[UIImagePickerControllerEditedImage];
        if(!image)
            image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            image = [CommonUtil fixOrientation:image];
            [self uploadLogo:image];
        }
        
        [self.alertPhotoView removeFromSuperview];
    }];
}

//上传头像
- (void)uploadLogo:(UIImage *)image{
    [DejalBezelActivityView activityViewForView:self.view];
    
    self.changeLogoImage = image;//修改的头像
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.tag = 4;
    request.delegate = self;
    request.timeOutSeconds = 30;
    request.requestMethod = @"POST";
    [request setPostValue:@"ChangeAvatar" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setData:UIImageJPEGRepresentation(image, 0.75) forKey:@"avatar"];
    [request startAsynchronous];
    
}

- (void)savePrice {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 0;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"SetPrice" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:pricestr forKey:@"price"];
    [request startAsynchronous];
    [DejalBezelActivityView activityViewForView:self.view];
}

@end
