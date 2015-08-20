//
//  UILabel+StringFrame.m
//  yimiaobao
//
//  Created by hubaokun80803 on 14-8-28.
//  Copyright (c) 2014年 Student. All rights reserved.
//

#import "UILabel+StringFrame.h"

//
//  UILabel+StringFrame.m
//  LabelHeight
//
//  Copyright (c) 2014年 Y.X. All rights reserved.
//

#import "UILabel+StringFrame.h"

@implementation UILabel (StringFrame)

- (CGSize)boundingRectWithSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName: self.font};
    
    CGSize retSize = [self.text boundingRectWithSize:size
                                             options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    
    return retSize;
}


@end