extends Node2D


const ELEMENTS = preload("res://elements/elements.gd")
const ELEMENT_TYPE = ELEMENTS.ElementType.FIRE


@export var dash_velocity = 300.0
@export var dash_duration = 1.0
@export var damage_linger_duration : float = .4
@export var disable_player_movement := true
@export var velocity_curve : Curve

var is_dashing := false
var target_in_damage_radius


func _physics_process(_delta):
	if is_dashing:
		apply_dash_damage()


func use(player_manager):
	var vel_modifier = VelocityModifier.new(Vector2(dash_velocity, 0), dash_duration, 1, \
	disable_player_movement, true)

	vel_modifier.set_ability($".")
	vel_modifier.set_curve(velocity_curve)
	player_manager.add_velocity_modifier(vel_modifier)
	is_dashing = true

	controller_vibration(0.3, 1.0, dash_duration)
	if get_parent() == null:
		call_deferred("exit")
		return

	create_timer(dash_duration).subscribe(exit)


func exit():
	if damage_linger_duration == 0.0:
		queue_free()

	create_timer(damage_linger_duration).subscribe(queue_free)


func apply_dash_damage():
	if target_in_damage_radius == null: return

	var damage_subject = target_in_damage_radius.get_damage_subject()

	if damage_subject == null: return
	if not damage_subject.has_method("took_fire_damage"): return

	damage_subject.took_fire_damage(self)


func get_color():
	return ELEMENTS.get_color(ELEMENT_TYPE)


func on_deal_damage_area_entered(target):
	target_in_damage_radius = target


func on_deal_damage_area_exited(_target):
	target_in_damage_radius = null


func create_timer(time):
	return TimerExtension.new(get_tree(), time)


func controller_vibration(weak_strength, strong_strength, duration):
	if Input.get_connected_joypads().size() <= 0: return
	Input.start_joy_vibration(0, weak_strength, strong_strength, duration)
