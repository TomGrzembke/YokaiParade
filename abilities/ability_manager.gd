extends Node2D

var current_ability
var area_taking_damage_in_radius

@onready var player: CharacterBody2D = $".."
@onready var visual: MeshInstance2D = $"../Visual"

const COLOR_PLAIN = Color("#949494")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability"):
		use_ability(player)

	if Input.is_action_just_pressed("catch_power") \
	and area_taking_damage_in_radius != null:
		if area_taking_damage_in_radius.has_method("get_parent"):
			var parent = area_taking_damage_in_radius.get_parent()
			if parent != null \
			and parent.has_method("got_caught"):
				var ability = parent.got_caught()
				set_current_ability(ability)


func use_ability(player_manager):
	if current_ability == null: return

	if current_ability.has_method("use"):
		current_ability.use(player_manager)

	reset_color()
	current_ability = null


func set_current_ability(ability_scene):
	if ability_scene == null: return

	var ability = ability_scene.instantiate()
	add_child(ability)
	current_ability = ability

	if ability != null \
	and ability.has_method("get_color"):
		visual.self_modulate = ability.get_color()


func reset_color():
	visual.self_modulate = COLOR_PLAIN


func get_current_ability():
	return current_ability


func _on_deal_damage_area_entered(other):
	if other.has_method("take_damage"):
		area_taking_damage_in_radius = other


func _on_deal_damage_area_exited(other):
	if other == area_taking_damage_in_radius:
		area_taking_damage_in_radius = null
