extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const ELEMENT_TYPE = ELEMENTS.ElementType.AIR

@export var double_jump_vel = 800.0
@export var double_jump_duration = 0.0
@export var disable_player_movement := false


func use(player_manager):
	var vel_modifier = VelocityModifier.new(Vector2(0, -double_jump_vel), double_jump_duration, 1, disable_player_movement)
	vel_modifier.set_ability( $".")
	player_manager.add_velocity_modifier(vel_modifier)


func exit_ability():
	pass


func get_color():
	return ELEMENTS.get_color(ELEMENT_TYPE)
