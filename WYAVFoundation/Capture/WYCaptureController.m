//
//  WYCapture.m
//  WYAVFoundation
//
//  Created by 王俨 on 15/12/30.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYCaptureController.h"
#import "WYTopImgBtn.h"
#import "UIView+Extension.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
#define kAnimationDuration 0.2

@interface WYCaptureController () <AVCaptureMetadataOutputObjectsDelegate>
{
    CGRect _leftBtnFrame;
    CGRect _centerBtnFrame;
    CGRect _rightBtnFrame;
}

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *dotLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) WYTopImgBtn *importBtn;

/// 负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *captureSession;
/// 负责从AVCaptureDevice获取输入数据
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
/// 照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
/// 相机拍摄预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end

@implementation WYCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.view.backgroundColor = RGB(0x16161b);
    
    [self setupCaptureView];
    [self addNotificationAppEnterBackground];
    [self ChangeToPhoto:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_captureSession startRunning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_captureSession stopRunning];
}
- (void)dealloc {
    [self removeNotification];
}

/// 初始化会话,摄像头设备,输入,输出,预览图层
- (void)setupCaptureView {
    // 1.初始化会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 2.设置分辨率
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    // 3.或得输入设备 -> 后置摄像头
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    if (captureDevice == nil) {
        NSLog(@"获取摄像头失败");
        return;
    }
    // 4.根据输入设备初始化设备输入对象,用于获得输入数据
    NSError *error = nil;
    _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"获取设备输入对象失败 error = %@", error);
        return;
    }
    // 5.初始化设备输出对象,用于获得输出数据
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _captureStillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG}; // 输出设置
    // 6.将输入设备添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    // 7.将输出设备添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    // 8.创建视频预览层,用于实时显示摄像头状态
    _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    CALayer *containerLayer = _viewContainer.layer;
    containerLayer.masksToBounds = YES;
    _captureVideoPreviewLayer.frame = containerLayer.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 设置填充模式
    [containerLayer insertSublayer:_captureVideoPreviewLayer atIndex:0];
    
    // 9.
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGestureRecognizer];
    
    // 10.实时人脸检测
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([_captureSession canAddOutput:metadataOutput]) {
        [_captureSession addOutput:metadataOutput];
    }
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
}

#pragma mark - AVCaptureMetadataObjectOutputDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects = %@", metadataObjects);
}

#pragma mark - 通知
/// 给输入设备添加通知
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice {
    // 注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}
/// 移除输入设备通知
- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/// 添加应用进入后台通知
- (void)addNotificationAppEnterBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

/// 移除所有通知
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)areaChange:(NSNotification *)n {
//    NSLog(@"捕获区域改变.. n = %@",n);
}
- (void)appEnterBackground:(NSNotification *)n {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VideoMethod
/// 取得指定位置的摄像头
///
/// @param position 摄像头位置[前置,后置]
///
/// @return 摄像头设备
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *captureDevice in cameras) {
        if (captureDevice.position == position) {
            return captureDevice;
        }
    }
    return nil;
}
/// 改变设备属性的统一方法
///
/// @param propertyChange 属性改变操作
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange {
    AVCaptureDevice *captureDevice = _captureDeviceInput.device;
    NSError *error = nil;
    // 注意改变属性之前一定要先调用lockForConfiguration;调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    } else {
        NSLog(@"设置设备属性过程中发生错误 -- error = %@", error);
    }
}
/// 添加点击聚焦手势
- (void)addGestureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick:)];
    [_viewContainer addGestureRecognizer:tapGesture];
}
- (void)tapGestureClick:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:tapGesture.view];
    // 把UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [_captureVideoPreviewLayer captureDevicePointOfInterestForPoint:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/// 设置聚焦焦点
/// @param point  聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point {
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            captureDevice.exposureMode = exposureMode;
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            captureDevice.exposurePointOfInterest = point;
        }
    }];
}

#pragma mark - UI设计
- (void)setupUI {
    [self prepareUI];
    
    [self.view addSubview:_closeBtn];
    [self.view addSubview:_toggleBtn];
    [self.view addSubview:_viewContainer];
    [_viewContainer addSubview:_imageView];
    [self.view addSubview:_progressView];
    [self.view addSubview:_dotLabel];
    [self.view addSubview:_leftBtn];
    [self.view addSubview:_centerBtn];
    [self.view addSubview:_rightBtn];
    [self.view addSubview:_cameraBtn];
    [self.view addSubview:_importBtn];
    
    _closeBtn.frame = CGRectMake(0, 10, 60, 30);
    _toggleBtn.frame = CGRectMake(APP_WIDTH - 60, 10, 60, 30);
    _viewContainer.frame = CGRectMake(0, 44, APP_WIDTH, APP_WIDTH);
    _imageView.frame = _viewContainer.bounds;
    _progressView.frame = CGRectMake(0, CGRectGetMaxY(_viewContainer.frame), APP_WIDTH, 2);
    _dotLabel.frame = CGRectMake((APP_WIDTH - 5) * 0.5, APP_WIDTH + 60 , 5, 5);
    CGFloat btnW = 40;
    CGFloat leftBtnX = (APP_WIDTH - 3 * btnW - 2 * 32) *0.5;
    CGFloat leftBtnY = CGRectGetMaxY(_dotLabel.frame) + 6;
    
    _leftBtnFrame = CGRectMake(leftBtnX, leftBtnY, btnW, btnW);
    _centerBtnFrame = CGRectOffset(_leftBtnFrame, 32 + btnW, 0);
    _rightBtnFrame = CGRectOffset(_centerBtnFrame, 32 + btnW, 0);
    [self restoreBtn];
    _cameraBtn.frame = CGRectMake((APP_WIDTH - 67) * 0.5, CGRectGetMaxY(_centerBtnFrame) + 32, 67, 67);
    _importBtn.frame = CGRectMake(CGRectGetMaxX(_cameraBtn.frame) + 25, _cameraBtn.y, 100, 60);
}
- (void)prepareUI {
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"button_camera_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _toggleBtn = [[UIButton alloc] init];
    [_toggleBtn setImage:[UIImage imageNamed:@"button_camera_CUT"] forState:UIControlStateNormal];
    [_toggleBtn addTarget:self action:@selector(toggleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _viewContainer = [[UIView alloc] init];
    _imageView = [[UIImageView alloc] init];
    _imageView.hidden = YES;
    
    _progressView = [UIView new];
    _progressView.backgroundColor = [UIColor orangeColor];
    
    _dotLabel = [UILabel new];  // 5 - 5
    _dotLabel.layer.cornerRadius = 2.5;
    _dotLabel.clipsToBounds = YES;
    _dotLabel.backgroundColor = RGB(0xffc437);
    
    _leftBtn = [UIButton new];
    [_leftBtn setTitle:@"照片" forState:UIControlStateNormal];
    [_leftBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _centerBtn = [UIButton new];
    [_centerBtn setTitleColor:RGB(0xffc437) forState:UIControlStateNormal];
    [_centerBtn setTitle:@"照片" forState:UIControlStateNormal];
    _centerBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _rightBtn = [UIButton new];
    [_rightBtn setTitle:@"MV" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _cameraBtn = [UIButton new];
    [_cameraBtn setImage:[UIImage imageNamed:@"button_camera_screen"] forState:UIControlStateNormal];
//    [_cameraBtn setImage:[UIImage imageNamed:@"button_camera_screen_click"] forState:UIControlStateHighlighted];
    [_cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _importBtn = [[WYTopImgBtn alloc] init];
    [_importBtn setImage:[UIImage imageNamed:@"icon_gallery_photo_import"] forState:UIControlStateNormal];
    [_importBtn setTitle:@"导入照片" forState:UIControlStateNormal];
    [_importBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _importBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_importBtn addTarget:self action:@selector(importBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ButtonClick
- (void)closeBtnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/// 切换前后摄像头
- (void)toggleBtnClick {
    AVCaptureDevice *currentDevice = _captureDeviceInput.device;
    AVCaptureDevicePosition currentPosition = currentDevice.position;
    [self removeNotificationFromCaptureDevice:currentDevice];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    // 1.需要调整的设备输入对象
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    // 2.改变会话的配置一定要先开启配置,配置完成后提交配置改变
    [_captureSession beginConfiguration];
    // 3.移除原有输入对象
    [_captureSession removeInput:_captureDeviceInput];
    // 4.添加新的输入对象
    if ([_captureSession canAddInput:captureDeviceInput]) {
        [_captureSession addInput:captureDeviceInput];
        _captureDeviceInput = captureDeviceInput;
    }
    // 5.提交会话配置
    [_captureSession commitConfiguration];
    
}
- (void)leftBtnClick:(UIButton *)btn {
    [_centerBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _dotLabel.hidden = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _leftBtn.frame = _centerBtnFrame;
        _centerBtn.frame = _rightBtnFrame;
    } completion:^(BOOL finished) {
        [self ChangeToPhoto:YES];
    }];
}
- (void)rightBtnClick:(UIButton *)btn {
    [_centerBtn setTitleColor:RGB(0xfefeff) forState:UIControlStateNormal];
    _dotLabel.hidden = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _rightBtn.frame = _centerBtnFrame;
        _centerBtn.frame = _leftBtnFrame;
    } completion:^(BOOL finished) {
        [self ChangeToPhoto:NO];
    }];
}
- (void)cameraBtnClick:(UIButton *)btn {
    // 1.根据设备输出获得链接
    AVCaptureConnection *captureConnection = [_captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    // 2.根据链接取得设备输出的数据
    [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        _imageView.image = [UIImage imageWithCGImage:[self handleImage:image]];
        _imageView.hidden = NO;
    }];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存照片成功 -- image = %@", image);
}

- (void)importBtnClick {
    
}

#pragma mark - private
- (void)restoreBtn {
    _leftBtn.frame = _leftBtnFrame;
    _centerBtn.frame = _centerBtnFrame;
    _rightBtn.frame = _rightBtnFrame;
    _dotLabel.hidden = NO;
    [_centerBtn setTitleColor:RGB(0xffc437) forState:UIControlStateNormal];
}
/// 切换拍照和视频录制
///
/// @param isPhoto YES->拍照  NO->视频录制
- (void)ChangeToPhoto:(BOOL)isPhoto {
    [self restoreBtn];
    NSString *centerTitle = isPhoto ? @"照片" : @"MV";
    [_centerBtn setTitle:centerTitle forState:UIControlStateNormal];
    _leftBtn.hidden = isPhoto;
    _rightBtn.hidden = !isPhoto;
    _progressView.hidden = isPhoto;
    _importBtn.hidden = !isPhoto;
    
    UIImage *photoImage = [UIImage imageNamed:@"button_camera_screen"];
    UIImage *mvImage = [UIImage imageNamed:@"button_video_recording_default"];
    UIImage *cameraImage = isPhoto ? photoImage : mvImage;
    [_cameraBtn setImage:cameraImage forState:UIControlStateNormal];
}

- (CGImageRef)handleImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.view.size, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, self.view.width, self.view.height)];
    CGImageRef imageRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    CGImageRef subRef = CGImageCreateWithImageInRect(imageRef, CGRectOffset(_viewContainer.frame, 0, 84));
    return subRef;
}

@end
