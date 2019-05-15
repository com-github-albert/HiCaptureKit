//
//  HiCaptureKit.h
//  HiCaptureKit
//
//  Created by Jett on 2019/3/4.
//  Copyright © 2019 mutating. All rights reserved.
//

#ifndef HiCaptureKit_h
#define HiCaptureKit_h

#if __has_include(<HiCaptureKit/HiCaptureKit.h>)

#import <Foundation/Foundation.h>

//! Project version number for HiCaptureKit.
FOUNDATION_EXPORT double HiCaptureKitVersionNumber;

//! Project version string for HiCaptureKit.
FOUNDATION_EXPORT const unsigned char HiCaptureKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HiCaptureKit/PublicHeader.h>
#import <HiCaptureKit/HiCapture.h>
#import <HiCaptureKit/HiCaptureView.h>
#import <HiCaptureKit/HiCapturePreview.h>
#import <HiCaptureKit/HiCaptureAuthorization.h>
#else
#import "HiCapture.h"
#import "HiCaptureView.h"
#import "HiCapturePreview.h"
#import "HiCaptureAuthorization.h"
#endif

#endif /* HiCaptureKit_h */
