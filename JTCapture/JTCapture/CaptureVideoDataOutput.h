//
//  CaptureVideoDataOutput.h
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface CaptureVideoDataOutput : AVCaptureVideoDataOutput

@property (nonatomic, strong) AVCaptureVideoOrientation *videoOrientation;

- (instancetype)initWithSession:(AVCaptureSession *)session;

@end
