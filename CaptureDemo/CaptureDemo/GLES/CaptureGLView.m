//
//  CaptureGLView.m
//  CameraDemo
//
//  Created by JT Ma on 04/08/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

#import "CaptureGLView.h"
#import "GLESUtils.h"

@interface CaptureGLView ()

@property (nonatomic) EAGLContext* context;
@property (nonatomic) GLuint renderBuffer;
@property (nonatomic) GLuint frameBuffer;

@property (nonatomic) GLuint programHandle;
@property (nonatomic) GLuint positionSlot;
@property (nonatomic) GLuint luminanceSlot;
@property (nonatomic) GLuint textureSlot;

@property (nonatomic, assign) CVOpenGLESTextureRef luminanceTextureRef;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCacheRef;
@property (nonatomic, assign) GLuint luminanceTexture;

@end

@implementation CaptureGLView

- (void)initalize {
    [self setupLayer];
    [self setupContext];
    [self setupProgram];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initalize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initalize];
    }
    return self;
}

- (void)dealloc {
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    CFRelease(_textureCacheRef);
    CFRelease(_luminanceTextureRef);
    
    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);
    
    [self destoryBuffers];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
}


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO],
                                     kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8,
                                     kEAGLDrawablePropertyColorFormat,
                                     nil];
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCacheRef);
    if (err) {
        NSLog(@"CVOpenGLESTextureCacheCreate %d",err);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _renderBuffer);
}

- (void)destoryBuffers {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
}

- (void)setupProgram {
    
    // Load shaders
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"CaptureShader" ofType:@"vsh"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"CaptureShader" ofType:@"fsh"];
    _programHandle = [GLESUtils loadProgramWithVertexShaderFilepath:vertexShaderPath withFragmentShaderFilepath:fragmentShaderPath];
    if (!_programHandle) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get attribute slot and uniform matrix from program
    _positionSlot = glGetAttribLocation(_programHandle, "position");
    _textureSlot = glGetAttribLocation(_programHandle, "inputTextureCoordinate");
    _luminanceSlot = glGetUniformLocation(_programHandle, "luminanceTexture");
}

- (void)render:(CVPixelBufferRef)sampleBuffer {
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // Setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 设置当前上下文,每个线程当前上下文都没有设置,需要自己设置一次
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    
    // 清空之前纹理缓存,否则不会刷新最新纹理
    [self cleanUpTextures];
    
    [self drawTexture:sampleBuffer];
    
    [self convertYUVToRGBOutput];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawTexture:(CVPixelBufferRef)sampleBuffer {
    if (sampleBuffer == NULL) return;
    
    GLsizei bufferWidth = (GLsizei)CVPixelBufferGetWidth(sampleBuffer);
    GLsizei bufferHeight = (GLsizei)CVPixelBufferGetHeight(sampleBuffer);

    glActiveTexture(GL_TEXTURE0);
    
    CVReturn err;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _textureCacheRef,
                                                       sampleBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       bufferWidth,
                                                       bufferHeight,
                                                       GL_RGBA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_luminanceTextureRef);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    _luminanceTexture = CVOpenGLESTextureGetName(_luminanceTextureRef);
    
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

// YUA 转 RGB，里面的顶点和片段都要转换
- (void)convertYUVToRGBOutput {
    // 在创建纹理之前，有激活过纹理单元，就是那个数字.GL_TEXTURE0,GL_TEXTURE1
    // 指定着色器中亮度纹理对应哪一层纹理单元
    // 这样就会把亮度纹理，往着色器上贴
    glUniform1i(_luminanceSlot, 0);

    // 计算顶点数据结构
    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(self.bounds.size.width, self.bounds.size.height), self.layer.bounds);
    
    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
    
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
    } else {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
    }
    
    // 确定顶点数据结构
    GLfloat quadVertexData[] = {
        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
             normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
             normalizedSamplingSize.width, normalizedSamplingSize.height,
    };
    
    GLfloat quadTextureData[] =  { // 正常坐标
        1, 1,
        1, 0,
        0, 1,
        0, 0
    };
    
    // 激活ATTRIB_POSITION顶点数组
    glEnableVertexAttribArray(_positionSlot);
    // 给ATTRIB_POSITION顶点数组赋值
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, 0, 0, quadVertexData);
    
    // 激活ATTRIB_TEXCOORD顶点数组
    glVertexAttribPointer(_luminanceSlot, 2, GL_FLOAT, 0, 0, quadTextureData);
    // 给ATTRIB_TEXCOORD顶点数组赋值
    glEnableVertexAttribArray(_luminanceSlot);
    
    // 渲染纹理数据数据
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)cleanUpTextures {
    if (_luminanceTextureRef) {
        CFRelease(_luminanceTextureRef);
        _luminanceTextureRef = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_textureCacheRef, 0);
}

@end
