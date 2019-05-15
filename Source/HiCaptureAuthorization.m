//
//  HiCaptureAuthorization.m
//  HiCapture
//
//  Created by Jett on 2018/11/23.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "HiCaptureAuthorization.h"
#import <AVFoundation/AVFoundation.h>

@implementation HiCaptureAuthorization

/*
 Check video authorization status. Video access is required and audio
 access is optional. If audio access is denied, audio is not recorded
 during movie recording.
 */
+ (void)request:(void (^)(BOOL granted))handler {
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] ) {
        case AVAuthorizationStatusAuthorized: {
            // The user has previously granted access to the camera.
            handler(YES);
            break;
        }
        case AVAuthorizationStatusNotDetermined: {
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:handler];
            break;
        }
        default: {
            // The user has previously denied access.
            handler(NO);
            break;
        }
    }
}

@end
