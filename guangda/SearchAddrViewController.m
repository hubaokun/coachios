//
//  SearchAddrViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SearchAddrViewController.h"
#import "BMapKit.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SearchAddrViewController () <UITextViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, UITextFieldDelegate, BMKPoiSearchDelegate>
@property (strong, nonatomic) IBOutlet UIView *naviView;
@property (strong, nonatomic) IBOutlet UITextView *positionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *pencilImageVIew;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *addrField;

@property (strong, nonatomic) BMKLocationService* locService;
@property (strong, nonatomic) BMKPoiSearch *poiSearch;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) BMKMapView *bMapView;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;

@property (strong, nonatomic) BMKPointAnnotation *nowAnnotation;//现在的标注
@property (strong, nonatomic) NSString *area;//城市
@property (strong, nonatomic) NSString *detailAddress;//详细地址
@end

@implementation SearchAddrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化参数
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.area = app.area;
    self.detailAddress = @"";
    
    
    self.bMapView = [[BMKMapView alloc]initWithFrame:self.mapView.bounds];
    [self.mapView addSubview:self.bMapView];
                           
    self.addrField.delegate = self;
    self.positionTextView.delegate = self;
    
    self.positionTextView.text = app.address;
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    //初始化检索对象
    self.poiSearch =[[BMKPoiSearch alloc] init];
    self.poiSearch.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 添加一个PointAnnotation
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    if (app.userCoordinate.latitude != 0 && app.userCoordinate.longitude != 0) {
        coor = app.userCoordinate;
        
        
    }else{
        self.latitude = @"30.26667";
        self.longitude = @"120.20000";
        coor.latitude = [self.latitude doubleValue];
        coor.longitude = [self.longitude doubleValue];
    }
    
    annotation.coordinate = coor;
//    annotation.title = @"群主在这里";
    
    
    //_bMapView.showsUserLocation = YES;//显示定位图层
    [_bMapView addAnnotation:annotation];
    self.nowAnnotation = annotation;
    
//    //设置经纬度
    self.bMapView.centerCoordinate = coor;
    
    _bMapView.zoomLevel = 14;//比例尺
    //设置中心点
    [_bMapView setCenterCoordinate:annotation.coordinate animated:YES];
    
    [_bMapView setMapCenterToScreenPt:CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds)/2)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_bMapView viewWillAppear];
    _bMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
- (void) viewWillDisappear:(BOOL)animated {
    [_bMapView viewWillDisappear];
    _bMapView.delegate = nil; // 不用时，置nil
    _poiSearch.delegate = nil;
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.image = [UIImage imageNamed:@"icon_pin.png"];
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        _bMapView.zoomLevel = 14;//比例尺
        //设置中心点
        [_bMapView setCenterCoordinate:annotation.coordinate animated:YES];
        
        return newAnnotationView;
    }
    return nil;
}


/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi{
    NSLog(@"22222");
}

/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
     NSLog(@"222223333322");
    
    [_bMapView removeAnnotation:self.nowAnnotation];
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    
    annotation.coordinate = coordinate;
    //    annotation.title = @"群主在这里";
    [_bMapView addAnnotation:annotation];
    self.nowAnnotation = annotation;
    
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = coordinate;
    
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
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        self.area = [NSString stringWithFormat:@"%@%@", result.addressDetail.province, result.addressDetail.city];
        self.detailAddress = [NSString stringWithFormat:@"%@%@%@", result.addressDetail.district, result.addressDetail.streetName, result.addressDetail.streetNumber];
        
        NSString *location = [NSString stringWithFormat:@"%@%@", self.area, self.detailAddress];
        
        self.positionTextView.text = location;
    }
}

#pragma mark - 搜索代理
//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSArray *pointArray = poiResultList.poiInfoList;
        
        if (pointArray.count > 0) {
            BMKPoiInfo *pointInfo = pointArray[0];
            
            NSString *address = pointInfo.address;
            self.positionTextView.text = address;
            
            self.area = pointInfo.city;//城市
            self.detailAddress = pointInfo.address;//详细地址
            
            [self mapView:_bMapView onClickedMapBlank:pointInfo.pt];//设置坐标点
        }else{
            [self makeToast:@"没有该地址，请重新输入"];
        }
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        [self makeToast:@"起始点有歧义，请重新输入"];
        NSLog(@"起始点有歧义");
    } else {
        [self makeToast:@"抱歉，未找到结果，请重新输入"];
        NSLog(@"抱歉，未找到结果");
    }
}

-(void)backupgroupTap:(id)sender{
    [self.addrField resignFirstResponder];
    [self.positionTextView resignFirstResponder];
}

#pragma mark - textView代理
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.pencilImageVIew setImage:[UIImage imageNamed:@"icon_pencil_blue"]];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.pencilImageVIew setImage:[UIImage imageNamed:@"icon_pencil_black"]];
}

#pragma mark - textField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.searchBtn setTitle:text forState:UIControlStateNormal];
    self.searchView.hidden = YES;
    
    //开始搜索地址
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //发起检索
    BMKCitySearchOption *option = [[BMKCitySearchOption alloc]init];
    option.pageIndex = 10;
    option.pageCapacity = 10;
    option.city = app.cityName;
    option.keyword = text;
    BOOL flag = [self.poiSearch poiSearchInCity:option];

    if(flag)
    {
        NSLog(@"检索发送成功");
    }
    else
    {
        NSLog(@"检索发送失败");
    }
    
    return YES;
}

#pragma mark - action
- (IBAction)clickForCancel:(id)sender {
    self.searchView.hidden = YES;
}

- (IBAction)clickForSearchNavi:(id)sender {
    self.searchView.hidden = NO;
}

- (IBAction)clickForSave:(id)sender {
    
    //上传数据
    NSString *place = [self.positionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([CommonUtil isEmpty:place]) {
        [self makeToast:@"请选择或者输入学车地址"];
        return;
    }
    
    if ([CommonUtil isEmpty:self.area]) {
        [self makeToast:@"请选择省市"];
        return;
    }
    
    if (self.nowAnnotation.coordinate.latitude == 0 && self.nowAnnotation.coordinate.longitude == 0) {
        [self makeToast:@"请选择经纬度"];
        return;
    }
    
    [self saveAddress:place];
    
}

#pragma mark - 接口
- (void)saveAddress:(NSString *)place{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kMyServlet]];
    request.tag = 1;
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"AddAddress" forKey:@"action"];
    [request setPostValue:userInfo[@"coachid"] forKey:@"coachid"];
    [request setPostValue:userInfo[@"token"] forKey:@"token"];
    [request setPostValue:[NSString stringWithFormat:@"%f", self.nowAnnotation.coordinate.longitude] forKey:@"longitude"];
    [request setPostValue:[NSString stringWithFormat:@"%f", self.nowAnnotation.coordinate.latitude] forKey:@"latitude"];
    [request setPostValue:self.area forKey:@"area"];
    [request setPostValue:place forKey:@"detail"];
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
        
        [self makeToast:@"添加地址成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
