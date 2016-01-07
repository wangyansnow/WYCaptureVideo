//
//  PregressView.m
//  ProgressView
//
//  Created by yuelixing on 15/5/28.
//  Copyright (c) 2015年 yuelixing. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()

@property (nonatomic, retain) CAShapeLayer * shapeLayer;
@property (nonatomic, retain) CAShapeLayer * littleLayer;
@property (nonatomic, retain) CAShapeLayer * backLayer;

@end

@implementation ProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.layer addSublayer:self.backLayer];
        [self.layer addSublayer:self.littleLayer];
        [self.layer addSublayer:self.shapeLayer];
        
        self.progress = 0;
    }
    return self;
}

- (void)setCurrentTime:(CGFloat)currentTime {
    _currentTime = currentTime;
    self.progress = _currentTime/self.totalTime;
}

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(1, MAX(0, progress));
    if (_progress < 0.33 * 0.5) {
        self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    } else if (_progress < 0.66 * 0.5) {
        self.shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
    } else {
        self.shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    }
    _shapeLayer.strokeEnd = _progress;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        
        
        // 创建出贝塞尔曲线
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
        
        // 贝塞尔曲线与CAShapeLayer产生关联
        _shapeLayer.path = path.CGPath;
        
        // 基本配置
        _shapeLayer.fillColor   = RGB(0x2c2d32).CGColor;
        _shapeLayer.lineWidth   = self.frame.size.height;
        _shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
        _shapeLayer.strokeEnd   = 0.f;

    }
    return _shapeLayer;
}

- (CAShapeLayer *)littleLayer {
    if (!_littleLayer) {
        _littleLayer = [CAShapeLayer layer];
        _littleLayer.frame = CGRectMake(self.frame.size.width/3.0, 0, 1, self.frame.size.height);
        
        // 创建出贝塞尔曲线
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(1, self.frame.size.height/2)];
        
        // 贝塞尔曲线与CAShapeLayer产生关联
        _littleLayer.path = path.CGPath;
        
        // 基本配置
        _littleLayer.lineWidth   = self.frame.size.height;
        _littleLayer.strokeColor = [UIColor whiteColor].CGColor;
        _littleLayer.strokeEnd   = 1;
    }
    return _littleLayer;
}

- (CAShapeLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAShapeLayer layer];
        _backLayer.frame = self.bounds;
        
        // 创建出贝塞尔曲线
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
        
        // 贝塞尔曲线与CAShapeLayer产生关联
        _backLayer.path = path.CGPath;
        
        // 基本配置
        _backLayer.strokeColor   = RGB(0x2c2d32).CGColor;
        _backLayer.lineWidth   = self.frame.size.height;
        _backLayer.strokeEnd   = 1;
    }
    return _backLayer;
}

@end
