#version 300 es
precision highp float;

in vec4 position;
out vec4 fragColor;

uniform float uTime;

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) -
          smoothstep( pct, pct+0.02, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy/vec2(600, 480);
    vec3 color = vec3(st, 0.0) * (sin(uTime * 0.001) + 1.0);

    fragColor = vec4(color, 1.0);
}
