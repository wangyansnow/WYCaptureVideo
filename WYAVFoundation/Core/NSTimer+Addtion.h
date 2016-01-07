//
//  NSTimer+Addtion.h
//  WYLoopDemo
//
//  Created by 王俨 on 15/12/16.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addtion)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end
