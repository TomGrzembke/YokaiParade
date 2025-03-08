extends LevelState


@export var playing_level_state: LevelState
@export var return_to_main_menu_level_state: LevelState
@export var options_in_game_level_state: LevelState
@export var reset_to_checkpoint_level_state: LevelState
@export var reset_level_state: LevelState
@export var quit_game_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	parent.set_game_paused(true)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	state_scene.set_playing_level_state(playing_level_state)
	state_scene.set_options_in_game_level_state(options_in_game_level_state)
	state_scene.set_return_to_main_menu_level_state(return_to_main_menu_level_state)
	state_scene.set_reset_to_checkpoint_level_state(reset_to_checkpoint_level_state)
	state_scene.set_reset_level_state(reset_level_state)
	state_scene.set_quit_game_level_state(quit_game_level_state)


func unhandled_input(event):
	if event.is_action_pressed("pause_game"):
		state_scene.change_to_level_state(previous_state)


func exit():
	super.exit()

	parent.set_game_paused(false)

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
