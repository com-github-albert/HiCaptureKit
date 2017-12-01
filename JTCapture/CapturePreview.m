//
//  CapturePreview.m
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import "CapturePreview.h"
#import <AVFoundation/AVFoundation.h>

@implementation CapturePreview

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session {
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    if (!self.videoPreviewLayer.session) {
        self.videoPreviewLayer.session = session;
    }
}

@end
