//
//  HiCaptureView.m
//  HiCapture
//
//  Created by Jett on 2018/11/21.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "HiCaptureView.h"
#import "HiCapturePreview.h"

@interface HiCaptureView () <HiCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation HiCaptureView {
    HiCapturePreview *_preview;
    BOOL _isDidAppear;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoPlay = YES;
        [self initCamera];
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    [self stop];
    [self removeNotification];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _preview.frame = self.bounds;
}

#pragma mark - Public

- (void)start {
    [_capture start];
}

- (void)stop {
    [_capture stop];
}

#pragma mark - Camera

- (void)initCamera {
    if (!_capture) {
        _capture = [HiCapture new];
        _capture.delegate = self;
        UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
        _capture.videoOrientation = (AVCaptureVideoOrientation)orientation;
        
        _preview = [HiCapturePreview new];
        [self addSubview:_preview];
        _preview.session = _capture.session;
    }
}

- (void)_changeCapturePreviewOrientation {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            _preview.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            _preview.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            _preview.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _preview.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            _preview.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
}

#pragma mark - HiCaptureVideoDataOutputSampleBufferDelegate

- (void)capture:(HiCapture *)capture
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
 fromConnection:(AVCaptureConnection *)connection {
    if (!_isDidAppear) {
        _isDidAppear = YES;
        [self _changeCapturePreviewOrientation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureViewDidAppear)]) {
            [self.delegate captureViewDidAppear];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureView:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate captureView:self didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

- (void)capture:(HiCapture *)capture interruptedWithError:(NSError *)error {
    NSLog(@"capture error: %@", error);
}

#pragma mark - Notification

- (void)addNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeNotification {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didBecomeActive {
    [_capture start];
}

- (void)willResignActive {
    [_capture stop];
}

- (void)deviceOrientationDidChange {
    [self _changeCapturePreviewOrientation];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        if ([coder containsValueForKey:@"autoPlay"]) {
            _autoPlay = [coder decodeBoolForKey:@"autoPlay"];
        } else {
            _autoPlay = YES;
        }
        [self initCamera];
        [self addNotification];
        
        if (_autoPlay) {
            [_capture start];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_autoPlay forKey:@"autoPlay"];
}

@end

