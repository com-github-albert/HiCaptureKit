//
//  CaptureVideoDataOutput.m
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import "CaptureVideoDataOutput.h"

@implementation CaptureVideoDataOutput

- (instancetype)initWithSession:(AVCaptureSession *)session {
    self = [super init];
    if (self) {
        [session beginConfiguration];
        
        if ([session canAddOutput:self]) {
            [session addOutput:self];
            
            /*
             On iOS, the only supported key is kCVPixelBufferPixelFormatTypeKey. 
             Supported pixel formats are kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA.
             */
            [self setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
        } else {
#if DEBUG
            NSLog( @"Could not add video device output to the session" );
#endif
            [session commitConfiguration];
            return nil;
        }
        
        [session commitConfiguration];
    }
    return self;
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation *)videoOrientation {
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoOrientationSupported]) {
        videoConnection.videoOrientation = videoOrientation;
    }
}

@end
