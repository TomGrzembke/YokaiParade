extends Node2D

const ELEMENTS = preload("res://elements/elements.gd")
const COLOR_BLACK = Color(0,0,0,1)
@export_category("VFX Color")
@export var time_to_blend : float = 1.0
@export var blend_curve : Curve
@export var default_vfx_col : Color
@export var vfx_instance : PackedScene
@export_category("Shrug")
@export var shrug_cooldown : float = .8
@export_category("Idle")
@export var idle_animation_probability : Dictionary = {"idling" : 75, "idling4": 7, "idling2": 15, "idling3": 3}
@onready var player: CharacterBody2D = $".."
@onready var abilities: Node2D = $"../Abilities"
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vfx_animation_character = $VfxAnimationCharacter
var shader_mat
var color_blend_timer
var state_machine
var shrug_timer


func _ready():
	shader_mat = vfx_animation_character.material as ShaderMaterial
	state_machine = animation_tree.get("parameters/playback")

	subscribe_events()
	sort_dictionary_descending()


func subscribe_events():
	abilities.player_hits.connect(func(): state_machine.start("hit"))
	abilities.used_ability.connect(on_ability)
	abilities.ability_changed.connect(on_pickup)

	player.player_reached_goal.connect(func(): state_machine.start("celebration"))
	player.player_gets_pushed.connect(func(): state_machine.start("got_hit"))
	player.on_death_zone.connect(player_death)
	player.player_despawned.connect(default_vfx)
	player.on_reload.connect(default_vfx)
	player.on_jump.connect(func(): spawn_vfx("jump", true, false))


func _exit_tree():
	abilities.used_ability.disconnect(on_ability)
	abilities.ability_changed.disconnect(on_pickup)

	player.on_death_zone.disconnect(player_death)
	player.player_despawned.disconnect(default_vfx)
	player.on_reload.disconnect(default_vfx)


func _physics_process(_delta):
	if shader_mat.get_shader_parameter("end_tint") == COLOR_BLACK: return
	if color_blend_timer == null || color_blend_timer.time_left <= 0: return

	var step = blend_curve.sample(1.0 - color_blend_timer.time_left / time_to_blend)
	shader_mat.set_shader_parameter("end_tint", lerp(shader_mat.get_shader_parameter("end_tint"), default_vfx_col, step))


func on_ability(current_ability):
	if current_ability == null:
		if shrug_timer == null || shrug_timer.time_left == 0:
			state_machine.start("no_ability_hit")
			shrug_timer = create_timer(shrug_cooldown)
		return

	if current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.FIRE:
		state_machine.start("dash")
	elif current_ability.ELEMENT_TYPE == ELEMENTS.ElementType.AIR:
		state_machine.start("double_jump")
		spawn_vfx("air_jump", true, true)


func spawn_vfx(anim_name, emit_in_global, freeze_physics):
	var vfx = vfx_instance.instantiate()
	call_deferred("add_child", vfx)

	if vfx.has_method("play"): vfx.play(anim_name, emit_in_global, freeze_physics)


func land():
	spawn_vfx("land", true, false)


func player_death():
	spawn_vfx("dying", true, true)
	state_machine.start("dying")


func on_pickup(color):
	if color == abilities.COLOR_PLAIN:
		blend_vfx_back()
		return

	shader_mat.set_shader_parameter("end_tint", color)
	spawn_vfx("absorb", false, true)

	if color_blend_timer != null:
		color_blend_timer.timeout.disconnect(reset_vfx_conditionally)
		color_blend_timer = null


func blend_vfx_back():
	color_blend_timer = create_timer(time_to_blend)
	if color_blend_timer == null: return
	color_blend_timer.timeout.connect(reset_vfx_conditionally)


func reset_vfx_conditionally():
	if color_blend_timer != null && color_blend_timer.time_left > 0: return
	default_vfx()


func default_vfx():
	shader_mat.set_shader_parameter("end_tint", COLOR_BLACK)


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
