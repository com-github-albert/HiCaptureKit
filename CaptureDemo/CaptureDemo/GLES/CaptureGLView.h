//
//  CaptureGLView.h
//  CameraDemo
//
//  Created by JT Ma on 04/08/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface CaptureGLView : UIView

- (void)render:(CVPixelBufferRef)sampleBuffer;

@end
