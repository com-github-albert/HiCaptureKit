//
//  GLPanelTexture.m
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import "GLPanelTexture.h"

@implementation GLPanelTexture

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

static ColorBuffer kColorBuffer[24];

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        CGFloat r, g, b, a;
        BOOL success = [color getRed:&r green:&g blue:&b alpha:&a];
        if (success) {
            self.effect.constantColor = GLKVector4Make(r, g, b, a); // rgba
            for (int i = 0; i < 6; i++) {
                kColorBuffer[i].colorCoords.r = r;
                kColorBuffer[i].colorCoords.g = g;
                kColorBuffer[i].colorCoords.b = b;
                kColorBuffer[i].colorCoords.a = a;
            }
        } else {
            return nil;
        }
        self.effect.useConstantColor = YES;
        [self genBuffer];
    }
    return self;
}

- (void)genBuffer {
    glGenBuffers(1, &_verticesID);
    glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(kVertices), kVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_fragmentsID);
    glBindBuffer(GL_ARRAY_BUFFER, _fragmentsID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(kColorBuffer), kColorBuffer, GL_STATIC_DRAW);
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
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glBindBuffer(GL_ARRAY_BUFFER, _fragmentsID);
    glVertexAttribPointer(GLKVertexAttribColor,
                          4,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          (void*)0);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
