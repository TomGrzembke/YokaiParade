extends LevelState


@export var next_level_state: LevelState


func enter(p_previous_state):
	super.enter(p_previous_state)
	state_scene.set_state_node(self)

	parent.level_load_progress.connect(func(progress): state_scene.update_progress(progress))

	parent.set_game_paused(true)


func exit():
	super.exit()
	parent.set_game_paused(false)


func unhandled_input(event):
	if not OS.has_feature("debug"):
		return

	if event.is_action_pressed("load_previous_level"):
		parent.request_setting_previous_level_path_index()
		return self

	if event.is_action_pressed("load_next_level"):
		parent.request_setting_next_level_path_index()
		return self


func change_to_next_level_state():
	change_state(next_level_state)


func load_level():
	var succeeded = await parent.try_changing_to_requested_level()

	if succeeded == true:
		await parent.spawn_player()
		state_scene.update_progress(1.0)
	else:
		printerr("Error: Loading of level failed!")
