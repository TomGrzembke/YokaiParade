extends Node


var state_node


func on_window_fullscreen_changed(active):
	state_node.set_window_fullscreen(active)


func on_volume_audio_bus_changed(bus_id, volume_linear):
	state_node.set_volume_audio_bus(bus_id, linear_to_db(volume_linear))


func on_back_button_pressed():
	change_to_previous_state()


func update_window_fullscreen(active):
	%Options.update_window_fullscreen_checkbox(active)


func update_volume_master(volume_db):
	%Options.update_volume_master_slider(db_to_linear(volume_db))


func update_volume_music(volume_db):
	%Options.update_volume_music_slider(db_to_linear(volume_db))


func update_volume_sfx(volume_db):
	%Options.update_volume_sfx_slider(db_to_linear(volume_db))


func update_volume_ui(volume_db):
	%Options.update_volume_ui_slider(db_to_linear(volume_db))


# Level States

func set_state_node(node):
	state_node = node


func change_to_previous_state():
	%AnimationPlayer.stop()
	%AnimationPlayer.play("state_transitions_long/hide_state_scene")
	await %AnimationPlayer.animation_finished
	state_node.change_to_previous_level_state()
