extends LevelState


@export var return_to_main_menu_level_state: LevelState
@export var quit_game_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_return_to_main_menu_level_state(return_to_main_menu_level_state)
	state_scene.set_quit_game_level_state(quit_game_level_state)
