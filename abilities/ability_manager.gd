extends Node2D


const COLOR_PLAIN = Color("#949494")


var current_ability
var target_in_damage_radius

@onready var player: CharacterBody2D = $".."
@onready var visual: MeshInstance2D = $"../Visual"


func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability"):
		use_ability()

	if Input.is_action_just_pressed("catch_power"):
		catch_power()


func use_ability():
	if current_ability == null: return

	if current_ability.has_method("use"):
		current_ability.use(player)

	reset_color()
	current_ability = null


func catch_power():
	if target_in_damage_radius == null: return

	var target_parent = target_in_damage_radius.get_parent()
	if target_parent == null: return
	if not target_parent.has_method("got_caught"): return

	var ability = target_parent.got_caught(self)
	set_current_ability(ability)


func set_current_ability(ability_scene):
	if ability_scene == null: return

	var ability = ability_scene.instantiate()
	add_child(ability)
	current_ability = ability

	if ability.has_method("get_color"):
		visual.self_modulate = ability.get_color()


func clear_abilities():
	for child in get_children():
		child.queue_free()
	reset_color()


func reset_color():
	visual.self_modulate = COLOR_PLAIN


func get_current_ability():
	return current_ability


func on_deal_damage_area_entered(other):
	target_in_damage_radius = other


func on_deal_damage_area_exited(other):
	if other == target_in_damage_radius:
		target_in_damage_radius = null
