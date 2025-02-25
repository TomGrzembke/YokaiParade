extends Node2D


@onready var player: CharacterBody2D = $".."
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var movement_line: Line2D = $MovementLine
@export var debug_speed_steps = 1

var debug_speed
var debug_mode


func _unhandled_input(event):
	if !visible: return

	if not OS.has_feature("debug"):
		return

	if event.is_action_pressed("debug_mode"):
		debug_mode = player.toggle_debug()
		collision_shape.disabled = debug_mode
		movement_line.visible = true

	set_debug_speed()


func set_debug_speed():
	if !debug_mode: return
	var speed_up_direction = sign(Input.get_axis("debug_mode_faster", "debug_mode_slower"))
	if speed_up_direction == 0: return

	debug_speed = player.debug_speed_modifier

	debug_speed = clampf(debug_speed, 3, 13)

	if speed_up_direction > 0:
		player.set_debug_speed_modifier(debug_speed + debug_speed_steps)
	else:
		player.set_debug_speed_modifier(debug_speed - debug_speed_steps)
