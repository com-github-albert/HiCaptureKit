//
//  GLVideoTexture.h
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "GLTexture.h"

@interface GLVideoTexture : GLTexture

- (instancetype)initWithRotation:(NSUInteger)rotation;

- (void)updateTexture:(CVPixelBufferRef)pixelBuffer;
- (void)updateTexture:(void *)buffer width:(int)width height:(int)height;

@end
