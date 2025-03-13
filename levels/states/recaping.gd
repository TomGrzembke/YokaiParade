extends LevelState


@export var loading_level_state: LevelState
@export var game_over_level_state: LevelState
@export var return_to_main_menu_level_state: LevelState
@export var reset_level_state: LevelState
@export var quit_game_level_state: LevelState

var current_level_index
var first_level_index
var level_count


func enter(p_previous_state):
	super.enter(p_previous_state)

	current_level_index = context.get_current_level_index()
	first_level_index = context.get_first_level_index()
	level_count = context.get_level_count()

	state_scene.set_loading_level_state(loading_level_state)
	state_scene.set_game_over_level_state(game_over_level_state)
	state_scene.set_return_to_main_menu_level_state(return_to_main_menu_level_state)
	state_scene.set_reset_level_state(reset_level_state)
	state_scene.set_quit_game_level_state(quit_game_level_state)

	state_scene.set_level_info(first_level_index, current_level_index, level_count)
	state_scene.set_play_time(context.get_play_time())

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func exit():
	super.exit()

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func get_requested_level_path_index():
	return context.get_requested_level_path_index()


func request_setting_next_level_path_index():
	context.request_setting_next_level_path_index()


func request_setting_previous_level_path_index():
	context.request_setting_previous_level_path_index()
