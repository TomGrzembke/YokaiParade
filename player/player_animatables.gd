extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
@export var idle_animation_probability : Dictionary = {"idling" : 75, "idling4": 7, "idling2": 15, "idling3": 3}
@onready var player: CharacterBody2D = $".."
@onready var abilities: Node2D = $"../Abilities"
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var state_machine


func _ready():
	state_machine = animation_tree.get("parameters/playback")
	abilities.player_hits.connect(func(): state_machine.start("hit"))
	abilities.used_ability.connect(on_ability)

	player.player_despawned.connect(func(): state_machine.start("dying"))
	player.player_gets_pushed.connect(func(): state_machine.start("got_hit"))

	sort_dictionary_descending()


func on_ability(current_ability):
	if current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.FIRE:
		state_machine.start("dash")
	elif current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.AIR:
		state_machine.start("jump")


func _on_animation_finished(anim_name):
	different_idles(anim_name)


func different_idles(anim_name):
	if !anim_name in idle_animation_probability: return
	if anim_name == "idling3": return

	var random_value = randf_range(0, get_total_idle_percentage())

	for key in idle_animation_probability:
		if random_value >= idle_animation_probability[key]: continue

		state_machine.start(key)
		return

	var last_key = idle_animation_probability.keys()[idle_animation_probability.size() - 1]
	state_machine.start(last_key)


func get_total_idle_percentage():
	var total_percentage = 0

	for value in idle_animation_probability.values():
		total_percentage += value

	return total_percentage


func sort_dictionary_descending():
	var sorted_items = idle_animation_probability.keys()
	sorted_items.sort_custom(func(a, b): return idle_animation_probability[a] < idle_animation_probability[b])

	var sorted_dict = {}
	for key in sorted_items:
		sorted_dict[key] = idle_animation_probability[key]

	idle_animation_probability = sorted_dict
