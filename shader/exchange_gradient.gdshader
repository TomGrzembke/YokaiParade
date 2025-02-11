shader_type canvas_item;

uniform float darkness_modifier : hint_range(-5, 10.0) = 1.;
uniform float white_feather_range : hint_range(0., .4) = .0;
uniform float black_feather_range : hint_range(0., .4) = .0;
uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;

float get_luminocity(vec4 color){
	float luminance =  0.5 * color.r + 0.3 * color.g + 0.2 * color.b * darkness_modifier;
	return clamp(luminance, .0 ,1.);
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
}
