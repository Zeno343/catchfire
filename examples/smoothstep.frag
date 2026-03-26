#version 300 es
precision highp float;

in vec4 position;
out vec4 fragColor;

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float sCurve(vec2 st, float pct) {
  return  smoothstep( pct - 0.02, pct, st.y) -
          smoothstep( pct, pct + 0.02, st.y);
}

float line(vec2 st) {    
    return smoothstep(0.02, 0.0, abs(st.y - st.x));
}

void main() {
    vec2 st = gl_FragCoord.xy / vec2(600, 480);
    vec3 color = vec3(smoothstep(0.1, 0.9, st.x));

    float pct = line(st);
    color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);

    fragColor = vec4(color,1.0);
}
