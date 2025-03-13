shader_type canvas_item;

uniform vec4 color_to_replace : source_color;
uniform sampler2D pattern_texture;
uniform float feather_range : hint_range(0., 1.) = .5;
uniform vec2 tilemap_offset = vec2(0.0, 0.0);
uniform float pattern_scale = 1.0;
varying vec2 world_position;

vec4 exchange_texture_areas(vec4 current_color, vec4 pattern_color) {
	if (distance(current_color.rgb, color_to_replace.rgb) < feather_range)
        current_color = pattern_color;
    
	return current_color;
}

vec4 calc_pattern_color(sampler2D sample) {
	vec2 scaled_position = world_position * vec2(1.0 / 1920.0, 1.0 / 1080.0) * vec2(pattern_scale) - tilemap_offset;
	vec2 pattern_uv = fract(scaled_position);
	vec4 pattern_color = texture(sample, pattern_uv);
	return pattern_color;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX , 0.0, 1.0)).xy;
}

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	vec4 pattern_color = calc_pattern_color(pattern_texture);
	
    vec4 exchanged_color = exchange_texture_areas(current_color, pattern_color);

    COLOR = exchanged_color;
}
