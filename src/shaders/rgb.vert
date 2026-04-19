#version 300 es
precision highp float;
layout(location = 0) in vec2 position;
layout(location = 1) in vec3 vertexColor;

out vec3 color;

uniform vec2 offset;

void main() {
	gl_Position = vec4(position.xy + offset, 0, 1);
	color = vertexColor;
}
