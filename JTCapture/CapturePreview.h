//
//  CapturePreview.h
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureVideoPreviewLayer;
@class AVCaptureSession;

@interface CapturePreview : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureSession *session;

@end
