shader_type canvas_item;

uniform float smoothing : hint_range(0.1, 10.0) = 2.0;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 water_color : source_color;
uniform sampler2D wave_noise : repeat_enable;

void fragment() {
	vec2 water_wave = (texture(wave_noise, SCREEN_UV + TIME).rg - 1.0) * 0.02 / smoothing;
	vec2 uv = vec2(SCREEN_UV.x, SCREEN_UV.y - UV.y) + water_wave;
	vec4 screen = texture(screen_texture, uv);
	float mix_value = 1.0 - UV.y;
	
	float average_color = (screen.r + screen.g + screen.b) / 3.0; 
	average_color = pow(average_color, 1.4); 
	mix_value += average_color; 
	
	mix_value = clamp(mix_value, 0.0, 0.9);
	
	COLOR = mix(water_color, screen, mix_value);
}
