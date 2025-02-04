extends Node2D

@onready var player: CharacterBody2D = $".."
@onready var collision_shapE: CollisionShape2D = $"../CollisionShape2D"

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("DebugMode"):
		var debug_mode = player.toggle_debug()
		collision_shapE.disabled = debug_mode
