//
//  HiCaptureView.h
//  HiCapture
//
//  Created by Jett on 2018/11/21.
//  Copyright © 2018 mutating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "HiCapture.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HiCaptureViewDelegate;

@interface HiCaptureView : UIView

/**
 The object that a HiCapture instance.
 */
@property (nonatomic, strong, readonly) HiCapture *capture;

/**
 Indicates whether a capture view start immediately when the instance initialize.
 You can set in storyboard's attributes inspector.
 Default value is YES.
 */
@property (nonatomic, assign) IBInspectable BOOL autoPlay;

/**
 The object that acts as the delegate of the capture view.
 */
@property (nonatomic, weak) id<HiCaptureViewDelegate> delegate;

/**
 Starts the capture view instance running.
 */
- (void)start;

/**
 Stops the capture view instance that is currently running.
 */
- (void)stop;

@end

@protocol HiCaptureViewDelegate <NSObject>

@optional

/**
 Called when an AVCaptureVideoDataOutput instance outputs the first video frame, just only once.
 */
- (void)captureViewDidAppear;

/**
 Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.
 
 @param captureView
     The HiCaptureView instance that output the frame.
 @param sampleBuffer
     A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.
 @param connection
     The AVCaptureConnection from which the video was received.
 */
- (void)captureView:(HiCaptureView *)captureView didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

NS_ASSUME_NONNULL_END

