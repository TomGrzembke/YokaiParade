shader_type canvas_item;

uniform sampler2D pattern_texture;
uniform float overlay_alpha : hint_range(0.0, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0);
uniform vec2 pattern_scale = vec2(1.0, 1.0);
uniform vec2 tilemap_offset = vec2(0.0, 0.0);
varying vec2 world_position;

//Outline
uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int outline_shape : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false
varying vec2 original_uv;

vec4 soft_light_blend(vec4 base, vec4 blend, float alpha){
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend),
	sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend),
	alpha);
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec4 overwrite(vec4 destination, vec4 addable){
	return (addable.a > 0.0) ? addable : destination;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (outline_shape == 0) {
			offset = width - abs(x);
		} else if (outline_shape == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (outline_shape == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	original_uv = UV;

		if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;

		vec2 centered_uv = UV - 0.5;
		vec2 scaled_uv = centered_uv * 1.155;
		scaled_uv += 0.5;
		original_uv = scaled_uv;
	}
}

void fragment() {
	vec2 scaled_position = world_position * vec2(1.0 / 1920.0, 1.0 / 1080.0) * pattern_scale - tilemap_offset;

	vec2 pattern_uv = fract(scaled_position);

	vec4 pattern_color = texture(pattern_texture, pattern_uv);

	vec4 texture_color = texture(TEXTURE, original_uv); //original_uv causes a clipping problem rn

	float filtered_alpha = mix(texture_color, pattern_color, pattern_color.x).a;

	vec4 pattern = mix(texture_color, pattern_color, filtered_alpha);

	vec4 soft_light_blend = soft_light_blend(texture_color,pattern,-pattern.a);

	vec4 final_color = mix(texture_color, soft_light_blend, overlay_alpha * pattern_color.a);

	vec4 pattern_result = mix(final_color, soft_light_blend, tint_amount);


	vec2 uv = UV;
	vec4 outline_result;

	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			outline_result.a = 0.0;
		} else {
			outline_result = texture(TEXTURE, uv);
		}
	} else {
		outline_result = texture(TEXTURE, uv);
	}

	if ((outline_result.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		outline_result.rgb = inside ? mix(outline_result.rgb, color.rgb, color.a) : color.rgb;
		outline_result.a += (1.0 - outline_result.a) * color.a;
	}

	vec4 wanted_pattern = mix(outline_result, pattern_color, outline_result.a); //Should use pattern_result instead of pattern_color when bug is fixed
	COLOR = mix(outline_result, wanted_pattern, wanted_pattern.a);
	//COLOR = texture_color;
}