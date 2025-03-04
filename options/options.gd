extends Control


signal window_fullscreen_changed(active)
signal volume_audio_bus_changed(bus_id, volume_db)
signal back_button_pressed()

var is_dragging = false
var is_cooling_down = false


func _ready():
	%FullscreenCheckBox.toggled.connect(func (active): window_fullscreen_changed.emit(active))

	%VolumeMasterSlider.value_changed.connect(
		func (volume_linear): volume_audio_bus_changed.emit(0, volume_linear)
	)
	%VolumeMusicSlider.value_changed.connect(
		func (volume_linear): volume_audio_bus_changed.emit(1, volume_linear)
	)
	%VolumeSfxSlider.value_changed.connect(
		func (volume_linear): change_effects_volume(2, volume_linear, %SfxAudioStreamPlayer)
	)
	%VolumeUiSlider.value_changed.connect(
		func (volume_linear): change_effects_volume(3, volume_linear, %UiAudioStreamPlayer)
	)

	%VolumeSfxSlider.drag_started.connect(drag_sfx_sound)
	%VolumeSfxSlider.drag_ended.connect(stop_sound_loop)

	%VolumeUiSlider.drag_started.connect(drag_ui_sound)
	%VolumeUiSlider.drag_ended.connect(stop_sound_loop)

	%BackButton.pressed.connect(func (): back_button_pressed.emit())
	%BackButton.grab_focus()


func update_window_fullscreen_checkbox(active):
	%FullscreenCheckBox.set_pressed_no_signal(active)


func update_volume_master_slider(volume_linear):
	%VolumeMasterSlider.set_value_no_signal(volume_linear)


func update_volume_music_slider(volume_linear):
	%VolumeMusicSlider.set_value_no_signal(volume_linear)


func update_volume_sfx_slider(volume_linear):
	%VolumeSfxSlider.set_value_no_signal(volume_linear)


func update_volume_ui_slider(volume_linear):
	%VolumeUiSlider.set_value_no_signal(volume_linear)


func change_effects_volume(bus_id, volume_linear, audio_player):
	volume_audio_bus_changed.emit(bus_id, volume_linear)

	if not is_dragging \
	and not is_cooling_down:
		audio_player.play()
		is_cooling_down = true

	get_tree().create_timer(0.125).timeout.connect(end_cooling_down)


func end_cooling_down():
	is_cooling_down = false


func drag_sfx_sound():
	is_dragging = true
	%AnimationPlayer.play("loop_sfx_sound")


func drag_ui_sound():
	is_dragging = true
	%AnimationPlayer.play("loop_ui_sound")


func stop_sound_loop(_changed):
	is_dragging = false
	%AnimationPlayer.stop()
