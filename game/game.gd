extends Node


var _current_level_index = 0
var _is_play_timer_running = false
var _play_time = 0.0:
	set(new_value):
		_play_time = new_value
		%PlayTimeLabel.text = "%5.2f" % _play_time


func _ready() -> void:
	var desired_level_index = 0
	_load_level(desired_level_index)


func _process(delta):
	if _is_play_timer_running:
		_play_time += delta


func _unhandled_input(_event):
	if Input.is_action_just_pressed("reset_level"):
		_load_level(_current_level_index)


	if Input.is_action_just_pressed("load_next_level"):
		var desired_level_index = _current_level_index + 1
		if desired_level_index >= %LevelManager.number_of_levels:
			print("Already at last level.")
		else:
			_load_level(desired_level_index)

	if Input.is_action_just_pressed("load_previous_level"):
		var desired_level_index = _current_level_index - 1
		if desired_level_index < 0:
			print("Already at first level.")
		else:
			_load_level(desired_level_index)


func _load_level(desired_level_index):
	var loaded_successfully = %LevelManager.load_level(desired_level_index)
	if loaded_successfully:
		_current_level_index = desired_level_index
		_start_level()


func _start_level():
	_play_time = 0.0
	_is_play_timer_running = true


func _spawn_player(player_position):
	if get_node_or_null("Player") != null:
		var old_player = $Player
		remove_child(old_player)
		old_player.queue_free()

	var player_scene = preload("res://player/player.tscn")

	var player = player_scene.instantiate()
	player.position = player_position
	player.player_despawned.connect(_on_player_despawned)
	player.player_reached_goal.connect(_on_player_reached_goal)

	var camera_node = get_tree().root.get_node_or_null("Game/Camera2D")

	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = camera_node.get_path()
	player.add_child(remote_transform)

	add_child.call_deferred(player)


func _on_player_despawned():
	_load_level(_current_level_index)


func _on_player_reached_goal():
	_is_play_timer_running = false


func _on_level_manager_level_loaded(player_spawn_position):
	_spawn_player(player_spawn_position)
