extends LevelState


@export var loading_level_state: LevelState
@export var game_over_level_state: LevelState
@export var return_to_main_menu_level_state: LevelState
@export var reset_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_state_node(self)

	state_scene.set_loading_level_state(loading_level_state)
	state_scene.set_game_over_level_state(game_over_level_state)
	state_scene.set_return_to_main_menu_level_state(return_to_main_menu_level_state)
	state_scene.set_reset_level_state(reset_level_state)

	state_scene.set_play_time(parent.get_play_time())


func get_requested_level_path_index():
	return parent.get_requested_level_path_index()


func request_setting_next_level_path_index():
	parent.request_setting_next_level_path_index()
