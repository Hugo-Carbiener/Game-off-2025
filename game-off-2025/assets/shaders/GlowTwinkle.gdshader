shader_type canvas_item;

uniform vec4 glow_color = vec4(1.0, 0.85, 0.3, 1.0);
uniform float glow_radius = 0.45;
uniform float glow_strength = 1.5;
uniform float pulse_speed = 2.0;
uniform float twinkle_density = 25.0;
uniform float twinkle_speed = 1.0;
uniform float twinkle_opacity : hint_range(0.0, 1.0) = 1.0;

float hash(vec2 p) {
    return fract(sin(dot(p ,vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;     // center coordinates
    float dist = length(uv);

    // --- Glow ---
    float glow = smoothstep(glow_radius, 0.0, dist);
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    glow *= pulse * glow_strength;

    // --- Twinkles ---
    vec2 grid = floor(UV * twinkle_density);
    vec2 cell_uv = fract(UV * twinkle_density);
    float rnd = hash(grid);

    float twinkle = 0.0;
    if (rnd > 0.75) {
        float flicker = abs(sin(TIME * twinkle_speed + rnd * 6.28));
        float sparkle = smoothstep(0.2, 0.0, length(cell_uv - 0.5));
        twinkle = sparkle * flicker * 1.5 * twinkle_opacity;
    }

    vec4 aura = glow_color * (glow + twinkle);
    aura.a *= glow + twinkle;

    COLOR = aura;
}