//
//  HiCapture.h
//  HiCapture
//
//  Created by Jett on 30/11/2017.
//  Copyright © 2017 mutating. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HiCaptureVideoDataOutputSampleBufferDelegate;

@interface HiCapture : NSObject

/**
 The object that acts as the delegate of the capture.
 */
@property (nonatomic, weak) id<HiCaptureVideoDataOutputSampleBufferDelegate> delegate;

/**
 Indicates the central hub of the AVFoundation capture classes.
 */
@property (nonatomic, readonly) AVCaptureSession *session;

/**
 Indicates the physical position of a capture device's hardware on the system.
 */
@property (nonatomic, assign) AVCaptureDevicePosition position;

/**
 Indicates the session preset currently in use by the receiver.
 */
@property (nonatomic, strong) NSString *sessionPreset;

/**
 The currently active format of the capture receiver.
 */
@property (nonatomic, assign) NSInteger activeVideoFrame;

/**
 Indicates whether the video flowing through the connection should be rotated to a given orientation.
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/**
 Indicates current mode of the receiver's flash, if it has one.
 */
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

/**
 Indicates current mode of the receiver's torch, if it has one.
 */
@property (nonatomic, assign) AVCaptureTorchMode torchMode;

/**
 Indicates current focus mode of the receiver, if it has one.
 */
@property (nonatomic, assign) AVCaptureFocusMode focusMode;

/**
 Indicates whether the capture session is running.
 */
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

/**
 Indicates whether printing the debug logs.
 */
@property (nonatomic, assign) BOOL debugLogEnable;

/**
 Starts the capture instance running.
 */
- (void)start;

/**
 Stops the capture instance that is currently running.
 */
- (void)stop;

@end

@protocol HiCaptureVideoDataOutputSampleBufferDelegate <NSObject>

@optional

/**
 Called when the capture encounters an error during running.
 
 @param capture
 The HiCapture instance that output the frame.
 @param error
 Returns, by-reference, a description of the error, if an error occurs.
 */
- (void)capture:(HiCapture *)capture interruptedWithError:(NSError *)error;

/**
 Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.

 @param capture
    The HiCapture instance that output the frame.
 @param sampleBuffer
    A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.
 @param connection
    The AVCaptureConnection from which the video was received.
 */
- (void)capture:(HiCapture *)capture didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

/**
 Asks the delegate could scan qr code.

 @return The result should scan qr code.
 */
- (BOOL)captureShouldOutputQRCodeMetadataObject;

/**
 Informs the delegate that the capture output object emitted new metadata objects.

 @param capture
     The HiCapture instance that output the frame.
 @param metadataObject
     An array of AVMetadataObject instances representing the newly emitted metadata. Because AVMetadataObject is an abstract class, the objects in this array are always instances of a concrete subclass.
 @param connection
     The AVCaptureConnection from which the video was received.
 */
- (void)capture:(HiCapture *)capture didOutputMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject fromConnection:(AVCaptureConnection *)connection;

@end

NS_ASSUME_NONNULL_END
