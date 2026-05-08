#version 300 es
precision highp float;

in vec4 position;
out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy/vec2(1920, 1080);

    fragColor = vec4(uv.xy, 0.0, 1.0);
}
