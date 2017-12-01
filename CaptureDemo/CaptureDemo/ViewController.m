//
//  ViewController.m
//  CameraDemo
//
//  Created by JT Ma on 27/07/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

#import "ViewController.h"
#import <JTCapture/JTCapture.h>
#import "CaptureGLView.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) Capture *capture;
@property (weak, nonatomic) IBOutlet CapturePreview *capturePreview;
@property (weak, nonatomic) IBOutlet UIImageView *photoPreview;

@property (weak, nonatomic) IBOutlet CaptureGLView *glView;

@end

@implementation ViewController {
    dispatch_queue_t _captureQueue;
    UIInterfaceOrientation _screenshotOrientation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.cameraPreset = AVCaptureSessionPreset1280x720;
    [self initCamera];
//    [self.glView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.capture authorizationObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.capture stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwinSegue:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Camera Settings

- (void)initCamera {
    if (!self.capture) {
        _captureQueue = dispatch_queue_create("com.hiscene.jt.captureSesstionQueue", DISPATCH_QUEUE_SERIAL);
        self.capture = [[Capture alloc] initWithSessionPreset:self.cameraPreset
                                               devicePosition:AVCaptureDevicePositionBack
                                                 sessionQueue:_captureQueue];
        
        self.capturePreview.session = self.capture.session;
        
        dispatch_async( _captureQueue, ^{
            CaptureVideoDataOutput *captureVideoDataOutput = [[CaptureVideoDataOutput alloc] initWithSession:self.capture.session];
            [captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                /*
                 Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                 handled by -[AVCamCameraViewController viewWillTransitionToSize:withTransitionCoordinator:].
                 */
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                self.capturePreview.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
            });
        });
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        self.capturePreview.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (self.glView) [self.glView render:pixelBuffer];
    
    if (_screenshotOrientation) {
        CGImageRef cgimage = [self imageFromPixelBufferRef:pixelBuffer];
        UIImageOrientation imageOrientation;
        switch (_screenshotOrientation) {
            case UIInterfaceOrientationPortrait:
                imageOrientation = UIImageOrientationRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationDown;
                break;
            case UIInterfaceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationUp;
                break;
            default:
                imageOrientation = UIImageOrientationRight;
                break;
        }
        
        UIImage *image = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:imageOrientation];
        CGImageRelease(cgimage);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoPreview.image = image;
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        });
        _screenshotOrientation = UIInterfaceOrientationUnknown;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
}

// Create a CGImageRef from sample buffer data
- (CGImageRef) imageFromPixelBufferRef:(CVPixelBufferRef)pixelBuffer {
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

#pragma mark - Take Photo

- (IBAction)takePhoto:(UIButton *)sender {
    _screenshotOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

#pragma mark - Change Preset

- (IBAction)changePreset:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Preset"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action352x288 = [UIAlertAction actionWithTitle:@"352x288" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self configCameraPreset:AVCaptureSessionPreset352x288];
    }];
    UIAlertAction *action640x480 = [UIAlertAction actionWithTitle:@"640x480" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self configCameraPreset:AVCaptureSessionPreset640x480];
    }];
    UIAlertAction *action1280x720 = [UIAlertAction actionWithTitle:@"1280x720" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self configCameraPreset:AVCaptureSessionPreset1280x720];
    }];
    UIAlertAction *action1920x1080 = [UIAlertAction actionWithTitle:@"1920x1080" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self configCameraPreset:AVCaptureSessionPreset1920x1080];
    }];
    
    [alert addAction:action352x288];
    [alert addAction:action640x480];
    [alert addAction:action1280x720];
    [alert addAction:action1920x1080];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)configCameraPreset:(NSString *)preset {
    if ([self.capture.session canSetSessionPreset:preset]) {
        self.capture.session.sessionPreset = preset;
    }
}

@end
