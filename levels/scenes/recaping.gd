extends Node


var play_time

var state_node
var next_level_state

var loading_level_state
var game_over_level_state
var return_to_main_menu_level_state
var reset_level_state
var quit_game_level_state


func _ready():
	await %AnimationPlayer.animation_finished

	if state_node != null:
		set_next_level_state()

	%NextLevelButton.pressed.connect(change_to_next_level_state)
	%ResetLevelButton.pressed.connect(change_to_reset_level_state)
	%ReturnToMainMenuButton.pressed.connect(change_to_return_to_main_menu_state)
	%QuitGameButton.pressed.connect(change_to_quit_game_level_state)

	%NextLevelButton.grab_focus()


func set_level_info(first_level_index, current_level_index, level_index_count):
	var current_level_number = current_level_index - first_level_index + 1
	var levels_above_first_count = level_index_count - first_level_index

	var current_level_text
	if current_level_index < first_level_index:
		current_level_text = "Tutorial Level"
	else:
		current_level_text = "Level %s of %s" % [current_level_number, levels_above_first_count]

	var info_text = "Completed %s!" % current_level_text
	%LevelInfoLabel.text = info_text


func set_play_time(p_play_time):
	play_time = p_play_time
	%PlayTimeLabel.text = "%5.2f" % play_time


# Level States

func set_next_level_state():
	var current_level_path_index = state_node.get_requested_level_path_index()
	state_node.request_setting_next_level_path_index()
	var next_level_path_index = state_node.get_requested_level_path_index()

	if current_level_path_index == next_level_path_index:
		next_level_state = game_over_level_state
	else:
		next_level_state = loading_level_state


func set_state_node(node):
	state_node = node


func set_loading_level_state(state):
	loading_level_state = state


func set_game_over_level_state(state):
	game_over_level_state = state


func set_return_to_main_menu_level_state(state):
	return_to_main_menu_level_state = state


func set_reset_level_state(state):
	reset_level_state = state


func set_quit_game_level_state(state):
	quit_game_level_state = state


func change_to_next_level_state():
	change_to_level_state(next_level_state)


func change_to_return_to_main_menu_state():
	change_to_level_state(return_to_main_menu_level_state)


func change_to_reset_level_state():
	state_node.request_setting_previous_level_path_index()
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
