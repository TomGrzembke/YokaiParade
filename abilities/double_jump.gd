extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const ELEMENT_TYPE = ELEMENTS.ElementType.AIR

@export var double_jump_vel = 800.0
@export var double_jump_duration = 0.0
@export var disable_player_movement := false
@export var velocity_curve : Curve


func use(player_manager):
	if Input.get_connected_joypads().size() > 0:
		Input.start_joy_vibration(0, 0.0, 1.0, 0.5)
	var vel_modifier = VelocityModifier.new(Vector2(0, -double_jump_vel), \
	double_jump_duration, 1, disable_player_movement, true)

	vel_modifier.set_ability( $".")
	vel_modifier.set_curve(velocity_curve)
	player_manager.add_velocity_modifier(vel_modifier)


func exit():
	queue_free()


func get_color():
	return ELEMENTS.get_color(ELEMENT_TYPE)
