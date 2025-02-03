extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const ELEMENT_TYPE = ELEMENTS.ElementType.FIRE

@export var dash_velocity = 300.0
@export var dash_duration = 1.0
@export var dash_curve : Curve
@export var disable_player_movement := true

var is_dashing := false
var body_in_damage_radius


func _physics_process(_delta):
	if is_dashing:
		apply_dash_damage()


func use(player_manager):
	if Input.get_connected_joypads().size() > 0:
		Input.start_joy_vibration(0, 1.0, 0.0, dash_duration)
	var vel_modifier = VelocityModifier.new(Vector2(dash_velocity, 0), dash_duration, 1, \
	disable_player_movement, true)

	vel_modifier.set_ability( $".")
	player_manager.add_velocity_modifier(vel_modifier)
	is_dashing = true


func exit_ability():
	pass


func apply_dash_damage():
	if body_in_damage_radius == null: return
	if !body_in_damage_radius.has_method("take_damage"): return

	body_in_damage_radius.take_damage(body_in_damage_radius)


func get_color():
	return ELEMENTS.get_color(ELEMENT_TYPE)


func on_deal_damage_area_entered(target):
	body_in_damage_radius = target


func on_deal_damage_area_exited(_target):
	body_in_damage_radius = null
