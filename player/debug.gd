extends Node2D


@onready var player: CharacterBody2D = $".."
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@export var debug_speed_steps = 1

var debug_speed
var debug_mode


func _unhandled_input(_event):
	if !visible: return

	if Input.is_action_just_pressed("DebugMode"):
		debug_mode = player.toggle_debug()
		collision_shape.disabled = debug_mode

	set_debug_speed()


func set_debug_speed():
	if !debug_mode: return
	var speed_up_direction = sign(Input.get_axis("SpeedDownDebug", "SpeedUpDebug"))
	if speed_up_direction == 0: return

	debug_speed = player.debug_speed_modifier

	debug_speed = clampf(debug_speed, 3, 13)

	if speed_up_direction > 0:
		player.set_debug_speed_modifier(debug_speed + debug_speed_steps)
	else:
		player.set_debug_speed_modifier(debug_speed - debug_speed_steps)
