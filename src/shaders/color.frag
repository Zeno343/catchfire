#version 300 es
precision highp float;

in vec4 position;
out vec4 fragColor;

uniform vec3 rgb;

void main() {
    fragColor = vec4(rgb, 1.0);
}
