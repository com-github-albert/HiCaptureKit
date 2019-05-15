//
//  HiCapturePreview.h
//  HiCapture
//
//  Created by Jett on 30/11/2017.
//  Copyright © 2017 mutating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HiCapturePreview : UIView

/**
 Indicates a HiCapturePreview can display capture preview.
 */
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

/**
 The object that an AVCaptureSession instance.
 Indicates the videoPreviewLayer in conjunction with an AVCaptureSession.
 */
@property (nonatomic, strong) AVCaptureSession *session;

@end

NS_ASSUME_NONNULL_END
