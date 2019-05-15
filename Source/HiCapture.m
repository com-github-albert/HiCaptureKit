//
//  HiCapture.m
//  HiCapture
//
//  Created by Jett on 30/11/2017.
//  Copyright © 2017 mutating. All rights reserved.
//

#import "HiCapture.h"
#import "HiCaptureError.h"

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HiCapturePipelineStateNone          = 0,
    HiCapturePipelineStateConfiguration = 1,
    HiCapturePipelineStateRunning       = 2
} HiCapturePipelineState;

@interface HiCapture ()
<
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) HiCapturePipelineState pipelineState;

@end

@implementation HiCapture

- (instancetype)init {
    return [[HiCapture alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                     devicePosition:AVCaptureDevicePositionBack];
}

- (instancetype)initWithSessionPreset:(NSString *)sessionPreset
                       devicePosition:(AVCaptureDevicePosition)position {
    self = [super init];
    if (self) {
        
        // Communicate with the session and other session objects on this queue.
        _sessionQueue = dispatch_queue_create("com.mutating.capture.sesstion", DISPATCH_QUEUE_SERIAL);
        
        // Create the AVCaptureSession.
        _session = [[AVCaptureSession alloc] init];
        
        _position = position;
        _sessionPreset = sessionPreset;
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        
        self.pipelineState = HiCapturePipelineStateNone;
        
        _debugLogEnable = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)start {
    dispatch_async( _sessionQueue, ^{
        if (self.pipelineState < HiCapturePipelineStateConfiguration) {
            self.pipelineState = HiCapturePipelineStateConfiguration;
            if ([self configureSession]) {
                self.pipelineState = HiCapturePipelineStateRunning;
            }
        }
        
        if (!self->_running && self.pipelineState == HiCapturePipelineStateRunning ) {
            [self.session startRunning];
            self->_running = YES;
        }
    });
}

- (void)stop {
    dispatch_async( _sessionQueue, ^{
        if (self.pipelineState == HiCapturePipelineStateRunning ) {
            if (self->_running) {
                [self.session stopRunning];
                self->_running = NO;
            }
        }
    });
}

- (void)setPosition:(AVCaptureDevicePosition)position {
    dispatch_async( _sessionQueue, ^{
        if (self->_position != position) {
            self->_position = position;
            if (self.pipelineState == HiCapturePipelineStateRunning) {
                [self _setPosition:position forDeveice:self->_deviceInput.device];
            }
        }
    });
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    dispatch_async( _sessionQueue, ^{
        if (self->_flashMode != flashMode) {
            self->_flashMode = flashMode;
            if (self.pipelineState == HiCapturePipelineStateRunning) {
                [self _setFlashMode:flashMode forDevice:self->_deviceInput.device];
            }
        }
    });
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    dispatch_async( _sessionQueue, ^{
        if (self->_torchMode != torchMode) {
            self->_torchMode = torchMode;
            if (self.pipelineState == HiCapturePipelineStateRunning) {
                [self _setTorchMode:torchMode forDevice:self->_deviceInput.device];
            }
        }
    });
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    dispatch_async( _sessionQueue, ^{
        if (self->_focusMode != focusMode) {
            self->_focusMode = focusMode;
            if (self.pipelineState == HiCapturePipelineStateRunning) {
                [self _setFocusMode:focusMode forDevice:self->_deviceInput.device];
            }
        }
    });
}

- (void)setActiveVideoFrame:(NSInteger)activeVideoFrame {
    dispatch_async(_sessionQueue, ^{
        if (self->_activeVideoFrame != activeVideoFrame) {
            self->_activeVideoFrame = activeVideoFrame;
            if (self.pipelineState == HiCapturePipelineStateRunning) {
                [self _setActiveVideoFrame:self->_activeVideoFrame forDevice:self->_deviceInput.device];
            }
        }
    });
}

#pragma mark - Private

- (BOOL)configureSession {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionNotification:) name:nil object:_session];
    
    [ _session beginConfiguration];
    /*
     We do not create an AVCaptureMovieFileOutput when setting up the session because the
     AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
     */
    _session.sessionPreset =  _sessionPreset;
    [ _session commitConfiguration];
    
    if (![self addInput] || ![self addOutput]) {
        return NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureShouldOutputQRCodeMetadataObject)]) {
        if ([self.delegate captureShouldOutputQRCodeMetadataObject]) {
            if (![self addMetadataOutput]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addInput {
    // Add video input.
    AVCaptureDevice *device;
    // Choose the back dual camera if available, otherwise default to a wide angle camera.
    
    if (@available(iOS 10.2, *)) {
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:_position];
        
        if ( ! device ) {
            // If the back dual camera is not available, default to the back wide angle camera.
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:_position];
        }
    } else if (@available(iOS 10.0, *)) {
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDuoCamera mediaType:AVMediaTypeVideo position:_position];
        
        if ( ! device ) {
            // If the back dual camera is not available, default to the back wide angle camera.
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:_position];
        }
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *d in devices) {
            if (d.position == _position) {
                device = d;
                break;
            }
        }
    }
    
    return [self _addInputDevice:device];
}

- (BOOL)addOutput {
    AVCaptureVideoDataOutput *videoOutput = [AVCaptureVideoDataOutput new];
    /*
     On iOS, the only supported key is kCVPixelBufferPixelFormatTypeKey.
     Supported pixel formats are kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA.
     */
    [videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    
    AVCaptureConnection *videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoOrientationSupported]) {
        videoConnection.videoOrientation = _videoOrientation;
    }
    
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_session beginConfiguration];
    
    if ([_session canAddOutput:videoOutput]) {
        [_session addOutput:videoOutput];
    } else {
        [_session commitConfiguration];
        NSString *description = @"Could not add video data output to the session";
        NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
        return NO;
    }
    
    [_session commitConfiguration];
    
    return YES;
}

- (BOOL)addMetadataOutput {
    [_session beginConfiguration];
    
    // Must add output to session before config metadataoutput, otherwise, it doesn't work.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([_session canAddOutput:captureMetadataOutput]) {
        [_session addOutput:captureMetadataOutput];
    } else {
        [_session commitConfiguration];
        NSString *description = @"Could not add metadata output to the session";
        NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
        return NO;
    }
    
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    captureMetadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
    
    [_session commitConfiguration];
    
    return YES;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate capture:self didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects == nil || metadataObjects.count == 0) {
        return;
    }
    
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([AVMetadataObjectTypeQRCode isEqualToString:metadataObject.type]) {
        NSString *value = metadataObject.stringValue;
        if (self.debugLogEnable) NSLog(@"Capture scan result is: %@", value);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didOutputMetadataObject:fromConnection:)]) {
        [self.delegate capture:self didOutputMetadataObject:metadataObject fromConnection:connection];
    }
}

#pragma mark - Session Notification

- (void)sessionNotification:(NSNotification *)notification {
    dispatch_async( _sessionQueue, ^{
        if ( [notification.name isEqualToString:AVCaptureSessionWasInterruptedNotification] ) {
            if (self.debugLogEnable) NSLog(@"Capture session interrupted");
            // Cannot stop session.
        } else if ( [notification.name isEqualToString:AVCaptureSessionInterruptionEndedNotification] ) {
            if (self.debugLogEnable) NSLog(@"Capture session interruption ended");
        } else if ( [notification.name isEqualToString:AVCaptureSessionRuntimeErrorNotification] ) {
            NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
            NSInteger notAvailableInBackgroundCode;
            if (@available(iOS 9.0, *)) {
                notAvailableInBackgroundCode = AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableInBackground;
            } else {
                notAvailableInBackgroundCode = AVErrorDeviceIsNotAvailableInBackground;
            }
            if ( error.code == notAvailableInBackgroundCode ) {
                if (self.debugLogEnable) NSLog(@"Capture device not available in background" );
                // Since we can't resume running while in the background we need to remember this for next time we come to the foreground
                // TODO: resume session when enter foreground.
                [self handleRecoverableCaptureSessionRuntimeError:error after:0.3];
            } else if ( error.code == AVErrorMediaServicesWereReset ) {
                if (self.debugLogEnable) NSLog( @"Capture media services were reset" );
                [self handleRecoverableCaptureSessionRuntimeError:error];
            } else {
                [self handleNonRecoverableCaptureSessionRuntimeError:error];
            }
        } else if ( [notification.name isEqualToString:AVCaptureSessionDidStartRunningNotification] ) {
            if (self.debugLogEnable) NSLog( @"Capture session started running" );
        } else if ( [notification.name isEqualToString:AVCaptureSessionDidStopRunningNotification] ) {
            if (self.debugLogEnable) NSLog( @"Capture session stopped running" );
        }
    } );
}

#pragma mark - Handle Error

- (void)handleRecoverableCaptureSessionRuntimeError:(NSError *)error {
    if ( _running ) {
        [_session startRunning];
    }
}

- (void)handleRecoverableCaptureSessionRuntimeError:(NSError *)error after:(NSTimeInterval)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive && self->_running) {
            [self.session startRunning];
        }
    });
}

- (void)handleNonRecoverableCaptureSessionRuntimeError:(NSError *)error {
    if (self.debugLogEnable) NSLog(@"Capture session fatal runtime error %@, code %d", error, (int)error.code);
    [_session stopRunning];
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:interruptedWithError:)]) {
        [self.delegate capture:self interruptedWithError:error];
    }
}

#pragma mark - Utils

- (BOOL)_addInputDevice:(AVCaptureDevice *)device {
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ( ! deviceInput ) {
        NSString *description = [NSString stringWithFormat:@"Could not create video device input - %@", error];
        NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
        return NO;
    }
    
    [ _session beginConfiguration];
    
    if ( [ _session canAddInput:deviceInput] ) {
        [ _session addInput:deviceInput];
        _deviceInput = deviceInput;
    } else {
        [ _session commitConfiguration];
        NSString *description = @"Could not add video device input to the session";
        NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
        return NO;
    }
    
    [ _session commitConfiguration];
    
    return YES;
}

- (void)_setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            NSString *description = [NSString stringWithFormat:@"Could not lock device for configuration: %@", error];
            NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
            [self handleNonRecoverableCaptureSessionRuntimeError:error];
        }
    }
}

- (void)_setTorchMode:(AVCaptureTorchMode)torchMode forDevice:(AVCaptureDevice *)device {
    if ( device.hasTorch && [device isTorchModeSupported:torchMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            NSString *description = [NSString stringWithFormat:@"Could not lock device for configuration: %@", error];
            NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
            [self handleNonRecoverableCaptureSessionRuntimeError:error];
        }
    }
}

- (void)_setFocusMode:(AVCaptureFocusMode)focusMode forDevice:(AVCaptureDevice *)device {
    if ( [device isFocusModeSupported:focusMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.focusMode = focusMode;
            [device unlockForConfiguration];
        } else {
            NSString *description = [NSString stringWithFormat:@"Could not lock device for configuration: %@", error];
            NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
            [self handleNonRecoverableCaptureSessionRuntimeError:error];
        }
    }
}

- (void)_setPosition:(AVCaptureDevicePosition)position forDeveice:(AVCaptureDevice *)device {
    NSArray *availableCameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in availableCameraDevices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (position == device.position) {
                [_session removeInput:_deviceInput];
                _deviceInput = nil;
                [self _addInputDevice:device];
            }
        }
    }
}

- (void)_setActiveVideoFrame:(NSInteger)activeVideoFrame forDevice:(AVCaptureDevice *)device {
    NSError *error;
    CMTime frameDuration = CMTimeMake(1, (int32_t)activeVideoFrame);
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    } else {
        NSString *description = [NSString stringWithFormat:@"Could not lock device for configuration or not supported frame rate: %@", error];
        NSError *error = [HiCaptureError errorWithCode:HiCaptureErrorCodeSessionConfigurationFailed description:description];
        [self handleNonRecoverableCaptureSessionRuntimeError:error];
    }
}

@end


