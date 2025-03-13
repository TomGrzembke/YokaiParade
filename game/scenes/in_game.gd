extends Node


signal player_despawned
signal player_reached_goal
signal level_load_progress(progress)


@export_category("Level States")
@export var initial_level_state: LevelState

@export_category("Debug Mode")
@export var is_debug_mode_active = false


var play_time
var state_node
var current_level_state_scene


func _ready():
	%Levels.player_ability_changed.connect(on_player_ability_changed)
	%Levels.player_despawned.connect(on_player_despawned)
	%Levels.player_reached_goal.connect(on_player_reached_goal)
	%Levels.level_load_progress.connect(on_level_load_progress)

	if OS.has_feature("debug"):
		%Levels.set_is_debug_level_active(is_debug_mode_active)

	reset_play_time()
	request_setting_next_level_path_index()
	%LevelStateMachine.init(self, initial_level_state)


func set_window_fullscreen(active):
	state_node.set_window_fullscreen(active)


func get_window_fullscreen():
	return state_node.get_window_fullscreen()


func set_volume_audio_bus(bus_id, volume_db):
	state_node.set_volume_audio_bus(bus_id, volume_db)


func get_volume_audio_bus(bus_id):
	return state_node.get_volume_audio_bus(bus_id)


func play_game_music():
	state_node.play_game_music()


func fade_to_game_over_music():
	state_node.fade_to_game_over_music()


func get_music_volume():
	return get_volume_audio_bus(1)


func set_music_volume(volume_db):
	set_volume_audio_bus(1, volume_db)


func set_game_paused(should_pause):
	get_tree().paused = should_pause


func reset_play_time():
	set_play_time(0.0)


func get_play_time():
	return play_time


func get_is_past_first_checkpoint():
	return %Levels.get_is_past_first_checkpoint()


func set_player_controls_active(active):
	%Levels.set_player_controls_active(active)


# UI

func set_play_time(new_time):
	play_time = new_time
	%PlayTimeLabel.text = "%5.2f" % play_time


# Signal Handlers

func on_player_ability_changed(color):
	%CurrentAbility.change_with_color(color)


func on_player_despawned():
	player_despawned.emit()


func on_player_reached_goal():
	player_reached_goal.emit()


func on_level_load_progress(progress):
	level_load_progress.emit(progress)


# Level Loading

func get_level_count():
	return %Levels.get_level_path_count()


func  get_first_level_index():
	return %Levels.get_first_level_path_index()


func get_current_level_index():
	return %Levels.get_current_level_path_index()


func get_requested_level_path_index():
	return %Levels.get_requested_level_path_index()


func request_setting_level_path_index(index):
	%Levels.request_setting_level_path_index(index)


func request_setting_previous_level_path_index():
	%Levels.request_setting_previous_level_path_index()


func request_setting_next_level_path_index():
	%Levels.request_setting_next_level_path_index()


func try_changing_to_requested_level():
	reset_play_time()
	return await %Levels.try_changing_to_requested_level()


func spawn_player():
	await %Levels.spawn_player()


func reset_to_checkpoint():
	await %Levels.reset_to_checkpoint()


func reset_level():
	await %Levels.reset_level()
	reset_play_time()


# State Machine

func _physics_process(delta):
	%LevelStateMachine.physics_process(delta)


func _process(delta):
	%LevelStateMachine.process(delta)


func _unhandled_input(event):
	%LevelStateMachine.unhandled_input(event)


func _input(event):
	%LevelStateMachine.input(event)


# Level State

func load_level_state_scene(level_state_scene):
	current_level_state_scene = level_state_scene
	add_child(current_level_state_scene)


func unload_level_state_scene(level_state_scene):
	var scene_to_be_removed
	for child in get_children():
		if child == level_state_scene:
			scene_to_be_removed = level_state_scene
	if scene_to_be_removed != null:
		remove_child(scene_to_be_removed)


func change_to_level_state(level_state):
	%LevelStateMachine.change_state(level_state)


# Game States

func set_state_node(node):
	state_node = node


func change_to_main_menu_game_state():
	state_node.change_to_main_menu_game_state()


func change_to_quit_game_state():
	state_node.change_to_quit_game_state()
