//
//  AmountTableViewCell.m
//  guangda
//
//  Created by 吴筠秋 on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AmountTableViewCell.h"

@implementation AmountTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/** 赋值
 * @param type      类型 "1.学员支付 2.提现 3.充值"
 * @param time      时间
 * @param amount    价格
 */
- (void)setType:(NSString *)type time:(NSString *)time amount:(NSString *)amount{
    
    //时间
    if (![CommonUtil isEmpty:time]) {
        self.timeLabel.text = time;
    }
    
    if ([CommonUtil isEmpty:amount]) {
        amount = @"0";
    }
    
    if ([type intValue] == 0){
        self.titleLabel.text = @"未知";
        self.moneyLabel.text = [NSString stringWithFormat:@"%@元", amount];
    }else if ([type intValue] == 1){
        //学员支付
        self.titleLabel.text = @"收入";
        self.moneyLabel.text = [NSString stringWithFormat:@"+ %@元", amount];
        self.moneyLabel.textColor = RGB(32, 180, 120);
        
    }else if ([type intValue] == 2){
        //提现
        self.titleLabel.text = @"提现";
        self.moneyLabel.text = [NSString stringWithFormat:@"- %@元", amount];
        self.moneyLabel.textColor = RGB(224, 72, 61);
        
    }else if ([type intValue] == 3){
        //充值
        self.titleLabel.text = @"充值";
        self.moneyLabel.text = [NSString stringWithFormat:@"+ %@元", amount];
        self.moneyLabel.textColor = RGB(32, 180, 120);
        
    }else if ([type intValue] == 4){
        //推荐奖
        self.titleLabel.text = @"推荐奖";
        self.moneyLabel.text = [NSString stringWithFormat:@"+ %@元", amount];
        self.moneyLabel.textColor = RGB(32, 180, 120);
        
    }else if ([type intValue] == 5){
        //被推荐教练开单奖
        self.titleLabel.text = @"被推荐教练开单奖";
        self.moneyLabel.text = [NSString stringWithFormat:@"+ %@元", amount];
        self.moneyLabel.textColor = RGB(32, 180, 120);
        
    }else if ([type intValue] == 6){
        //提现失败
        self.titleLabel.text = @"提现失败";
        self.moneyLabel.text = [NSString stringWithFormat:@"+ %@元", amount];
        self.moneyLabel.textColor = RGB(32, 180, 120);
        
    }else if ([type intValue] == 7){
        //提现
        self.titleLabel.text = @"提现";
        self.moneyLabel.text = [NSString stringWithFormat:@"- %@元", amount];
        self.moneyLabel.textColor = RGB(224, 72, 61);
        
    }
}

/**
 * 给描述赋值
 */
- (void)setDesDic:(NSDictionary *)dic{
    NSString *amount = [dic[@"amount"] description];//数量
    NSString *type = [dic[@"type"] description];//数量
    NSString *amount_out1 = [dic[@"amount_out1"] description];//平台抽成
    NSString *amount_out2 = [dic[@"amount_out2"] description];//驾校抽成
    
    NSString *str = @"";
    if ([type intValue] == 1) {
        if (![CommonUtil isEmpty:amount]) {
            str = [NSString stringWithFormat:@"(课程总额%.0f元", [amount floatValue] + [amount_out1 floatValue] + [amount_out2 floatValue]];
            
            if (![CommonUtil isEmpty:amount_out1] && [amount_out1 doubleValue] > 0) {
                str = [NSString stringWithFormat:@"%@，其中%@元小巴平台抽成", str, amount_out1];
            }
            
            if (![CommonUtil isEmpty:amount_out2] && [amount_out2 doubleValue] > 0) {
                str = [NSString stringWithFormat:@"%@，其中%@元驾校抽成", str, amount_out2];
            }
            
            str = [NSString stringWithFormat:@"%@)", str];
        }
    }
    
    CGFloat height = 0;
    if (![CommonUtil isEmpty:str]) {
        CGSize size = [CommonUtil sizeWithString:str fontSize:12 sizewidth:[_width doubleValue] - 23 sizeheight:MAXFLOAT];
        
        height += ceilf(size.height) + 15;
    }
    self.desHeightConstraint.constant = height;
    
    //赋值
    self.desLabel.text = str;
}
@end
