//
//  MyComplainCell.m
//  guangda
//
//  Created by 冯彦 on 15/3/18.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyComplainCell.h"

@interface MyComplainCell()
@property (strong, nonatomic) IBOutlet UIImageView *dealedImageView;    // 已处理图标
@property (strong, nonatomic) IBOutlet UILabel *complainContentLabel;   // 投诉内容
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;              // 学员名字
@property (strong, nonatomic) IBOutlet UILabel *taskTimeLabel;          // 任务时间
//@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView;   // 学员头像
@property (strong, nonatomic) IBOutlet UILabel *handleLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *complainContentHeight; // 投诉内容约束高度
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dialogIconY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentAndLineHeight;  // 投诉内容与线的高度
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *depositLabels; // 存放labelview的高度
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *depositAndLine;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *depositAndLabel;



@end  

@implementation MyComplainCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 对头像裁剪成六边形
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}


- (void)loadData:(NSArray *)arrayData {
    NSString *complainContent = self.complainContent; // 投诉内容
    self.taskTimeLabel.text = self.complainData;      // 任务时间
    self.nameLabel.text = self.studentName;           // 学员名字
    self.contentAndLineHeight.constant = self.clheight + 15;
    self.depositAndLine.constant = 0;
    self.depositAndLabel.constant = 0;
    //self.depositLabels.constant = self.clheight + 15;
    if([CommonUtil isEmpty:self.studentIcon])         // 设置学员头像
    {
        self.studentIcon = @"";
    }
    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:self.studentIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(image != nil){
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
//            [self updateLogoImage:self.studentIconImageView];//裁切头像
        }
    }];
    //延时调用是为了等图片显示出来之后再进行裁剪
   // [self performSelector:@selector(updateLogoImage:) withObject:self.studentIconImageView afterDelay:0];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:complainContent];
    //NSLog(@"%i",self.hasDealedWith);
    [str addAttribute:NSForegroundColorAttributeName value:RGB(33, 180, 120) range:NSMakeRange(0,self.complainBecauseLenght)];
     self.complainContentLabel.attributedText = str;
    CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:0];
    self.complainContentHeight.constant = textSize.height;
    // 已处理
    if (self.hasDealedWith == 1) {
        self.handleLabel.hidden = YES;
        self.dealedImageView.hidden = NO;
        self.dialogIconY.constant = 46;
        self.complainContentLabel.textColor = RGB(210, 210, 210);
        self.nameLabel.textColor = RGB(210, 210, 210);
        self.taskTimeLabel.textColor = RGB(210, 210, 210);
    }else{
        self.handleLabel.hidden = NO;
        self.dealedImageView.hidden = YES;
        self.dialogIconY.constant = 17;
        self.complainContentLabel.textColor = RGB(37, 37, 37);
        //NSLog(@"%i",self.hasDealedWith);
        [str addAttribute:NSForegroundColorAttributeName value:RGB(33, 180, 120) range:NSMakeRange(0,self.complainBecauseLenght)];
        self.complainContentLabel.attributedText = str;
        CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(_screenWidth - 77) sizeheight:0];
        self.complainContentHeight.constant = textSize.height;
        //self.complainContentLabel.textColor = RGB(37, 37, 37);
        self.nameLabel.textColor = RGB(37, 37, 37);
        self.taskTimeLabel.textColor = RGB(37, 37, 37);
    }
    if(self.type2 == 1 || self.type2 == 2){
        self.complainContentLabel.textColor = RGB(210, 210, 210);
    }
}

// 根据文字，字号及固定宽(固定高)来计算高(宽)
- (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height
{
    
    // 用何种字体显示
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment=NSTextAlignmentLeft;
        
        NSAttributedString *attributeText=[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
        CGSize labelsize = [attributeText boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        expectedLabelSize = CGSizeMake(ceilf(labelsize.width),ceilf(labelsize.height));
    } else {
        expectedLabelSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByCharWrapping];
    }
    
    // 计算出显示完内容的最小尺寸
    
    return expectedLabelSize;
}

@end
