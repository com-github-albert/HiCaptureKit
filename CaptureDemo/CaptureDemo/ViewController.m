//
//  ViewController.m
//  CaptureDemo
//
//  Created by JT Ma on 14/12/2017.
//  Copyright © 2017 JT (ma.jiangtao.86@gmail.com). All rights reserved.
//

#import "ViewController.h"
#import "CapturePreview.h"
#import "Capture+Authorization.h"
#import <JTCapture/JTCapture.h>

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet CapturePreview *preview;
@property (nonatomic, strong) Capture *capture;

@end

@implementation ViewController {
    dispatch_queue_t _captureQueue;
    NSString *_capturePreset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _capturePreset = AVCaptureSessionPreset1280x720;
    [self initCapture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.capture authorizationObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.capture stop];
}

- (void)initCapture {
    if (!self.capture) {
        _captureQueue = dispatch_queue_create("com.hiscene.jt.captureSesstionQueue", DISPATCH_QUEUE_SERIAL);
        self.capture = [[Capture alloc] initWithSessionPreset:_capturePreset
                                               devicePosition:AVCaptureDevicePositionBack
                                                 sessionQueue:_captureQueue];
        self.preview.session = self.capture.session;

        dispatch_async( _captureQueue, ^{
            CaptureVideoDataOutput *captureVideoDataOutput = [[CaptureVideoDataOutput alloc] initWithSession:self.capture.session];
            [captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                /*
                 Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                 handled by -[AVCamCameraViewController viewWillTransitionToSize:withTransitionCoordinator:].
                 */
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                self.preview.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
            });
        });
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        self.preview.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

}

@end
