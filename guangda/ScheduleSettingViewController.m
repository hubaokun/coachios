//
//  ScheduleSettingViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/4/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ScheduleSettingViewController.h"
#import "LoginViewController.h"

@interface ScheduleSettingViewController ()<UITextFieldDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *array100;
    NSArray *array10;
    NSArray *array1;
    UILabel *myView1;
    UILabel *myView2;
    UILabel *myView3;
}
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *timeScrollView;//时间点scrollView
@property (strong, nonatomic) IBOutlet UISwitch *stateSwitch;//状态开关
@property (strong, nonatomic) IBOutlet UILabel *timeStateLabel;//时间状态描述文字
@property (strong, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *priceTextField;//价格
@property (strong, nonatomic) IBOutlet UIButton *pricePencilBtn;
@property (strong, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;//上车地址
@property (strong, nonatomic) IBOutlet UIButton *addressPencilBtn;
@property (strong, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *contentTextField;//教学内容
@property (strong, nonatomic) IBOutlet UIButton *contentPencilBtn;
@property (strong, nonatomic) IBOutlet UIButton *comfirmBtn;

//选择框
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIPickerView *selectPickerView;
@property (strong, nonatomic) IBOutlet UIView *selectView2;
@property (strong, nonatomic) IBOutlet UIPickerView *pricePickerView;
@property (strong, nonatomic) NSString *price;//价格

//参数
@property (strong, nonatomic) NSMutableArray *selectArray;
@property (strong, nonatomic) NSMutableArray *addressArray;//地址
@property (strong, nonatomic) NSMutableArray *subjectArray;//科目
@property (strong, nonatomic) NSString *addressId;//地址id
@property (strong, nonatomic) NSString *subjectId;//科目id
@property (nonatomic) CGRect viewRect;

- (IBAction)clickForback:(id)sender;

@end

@implementation ScheduleSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectArray = [NSMutableArray array];
    self.addressArray = [NSMutableArray array];
    self.subjectArray = [NSMutableArray array];
    
    //将价格输入框变成选择框
    self.pricePickerView.delegate = self;
    self.pricePickerView.dataSource = self;
    array100 = @[@"0",@"1",@"2",@"3",@"4",@"5"];                     //百位 十位 个位
    array10 = @[@"5",@"6",@"7",@"8",@"9"];
    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    
    self.priceTextField.enabled = NO;
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self getAddressData];
    [self getContentData];
    [self initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.viewRect = self.view.frame;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initView{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.detailView.frame = CGRectMake(0, 0, width, CGRectGetHeight(self.detailView.frame));
    [self.mainScrollView addSubview:self.detailView];
    
    //------------------赋值-------------------
    //时间
    CGSize size = [CommonUtil sizeWithString:self.time fontSize:18 sizewidth:MAXFLOAT sizeheight:CGRectGetHeight(self.timeLabel.frame)];
    CGFloat maxWidth = ceil(size.width);
    self.timeLabel.frame = CGRectMake(0, 0, maxWidth, CGRectGetHeight(self.timeScrollView.frame));
    self.timeLabel.text = self.time;
    [self.timeScrollView addSubview:self.timeLabel];
    self.timeScrollView.contentSize = CGSizeMake(maxWidth, CGRectGetHeight(self.timeScrollView.frame));
    
    //价格
    NSString *price = [self.timeDic[@"price"] description];
    price = [CommonUtil isEmpty:price]?@"":price;
    price = price;//[NSString stringWithFormat:@"%d", [price floatValue]];
    self.priceTextField.text = price;
    
    //地址
    NSString *address = [CommonUtil isEmpty:self.timeDic[@"addressdetail"]]?@"":self.timeDic[@"addressdetail"];
    self.addressTextField.text = address;
    
    //教学内容
    NSString *subject = [CommonUtil isEmpty:self.timeDic[@"subject"]]?@"":self.timeDic[@"subject"];
    self.contentTextField.text = subject;
    
    self.addressId = self.timeDic[@"addressid"];
    self.subjectId = self.timeDic[@"subjectid"];
    
    NSString *isRest = self.timeDic[@"isrest"];//1:休息
    if ([isRest integerValue] == 1) {
        [self.stateSwitch setOn:NO];
    }else{
        [self.stateSwitch setOn:YES];
    }
    
    if (self.stateSwitch.isOn) {
        //打开状态
        self.timeStateLabel.text = @"开课状态，若关闭，以上时间点屏蔽任何 学员选课！";
        
        //时间单价状态
        self.priceTitleLabel.textColor = RGB(37, 37, 37);
        self.priceTextField.textColor = RGB(37, 37, 37);
        self.pricePencilBtn.hidden = NO;
        
        //上车地址状态
        self.addressTitleLabel.textColor = RGB(37, 37, 37);
        self.addressTextField.textColor = RGB(37, 37, 37);
        self.addressPencilBtn.hidden = NO;
        
        //教学内容状态
        self.contentPencilBtn.hidden = NO;
        self.contentTextField.textColor = RGB(37, 37, 37);
        self.contentTitleLabel.textColor = RGB(37, 37, 37);
        
    }else{
        //关闭状态
        self.timeStateLabel.text = @"未开课，以上时间点屏蔽任何学员选课！";
        
        //时间单价状态
        self.priceTitleLabel.textColor = RGB(210, 210, 210);
        self.priceTextField.textColor = RGB(210, 210, 210);
        self.pricePencilBtn.hidden = YES;
        
        //上车地址状态
        self.addressTitleLabel.textColor = RGB(210, 210, 210);
        self.addressTextField.textColor = RGB(210, 210, 210);
        self.addressPencilBtn.hidden = YES;
        
        //教学内容状态
        self.contentPencilBtn.hidden = YES;
        self.contentTextField.textColor = RGB(210, 210, 210);
        self.contentTitleLabel.textColor = RGB(210, 210, 210);
    }
    
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 45.0;
    
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.pricePickerView) {
        return 3;
    }
    return 1;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pricePickerView) {
        if (component == 0) {
            return array100.count;
        }
        if (component == 1) {
            return array10.count;
        }
        if (component == 2) {
            return array1.count;
        }
    }
    return self.selectArray.count;
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (pickerView == self.pricePickerView) {
        if (component == 0) {
            myView1 = nil;
            myView1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView1.textAlignment = NSTextAlignmentCenter;
            myView1.text = [array100 objectAtIndex:row];
            myView1.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView1.textColor = [UIColor whiteColor];
            myView1.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView1;
        }
        if (component == 1) {
            myView2 = nil;
            myView2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView2.textAlignment = NSTextAlignmentCenter;
            myView2.text = [array10 objectAtIndex:row];
            myView2.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView2.textColor = [UIColor whiteColor];
            myView2.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView2;
        }
        if (component == 2) {
            myView3 = nil;
            myView3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView3.textAlignment = NSTextAlignmentCenter;
            myView3.text = [array1 objectAtIndex:row];
            myView3.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView3.textColor = [UIColor whiteColor];
            myView3.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView3;
        }
        return nil;
    }
    
    UILabel *myView = nil;
    
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
    myView.textAlignment = NSTextAlignmentCenter;
    NSDictionary *dic = [self.selectArray objectAtIndex:row];
    myView.text = dic[@"name"];
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    
    myView.textColor = [UIColor whiteColor];
    
    myView.backgroundColor = [UIColor clearColor];
    
    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pricePickerView) {
        //限制价格的区间，在50~500之间
        if (component == 0) {
            if ([array100[row] isEqualToString:@"5"]) {
                array10 = @[@"0"];
                array1 = @[@"0"];
                [self.pricePickerView reloadComponent:1];
                [self.pricePickerView reloadComponent:2];
                
            }else{
                if ([array100[row] isEqualToString:@"0"]) {
                    array10 = @[@"5",@"6",@"7",@"8",@"9"];
                    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    [self.pricePickerView reloadComponent:1];
                    [self.pricePickerView reloadComponent:2];
                }else{
                    array10 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    [self.pricePickerView reloadComponent:1];
                    [self.pricePickerView reloadComponent:2];
                }
            }
        }
        [self.pricePickerView reloadAllComponents];
    }
    
}

#pragma mark - 页面特性
// 开始编辑，铅笔变蓝
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.priceTextField]) {
        self.pricePencilBtn.selected = YES;
        self.comfirmBtn.selected = YES;
        CGRect frame1 = self.priceTextField.frame;
        UIView *view1 = self.priceTextField.superview;
        CGRect frame2 = view1.frame;
        UIView *view2 = view1.superview;
        CGRect frame3 = view2.frame;
        CGFloat offset = (frame1.origin.y + frame2.origin.y + frame3.origin.y) + 32 - (self.view.frame.size.height - 216.0) + 64;
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if (offset>0){
            NSTimeInterval animationDuration = 0.30;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            [self.view setFrame:CGRectMake(0, -offset, self.viewRect.size.width, self.viewRect.size.height)];
            [UIView commitAnimations];
        }
    }
}

// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.priceTextField]) {
        self.pricePencilBtn.selected = NO;
        self.view.frame = self.viewRect;
    }
    
}

#pragma mark - 监听
- (void)keyboardWillShow:(NSNotification *)notification {
    //    scrollFrame = self.view.frame;
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.frame;
    
    if (self.priceTextField == nil) {
        return;
    }
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
    CGRect textFrame = self.priceTextField.superview.frame;
    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame);
    
    if(textFieldY < keyboardTop){
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    newTextViewFrame.origin.y = keyboardTop - textFieldY;
    
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.detailView.frame = newTextViewFrame;
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.detailView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.detailView.frame));
    [UIView commitAnimations];
}

#pragma mark - private
- (void)backupgroupTap:(id)sender{
    [self.priceTextField resignFirstResponder];
}

#pragma mark - action
- (IBAction)clickForChangeState:(id)sender {
    UISwitch *swi = (UISwitch *)sender;
    if (swi.isOn) {
        //打开状态
        self.timeStateLabel.text = @"开课状态，若关闭，以上时间点屏蔽任何 学员选课！";
        
        //时间单价状态
        self.priceTitleLabel.textColor = RGB(37, 37, 37);
        self.priceTextField.textColor = RGB(37, 37, 37);
        self.pricePencilBtn.hidden = NO;
        
        //上车地址状态
        self.addressTitleLabel.textColor = RGB(37, 37, 37);
        self.addressTextField.textColor = RGB(37, 37, 37);
        self.addressPencilBtn.hidden = NO;
        
        //教学内容状态
        self.contentPencilBtn.hidden = NO;
        self.contentTextField.textColor = RGB(37, 37, 37);
        self.contentTitleLabel.textColor = RGB(37, 37, 37);
        
    }else{
        //关闭状态
        self.timeStateLabel.text = @"未开课，以上时间点屏蔽任何学员选课！";
        
        //时间单价状态
        self.priceTitleLabel.textColor = RGB(210, 210, 210);
        self.priceTextField.textColor = RGB(210, 210, 210);
        self.pricePencilBtn.hidden = YES;
        
        //上车地址状态
        self.addressTitleLabel.textColor = RGB(210, 210, 210);
        self.addressTextField.textColor = RGB(210, 210, 210);
        self.addressPencilBtn.hidden = YES;
        
        //教学内容状态
        self.contentPencilBtn.hidden = YES;
        self.contentTextField.textColor = RGB(210, 210, 210);
        self.contentTitleLabel.textColor = RGB(210, 210, 210);
    }
    
    self.comfirmBtn.selected = YES;
}

//价格
- (IBAction)clickForPrice:(id)sender {
    if (self.stateSwitch.isOn) {
        [self.selectArray removeAllObjects];
        self.selectView2.frame = self.view.frame;
        [self.view addSubview:self.selectView2];
        [self.pricePickerView reloadAllComponents];
    }
    
}

//选择地址
- (IBAction)clickForChooseAddress:(id)sender {
    if (self.stateSwitch.isOn) {
        [self.selectArray removeAllObjects];
        
        for (NSDictionary *dic in self.addressArray) {
            NSString *detail = dic[@"detail"];
            detail = [CommonUtil isEmpty:detail]?@"":detail;
            
            NSString *addressid = [dic[@"addressid"] description];
            if ([CommonUtil isEmpty:addressid]) {
                addressid = @"";
            }
            
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            [dataDic setObject:detail forKey:@"name"];
            [dataDic setObject:addressid forKey:@"id"];
            [self.selectArray addObject:dataDic];
        }
        
        self.selectPickerView.tag = 0;
        self.selectView.frame = self.view.frame;
        [self.view addSubview:self.selectView];
        [self.selectPickerView reloadAllComponents];
    }
}

//教学内容
- (IBAction)clickForContent:(id)sender {
    if (self.stateSwitch.isOn) {
        [self.selectArray removeAllObjects];
        
        for (NSDictionary *dic in self.subjectArray) {
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            
            NSString *subject = dic[@"subjectname"];
            subject = [CommonUtil isEmpty:subject]?@"":subject;
            
            NSString *subjectId = [dic[@"subjectid"] description];
            if ([CommonUtil isEmpty:subjectId]) {
                subjectId = @"";
            }
            
            [dataDic setObject:subject forKey:@"name"];
            [dataDic setObject:subjectId forKey:@"id"];
            [self.selectArray addObject:dataDic];
        }
        
        self.selectPickerView.tag = 1;
        self.selectView.frame = self.view.frame;
        [self.view addSubview:self.selectView];
        [self.selectPickerView reloadAllComponents];
    }
}

- (IBAction)clickForRemoveSelect:(id)sender {
    [self.selectView removeFromSuperview];
    [self.selectView2 removeFromSuperview];
}

- (IBAction)clickForSelect:(id)sender {
    if (self.pricePickerView) {
        NSString *str = [self.price substringToIndex:1];
        if ([str isEqualToString:@"0"]) {
            self.price = [self.price substringFromIndex:1];
        }
        self.comfirmBtn.selected = YES;
        self.priceTextField.text = self.price;
        [self.selectView2 removeFromSuperview];
    }else{
        NSInteger row = [self.selectPickerView selectedRowInComponent:0];
        NSDictionary *dic = [self.selectArray objectAtIndex:row];
        
        if (self.selectPickerView.tag == 0) {
            //地址
            self.addressId = dic[@"id"];
            self.addressTextField.text = dic[@"name"];
        }else if (self.selectPickerView.tag == 1){
            //教学内容
            self.subjectId = dic[@"id"];
            self.contentTextField.text = dic[@"name"];
        }
        
        [self.selectView removeFromSuperview];
        self.comfirmBtn.selected = YES;
        
        [self.selectView2 removeFromSuperview];
    }
}

- (IBAction)clickForConfirm:(id)sender {
    if (self.comfirmBtn.selected) {
        
        if (self.stateSwitch.isOn){
            NSString *price = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([CommonUtil isEmpty:price]) {
                [self makeToast:@"请输入时间单价"];
                [self.priceTextField becomeFirstResponder];
                return;
            }
            
            if ([CommonUtil isEmpty:self.addressTextField.text]) {
                [self makeToast:@"请选择学车地址"];
                return;
            }
            
            if ([CommonUtil isEmpty:self.contentTextField.text]) {
                [self makeToast:@"请选择教学内容"];
                return;
            }
        }
        
        [self.priceTextField resignFirstResponder];
        
        [self comfirmMsg];
    }
}

#pragma mark - 接口
- (void)getAddressData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 0;
    request.delegate = self;
    [request setPostValue:@"GetAllAddress" forKey:@"action"];
    [request setPostValue:[userInfo[@"coachid"] description] forKey:@"coachid"];
    [request setPostValue:[userInfo[@"token"] description] forKey:@"token"];
    [request startAsynchronous];
}

//获取教学内容
- (void)getContentData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 1;
    request.delegate = self;
    [request setPostValue:@"GetAllSubject" forKey:@"action"];
    [request setPostValue:[userInfo[@"coachid"] description] forKey:@"coachid"];
    [request setPostValue:[userInfo[@"token"] description] forKey:@"token"];
    [request startAsynchronous];
}

//提交修改信息
- (void)comfirmMsg{
    NSString *price = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *state = [self.timeDic[@"state"] description];
    if ([CommonUtil isEmpty:state]) {
        state = @"";
    }
    NSString *cancelstate = [self.timeDic[@"cancelstate"] description];
    if ([CommonUtil isEmpty:cancelstate]) {
        cancelstate = @"";
    }
    
    NSArray *timeArray = [self.time componentsSeparatedByString:@"、"];
    
    NSMutableArray *msgArray = [NSMutableArray array];
    for (NSString *str in timeArray) {
        NSDate *strDate = [CommonUtil getDateForString:str format:@"HH:00"];
        NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:hourStr forKey:@"hour"];
        [dic setObject:state forKey:@"state"];
        [dic setObject:cancelstate forKey:@"cancelstate"];
        [dic setObject:price forKey:@"price"];
        if (self.stateSwitch.isOn) {
            //是否休息 0.不休息  1.休息
            [dic setObject:@"0" forKey:@"isrest"];
        }else{
            //休息
            [dic setObject:@"1" forKey:@"isrest"];
        }
        
        [dic setObject:self.addressId forKey:@"addressid"];
        [dic setObject:self.subjectId forKey:@"subjectid"];
        
        [msgArray addObject:dic];
    }
    
    [DejalBezelActivityView activityViewForView:self.view];
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kScheduleServlet]];
    request.tag = 2;
    request.delegate = self;
    [request setPostValue:@"SetDateTime" forKey:@"action"];
    [request setPostValue:[userInfo[@"coachid"] description] forKey:@"coachid"];
    [request setPostValue:[userInfo[@"token"] description] forKey:@"token"];
    [request setPostValue:self.date forKey:@"day"];
    [request setPostValue:msgArray forKey:@"setjson"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    request.delegate = nil;
    NSDictionary *result = [[request responseString] JSONValue];
    
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    
    // 取得数据成功
    if ([code intValue] == 1) {
        if (request.tag == 0) {
            self.addressArray = [NSMutableArray arrayWithArray:result[@"addresslist"]];
        }else if (request.tag == 1){
            self.subjectArray = [NSMutableArray arrayWithArray:result[@"subjectlist"]];
        }else if (request.tag == 2){
            [DejalBezelActivityView removeViewAnimated:YES];
            
            //提交修改信息
            [self makeToast:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:result[@"datelist"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDaySchedule" object:array];
        }
    }else if([code intValue] == 95){
        [self makeToast:message];
        [CommonUtil logout];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(backLogin)
                                       userInfo:nil
                                        repeats:NO];
    }else{
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([CommonUtil isEmpty:message]) {
            message = ERR_NETWORK;
        }
        
        [self makeToast:message];
    }
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

- (IBAction)clickForback:(id)sender {
    if (self.comfirmBtn.selected == YES) {   //添加一个退出的提示，防止教练在不经意的情况下退出了。
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您修改了课程设置，确定要退出吗？" delegate:self cancelButtonTitle:@"确认退出" otherButtonTitles:@"保存修改", nil];
        [alert show];
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDaySchedule" object:array];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSMutableArray *array = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDaySchedule" object:array];
        [self.navigationController popViewControllerAnimated:YES];
    }else if(buttonIndex == 1){
        
        if (self.stateSwitch.isOn){
            NSString *price = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([CommonUtil isEmpty:price]) {
                [self makeToast:@"请输入时间单价"];
                [self.priceTextField becomeFirstResponder];
                return;
            }
            
            if ([CommonUtil isEmpty:self.addressTextField.text]) {
                [self makeToast:@"请选择学车地址"];
                return;
            }
            
            if ([CommonUtil isEmpty:self.contentTextField.text]) {
                [self makeToast:@"请选择教学内容"];
                return;
            }
        }
        
        [self.priceTextField resignFirstResponder];
        
        [self comfirmMsg];
    }
}


@end
