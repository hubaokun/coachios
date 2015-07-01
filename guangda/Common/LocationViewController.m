//
//  LocationViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/4/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreText/CoreText.h>

@interface LocationViewController ()

@property (strong, nonatomic) NSDictionary *stateZips;//省市
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *provinceArray;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    if (self.selectDic == nil) {
        self.selectDic = [NSMutableDictionary dictionary];
    }
    
    //默认值
    if ([CommonUtil isEmpty:self.selectPro]) {
        self.selectPro = @"浙江省";
    }
    if ([CommonUtil isEmpty:self.selectCity]) {
        self.selectCity = @"杭州市";
    }
    
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"statedictionary" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc ] initWithContentsOfFile :plistPath];
    
    self.stateZips = dictionary;
    NSArray *components = [self.stateZips allKeys];
    NSArray *sorted = [components sortedArrayUsingSelector: @selector (compare:)];
    self.provinceArray = [sorted mutableCopy];
    
    NSString *selectedState = [self.provinceArray objectAtIndex :0 ];
    
    NSArray *array = [[NSArray alloc] initWithArray:(NSArray *)[self.stateZips objectForKey:selectedState]];
    self.cityArray = array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonOKClick:(id)sender {
    
    [self.selectDic setObject:self.selectPro forKey:@"province"];
    [self.selectDic setObject:self.selectCity forKey:@"city"];
  
    if (_delegate && [_delegate respondsToSelector:@selector(location:selectDic:)]) {
        [_delegate location:self selectDic:self.selectDic];
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)clickForCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {//省份个数
        return [_provinceArray count];
        
    } else {//市的个数
        
        return [_cityArray count];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return CGRectGetWidth([UIScreen mainScreen].bounds) / 2;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds)/ 2;
    if (component == 0) {
        NSString *state = [self.provinceArray objectAtIndex:row];
        state = [state substringFromIndex:2];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = state;
        
        label.textColor = RGB(161, 161, 161);
        
        if ([state isEqualToString:self.selectPro]) {
            label.textColor = RGB(34, 192, 100);
        }

        [view addSubview:label];
        return view;
        
    } else {
        NSString *state = [_cityArray objectAtIndex:row];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = state;
        
        label.textColor = RGB(161, 161, 161);
        
        if ([state isEqualToString:self.selectCity]) {
            label.textColor = RGB(34, 192, 100);
        }
        
        [view addSubview:label];
        return view;
        
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        //省
        NSString *pro = [self.provinceArray objectAtIndex:row];
        self.selectPro = [pro substringFromIndex:2];
        
        //获取对应的市
        NSString *selectedState = [_provinceArray objectAtIndex:row];
        NSArray *array = [self.stateZips objectForKey:selectedState];
        
        self.cityArray = array;
        
        if (array.count > 0){
            NSString *city = [_cityArray objectAtIndex:0];
            self.selectCity = city;
        }
        
        [pickerView reloadComponent:0];
        [pickerView reloadComponent:1];
        [self.pickerView selectRow:0 inComponent:1 animated:YES];
        
    }else{
        //市
        NSString *city = [_cityArray objectAtIndex:row];
        self.selectCity = city;
        [pickerView reloadComponent:0];
        [pickerView reloadComponent:1];
    }
    

}

@end
