//
//  GLCameraTexture.h
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "GLTexture.h"

@interface GLCameraTexture : GLTexture

- (void)update:(CVPixelBufferRef)pixelBuffer;
- (void)updateTexture:(void *)buffer width:(int)width height:(int)height;

@end
