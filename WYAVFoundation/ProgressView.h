//
//  PregressView.h
//  ProgressView
//
//  Created by yuelixing on 15/5/28.
//  Copyright (c) 2015年 yuelixing. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define APP_WIDTH [UIScreen mainScreen].bounds.size.width
#define APP_HEIGHT [UIScreen mainScreen].bounds.size.height

/**
 *  视频录制中的进度条
 */
@interface ProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, assign) CGFloat currentTime;

@end
