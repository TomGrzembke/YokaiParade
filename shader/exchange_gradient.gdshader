shader_type canvas_item;

uniform float darkness_modifier : hint_range(-5, 10.0) = 1.;
uniform float white_feather_range : hint_range(0., .4) = .0;
uniform float black_feather_range : hint_range(0., .4) = .0;
uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;

uniform sampler2D pattern_texture;
uniform sampler2D empty_texture;
uniform float overlay_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float pattern_scale = 1.0;
uniform vec2 tilemap_offset = vec2(0.0, 0.0);
uniform bool flip_alpha = true;
uniform bool use_hard_blend = false;
uniform bool use_local = true;
uniform float world_scale = 1.0;
uniform float pattern_multiplier = 1.0;
uniform vec4 end_tint : source_color = vec4(0,0,0,1);
const vec4 BLACK_COLOR = vec4(0,0,0,1);
varying vec2 world_position;
varying vec2 local_position;

float get_luminocity(vec4 color){
	float luminance =  0.5 * color.r + 0.3 * color.g + 0.2 * color.b * darkness_modifier;
	return clamp(luminance, .0 ,1.);
}

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


vec4 hard_blend_result(vec4 texture_color, vec4 pattern, vec4 final_color){
	mix(texture_color, pattern, texture_color.a * overlay_alpha);
	float brightness = get_luminocity(final_color);
    float flipped_brightness = 1.0 - brightness;

    vec4 flipped_color = vec4(vec3(flipped_brightness), texture_color.a);

	final_color = flip_alpha ? flipped_color : final_color;
	return final_color;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX , 0.0, world_scale)).xy;
	local_position = (inverse(MODEL_MATRIX) * vec4(world_position, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);

	float brightness = get_luminocity(texture_color);
    float flipped_brightness = 1.0 - brightness;

    vec4 flipped_color = vec4(vec3(flipped_brightness), texture_color.a);


	vec4 first_color = mix(texture_color, color_a, smoothstep(.0 , .1, texture_color.r));
	vec4 second_color = mix(flipped_color, color_b, smoothstep(1. , .5, texture_color.r));

	vec4 final_mix = mix(first_color, second_color, 1.- brightness);

	final_mix.a = texture_color.a;
	COLOR = final_mix;


	if (distance(texture_color.rgb, vec3(1.0)) < white_feather_range)
    	COLOR = texture_color;

	if (distance(texture_color.rgb, vec3(0.0)) < black_feather_range)
    	COLOR = texture_color;


	texture_color = final_mix;
	vec2 position_type = use_local ? local_position : world_position;
	vec2 scaled_position = position_type * vec2(1.0 / 1920.0, 1.0 / 1080.0) * vec2(pattern_scale) - tilemap_offset;

	vec2 pattern_uv = fract(scaled_position);

	vec4 pattern_color = texture(pattern_texture, pattern_uv) ;

	float filtered_alpha = mix(texture_color, pattern_color, pattern_color.x).a;

	vec4 pattern = mix(texture_color, pattern_color, filtered_alpha);

	vec4 soft_light_blend_result = soft_light_blend(texture_color, pattern * pattern_multiplier, overlay_alpha);

	float alpha = -soft_light_blend_result.r * 2.0 * overlay_alpha * pattern_color.a;
	alpha = flip_alpha ? -alpha : alpha;

	vec4 final_color = mix(texture_color, soft_light_blend_result, alpha);

	if (use_hard_blend)
		final_color = hard_blend_result(texture_color, soft_light_blend_result, final_color);

	if (end_tint != BLACK_COLOR){
		float brightness = get_luminocity(final_color);
		float flipped_brightness = 1.0 - brightness;
		brightness = flip_alpha ? flipped_brightness : brightness;
		final_color = overlay(vec4(vec3(brightness), texture_color.a), end_tint);
	}
 
	COLOR = final_color;
}
