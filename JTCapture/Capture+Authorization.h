//
//  Capture+Authorization.h
//  JTCapture
//
//  Created by JT Ma on 30/11/2017.
//  Copyright © 2017 JT(ma.jiangtao.86@gmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Capture.h"

@interface Capture (Authorization)

- (void)authorizationObserver:(UIViewController *)target;

@end
