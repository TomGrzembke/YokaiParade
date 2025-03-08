extends Node


var state_node


# Level States

func _ready():
	await %AnimationPlayer.animation_finished

	change_to_next_level_state()


func reset_music_volue(duration):
	await state_node.reset_music_volume(duration)


func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.queue("fading_outro_long")
	await %AnimationPlayer.animation_finished

	state_node.change_to_next_level_state()
