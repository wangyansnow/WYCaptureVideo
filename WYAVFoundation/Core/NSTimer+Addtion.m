//
//  NSTimer+Addtion.m
//  WYLoopDemo
//
//  Created by 王俨 on 15/12/16.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "NSTimer+Addtion.h"

@implementation NSTimer (Addtion)

- (void)pauseTimer {
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate distantFuture]]; // 未来时间
}
- (void)resumeTimer {
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate date]];
}
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval {
    if (![self isValid]) {
        return;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end
