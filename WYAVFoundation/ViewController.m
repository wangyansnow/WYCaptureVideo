//
//  ViewController.m
//  WYAVFoundation
//
//  Created by 王俨 on 15/12/30.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WYCaptureController.h"
#import "WYVideoCaptureController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)takeButtonClick:(UIButton *)sender {
    WYVideoCaptureController *videoVC = [WYVideoCaptureController new];
    [self presentViewController:videoVC animated:YES completion:nil];
}

@end
