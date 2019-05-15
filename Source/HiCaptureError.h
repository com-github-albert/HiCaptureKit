//
//  HiCaptureError.h
//  HiCaptureKit
//
//  Created by Jett on 2019/3/5.
//  Copyright © 2019 mutating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSErrorDomain const HiCaptureErrorDomain;

typedef enum : NSUInteger {
    HiCaptureErrorCodeSessionConfigurationFailed = 0,
    HiCaptureErrorCodeUnknown,
} HiCaptureErrorCode;

@interface HiCaptureError : NSObject

+ (NSError *)errorWithCode:(HiCaptureErrorCode)code;
+ (NSError *)errorWithCode:(HiCaptureErrorCode)code description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
