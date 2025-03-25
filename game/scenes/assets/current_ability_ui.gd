extends Control

const ELEMENTS = preload("res://elements/elements.gd")

@export var blend_time : float = .5
@export var blend_curve : Curve
@export var air_frame : TextureRect
@export var fire_frame : TextureRect

var blend_timer
var current_blendout

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
	if  blend_timer == null || !blend_timer.has_time_left: return

	fadeout_rect(air_frame)
	fadeout_rect(fire_frame)


func activate_rect(rect):
	if current_blendout != null:
		current_blendout.modulate = get_white_set_alpha(0)

	rect.modulate = get_white_set_alpha(1)
	current_blendout = rect

	if blend_timer == null: return
	blend_timer.set_time_left(0.0)


func fadeout_rect(rect):
	var current_value = 0.0
	var time_percentage =  blend_timer.get_progress_percent()
	var current_color = 1.0 if rect == current_blendout else rect.modulate.a
	var step = time_percentage if blend_curve == null else blend_curve.sample(time_percentage)

	current_value = lerpf(current_color, 0.0, step)

	rect.modulate = get_white_set_alpha(current_value)


func get_white_set_alpha(alpha):
	alpha = clamp(alpha, 0.0, 1.0)
	return Color(1, 1, 1, alpha)


func create_timer(time):
	return TimerExtension.new(get_tree(), time)
