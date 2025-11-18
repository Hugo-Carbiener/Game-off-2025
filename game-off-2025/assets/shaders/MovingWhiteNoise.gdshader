shader_type canvas_item;
render_mode unshaded;

uniform float grid_scale = 1.0;
uniform vec4 base_color : source_color; 
uniform float opacity : hint_range( 0.0,2.0 );
uniform float movement_amplitude;
uniform float movement_speed;
uniform int pixelSize = 1;

vec2 random2D(vec2 uv){
	
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise2D(vec2 uv){
	uv *= grid_scale;
	vec2 gridIndex = floor(uv); 
	vec2 gridFract = fract(uv);
	
	vec2 blur = smoothstep(0.0, 1.0, gridFract);
	
	vec2 bl = gridIndex + vec2(0.0, 0.0);
	vec2 br = gridIndex + vec2(1.0, 0.0);
	vec2 tl = gridIndex + vec2(0.0, 1.0);
	vec2 tr = gridIndex + vec2(1.0, 1.0);
	
	vec2 gradBL = random2D(bl); 
	vec2 gradBR = random2D(br);
	vec2 gradTL = random2D(tl);
	vec2 gradTR = random2D(tr);
	
	vec2 distToPixelFromBL = gridFract - vec2(0.0, 0.0);
	vec2 distToPixelFromBR = gridFract - vec2(1.0, 0.0);
	vec2 distToPixelFromTL = gridFract - vec2(0.0, 1.0);
	vec2 distToPixelFromTR = gridFract - vec2(1.0, 1.0);
	
	float dotBL = dot(gradBL, distToPixelFromBL);
	float dotBR = dot(gradBR, distToPixelFromBR);
	float dotTL = dot(gradTL, distToPixelFromTL);
	float dotTR = dot(gradTR, distToPixelFromTR);
	
	return mix(mix(dotBL, dotBR, blur.x), mix(dotTL, dotTR, blur.x), blur.y) + 0.5;
}

vec2 randomMotion(float t) {
    return vec2(
        (sin(t * 0.7 * movement_speed) + sin(t * 1.3  * movement_speed + 2.1)) * movement_amplitude,
        (cos(t * 0.9 * movement_speed) + cos(t * 1.7  * movement_speed + 1.7)) * movement_amplitude
    ) * 0.25;
}

vec2 pixelize(vec2 uv, ivec2 texture_size) {	
	int xRes = texture_size.x;
	int yRes = texture_size.y;
	
	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);
	
	float grid_uv_x = round(uv.x * xFactor) / xFactor;
	float grid_uv_y = round(uv.y * yFactor) / yFactor;
	return vec2(grid_uv_x, grid_uv_y);
}

void fragment() {
	ivec2 size = textureSize(TEXTURE, 0);
	vec2 uv = UV + randomMotion(TIME);
	//uv = pixelize(uv, size);
	vec4 color = base_color;
	color.rgb += noise2D(uv) * opacity;
	COLOR = color;
}