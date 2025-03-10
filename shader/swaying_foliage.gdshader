shader_type canvas_item;

uniform bool ankered_top = false;
uniform float heightOffset : hint_range(0.0, 1.0);
uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0) = 0.05;
uniform float maxStrength : hint_range(0.0, 1.0) = 1.0;
uniform float strengthScale = 100.0;
uniform float interval = 2.0;
uniform float detail = 1.0;

//different Id will equal different wind seed
uniform float wind_id = 0; 


float get_wind(vec2 vertex, vec2 uv, float time){
    float diff = pow(maxStrength - minStrength, 2.0);
    float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength) * strengthScale;
    float anker_pos = ankered_top ? uv.y : 1.0 - uv.y;
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, anker_pos - heightOffset);
    
    return wind; 
}

void vertex() {
    float time = TIME * speed + wind_id;
    VERTEX.x += get_wind(VERTEX.xy, UV, time);
}