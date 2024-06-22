#version 460
out vec4 color;
uniform vec2 resolution = vec2(960, 544);

void main() {
	vec2 uv = gl_FragCoord.xy / resolution;
	color = vec4(uv, 0, 1);
}
