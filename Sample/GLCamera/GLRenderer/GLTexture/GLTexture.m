//
//  GLTexture.m
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "GLTexture.h"

@implementation GLTexture

- (instancetype)init {
    self = [super init];
    if (self) {
        _verticesID = 0;
        _textureID = 0;
        _textureUVID = 0;
        _fragmentsID = 0;
        _effect = [[GLKBaseEffect alloc] init];
        _debugLogEnable = NO;
    }
    return self;
}

- (void)dealloc {
    /*
     glDeleteBuffers or glDeleteTextures (GLsizei n, const GLuint* buffers);
     
     @param n Specifies the number of buffer objects to be deleted.
     @param buffers Specifies an array of buffer objects to be deleted.
     */
    if (_verticesID) {
        glDeleteBuffers(1, &_verticesID);
        _verticesID = 0;
    }
    if (_textureUVID) {
        glDeleteBuffers(1, &_textureUVID);
        _textureUVID = 0;
    }
    if (_fragmentsID) {
        glDeleteBuffers(1, &_fragmentsID);
        _fragmentsID = 0;
    }
    if (_textureID) {
        glDeleteTextures(1, &_textureID);
        _textureID = 0;
    }
    _effect = nil;
}

- (void)draw {}

- (void)setProjectionMatrix:(GLKMatrix4)projectionMatrix {
    /*!
     * Update projection matrix.
    GLKMatrix4 m4 = projectionMatrix;
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    float radians = 0;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            radians = M_PI * 3 / 2;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            radians = M_PI;
            break;
        case UIInterfaceOrientationLandscapeRight:
            radians = 0;
            break;
        default:
            break;
    }
    GLKMatrix4 rm = GLKMatrix4MakeZRotation(radians);
    m4 = GLKMatrix4Multiply(rm, m4);
     */
    _projectionMatrix = projectionMatrix;
    self.effect.transform.projectionMatrix = _projectionMatrix;
    
}

- (void)setModelviewMatrix:(GLKMatrix4)modelviewMatrix {
    _modelviewMatrix = modelviewMatrix;
    self.effect.transform.modelviewMatrix = modelviewMatrix;
}

@end
