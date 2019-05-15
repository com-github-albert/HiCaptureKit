//
//  GLCameraViewController.m
//  GLCamera
//
//  Created by JT Ma on 2019/3/7.
//  Copyright © 2019 mutating. All rights reserved.
//

#import "GLCameraViewController.h"
#import "GLCameraTexture.h"
@import HiCaptureKit;

@interface GLCameraViewController () <HiCaptureVideoDataOutputSampleBufferDelegate, GLKViewDelegate>

@property (nonatomic, strong) GLKView *renderView;
@property (nonatomic, strong) HiCapture *capture;
@property (nonatomic, strong) GLCameraTexture *cameraTexture;

@end

@implementation GLCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.renderView = [[GLKView alloc] init];
    self.renderView.delegate = self;
    self.renderView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.renderView.backgroundColor = [UIColor blackColor];
    self.renderView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self.view insertSubview:self.renderView atIndex:0];
    [EAGLContext setCurrentContext:self.renderView.context];
    [self updateRenderViewTransform];
    
    self.cameraTexture = [GLCameraTexture new];
    
    self.capture = [HiCapture new];
    self.capture.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.capture start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.capture stop];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.renderView.frame = self.view.bounds;
}

- (void)updateRenderViewTransform {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
            break;
        case UIInterfaceOrientationLandscapeRight:
            break;
        case UIInterfaceOrientationPortrait:
            self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 1/ 2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 3/ 2);
            break;
        default:
            self.renderView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 1/ 2);
            break;
    }
}

#pragma mark - HiCaptureVideoDataOutputSampleBufferDelegate

- (void)capture:(HiCapture *)capture didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void *buffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    switch (format) {
        case kCVPixelFormatType_32BGRA:
            // BGRA
            [(GLCameraTexture *)_cameraTexture updateTexture:buffer width:width height:height];
            break;
        default:
            break;
    }
    
    [self.renderView display];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(0, 0, 0, 0); // rgba, (0, 0, 0, 1) is black color, (1, 1, 1, 1) is white color
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [_cameraTexture draw];
}

@end
