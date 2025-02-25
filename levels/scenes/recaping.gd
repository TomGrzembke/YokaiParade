extends Node


var play_time

var state_node

var loading_level_state
var return_to_main_menu_level_state
var reset_level_state


# Level States

func _ready():
	await %AnimationPlayer.animation_finished
	%NextLevelButton.pressed.connect(change_to_loading_level_state)
	%ResetLevelButton.pressed.connect(change_to_reset_level_state)
	%ReturnToMainMenuButton.pressed.connect(change_to_return_to_main_menu_state)
	%QuitGameButton.pressed.connect(quit_game)


func set_play_time(p_play_time):
	play_time = p_play_time
	%PlayTimeLabel.text = "%5.2f" % play_time


# Level States

func set_state_node(node):
	state_node = node


func set_loading_level_state(state):
	loading_level_state = state


func set_return_to_main_menu_level_state(state):
	return_to_main_menu_level_state = state


func set_reset_level_state(state):
	reset_level_state = state


func change_to_loading_level_state():
	state_node.request_setting_next_level_path_index()
	change_to_level_state(loading_level_state)


func change_to_return_to_main_menu_state():
	change_to_level_state(return_to_main_menu_level_state)


func change_to_reset_level_state():
	change_to_level_state(reset_level_state)


func exit_state_transition():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished


func change_to_level_state(level_state):
	await exit_state_transition()

	state_node.change_state(level_state)


func quit_game():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("game_quit_transitions/blackout")
	await %AnimationPlayer.animation_finished

	get_tree().quit()
