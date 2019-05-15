//
//  HiCaptureError.m
//  HiCaptureKit
//
//  Created by Jett on 2019/3/5.
//  Copyright © 2019 mutating. All rights reserved.
//

#import "HiCaptureError.h"

NSErrorDomain const HiCaptureErrorDomain = @"HiCaptureErrorDomain";

@implementation HiCaptureError

+ (NSString *)errorDescriptionWithCode:(HiCaptureErrorCode)code {
    switch (code) {
        case HiCaptureErrorCodeSessionConfigurationFailed:
            return @"Capture Configuration Error.";
        default:
            return @"Capture Unknown Error.";
    }
}

+ (NSError *)errorWithCode:(HiCaptureErrorCode)code {
    NSString *description = [HiCaptureError errorDescriptionWithCode:code];
    return [HiCaptureError errorWithCode:code description:description];
}

+ (NSError *)errorWithCode:(HiCaptureErrorCode)code description:(NSString *)description {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description
                                                         forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:HiCaptureErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

@end
