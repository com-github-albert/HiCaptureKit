//
//  GLESUtils.h
//
//  Created by mjt on 16/4/27.
//  Copyright © 2016年 MaJT. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;

+(GLuint)loadProgramWithVertexShaderFilepath:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;

@end
