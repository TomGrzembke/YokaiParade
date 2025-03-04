extends Node


var state_node

var playing_level_state
var options_in_game_level_state
var return_to_main_menu_level_state
var reset_to_checkpoint_level_state
var reset_level_state
var quit_game_level_state


func _ready():
	%ResumeButton.pressed.connect(change_to_playing_level_state)
	%OptionsButton.pressed.connect(change_to_options_in_game_level_state)
	%ReturnToMainMenuButton.pressed.connect(change_to_return_to_main_menu_state)
	%ResetCheckpointButton.pressed.connect(change_to_reset_to_checkpoint_level_state)
	%ResetLevelButton.pressed.connect(change_to_reset_level_state)
	%QuitGameButton.pressed.connect(change_to_quit_game_level_state)

	%ResumeButton.grab_focus()


# Level States

func set_state_node(node):
	state_node = node


func set_playing_level_state(state):
	playing_level_state = state


func set_options_in_game_level_state(state):
	options_in_game_level_state = state


func set_return_to_main_menu_level_state(state):
	return_to_main_menu_level_state = state


func set_reset_to_checkpoint_level_state(state):
	reset_to_checkpoint_level_state = state


func set_reset_level_state(state):
	reset_level_state = state


func set_quit_game_level_state(state):
	quit_game_level_state = state


func change_to_playing_level_state():
	change_to_level_state(playing_level_state)


func change_to_options_in_game_level_state():
	change_to_level_state(options_in_game_level_state)


func change_to_return_to_main_menu_state():
	change_to_level_state(return_to_main_menu_level_state)


func change_to_reset_to_checkpoint_level_state():
	change_to_level_state(reset_to_checkpoint_level_state)


func change_to_reset_level_state():
	change_to_level_state(reset_level_state)


func change_to_quit_game_level_state():
	change_to_level_state(quit_game_level_state)


func exit_state_transition():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished


func change_to_level_state(level_state):
	await exit_state_transition()

	state_node.change_state(level_state)
