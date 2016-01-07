//
//  WYVideoTimeView.m
//  WYAVFoundation
//
//  Created by 王俨 on 16/1/4.
//  Copyright © 2016年 wangyan. All rights reserved.
//

#import "WYVideoTimeView.h"
#import "UIView+AutoLayoutViews.h"

#define kDotLabelW 9

@interface WYVideoTimeView ()

@property (nonatomic, strong) UILabel *dotLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation WYVideoTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self prepareUI];
    [self addSubview:_dotLabel];
    [self addSubview:_timeLabel];
    
    [_dotLabel lx_InnerLayoutForType:LXLayoutInnerTypeLeftCenter referedView:self size:CGSizeMake(kDotLabelW, kDotLabelW) offset:CGPointZero];
    [_timeLabel lx_OuterLayoutForType:LXLayoutOuterTypeRightCenter referedView:_dotLabel offset:CGPointMake(kDotLabelW, 0)];
}

- (void)prepareUI {
    _dotLabel = [[UILabel alloc] init]; // 9 - 9
    _dotLabel.layer.cornerRadius = kDotLabelW * 0.5;
    _dotLabel.clipsToBounds = YES;
    _dotLabel.backgroundColor = RGB(0xd43c3c);
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.textColor = [UIColor whiteColor];
//    _timeLabel.text = @"00.00";
//    [_timeLabel sizeToFit];
}

- (void)setVideoTime:(CGFloat)videoTime {
    _videoTime = videoTime;
    _timeLabel.text = [NSString stringWithFormat:@"%.1lf%1d", videoTime, arc4random()%10];
}

@end
