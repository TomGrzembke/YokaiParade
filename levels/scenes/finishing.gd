extends Node


var state_node


# Level States

func _ready():
	await %AnimationPlayer.animation_finished

	change_to_next_level_state()


func set_state_node(node):
	state_node = node


func change_to_next_level_state():
	%AnimationPlayer.stop()
	%AnimationPlayer.queue("confetti")
	%AnimationPlayer.queue("fading_outro_long")
	await %AnimationPlayer.animation_finished

	state_node.change_to_next_level_state()
