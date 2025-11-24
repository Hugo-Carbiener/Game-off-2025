shader_type canvas_item;

uniform sampler2D main_tex;
uniform sampler2D noise_tex;

uniform float time_scale = 60.0;
uniform float noise_scale : hint_range( 0.0,1.0 );
uniform float width_scale : hint_range( 1.0,10.0 );

vec2 wrap(vec2 uv) {
    return fract(uv); // keep only the fractional part
}

void fragment() {
	vec2 uv = UV - vec2(0.5);

	vec2 noise_uv = wrap(uv/noise_scale - vec2(TIME/time_scale, 0.0));
	vec2 shim = uv + vec2(
    	texture(noise_tex, noise_uv).x,
    	texture(noise_tex, wrap(uv - vec2(0.0, sin(TIME/time_scale)))).y
	);

	float dist = distance(UV, vec2(0.5));
    vec4 col = texture(main_tex, shim) * COLOR;
	col.a += dist * width_scale;
    COLOR = col;
}