extends Node


var state_node


# Level States

func set_state_node(node):
	state_node = node


func _ready():
		await %AnimationPlayer.animation_finished

		state_node.change_to_next_level_state()
