extends Node
# TODO: Rename this to LevelCoordinator

signal level_load_progress(progress)
signal level_load_completed(level_packed_scene)
signal player_ability_changed(color)
signal player_despawned
signal player_reached_goal
signal cleared_level()


@export var level_paths: Array[String]
@export var debug_level_path: String


var requested_level_path_index
var current_level_path_index
var currently_loading_level_path

var last_checkpoint_position


func _physics_process(_delta):
	if currently_loading_level_path == null:
		return

	match ResourceLoader.load_threaded_get_status(currently_loading_level_path):
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			var progress = []
			ResourceLoader.load_threaded_get_status(currently_loading_level_path, progress)
			if progress.size() > 0:
				level_load_progress.emit(progress.front())
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var level_packed_scene = ResourceLoader.load_threaded_get(currently_loading_level_path)
			level_load_completed.emit(level_packed_scene)

		_:
			printerr("Error: Loading %s failed." % currently_loading_level_path)
			level_load_completed.emit(null)


func get_level_path_count():
	return level_paths.size()


func get_first_level_path_index():
	var first_level_path_index = 1

	if OS.has_feature("debug"):
		first_level_path_index += 1

	return first_level_path_index


func get_current_level_path_index():
	return current_level_path_index


func get_requested_level_path_index():
	return requested_level_path_index


func request_setting_level_path_index(index):
	requested_level_path_index = clampi(index, 0, level_paths.size() - 1)


func request_setting_previous_level_path_index():
	if current_level_path_index == null:
		request_setting_level_path_index(0)
	else:
		request_setting_level_path_index(current_level_path_index - 1)


func request_setting_next_level_path_index():
	if current_level_path_index == null:
		request_setting_level_path_index(0)
	else:
		request_setting_level_path_index(current_level_path_index + 1)


func try_changing_to_requested_level():
	var succeeded = false

	if requested_level_path_index == null:
		printerr("Error: No requested_path_index set!")
		return succeeded

	if requested_level_path_index == current_level_path_index:
		printerr("Error: Level %s is already the current level!" % current_level_path_index)

	succeeded = await try_changing_to_level(requested_level_path_index)
	return succeeded


func try_changing_to_level(level_index):
	var succeeded = false

	if level_index >= 0 \
	and level_index < level_paths.size():
		var level_path = level_paths[level_index]
		succeeded = await try_loading_level(level_path)
	if succeeded:
		current_level_path_index = level_index

	return succeeded


func try_loading_level(level_path):
	var succeeded = false

	currently_loading_level_path = level_path

	ResourceLoader.load_threaded_request(currently_loading_level_path)
	var level_packed_scene = await level_load_completed

	currently_loading_level_path = null

	if level_packed_scene == null:
		return succeeded

	set_current_level(level_packed_scene)
	succeeded = true

	return succeeded


func clear_current_level():
	var current_level = get_current_level()
	cleared_level.emit()
	if current_level != null:
		%CurrentLevel.remove_child(current_level)


func set_current_level(level_packed_scene):
	clear_current_level()
	reset_last_checkpoint_position()

	var level_scene = level_packed_scene.instantiate()

	%CurrentLevel.add_child(level_scene)


func get_current_level():
	if current_level_path_index == null:
		return null

	var current_level

	for child in %CurrentLevel.get_children():
		if child.scene_file_path == level_paths[current_level_path_index]:
			current_level = child

	return current_level


func get_is_past_first_checkpoint():
	return last_checkpoint_position != null


func reset_last_checkpoint_position():
	last_checkpoint_position = null


func get_player_spawn_position():
	var player_spawn_position = last_checkpoint_position

	if player_spawn_position == null:
		player_spawn_position = get_current_level().get_player_spawn_position()

	if player_spawn_position == null:
		printerr("Error: Current level is missing a player spawn point!")

	return player_spawn_position


func spawn_player():
	var player = %CurrentLevel.get_node_or_null("Player")
	if player != null:
		%CurrentLevel.remove_child(player)

	if %CurrentLevel.get_node_or_null("Player") != null:
		printerr("Error: Player not cleared yet!")

	var player_scene = preload("res://player/player.tscn")
	player = player_scene.instantiate()
	player.position = get_player_spawn_position()

	player.player_ability_changed.connect(on_player_ability_changed)
	player.player_despawned.connect(on_player_despawned)
	player.player_reached_checkpoint.connect(on_player_reached_checkpoint)
	player.player_reached_goal.connect(on_player_reached_goal)
	cleared_level.connect(player.reload)

	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = %PlayerCamera.get_path()
	player.set_cam_remote(remote_transform)

	%CurrentLevel.add_child.call_deferred(player)
	await player.tree_entered


func reset_to_checkpoint():
	await spawn_player()


func reset_level():
	reset_last_checkpoint_position()
	await try_loading_level(level_paths[current_level_path_index])
	await spawn_player()


# Signal Handlers

func on_player_ability_changed(color):
	player_ability_changed.emit(color)


func on_player_despawned():
	player_despawned.emit()


func on_player_reached_checkpoint(position):
	last_checkpoint_position = position


func on_player_reached_goal():
	player_reached_goal.emit()


# Player Controls

func set_player_controls_active(active):
	var player = %CurrentLevel.get_node_or_null("Player")

	if player == null:
		return

	player.set_controls_active(active)


# Debug Level

func set_is_debug_level_active(active):
	if active:
		level_paths.insert(0, debug_level_path)
	else:
		var index = level_paths.find(debug_level_path)
		if index < 0:
			return
		level_paths.remove_at(index)
