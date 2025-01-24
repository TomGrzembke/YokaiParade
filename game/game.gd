extends Node


var current_level_index = 0
var is_play_timer_running = false
var play_time = 0.0


func _ready() -> void:
	load_level(0)
	start_timer()


func _process(delta):
	if is_play_timer_running:
		set_play_time(play_time + delta)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("reset_level"):
		load_level(current_level_index)
		start_timer()

	if Input.is_action_just_pressed("reset_checkpoint"):
		load_level(current_level_index)

	if Input.is_action_just_pressed("load_next_level"):
		var desired_level_index = current_level_index + 1
		if desired_level_index >= %LevelManager.get_number_of_levels():
			print("Already at last level.")
		else:
			load_level(desired_level_index)
			start_timer()

	if Input.is_action_just_pressed("load_previous_level"):
		var desired_level_index = current_level_index - 1
		if desired_level_index < 0:
			print("Already at first level.")
		else:
			load_level(desired_level_index)
			start_timer()


func load_level(desired_level_index):
	var loaded_successfully = %LevelManager.load_level(desired_level_index)
	if loaded_successfully:
		current_level_index = desired_level_index


func set_play_time(new_time):
	play_time = new_time
	%PlayTimeLabel.text = "%5.2f" % play_time


func start_timer():
	set_play_time(0.0)
	is_play_timer_running = true


func stop_timer():
	is_play_timer_running = false


func spawn_player(player_position):
	if get_node_or_null("Player") != null:
		var old_player = $Player
		remove_child(old_player)
		old_player.queue_free()

	var player_scene = preload("res://player/player.tscn")

	var player = player_scene.instantiate()
	player.position = player_position
	player.player_despawned.connect(on_player_despawned)
	player.player_reached_goal.connect(on_player_reached_goal)
	player.player_reached_checkpoint.connect(on_player_reached_checkpoint)

	var camera_node = get_tree().root.get_node_or_null("Game/Camera2D")

	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = camera_node.get_path()
	player.add_child(remote_transform)

	add_child.call_deferred(player)


func on_player_despawned():
	load_level(current_level_index)


func on_player_reached_goal():
	stop_timer()


func on_player_reached_checkpoint(position):
	%LevelManager.set_player_spawn_position(position)


func on_level_manager_level_loaded(player_spawn_position):
	spawn_player(player_spawn_position)
