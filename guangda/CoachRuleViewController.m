//
//  CoachRuleViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachRuleViewController.h"

@interface CoachRuleViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CoachRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.editable = NO;
}

- (void)textViewDidChangeSelection:(UITextView *)textView

{
    
    NSRange range;
    range.location = 0;
    range.length = 0;
    textView.selectedRange = range;
    
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
