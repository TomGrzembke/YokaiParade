extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const COLOR_BLACK = Color(0,0,0,1)
@export_category("VFX Color")
@export var time_till_blend : float = 1.3
@export var time_to_blend : float = .2
@export var default_vfx_col : Color

@export_category("Idle")
@export var idle_animation_probability : Dictionary = {"idling" : 75, "idling4": 7, "idling2": 15, "idling3": 3}
@onready var player: CharacterBody2D = $".."
@onready var abilities: Node2D = $"../Abilities"
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vfx_animation_character = $VfxAnimationCharacter
var shader_mat
var color_blend_timer
var color_stay_timer
var state_machine


func _ready():
	shader_mat = vfx_animation_character.material as ShaderMaterial
	state_machine = animation_tree.get("parameters/playback")
	abilities.player_hits.connect(func(): state_machine.start("hit"))
	abilities.used_ability.connect(on_ability)

	player.player_despawned.connect(func(): state_machine.start("dying"))
	player.player_gets_pushed.connect(func(): state_machine.start("got_hit"))

	sort_dictionary_descending()


func _physics_process(_delta):
	if shader_mat.get_shader_parameter("end_tint") == COLOR_BLACK: return
	if color_stay_timer == null || color_stay_timer.time_left > 0: return

	shader_mat.set_shader_parameter("end_tint", lerp(shader_mat.get_shader_parameter("end_tint"), default_vfx_col, 1.0 - color_blend_timer.time_left / time_to_blend))


func on_ability(current_ability):
	shader_mat.set_shader_parameter("end_tint", ELEMENTS.COLOR_MAP[current_ability.ELEMENT_TYPE])

	if current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.FIRE:
		state_machine.start("dash")
	elif current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.AIR:
		state_machine.start("jump")

	color_stay_timer = create_timer(time_till_blend)
	color_stay_timer.timeout.connect(blend_vfx_back)


func blend_vfx_back():
	color_blend_timer = create_timer(time_to_blend)
	color_blend_timer.timeout.connect(func(): if color_blend_timer.time_left <= 0: \
	shader_mat.set_shader_parameter("end_tint", COLOR_BLACK))


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


func create_timer(time):
	return get_tree().create_timer(time)
