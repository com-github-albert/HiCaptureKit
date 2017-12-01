precision mediump float;
varying highp vec2 textureCoordinate;
uniform sampler2D luminanceTexture;

void main(void) {
    vec4 color = texture2D(luminanceTexture, textureCoordinate);
    gl_FragColor = vec4(color.z, color.y, color.x, color.w);
}
