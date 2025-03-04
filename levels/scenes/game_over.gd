extends Node


var state_node

var return_to_main_menu_level_state
var quit_game_level_state


func _ready():
	await %AnimationPlayer.animation_finished
	%ReturnToMainMenuButton.pressed.connect(change_to_return_to_main_menu_state)
	%QuitGameButton.pressed.connect(change_to_quit_game_level_state)


# Level States

func set_state_node(node):
	state_node = node


func set_return_to_main_menu_level_state(state):
	return_to_main_menu_level_state = state


func set_quit_game_level_state(state):
	quit_game_level_state = state


func change_to_return_to_main_menu_state():
	change_to_level_state(return_to_main_menu_level_state)


func change_to_quit_game_level_state():
	change_to_level_state(quit_game_level_state)


func exit_state_transition():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished


func change_to_level_state(level_state):
	await exit_state_transition()

	state_node.change_state(level_state)
