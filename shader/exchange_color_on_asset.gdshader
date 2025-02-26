shader_type canvas_item;

uniform vec4 color_to_replace : source_color;
uniform vec4 wanted_color : source_color;
uniform float feather_range : hint_range(0., 1.) = .5;

void fragment() {
	 vec4 current_color = texture(TEXTURE, UV);

    if (distance(current_color.rgb, color_to_replace.rgb) < feather_range) {
        current_color = wanted_color;
    }

    COLOR = current_color;
}
