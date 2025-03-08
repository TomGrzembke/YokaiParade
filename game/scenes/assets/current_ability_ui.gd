extends Control

const ELEMENTS = preload("res://elements/elements.gd")

@export var blend_time : float = .5
@export var blend_curve : Curve
@export var air_frame : TextureRect
@export var fire_frame : TextureRect

var blend_timer

func change_with_color(color):
	if is_color_element(color, ELEMENTS.ElementType.AIR):
		activate_rect(air_frame)

	elif is_color_element(color, ELEMENTS.ElementType.FIRE):
		activate_rect(fire_frame)

	else:
		blend_timer = create_timer(blend_time)


func is_color_element(color, element):
	return  color == ELEMENTS.COLOR_MAP[element]


func _physics_process(_delta):
	if  blend_timer == null || blend_timer.time_left <= 0: return

	fadeout_rect(air_frame)
	fadeout_rect(fire_frame)


func activate_rect(rect):
	rect.modulate = get_white_set_alpha(1)

	if blend_timer == null: return
	blend_timer.time_left = 0.0


func fadeout_rect(rect):
	var current_value
	var time_percentage =  1.0 - blend_timer.time_left / blend_time
	if blend_curve == null:
		current_value = lerpf(rect.modulate.a, 0.0, time_percentage)
	else:
		current_value = lerpf(rect.modulate.a, 0.0, blend_curve.sample(time_percentage))

	rect.modulate = get_white_set_alpha(current_value)


func get_white_set_alpha(alpha):
	alpha = clamp(alpha, 0.0, 1.0)
	return Color(1, 1, 1, alpha)


func create_timer(time):
	return get_tree().create_timer(time)
