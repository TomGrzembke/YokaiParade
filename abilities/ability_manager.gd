extends Node2D

var current_ability
var target_area

@onready var player: CharacterBody2D = $".."
@onready var visual: MeshInstance2D = $"../Visual"

const COLOR_PLAIN = Color("#949494")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("use_ability"):
		use_ability(player)

	if Input.is_action_just_pressed("catch_power"):
		catch_power()

func use_ability(player):
	if current_ability == null: return

	if current_ability.has_method("use"):
		current_ability.use(player)

	reset_color()
	current_ability = null


func catch_power():
	if target_area == null: return

	var target_parent = target_area.get_parent()
	if !target_parent.has_method("got_caught"): return

	var ability = target_parent.got_caught()
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


func _on_deal_damage_area_entered(other):
	if other.has_method("take_damage"):
		target_area = other


func _on_deal_damage_area_exited(other):
	if other == target_area:
		target_area = null
