shader_type canvas_item;

//uniform sampler2D pattern_texture;
uniform float mix_amount : hint_range(0.0, 1.0); 
uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = smoothstep(.0, 1., base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * blend, limit);
}

void fragment() {
	
	vec4 texture_color = texture(TEXTURE, UV);
	
	float brightness = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));  // Luminosity method for RGB to grayscale

    float flipped_brightness = 1.0 - brightness;

    vec4 flipped_color = vec4(vec3(flipped_brightness), texture_color.a);
	
	
	vec4 first_color = mix(texture_color, color_a, smoothstep(.5 , 1., texture_color.r * texture_color.a));
	
	vec4 second_color = mix(flipped_color, color_b, smoothstep(1. , .5, texture_color.r * texture_color.a));
	
	vec4 final_mix = mix(first_color, second_color, .5);
	
	final_mix *= 2.;
	final_mix.a = texture_color.a;
	COLOR = final_mix;
}
