//
//  HiCaptureAuthorization.h
//  HiCapture
//
//  Created by Jett on 2018/11/23.
//  Copyright © 2018 mutating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HiCaptureAuthorization : NSObject

/**
 Check video authorization status.

 @param handler
     A block to be called once permission is granted or denied.
     The block will return immediately in an asynchronous thread. If you setting UI that need to dispatch a main thread.
 
     granted
         If the user grants permission to use the Camera YES is returned; otherwise NO.
 */
+ (void)request:(void (^)(BOOL granted))handler;

@end

NS_ASSUME_NONNULL_END
