extends Node


@export var music_volume_fraction: float:
	set(fraction):
		state_node.set_music_volume_fraction(fraction)

var state_node


# Level States

func _ready():
	# Workaround for audio bug in Godot that occurs in web builds on Chromium-based
	# browsers when AudiosStreamPlayer is started from AnimationPlayer
	%AudioStreamPlayer.play()
	await %AnimationPlayer.animation_finished
	await %AudioStreamPlayer.finished

	change_to_next_level_state()


func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.queue("fading_outro_long")
	await %AnimationPlayer.animation_finished

	state_node.change_to_next_level_state()
