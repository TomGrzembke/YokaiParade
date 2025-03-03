extends LevelState


@export var loading_level_state: LevelState
@export var paused_level_state: LevelState
@export var reset_to_checkpoint_level_state: LevelState
@export var reset_level_state: LevelState
@export var despawning_level_state: LevelState
@export var finishing_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_state_node(self)

	parent.player_despawned.connect(func(): change_state(despawning_level_state))
	parent.player_reached_goal.connect(func(): change_state(finishing_level_state))

	parent.set_player_controls_active(true)
	parent.set_game_paused(false)


func process(delta):
	var play_time = parent.get_play_time()
	parent.set_play_time(play_time + delta)


func unhandled_input(event):
	if event.is_action_pressed("pause_game"):
		return paused_level_state

	if event.is_action_pressed("reset_to_checkpoint"):
		return reset_to_checkpoint_level_state

	if event.is_action_pressed("reset_level"):
		return reset_level_state

	if not OS.has_feature("debug"):
		return

	if event.is_action_pressed("load_previous_level"):
		parent.request_setting_previous_level_path_index()
		return loading_level_state

	if event.is_action_pressed("load_next_level"):
		parent.request_setting_next_level_path_index()
		return loading_level_state
