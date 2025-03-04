extends GameState


@export var main_menu_game_state: GameState
@export var quit_game_state: GameState


func get_window_fullscreen():
	return parent.get_window_fullscreen()


func set_window_fullscreen(active):
	parent.set_window_fullscreen(active)


func set_volume_audio_bus(bus_id, volume_db):
	parent.set_volume_audio_bus(bus_id, volume_db)


func get_volume_audio_bus(bus_id):
	return parent.get_volume_audio_bus(bus_id)


func play_game_music():
	parent.play_game_music()


# Game States

func enter(p_previous_state):
	super.enter(p_previous_state)

	state_scene.set_state_node(self)

	await parent.fade_out_audio(1.0)


func change_to_main_menu_game_state():
	change_state(main_menu_game_state)


func change_to_quit_game_state():
	change_state(quit_game_state)
