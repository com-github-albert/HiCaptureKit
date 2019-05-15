//
//  GLTexture.h
//  GLRenderer
//
//  Created by JT Ma on 11/06/2018.
//  Copyright © 2018 mutating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;

typedef struct {
    GLKVector2 positionCoords;
} UVVertex;

typedef struct {
    GLKVector4 colorCoords;
} ColorBuffer;

@interface GLTexture : NSObject

@property (nonatomic) GLuint verticesID;
@property (nonatomic) GLuint fragmentsID;
@property (nonatomic) GLuint textureUVID;
@property (nonatomic) GLuint textureID;

@property (nonatomic) GLKBaseEffect *effect;

@property (nonatomic) GLKMatrix4 modelviewMatrix, projectionMatrix;

@property (nonatomic) BOOL debugLogEnable;

- (void)draw;

@end
