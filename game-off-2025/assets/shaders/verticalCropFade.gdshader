shader_type canvas_item;

uniform float fade_length: hint_range(0.0, 1.0);
uniform float fade_start: hint_range(0.0, 1.0);

void fragment() {
	vec2 centered_uv = UV - vec2(0, 0.5);
	float center_distance = abs(centered_uv.y);
	vec4 col = texture(TEXTURE, UV);
	col.a *= 1. - smoothstep(fade_start - fade_length, fade_start, center_distance);
    COLOR = col;
}