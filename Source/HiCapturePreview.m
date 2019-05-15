//
//  HiCapturePreview.m
//  HiCapture
//
//  Created by Jett on 30/11/2017.
//  Copyright © 2017 mutating. All rights reserved.
//

#import "HiCapturePreview.h"
#import <AVFoundation/AVFoundation.h>

@implementation HiCapturePreview

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
