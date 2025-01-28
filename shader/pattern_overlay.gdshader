shader_type canvas_item;

uniform sampler2D pattern_texture;
uniform float overlay_alpha : hint_range(0.0, 1.0); 
uniform vec2 pattern_scale = vec2(1.0, 1.0); 
uniform vec2 tilemap_offset = vec2(0.0, 0.0); 
varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 scaled_position = world_position * vec2(1.0 / 1920.0, 1.0 / 1080.0) * pattern_scale - tilemap_offset;
	
	vec2 pattern_uv = fract(scaled_position);

	vec4 pattern_color = texture(pattern_texture, pattern_uv);

	vec4 texture_color = texture(TEXTURE, UV);


	vec4 filtered_alpha = mix(texture_color, pattern_color, pattern_color.x);
	
	vec4 pattern = mix(texture_color, pattern_color, overlay_alpha * filtered_alpha.a);
	
	vec4 applied_texture = mix(texture_color, pattern, -pattern_color.a);
	
	vec4 limit = step(0.5, pattern);
	vec4 soft_light_result = mix(2.0 * texture_color * pattern + texture_color * texture_color * (1.0 - 2.0 * pattern), 
	sqrt(texture_color) * (2.0 * pattern - 1.0) + (2.0 * texture_color) * (1.0 - pattern), -limit.a);
	
	vec4 final_color = mix(texture_color, soft_light_result, overlay_alpha * pattern_color.a);
	//final_color = mix(texture_color, pattern, -pattern_color.a);
	
	COLOR = final_color;
}



