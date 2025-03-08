extends GameState


func set_window_fullscreen(active):
	parent.set_window_fullscreen(active)


func get_window_fullscreen():
	return parent.get_window_fullscreen()


func set_volume_audio_bus(bus_id, volume_db):
	parent.set_volume_audio_bus(bus_id, volume_db)


func get_volume_audio_bus(bus_id):
	return parent.get_volume_audio_bus(bus_id)


# Game States

func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.update_window_fullscreen(get_window_fullscreen())

	state_scene.update_volume_master(get_volume_audio_bus(0))
	state_scene.update_volume_music(get_volume_audio_bus(1))
	state_scene.update_volume_sfx(get_volume_audio_bus(2))
	state_scene.update_volume_ui(get_volume_audio_bus(3))

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func exit():
	super.exit()

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func change_to_previous_state():
	change_state(previous_state)
