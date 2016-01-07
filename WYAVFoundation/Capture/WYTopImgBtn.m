//
//  WYTopImgBtn.m
//  WYAVFoundation
//
//  Created by 王俨 on 15/12/30.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYTopImgBtn.h"
#import "UIView+Extension.h"

#define kVMargin 3

@implementation WYTopImgBtn

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageX = (self.width - self.imageView.width) * 0.5;
    CGFloat imageY = (self.height - self.imageView.height - kVMargin) * 0.5;
    self.imageView.frame = CGRectMake(imageX, imageY, self.imageView.width, self.imageView.height);
    
    CGFloat titleX = (self.width - self.titleLabel.width) * 0.5;
    self.titleLabel.frame = CGRectMake(titleX, CGRectGetMaxY(self.imageView.frame) + kVMargin, self.titleLabel.width, self.titleLabel.height);
}

@end
