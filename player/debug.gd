extends Node2D


@onready var player: CharacterBody2D = $".."
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var movement_lines = $MovementLines

@export var debug_speed_steps = 1
@export_range(0.0, 1.0) var instant_token_percentage = 1.0

var debug_speed
var debug_mode


func _unhandled_input(event):
	if !visible: return

	if not OS.has_feature("debug"):
		return

	if event.is_action_pressed("debug_mode"):
		debug_mode = player.toggle_debug()
		collision_shape.disabled = debug_mode
		movement_lines.visible = true

	set_debug_speed()


func set_debug_speed():

	var speed_up_direction = sign(Input.get_axis("debug_mode_faster", "debug_mode_slower"))
	if speed_up_direction == 0: return

	debug_speed = clampf(player.debug_speed_modifier, 3, 13)

	var faster = speed_up_direction > 0

	if debug_mode: modify_debug_speed(faster)
	else: modify_tokens(faster)


func modify_debug_speed(faster):
	player.set_debug_speed_modifier(debug_speed + (debug_speed_steps if faster else -debug_speed_steps))

func modify_tokens(faster):
	player.add_current_speed_tokens(player.max_token_amount * instant_token_percentage if faster else -player.max_token_amount)
