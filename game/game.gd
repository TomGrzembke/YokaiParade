extends Node


const MASTER_BUS_ID = 0
const MUSIC_BUS_ID = 1
const SFX_BUS_ID = 2
const UI_BUS_ID = 3
const MUTE_VOLUME = -80.0


@export var initial_game_state: GameState
@export var title_music_stream: AudioStream
@export var game_music_stream: AudioStream
@export var game_over_music_stream: AudioStream

var current_game_state_scene
var stored_ui_volume


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	%GameStateMachine.init(self, initial_game_state)


# Music

func get_is_music_playing():
	return %MusicPlayer.playing


func play_title_music():
	play_music(title_music_stream)


func play_game_music():
	play_music(game_music_stream)


func fade_to_game_over_music():
	play_music(game_over_music_stream)


func play_music(stream):
	if stream == %MusicPlayer.stream:
		return

	await fade_out_audio(1.0)

	%MusicPlayer.stream = stream
	%MusicPlayer.play()


func fade_out_audio(duration):
	if not %MusicPlayer.playing:
		return

	var current_volume_master = get_volume_audio_bus(MASTER_BUS_ID)

	var set_volume_audio_bus_master = func(volume_db):
		set_volume_audio_bus(MASTER_BUS_ID, volume_db)

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(set_volume_audio_bus_master, current_volume_master, MUTE_VOLUME, duration)

	await tween.finished

	%MusicPlayer.stop()

	# Workaround for AudioStreamPlayer.stop() not stopping immediately and not being awaitable,
	# which leads to sound pops from turning up the volume again without a delay
	OS.delay_msec(50)

	set_volume_audio_bus_master.call(current_volume_master)


# Options

func set_window_fullscreen(active):
	if active:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED


func get_window_fullscreen():
	return get_window().mode == Window.MODE_FULLSCREEN


func set_volume_audio_bus(bus_id, volume_db):
	AudioServer.set_bus_volume_db(bus_id, volume_db)


func get_volume_audio_bus(bus_id):
	return AudioServer.get_bus_volume_db(bus_id)


# State Machine

func _physics_process(delta):
	%GameStateMachine.physics_process(delta)


func _process(delta):
	%GameStateMachine.process(delta)


func _unhandled_input(event):
	%GameStateMachine.unhandled_input(event)


func _input(event):
	%GameStateMachine.input(event)


# Game States

func load_game_state_scene(game_state_scene):
	current_game_state_scene = game_state_scene
	add_child(current_game_state_scene)


func unload_game_state_scene(game_state_scene):
	var scene_to_be_removed
	for child in get_children():
		if child == game_state_scene:
			scene_to_be_removed = game_state_scene
	if scene_to_be_removed != null:
		remove_child(scene_to_be_removed)


func change_to_game_state(game_state):
	%GameStateMachine.change_state(game_state)
