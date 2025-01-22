extends Node2D

@export var dash_velocity = 300.0
@export var dash_duration = 1.0
@export var dash_curve : Curve

var body_in_damage_radius

func use(player_manager):
	var vel_modifier = VelocityModifier.new(Vector2(dash_velocity, 0), dash_duration, 1, true)
	player_manager.add_velocity_modifier(vel_modifier)


func exit_ability():
	pass


func apply_dash_damage():
	if body_in_damage_radius == null: return
	if !body_in_damage_radius.has_method("take_damage"): return
	
	body_in_damage_radius.take_damage()


#func _on_deal_damage_area_body_entered(body):
	#body_in_damage_radius = body
#
#
#func _on_deal_dash_damage_area_body_exited(_body):
	#body_in_damage_radius = null
