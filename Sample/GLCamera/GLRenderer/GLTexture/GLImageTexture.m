//
//  GLImageTexture.m
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "GLImageTexture.h"

@implementation GLImageTexture {
    UIImage *_image;
}

@synthesize
verticesID  = _verticesID,
fragmentsID = _fragmentsID,
textureUVID = _textureUVID,
textureID   = _textureID;

static const SceneVertex kVertices[] = {
    {{ 0.5, -0.5, 0}},
    {{-0.5, -0.5, 0}},
    {{ 0.5,  0.5, 0}},
    {{ 0.5,  0.5, 0}},
    {{-0.5, -0.5, 0}},
    {{-0.5,  0.5, 0}}
};

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
        self.effect.constantColor = GLKVector4Make(1, 1, 1, 1); // rgba
        self.effect.useConstantColor = GL_TRUE;
        [self genBuffer];
        [self bindTexture];
    }
    return self;
}

- (void)genBuffer {
    glGenBuffers(1, &_verticesID);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(kVertices), kVertices, GL_STATIC_DRAW);
}

- (void)bindTexture {
    CGImageRef imageRef = _image.CGImage;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.target = textureInfo.target;
}

- (void)draw {
    [self.effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
