#version 300 es
precision highp float;
layout(location = 0) in vec2 position;
layout(location = 1) in vec3 vertexColor;

out vec3 color;

void main() {
	gl_Position = vec4(position.xy, 0, 1);
	color = vertexColor;
}
