shader_type canvas_item;

uniform sampler2D existing_screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D pattern_texture;
uniform float overlay_alpha : hint_range(0.0, 1.0);
uniform float color_multiplier : hint_range(1.0, 40.0);
uniform vec2 pattern_scale = vec2(1.0, 1.0);
uniform vec2 tilemap_offset = vec2(0.0, 0.0);
varying vec2 world_position;
varying vec2 local_position;
uniform bool flip_alpha = true;

vec4 soft_light_blend(vec4 base, vec4 blend){
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend),
	sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend),
	1);
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec4 color_dodge(vec4 base, vec4 blend){
	return base / 1.0 + blend;
}

vec4 overlay_screen_pattern(vec4 screen_color){
	vec2 scaled_position = (local_position - tilemap_offset) * pattern_scale ;

	vec2 pattern_uv = fract(scaled_position);

	vec4 pattern_color = texture(pattern_texture, pattern_uv);

	vec4 pattern = mix(screen_color, pattern_color, pattern_color.a);

	vec4 soft_light_blend = soft_light_blend(screen_color, pattern);

	float alpha = -soft_light_blend.r * color_multiplier * pattern_color.a;
	alpha = flip_alpha ? -alpha : alpha;

	vec4 result = mix(screen_color, soft_light_blend, alpha * overlay_alpha);

	return result;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	local_position = (inverse(MODEL_MATRIX) * vec4(world_position, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 screen_color = texture(existing_screen_texture, SCREEN_UV, 0.0);

	vec4 screen_pattern_overlay = overlay_screen_pattern(screen_color);
	
	COLOR = screen_pattern_overlay;
}
