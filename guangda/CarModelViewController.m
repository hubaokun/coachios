//
//  CarModelViewController.m
//  guangda
//
//  Created by Ray on 15/8/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CarModelViewController.h"
#import "LoginViewController.h"
@interface CarModelViewController ()
@property (strong, nonatomic) NSMutableDictionary *msgDic;//参数
@property (strong, nonatomic) IBOutlet UIButton *C1Button;
@property (strong, nonatomic) IBOutlet UIButton *C2Button;

@end

@implementation CarModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
    [self.C1Button setImage:[UIImage imageNamed:@"ic_c1car"] forState:UIControlStateNormal];
    [self.C1Button setImage:[UIImage imageNamed:@"ic_selected_c1car"] forState:UIControlStateSelected];
    [self.C2Button setImage:[UIImage imageNamed:@"ic_c2car"] forState:UIControlStateNormal];
    [self.C2Button setImage:[UIImage imageNamed:@"ic_selected_c2car"] forState:UIControlStateSelected];
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *modelid = [userInfo[@"modelid"]description];//准教车型id
    NSArray *array = [modelid componentsSeparatedByString:@","];
    for (int i=0; i<array.count; i++) {
        NSString *model = array[i];
        if ([model intValue] == 17) {
            self.C1Button.selected = YES;
        }
        if ([model intValue] == 18) {
            self.C2Button.selected = YES;
        }
    }
}
- (IBAction)clickForC1:(id)sender {
    if (self.C1Button.selected) {
        self.C1Button.selected = NO;
    }else{
        self.C1Button.selected = YES;
    }
}
- (IBAction)clickForC2:(id)sender {
    if (self.C2Button.selected) {
        self.C2Button.selected = NO;
    }else{
        self.C2Button.selected = YES;
    }
}
- (IBAction)commitCarmodel:(id)sender {
    if (self.C1Button.selected || self.C2Button.selected) {
        [self pushCarModel];
    }else{
        [self makeToast:@"请至少选择一种车型"];
    }
}

- (void)pushCarModel{
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kUserServlet]];
    request.delegate = self;
    request.requestMethod = @"POST";
    [request setPostValue:@"PERFECTCOACHMODELID" forKey:@"action"];
    
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId  = [ds objectForKey:@"coachid"];
    
    [request setPostValue:coachId forKey:@"coachid"];             // 教练ID
    [request setPostValue:ds[@"token"] forKey:@"token"];
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
    [self.msgDic setObject:modelIds forKey:@"modelid"];
    
    [request setPostValue:modelIds forKey:@"modelid"];             // 准教车型ID
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
        [self makeToast:@"提交成功"];
        NSMutableDictionary * ds = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getObjectFromUD:@"userInfo"]];
        for (NSString *key in self.msgDic.allKeys) {
            [ds setObject:[self.msgDic objectForKey:key] forKey:key];
        }
        [CommonUtil saveObjectToUD:ds key:@"userInfo"];
        [self.navigationController popViewControllerAnimated:YES];
    }else if([code intValue] == 95){
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
