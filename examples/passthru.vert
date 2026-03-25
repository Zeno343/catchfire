#version 300 es
precision highp float;

layout(location = 0) in vec2 position;

out vec4 color;

void main() {
	gl_Position = vec4(position.xy, 0, 1);
	color = vec4(0.0);
}
