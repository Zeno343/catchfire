#version 300 es
precision highp float;

in vec4 position;
out vec4 fragColor;

uniform ivec2 u_resolution;

void main() {
    vec2 uv = gl_FragCoord.xy/float(u_resolution);

    fragColor = vec4(uv.xy, 0.0, 1.0);
}
