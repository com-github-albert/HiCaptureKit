//
//  Capture.h
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM( NSInteger, AVCaptureSetupResult ) {
    AVCaptureSetupResultSuccess,
    AVCaptureSetupResultCameraNotAuthorized,
    AVCaptureSetupResultSessionConfigurationFailed
};

@interface Capture : NSObject

@property (nonatomic, readonly) AVCaptureSession *session;
@property (nonatomic, assign) AVCaptureSetupResult setupResult;
@property (nonatomic) dispatch_queue_t sessionQueue;

@property (nonatomic, assign) AVCaptureDevicePosition position;
@property (nonatomic, strong) NSString *sessionPreset;
@property (nonatomic, assign) NSInteger activeVideoFrame;

@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureFocusMode focusMode;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSessionPreset:(NSString *)sessionPreset
                       devicePosition:(AVCaptureDevicePosition)position
                         sessionQueue:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

- (void)start;
- (void)stop;

@end
