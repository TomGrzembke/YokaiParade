extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const ELEMENT_TYPE = ELEMENTS.ElementType.AIR

@export var double_jump_vel = 800.0
@export var double_jump_duration = 0.1
@export var disable_player_movement := false
@export var velocity_curve : Curve


func use(player_manager):
	var vel_modifier = VelocityModifier.new(Vector2(0, -double_jump_vel), \
	double_jump_duration, 1, disable_player_movement, true)

	vel_modifier.set_ability( $".")
	vel_modifier.set_curve(velocity_curve)
	player_manager.add_velocity_modifier(vel_modifier)

	controller_vibration(0.5, 1.0, .1)
	if get_parent() == null:
		call_deferred("exit")
		return

	create_timer(double_jump_duration).subscribe(exit)


func exit():
	queue_free()


func get_color():
	return ELEMENTS.get_color(ELEMENT_TYPE)


func controller_vibration(weak_strength, strong_strength, duration):
	if Input.get_connected_joypads().size() <= 0: return
	Input.start_joy_vibration(0, weak_strength, strong_strength, duration)


func create_timer(time):
	return TimerExtension.new(get_tree(), time)
