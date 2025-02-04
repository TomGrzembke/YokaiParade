shader_type canvas_item;

uniform sampler2D pattern_texture;
uniform float overlay_alpha : hint_range(0.0, 1.0); 
uniform float tint_amount : hint_range(0.0, 1.0); 
uniform vec2 pattern_scale = vec2(1.0, 1.0); 
uniform vec2 tilemap_offset = vec2(0.0, 0.0); 
varying vec2 world_position;
uniform bool flip_alpha = true;

vec4 soft_light_blend(vec4 base, vec4 blend, float alpha){
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
	sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), 
	alpha);
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec4 color_dodge(vec4 base, vec4 blend){
	return base / 1.0 + blend;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 scaled_position = world_position * vec2(1.0 / 1920.0, 1.0 / 1080.0) * pattern_scale - tilemap_offset;
	
	vec2 pattern_uv = fract(scaled_position);

	vec4 pattern_color = texture(pattern_texture, pattern_uv);

	vec4 texture_color = texture(TEXTURE, UV);


	float filtered_alpha = mix(texture_color, pattern_color, pattern_color.x).a;
	
	vec4 pattern = mix(texture_color, pattern_color, filtered_alpha);
	
	vec4 soft_light_blend = soft_light_blend(texture_color, pattern, overlay_alpha);
	
	float alpha = -soft_light_blend.r * 2.0 * overlay_alpha * pattern_color.a;
	alpha = flip_alpha ? -alpha : alpha;
	
	vec4 final_color = mix(texture_color, soft_light_blend, alpha);
	
	COLOR = final_color;
}
