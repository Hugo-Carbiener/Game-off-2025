shader_type canvas_item;

uniform sampler2D main_tex;
uniform sampler2D noise_tex;

uniform float time_scale = 60.0;
uniform vec2 center_offset;
uniform float noise_scale : hint_range(0.0, 1.0);
uniform float width_scale : hint_range(0.0, 10.0);
uniform float rotation_coef : hint_range(0.0, 1.0) = 1.0;

vec2 wrap(vec2 uv) {
    return fract(uv); // keep only the fractional part
}

mat2 rotate2d(float _angle){
	mat2 mat;
    return mat2(vec2(cos(_angle),-sin(_angle)),
                vec2(sin(_angle),cos(_angle)));
}

void fragment() {
	vec2 real_center = vec2(0.5) - center_offset;
	vec2 uv = UV - real_center;
	uv = uv * rotate2d(TIME / time_scale * rotation_coef);
	vec2 shim = uv + vec2(
    	texture(noise_tex, wrap(uv/noise_scale - vec2(TIME/time_scale, 0.0))).x,
    	texture(noise_tex, wrap(uv/noise_scale - vec2(0.0, TIME/time_scale))).y
	);

	float dist = distance(UV, real_center);
    vec4 col = texture(main_tex, shim) * COLOR;
	col.a += dist * width_scale;
    COLOR = col;
}